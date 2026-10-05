class CardanoUp < Formula
  desc "Command-line utility for managing Cardano services"
  homepage "https://github.com/blinklabs-io/cardano-up"
  # Normalize OS/arch to match upstream filenames
  OSN = if OS.mac?
    "darwin"
  elsif OS.linux?
    "linux"
  else
    raise "Unsupported OS for cardano-up"
  end.freeze

  VERSION = "0.17.0".freeze

  ARCH = if Hardware::CPU.arm?
    "arm64"
  else
    "amd64"
  end.freeze

  # Per-platform checksums
  SHA_TABLE = {
    ["darwin", "arm64"] => "18e71c538ecbe16b07c8f261dbab16c3f254c87d7de922d3163d489df42a1838",
    ["darwin", "amd64"] => "eaedc1357f3872b65cfb4a5b8cd37f9e272be8be9b8354c7a8445458a14657d7",
    ["linux",  "arm64"] => "bcf467854cbbf73ab688007e0b2ee8e5b9094af45c4d4c7bb9e2005b6cd0b3b9",
    ["linux",  "amd64"] => "83be0ae4741008e9f29b01b35321a11632b693217f266f5b264c0a330c3eb634",
  }.freeze

  url "https://github.com/blinklabs-io/cardano-up/releases/download/v#{VERSION}/cardano-up-v#{VERSION}-#{OSN}-#{ARCH}"
  sha256 SHA_TABLE.fetch([OSN, ARCH])
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    bin.install "cardano-up-v#{version}-#{OSN}-#{ARCH}" => "cardano-up"
    chmod 0755, bin/"cardano-up"
    generate_completions_from_executable(bin/"cardano-up", "completion")
  end

  test do
    assert_match(/^cardano-up v#{version}/, shell_output("#{bin}/cardano-up version"))
  end
end
