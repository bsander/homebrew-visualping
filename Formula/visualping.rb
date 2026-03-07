class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0307.1/visualping-v0.2026.0307.1-macos.tar.gz"
  version "0.2026.0307.1"
  sha256 "296b56f5a978b3b538f61d75dd2d80ea597b88c85d05fdf26801715923eca140"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
