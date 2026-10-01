#!/usr/bin/env bash
#
# install.sh - symlink the scripts in bin/ into a directory on your PATH.
# Usage: ./install.sh [target_dir]   (default: ~/.local/bin)
#
set -euo pipefail

target_dir="${1:-${HOME}/.local/bin}"
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/bin" && pwd)"

mkdir -p "${target_dir}"

for script in "${source_dir}"/*; do
  name="$(basename "${script}")"
  ln -sf "${script}" "${target_dir}/${name}"
  echo "linked ${name} -> ${target_dir}/${name}"
done

echo
echo "Done. Ensure ${target_dir} is on your PATH, e.g. add to your shell rc:"
echo "  export PATH=\"${target_dir}:\$PATH\""
