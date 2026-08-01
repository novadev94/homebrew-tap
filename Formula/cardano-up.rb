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

  VERSION = "0.15.0".freeze

  ARCH = if Hardware::CPU.arm?
    "arm64"
  else
    "amd64"
  end.freeze

  # Per-platform checksums
  SHA_TABLE = {
    ["darwin", "arm64"] => "97339101c7c2fb49f9fe5c0750674597b417427325285606c15ad8699fc6916a",
    ["darwin", "amd64"] => "16661a7edf15e5b618e5ceb46ca0ddeb0eb3fe3c5c5486b4a9b846d86cb95ecd",
    ["linux",  "arm64"] => "f39f3fb719698f69395a537b521abccf7c280991d25401a86d4f40dbfa2975b9",
    ["linux",  "amd64"] => "5efb8751b52a3eb02a4c767de562ad00e92e58fce3e69e9f50fcc34f7eaa75b0",
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
