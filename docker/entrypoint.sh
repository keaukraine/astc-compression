#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: docker compose run --rm tools <command>

Commands:
  astc [quality]  Compress PNG files from auto-compression/source into
                  auto-compression/astc. quality is the SSIMULACRA2
                  threshold (0-100, default 70).
  mipmaps         Generate mipmaps from mipmaps-generation/src into
                  mipmaps-generation/mipmaps.
  bash            Open an interactive shell in the container.
  help            Show this help.
EOF
}

command="${1:-help}"
if [ "$#" -gt 0 ]; then
    shift
fi

prepare_astc_dirs() {
    mkdir -p \
        /work/auto-compression/source \
        /work/auto-compression/decoded \
        /work/auto-compression/astc/{12x12,12x10,10x10,10x8,8x8,10x6,10x5,8x6,8x5,6x6,6x5,5x5,5x4,4x4}
}

case "$command" in
    astc)
        prepare_astc_dirs
        cd /work/auto-compression
        exec bash ./astc.sh "$@"
        ;;
    mipmaps)
        cd /work/mipmaps-generation
        exec bash ./convert-all.sh "$@"
        ;;
    bash|sh)
        exec "$command" "$@"
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        echo "Unknown command: $command" >&2
        echo >&2
        usage >&2
        exit 1
        ;;
esac
