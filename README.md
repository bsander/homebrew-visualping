# visualping

A macOS CLI tool that displays Lottie animations as transparent, click-through desktop overlays. Play an animation once and exit — perfect for non-intrusive visual notifications.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)

## Features

- Renders `.json` (Lottie) and `.lottie` (dotLottie) animations
- Loads from local files or URLs
- Transparent, click-through overlay — doesn't interfere with your workflow
- 7 screen positions: center, top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
- Configurable animation size
- No dock icon or menu bar entry
- Visible on all spaces/desktops
- Exits automatically when the animation completes

## Installation

```bash
git clone <repo-url>
cd visual-notifications
swift build -c release
```

The binary will be at `.build/release/visualping`. Copy it somewhere on your `$PATH`:

```bash
cp .build/release/visualping /usr/local/bin/
```

## Usage

```
visualping <source> [--position <position>] [--size <pixels>]
```

**Arguments:**

| Argument | Description | Default |
|----------|-------------|---------|
| `source` | URL or local file path to a `.json` or `.lottie` animation | *(required)* |
| `--position` | Screen position (see below) | `center` |
| `--size` | Animation width and height in pixels | `300` |

**Positions:** `center`, `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`

### Examples

```bash
# Play a local animation in the center
visualping animation.json

# Download and play in the top-right corner at 200px
visualping https://example.com/alert.lottie --position top-right --size 200

# Bottom-center notification at 400px
visualping ~/animations/success.json --position bottom-center --size 400
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [lottie-spm](https://github.com/airbnb/lottie-spm) | 4.6.0 | Lottie animation rendering |
| [swift-argument-parser](https://github.com/apple/swift-argument-parser) | 1.7.0 | CLI argument parsing |

## How It Works

1. Parses CLI arguments
2. Resolves the animation source (downloads if URL, reads if local path)
3. Creates a transparent, floating `NSWindow` at the specified screen position
4. Loads and plays the Lottie animation once
5. Terminates the process when playback completes

The app runs as a headless `NSApplication` — no app bundle, dock icon, or menu bar presence.

## License

MIT
