#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  echo "Usage: $0" >&2
  exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
formula="$script_dir/../Formula/cardano-up.rb"
repo="blinklabs-io/cardano-up"
tmpdir=$(mktemp -d)
staging_dir=""
trap 'rm -rf -- "$tmpdir"; [[ -z "$staging_dir" ]] || rm -rf -- "$staging_dir"' EXIT

gh api "repos/$repo/releases/latest" > "$tmpdir/release.json"
tag=$(jq -er '.tag_name | if test("^v[0-9]+\\.[0-9]+\\.[0-9]+$") then . else error("Unsupported release tag") end' "$tmpdir/release.json")
version=${tag#v}
platforms=(darwin-arm64 darwin-amd64 linux-arm64 linux-amd64)

# Published digests let an unchanged formula skip binary downloads.
for platform in "${platforms[@]}"; do
  asset="cardano-up-$tag-$platform"
  digest=$(jq -er --arg name "$asset" '
    [.assets[] | select(.name == $name)] |
    if length == 1 then .[0].digest else error("Expected one release asset: " + $name) end |
    if type == "string" and test("^sha256:[0-9a-f]{64}$") then . else error("Missing or invalid SHA-256 digest: " + $name) end
  ' "$tmpdir/release.json")
  printf '%s %s\n' "$platform" "${digest#sha256:}" >> "$tmpdir/checksums"
done

# Validate every replacement before writing the formula.
awk -v version="$version" '
  FNR == NR { checksums[$1] = $2; next }
  /^  VERSION = "[^"]+"\.freeze$/ {
    sub(/"[^"]+"/, "\"" version "\"")
    versions++
  }
  {
    for (platform in checksums) {
      split(platform, parts, "-")
      pattern = "\\[\"" parts[1] "\",[[:space:]]*\"" parts[2] "\"\\][[:space:]]*=>[[:space:]]*\"[0-9a-f]+\""
      if ($0 ~ pattern) {
        sub(/"[0-9a-f]+"/, "\"" checksums[platform] "\"")
        replacements[platform]++
      }
    }
    print
  }
  END {
    if (versions != 1) {
      print "Expected one VERSION declaration in formula" > "/dev/stderr"
      exit 1
    }
    for (platform in checksums) {
      if (replacements[platform] != 1) {
        print "Expected one checksum entry for " platform > "/dev/stderr"
        exit 1
      }
    }
  }
' "$tmpdir/checksums" "$formula" > "$tmpdir/cardano-up.rb"

if cmp -s -- "$formula" "$tmpdir/cardano-up.rb"; then
  echo "cardano-up is already at $version with matching checksums"
  exit 0
fi

download_args=()
for platform in "${platforms[@]}"; do
  download_args+=(--pattern "cardano-up-$tag-$platform")
done
gh release download "$tag" --repo "$repo" --dir "$tmpdir" "${download_args[@]}"
while read -r platform expected_checksum; do
  asset="cardano-up-$tag-$platform"
  checksum=$(shasum -a 256 -- "$tmpdir/$asset")
  if [[ "${checksum%% *}" != "$expected_checksum" ]]; then
    echo "Checksum mismatch: $asset" >&2
    exit 1
  fi
done < "$tmpdir/checksums"

# Rename on the same filesystem so an interrupted write cannot truncate the formula.
staging_dir=$(mktemp -d "$script_dir/../Formula/.cardano-up-bump.XXXXXX")
cp -p -- "$formula" "$staging_dir/cardano-up.rb"
cat "$tmpdir/cardano-up.rb" > "$staging_dir/cardano-up.rb"
mv -f -- "$staging_dir/cardano-up.rb" "$formula"
echo "Bumped cardano-up to $version"
