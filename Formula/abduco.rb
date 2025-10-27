class Abduco < Formula
  desc "Provides session management: i.e. separate programs from terminals"
  homepage "https://www.brain-dump.org/projects/abduco/"
  url "https://github.com/novadev94/abduco/archive/refs/tags/v0.6.1-rc.tar.gz"
  sha256 "bf868495495bac44834e9e3fd1359b30b4b5a3c779bef2162e0bc8c1d7f70688"
  license "ISC"
  head "https://github.com/novadev94/abduco.git", branch: "master"

  no_autobump! because: :requires_manual_review

  def install
    ENV.append_to_cflags "-D_DARWIN_C_SOURCE"
    system "make", "PREFIX=#{prefix}", "MANPREFIX=#{man}", "install"
  end

  test do
    result = shell_output("#{bin}/abduco -v")
    result.force_encoding("UTF-8") if result.respond_to?(:force_encoding)
    assert_match(/^abduco-#{version}/, result)
  end
end
