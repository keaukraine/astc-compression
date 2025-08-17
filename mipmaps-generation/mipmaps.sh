#!/bin/bash

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
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
while [ "$width" -gt 0 ] || [ "$height" -gt 0 ]; do
    output_file="$output_dir/${base_name}_${level}.png"
    magick "$input_image" -resize "${width}x${height}" "$output_file"
    echo "Generated: $output_file"

    # Halve the dimensions
    width=$((width / 2))
    height=$((height / 2))
    level=$((level + 1))
done

echo "Mipmap generation complete. Saved in '$output_dir'."
