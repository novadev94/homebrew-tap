class Cliproxyapiplus < Formula
  desc "Plus version of CLIProxyAPI"
  homepage "https://github.com/router-for-me/CLIProxyAPIPlus"
  url "https://github.com/router-for-me/CLIProxyAPIPlus/archive/refs/tags/v6.8.1-1.tar.gz"
  sha256 "e91906872952d40a6e0476a52ff188914c14290da2671fd851c574b2549ba66c"
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
