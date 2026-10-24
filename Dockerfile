# The constant platform is intentional: see README_DOCKER.md.
# check=skip=FromPlatformFlagConstDisallowed
# The bundled astcenc and ssimulacra2 binaries are Linux x86-64,
# so the image is amd64 even when building on Apple Silicon.
FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/tmp

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bc \
        imagemagick \
        libhwy1 \
        liblcms2-2 \
        libpng16-16 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# Scripts and prebuilt tools. Windows checkouts may contain CRLF line endings,
# so they are normalized below.
COPY auto-compression/astcenc-avx2 \
     auto-compression/ssimulacra2 \
     auto-compression/astc.sh \
     /work/auto-compression/

COPY mipmaps-generation/convert-all.sh \
     mipmaps-generation/mipmaps.sh \
     /work/mipmaps-generation/

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN sed -i 's/\r$//' \
        /work/auto-compression/astc.sh \
        /work/mipmaps-generation/convert-all.sh \
        /work/mipmaps-generation/mipmaps.sh \
        /usr/local/bin/entrypoint.sh \
    && chmod +x \
        /work/auto-compression/astcenc-avx2 \
        /work/auto-compression/ssimulacra2 \
        /work/auto-compression/astc.sh \
        /work/mipmaps-generation/convert-all.sh \
        /work/mipmaps-generation/mipmaps.sh \
        /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["help"]
