class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0311.1/visualping-v0.2026.0311.1-macos.tar.gz"
  version "0.2026.0311.1"
  sha256 "c2414af8ceed3a9ebdcac43efb37ff5c4e6a617bb3a18b5b64c33d35b4c47375"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
