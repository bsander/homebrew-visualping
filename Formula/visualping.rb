class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0306.3/visualping-v0.2026.0306.3.tar.gz"
  version "0.2026.0306.3"
  sha256 "ddb915ea120f908bc6b903259cd026ea472a5c9df5c6d16a4cbfcafdfd5d0b87"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
