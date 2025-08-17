find ./astc -name '*.astc' -type f -delete
rm -rf temp/*.png

# SSIMULACRA2 score threshold
threshold="${1:-80}"

# ASTC blocks from lowest to highest bitrate
blocks=("12x12" "12x10" "10x10" "10x8" "8x8" "10x6" "10x5" "8x6" "8x5" "6x6" "6x5" "5x5" "5x4" "4x4")

is_good_quality() {
    filename=$1
    block=$2

    ./astcenc-avx2 -tl "$file" temp/"$filename"_"$block".png "$block" -verythorough > /dev/null

    score=$(./ssimulacra2 "source/$filename.png" temp/"$filename"_"$block".png 2>/dev/null) # floating-point output

    if [ "$(echo "$score > $threshold" | bc -l)" -eq 1 ]; then
        echo "$filename using $block block, score is $score"
        return 0 # true
    else
        return 1 # false
    fi
}

compress_image() {
    file=$1
    block=$2
    filename=$(basename "$file" .png)
    ./astcenc-avx2 -cl "$file" astc/"$block"/"$filename".astc "$block" -exhaustive > /dev/null
}

for file in source/*.png; do
    filename=$(basename "$file" .png)

    for blockSize in "${blocks[@]}"; do
        if is_good_quality "$filename" "$blockSize"; then
            compress_image $file $blockSize
            break
        fi
    done
done

rm -rf temp/*.png
