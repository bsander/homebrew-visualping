class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0306/visualping-v0.2026.0306.tar.gz"
  version "0.2026.0306"
  sha256 "768a1556b3e1d6a9261eb047e4ba087ca61e64c73c0939c63ded24cfde7e821a"
  license "MIT"

  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
