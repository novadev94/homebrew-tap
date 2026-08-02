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

  VERSION = "0.16.0".freeze

  ARCH = if Hardware::CPU.arm?
    "arm64"
  else
    "amd64"
  end.freeze

  # Per-platform checksums
  SHA_TABLE = {
    ["darwin", "arm64"] => "3d5bbc4713f3a5206daba535635ab72d3cbba8c81697131afbd27429199fe674",
    ["darwin", "amd64"] => "450091d7b8f775284ddf77b40b7bf2c986a34fcb2730cc8cc17353ba63bfe63c",
    ["linux",  "arm64"] => "62adc9770f182f9c42d0f0a77334797d407e2812ffb8bb21bfae64ca9cc9b3dd",
    ["linux",  "amd64"] => "fb5072c5ae9434a9c6a7c1f6e7c6124f698c63a2d768b18ce6831df94bab5e66",
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
