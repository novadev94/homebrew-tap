class Cliproxyapiplus < Formula
  desc "Plus version of CLIProxyAPI"
  homepage "https://github.com/router-for-me/CLIProxyAPIPlus"
  url "https://github.com/novadev94/CLIProxyAPIPlus/archive/refs/tags/v6.6.108-0x.tar.gz"
  sha256 "c4fa6d1a2821176ee9e09660994360a4784502745c08824fad956f3c74ff8bbb"
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
