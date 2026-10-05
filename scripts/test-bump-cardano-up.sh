#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/scripts" "$fixture/Formula" "$fixture/bin"
cp "$script_dir/bump-cardano-up.sh" "$fixture/scripts/"

checksum=$(printf '%064d' 0)
cat > "$fixture/Formula/cardano-up.rb" <<EOF
class CardanoUp < Formula
  VERSION = "1.2.3".freeze
  SHA_TABLE = {
    ["darwin", "arm64"] => "$checksum",
    ["darwin", "amd64"] => "$checksum",
    ["linux",  "arm64"] => "$checksum",
    ["linux",  "amd64"] => "$checksum",
  }.freeze
end
EOF
cp -p "$fixture/Formula/cardano-up.rb" "$fixture/before.rb"

# Any request beyond release metadata makes this regression test fail.
cat > "$fixture/bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$*" != "api repos/blinklabs-io/cardano-up/releases/latest" ]]; then
  echo "Unexpected gh invocation: $*" >&2
  exit 1
fi
jq -n --arg digest "sha256:$(printf '%064d' 0)" '{
  tag_name: "v1.2.3",
  assets: (["darwin-arm64", "darwin-amd64", "linux-arm64", "linux-amd64"] |
    map({name: ("cardano-up-v1.2.3-" + .), digest: $digest}))
}'
EOF
chmod +x "$fixture/bin/gh"

PATH="$fixture/bin:$PATH" bash "$fixture/scripts/bump-cardano-up.sh"
cmp -s "$fixture/before.rb" "$fixture/Formula/cardano-up.rb"
if [[ "$fixture/Formula/cardano-up.rb" -nt "$fixture/before.rb" ]]; then
  echo "Matching formula was unnecessarily rewritten" >&2
  exit 1
fi
echo "PASS: matching latest release skips downloads and formula writes"
