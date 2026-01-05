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

  VERSION = "0.14.2".freeze

  ARCH = if Hardware::CPU.arm?
    "arm64"
  else
    "amd64"
  end.freeze

  # Per-platform checksums
  SHA_TABLE = {
    ["darwin", "arm64"] => "aafb5d4c43124d1760b6a0709c63fe4e5566d390b0f0990b89ca1682680158d0",
    ["darwin", "amd64"] => "9ceec837f312846502985713a15ab98141b51eaa0eb6e14a51fc7fc48ef15f3a",
    ["linux",  "arm64"] => "8e53954e35eb1d22f75ae28d695f5becb50d00abacc888b2698979d240752aca",
    ["linux",  "amd64"] => "32d41bfb7c3c0ef9f0963ef8aeccbf5ba91e2c86f6d8a2c56ec3e31901df658a",
  }.freeze

  url "https://github.com/blinklabs-io/cardano-up/releases/download/v#{VERSION}/cardano-up-v#{VERSION}-#{OSN}-#{ARCH}"
  version VERSION
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
