# Automated ASTC compression

This repo has two tools:
1. Simple bash script picks the best possible ASTC compression based on SSIMULACRA2 quality score.
2. Automated mipmaps generation from PNG files using ImageMagick.

# Used libraries

- astc-encoder, official ARM ASTC compression tool https://github.com/ARM-software/astc-encoder
- SSIMULACRA2, perceptual compression quality comparison tool https://github.com/cloudinary/ssimulacra2
- ImageMagick, versatile command-line image processing tool https://github.com/ImageMagick/ImageMagick

# Usage

These tools are meant to be run in Linux (some amd64 binaries are included). Theoretically it is very easy to rebuild tools for any other OS, and bash scripts should be POSIX-compatible.
I have tested it on WSL with Ubuntu.

## ASTC compression

1. Put your source PNG files in the `auto-compression/source` directory.
2. Run `./astc.sh <quality>`

Quality parameter is SSIMULACRA2 quality score in range from 0 to 100, please refer to README for explanation of this score.

If omitted, default 70 quality will be used which stands for "high quality", similar to typical JPEGs used in web.

Please note that script detects mipmapped images by file name pattern `name_mip.png`. So `img_0.png`, `img_1.png` and `img_2.png` will be treated as mipmaps of the same image and will use the same compression as for the mipmap 0.

## Mipmap generation

Put source PNG files in `mipmaps-generation/src` and run `convert-all.sh` script.

# License

**The MIT License**

Copyright (c) 2025 Oleksandr Popov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
