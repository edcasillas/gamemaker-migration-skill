#!/usr/bin/env bash
set -euo pipefail

PACKAGE_URL="${PACKAGE_URL:-https://deb.debian.org/debian/pool/main/f/fluidr3mono-gm-soundfont/fluidr3mono-gm-soundfont_2.315-7_all.deb}"
PACKAGE_SHA256="${PACKAGE_SHA256:-4098301bf29f4253c2f5799a844f42dd4aa733d91a210071ad16d7757dea51d6}"
SOUNDFONT_SHA256="${SOUNDFONT_SHA256:-cda013d8c370a48ae8dad271e761078d2e77455488dabdedbfbe5fc76a38c682}"
SOUNDFONT_NAME="FluidR3Mono_GM.sf3"
DEFAULT_OUTPUT_DIR="tools/soundfonts"

usage() {
  cat <<EOF
Usage: $0 [--output-dir PATH]

Fetches FluidR3Mono_GM.sf3 from the Debian fluidr3mono-gm-soundfont package
or copies it from a system install when available.
EOF
}

output_dir="$DEFAULT_OUTPUT_DIR"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-dir)
      output_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "Missing sha256sum or shasum." >&2
    exit 1
  fi
}

download_file() {
  url="$1"
  dest="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --output "$dest" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$dest" "$url"
  else
    echo "Missing curl or wget." >&2
    exit 1
  fi
}

verify_sha256() {
  file="$1"
  expected="$2"
  actual="$(sha256_file "$file")"
  if [ "$actual" != "$expected" ]; then
    echo "Checksum mismatch for $file" >&2
    echo "Expected: $expected" >&2
    echo "Actual:   $actual" >&2
    exit 1
  fi
}

mkdir -p "$output_dir"
target="$output_dir/$SOUNDFONT_NAME"

for system_path in \
  "/usr/share/sounds/sf3/$SOUNDFONT_NAME" \
  "/usr/local/share/sounds/sf3/$SOUNDFONT_NAME"; do
  if [ -f "$system_path" ]; then
    cp "$system_path" "$target"
    verify_sha256 "$target" "$SOUNDFONT_SHA256"
    echo "Copied verified SoundFont from: $system_path"
    echo "$target"
    exit 0
  fi
done

if ! command -v ar >/dev/null 2>&1; then
  echo "Missing ar, needed to extract the Debian package." >&2
  exit 1
fi

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

deb_path="$temp_dir/fluidr3mono-gm-soundfont.deb"
download_file "$PACKAGE_URL" "$deb_path"
verify_sha256 "$deb_path" "$PACKAGE_SHA256"

(
  cd "$temp_dir"
  ar x "$deb_path"
)

data_archive="$(find "$temp_dir" -maxdepth 1 -name 'data.tar.*' -print -quit)"
if [ -z "$data_archive" ]; then
  echo "Could not find data.tar.* inside Debian package." >&2
  exit 1
fi

tar -xf "$data_archive" -C "$temp_dir" "./usr/share/sounds/sf3/$SOUNDFONT_NAME"
cp "$temp_dir/usr/share/sounds/sf3/$SOUNDFONT_NAME" "$target"
verify_sha256 "$target" "$SOUNDFONT_SHA256"

echo "Downloaded and verified SoundFont from Debian package."
echo "$target"
