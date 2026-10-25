#!/bin/bash

# Check if ImageMagick is installed. ImageMagick 7 provides "magick",
# ImageMagick 6 (Ubuntu/Debian packages) provides "convert".
if command -v magick &> /dev/null; then
    magick_cmd="magick"
elif command -v convert &> /dev/null; then
    magick_cmd="convert"
else
    echo "Error: ImageMagick is not installed. Install it with 'sudo apt install imagemagick' or equivalent."
    exit 1
fi

# Check for input arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_image>"
    exit 1
fi

input_image="src/$1"
input_image_raw="$1"
base_name="${input_image_raw%.*}"
output_dir="mipmaps"

# Create output directory
mkdir -p "$output_dir"

# Get original image dimensions
width=$(identify -format "%w" "$input_image")
height=$(identify -format "%h" "$input_image")

# echo $width
# echo $height

level=0
while :; do
    output_file="$output_dir/${base_name}_${level}.png"
    # "!" forces exact dimensions: once one side reaches 1, the aspect
    # ratio no longer matches the original image.
    # color-type=2 and depth 8 force 24-bit RGB PNGs instead of letting
    # ImageMagick pick the smallest depth (e.g. grayscale or palette).
    "$magick_cmd" "$input_image" -resize "${width}x${height}!" \
        -define png:color-type=2 -depth 8 "$output_file"
    echo "Generated: $output_file"

    if [ "$width" -eq 1 ] && [ "$height" -eq 1 ]; then
        break
    fi

    # Halve the dimensions, clamping each side to 1
    width=$((width / 2))
    height=$((height / 2))
    [ "$width" -lt 1 ] && width=1
    [ "$height" -lt 1 ] && height=1
    level=$((level + 1))
done

echo "Mipmap generation complete. Saved in '$output_dir'."
