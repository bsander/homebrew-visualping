class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0313/visualping-v0.2026.0313-macos.tar.gz"
  version "0.2026.0313"
  sha256 "de04ceaaba6859d44469561fe25261037397c2359743eb80b0c1a722b471617b"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
