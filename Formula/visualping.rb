class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0311/visualping-v0.2026.0311-macos.tar.gz"
  version "0.2026.0311"
  sha256 "79d6ca06ae400b357b41d48876e805c91ad064e2e655c2ec634307a6cd0beb81"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
