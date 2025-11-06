class Shdotenv < Formula
  desc "dotenv for shells with support for POSIX-compliant and multiple .env file syntax"
  homepage "https://github.com/ko1nksm/shdotenv"
  url "https://github.com/ko1nksm/shdotenv/releases/download/v0.14.0/shdotenv"
  version "0.14.0"
  sha256 "efa1c0aa7d59331c0823e8a3a56066db6088094052b00dae63694e046985d29e"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    bin.install "shdotenv"
  end

  test do
    assert_match(/^#{version}/, shell_output("#{bin}/shdotenv --version"))
  end
end
