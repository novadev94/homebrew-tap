class Cliproxyapiplus < Formula
  desc "Plus version of CLIProxyAPI"
  homepage "https://github.com/router-for-me/CLIProxyAPIPlus"
  url "https://github.com/router-for-me/CLIProxyAPIPlus/archive/refs/tags/v6.7.6-1.tar.gz"
  sha256 "a345c47e74030d95032a09de120fb2e6be68d7a0bb94f0095e7d52b312eee7fb"
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
    log_path var/"log/cliproxyapi.log"
    error_log_path var/"log/cliproxyapi.log"
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
