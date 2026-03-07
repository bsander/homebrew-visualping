class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0307/visualping-v0.2026.0307-macos.tar.gz"
  version "0.2026.0307"
  sha256 "ecd029a0685e2a9e339046c06d5cb053919dfdf394e6d8639bacd00c1206a97a"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
