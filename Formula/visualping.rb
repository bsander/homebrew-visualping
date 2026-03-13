class Visualping < Formula
  desc "macOS CLI tool that displays Lottie animations as transparent desktop overlays"
  homepage "https://github.com/bsander/homebrew-visualping"
  url "https://github.com/bsander/homebrew-visualping/releases/download/v0.2026.0313.2/visualping-v0.2026.0313.2-macos.tar.gz"
  version "0.2026.0313.2"
  sha256 "fc0186eb375aba83b1edb00c3b4acf89ec2b95065b1108f4437431a028c6666b"
  license "MIT"

  depends_on :macos

  def install
    bin.install "visualping"
  end

  test do
    assert_match "OVERVIEW:", shell_output("#{bin}/visualping --help")
  end
end
