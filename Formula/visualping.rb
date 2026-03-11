class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0311.2/visualping-v0.2026.0311.2-macos.tar.gz"
  version "0.2026.0311.2"
  sha256 "3ce07ffdd1e59a03c2c56faa1a2b76e689aefc19306538f74499c7cf277142cd"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
