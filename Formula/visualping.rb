class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0313.1/visualping-v0.2026.0313.1-macos.tar.gz"
  version "0.2026.0313.1"
  sha256 "ce0818449815468b423e3a6e609d143926cf8a0a5b52febf51a2d30cf7b704c4"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
