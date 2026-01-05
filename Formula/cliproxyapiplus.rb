class Cliproxyapiplus < Formula
  desc "Plus version of CLIProxyAPI"
  homepage "https://github.com/router-for-me/CLIProxyAPIPlus"
  url "https://github.com/router-for-me/CLIProxyAPIPlus/archive/refs/tags/v6.6.84-0.tar.gz"
  sha256 "17e7f2f7ae7640bc2a5a0600a6cd7cad85b3fdffdfde0f2ff0635cb39418bd08"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)*(?:-[a-zA-Z0-9]+)?)$/i)
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
      -X main.Commit=#{tap.user}
      -X main.BuildDate=#{time.iso8601}
      -X main.DefaultConfigPath=#{etc/"cliproxyapi.conf"}
    ]

    system "go", "build", *std_go_args(ldflags:), "cmd/server/main.go"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
  end

  service do
    run [opt_bin/"cliproxyapiplus"]
    keep_alive true
  end

  test do
    require "pty"
    PTY.spawn(bin/"cliproxyapiplus", "-login", "-no-browser") do |r, _w, pid|
      sleep 5
      Process.kill "TERM", pid
      assert_match "accounts.google.com", r.read_nonblock(1024)
    end
  end
end
