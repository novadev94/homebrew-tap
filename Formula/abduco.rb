class Abduco < Formula
  desc "abduco provides session management i.e. it allows programs to be run independently from its controlling terminal. That is programs can be detached - run in the background - and then later reattached."
  homepage "https://github.com/martanne/abduco"
  head "https://github.com/novadev94/abduco.git", branch: "master"
  url "https://github.com/novadev94/abduco/archive/refs/tags/v0.6.1-rc.tar.gz"
  version "0.6.1-rc"
  sha256 "bf868495495bac44834e9e3fd1359b30b4b5a3c779bef2162e0bc8c1d7f70688"
  license "ISC"

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
