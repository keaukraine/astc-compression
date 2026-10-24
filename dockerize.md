# Goal

Dockerize scripts.

# Requirements

Currently I run `auto-compression` script only from WSL2 Ubuntu because binaries are Linux-only.
`mipmaps-generation` is cross-platform - can be run in Win11 git bash but I'd like it not to depend on installed ImageMagick.

1. Run scripts in Docker so they will be platform-agnostic - will work on Mac too.
2. Image should have ImageMagick preinstalled.
3. I should be able to "feed" dockerized source PNG files on local file system and the results will also appear on the local filesystem - without need to copy anything in/out of container.
4. Please create a README_DOCKER.md explaining all commands and how to use scripts.

