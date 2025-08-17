for img in src/*.png; do
    [ -e "$img" ] || continue
    filename="${img##*/}"  # Strip path, leave only filename

    echo "Processing: $filename"
    ./mipmaps.sh $filename
    # Do something with "$img" here
done
