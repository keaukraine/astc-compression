find ./astc -name '*.astc' -type f -delete
rm -rf decoded/*.png

# SSIMULACRA2 score threshold
threshold="${1:-70}"

# ASTC blocks from lowest to highest bitrate
blocks=("12x12" "12x10" "10x10" "10x8" "8x8" "10x6" "10x5" "8x6" "8x5" "6x6" "6x5" "5x5" "5x4" "4x4")

is_good_quality() {
    filename=$1
    block=$2

    printf "\rMeasuring quality: %s %s   " "$filename" "$block" 1>&2

    ./astcenc-avx2 -tl "$file" decoded/"$filename".png "$block" -verythorough > /dev/null

    score=$(./ssimulacra2 "source/$filename.png" decoded/"$filename".png 2>/dev/null) # floating-point output

    printf "\r" 1>&2

    if echo "$score" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        if [ "$(echo "$score > $threshold" | bc -l)" -eq 1 ]; then
            printf "%-30s uses %-5s block, score is %-5s\n" "$filename" "$block" "$score"
            return 0 # true
        else
            return 1 # false
        fi
    else
        if [ "$block" = "4x4" ]; then
            printf "%-30s cannot be tested (probably too small), using %s\n" "$filename" "$block"
            return 0 # true
        else
            return 1 # false
        fi
    fi
}

compress_image() {
    file=$1
    block=$2
    filename=$(basename "$file" .png)

    printf "\rCompressing %s            " "$filename" 1>&2
    ./astcenc-avx2 -cl "$file" astc/"$block"/"$filename".astc "$block" -exhaustive > /dev/null
    printf "\r" 1>&2
}

for file in source/*.png; do
    filename=$(basename "$file" .png)

    # Test if image has mipmaps by its filename. Format is "image_mip.png".
    if expr "$filename" : '.*_[0-9][0-9]*$' >/dev/null; then
        # Test quality only for mipmap=0 and process all other mipmaps with the same compression
        if expr "$filename" : '.*_0$' >/dev/null; then
            for blockSize in "${blocks[@]}"; do
                if is_good_quality "$filename" "$blockSize"; then
                    no_mipmap_level_name=$(echo "$filename" | sed 's/_0$//')

                    for file_mip in source/"$no_mipmap_level_name"_[0-9]*.png; do
                        compress_image $file_mip $blockSize
                    done

                    break
                fi
            done
        fi
    else
        # File has no mipmaps, process it as-is
        for blockSize in "${blocks[@]}"; do
            if is_good_quality "$filename" "$blockSize"; then
                compress_image $file $blockSize
                break
            fi
        done
    fi
done

rm -rf decoded/*.png
