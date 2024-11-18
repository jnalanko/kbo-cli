#!/bin/bash
## Build script for cross-compiling kbo for aarch64-apple-darwin.
## Run this inside https://github.com/shepherdjerred/macos-cross-compiler

set -exo pipefail

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

rustup default stable

mkdir /io/tmp
cd /io/tmp

# Extract and enter source
git clone https://github.com/tmaklin/kbo-cli.git
cd kbo-cli
git checkout ${VER}

mkdir -p .cargo
# Rust toolchain
rustup target add x86_64-apple-darwin

echo "[build]" >> .cargo/config.toml
echo "target = \"x86_64-apple-darwin\"" >> .cargo/config.toml
echo "[target.x86_64-apple-darwin]" >> .cargo/config.toml
echo "linker = \"x86_64-apple-darwin22-gcc\"" >> .cargo/config.toml

export CC="x86_64-apple-darwin22-gcc"
export CXX="x86_64-apple-darwin22-g++"

RUSTFLAGS='-L /osxcross/SDK/MacOSX13.0.sdk/usr/lib' cargo build --all-features --release --target x86_64-apple-darwin

## gather the stuff to distribute
target=kbo-candidate-x86_64-apple-darwin
path=/io/tmp/$target
mkdir $path
cp target/x86_64-apple-darwin/release/kbo $path/
cp README.md $path/
cp COPYRIGHT $path/
cp LICENSE-APACHE $path/
cp LICENSE-MIT $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
sha256sum $target.tar.gz > $target".tar.gz.sha256sum"
mv $target.tar.gz /io/
mv $target".tar.gz.sha256sum" /io/
cd /io/
