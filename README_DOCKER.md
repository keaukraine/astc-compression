# Running in Docker

Both tools can run in Docker on Windows, macOS and Linux. The image includes
the bundled `astcenc` and `ssimulacra2` binaries, ImageMagick and `bc`.

## Requirements

- Docker Desktop (Windows, macOS) or Docker Engine with the Compose plugin (Linux).
- About 250 MB of disk for the image.

## Build the image

```bash
docker compose build
```

Run this once before the first use, and again after changing the `Dockerfile`,
`docker/entrypoint.sh` or the shell scripts.

## Compress PNG files to ASTC

1. Put source PNG files into `auto-compression/source/`.
2. Run:

```bash
docker compose run --rm tools astc 70
```

The optional argument is the SSIMULACRA2 quality threshold (0-100). Default is
70. The script prints the chosen block size and the measured score for each
image.

Results:

- `auto-compression/astc/<block>/<name>.astc` - compressed textures.
- `auto-compression/decoded/` - scratch decoded PNGs, emptied after the run.

Mipmapped images are detected by the `name_0.png`, `name_1.png`, ... file name
pattern, same as when running the script directly.

## Generate mipmaps

1. Put source PNG files into `mipmaps-generation/src/`.
2. Run:

```bash
docker compose run --rm tools mipmaps
```

Results:

- `mipmaps-generation/mipmaps/<name>_<level>.png`

## File access

Input and output directories are bind-mounted into the container, so no
`docker cp` is needed. Files written by the container appear on the host
immediately.

| Host path | Container path | Used for |
| --- | --- | --- |
| `auto-compression/source/` | `/work/auto-compression/source/` | ASTC input |
| `auto-compression/astc/` | `/work/auto-compression/astc/` | ASTC output |
| `auto-compression/decoded/` | `/work/auto-compression/decoded/` | ASTC scratch files |
| `mipmaps-generation/src/` | `/work/mipmaps-generation/src/` | Mipmap input |
| `mipmaps-generation/mipmaps/` | `/work/mipmaps-generation/mipmaps/` | Mipmap output |

## Command reference

| Command | Description |
| --- | --- |
| `docker compose build` | Build or rebuild the image |
| `docker compose run --rm tools astc [quality]` | Compress PNGs to ASTC |
| `docker compose run --rm tools mipmaps` | Generate mipmaps |
| `docker compose run --rm tools bash` | Open a shell in the container |
| `docker compose run --rm tools help` | Show container help |
| `docker compose down --rmi local` | Remove the container and the image |

## Platform notes

### Apple Silicon (M-series Macs)

The bundled binaries are Linux x86-64, so the image is built for
`linux/amd64` and Docker Desktop runs it under emulation. It works, but
compression is slower than on a native x86-64 machine.

If `astcenc` exits with `Illegal instruction`, Docker Desktop is using Rosetta
emulation, which does not cover all AVX2 instructions. Disable **Use Rosetta
for x86_64/amd64 emulation** in Docker Desktop settings (Settings > General)
and run the command again; the QEMU fallback supports AVX2.

### Linux file ownership

On Linux, container processes run as `root` by default, so output files would
be owned by `root`. Export your user and group IDs before running Compose:

```bash
export DOCKER_UID=$(id -u)
export DOCKER_GID=$(id -g)
```

Docker Desktop on Windows and macOS does the ownership mapping automatically,
so nothing is needed there.

### Windows

Run the commands from PowerShell or Git Bash. No path setup is required;
Compose resolves the relative paths.

### CPU requirement

`astcenc-avx2` needs an x86-64 CPU with AVX2 (Intel Haswell 2013 or newer,
AMD Excavator 2015 or newer). Apple Silicon uses emulation as described above.

## Troubleshooting

- **`permission denied` when writing outputs on Linux** - set `DOCKER_UID`
  and `DOCKER_GID` as shown above.
- **`exec format error`** - run through `docker compose run`, which sets the
  `linux/amd64` platform, or pass `--platform linux/amd64` to `docker run`.
- **Script changes have no effect** - rebuild with `docker compose build`.
- **`magick: command not found` inside a custom image** - the Ubuntu package
  provides ImageMagick 6 (`convert`); `mipmaps.sh` detects either command.
