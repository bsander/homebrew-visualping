# visualping

A macOS CLI tool that displays Lottie animations as transparent, click-through desktop overlays. Play an animation once and exit — perfect for non-intrusive visual notifications.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)

## Features

- Renders `.json` (Lottie) and `.lottie` (dotLottie) animations
- Built-in keyword animations (`done`, `error`, `attention`) — no config needed
- Loads from keywords, local files, or URLs
- Transparent, click-through overlay — doesn't interfere with your workflow
- 7 screen positions: center, top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
- Multi-screen support: main screen, all screens, or specific screen by index
- Configurable animation size
- No dock icon or menu bar entry
- Visible on all spaces/desktops
- Exits automatically when the animation completes

## Installation

### Homebrew (recommended)

```bash
brew install bsander/visualping/visualping
```

### From source

```bash
git clone https://github.com/bsander/visualping.git
cd visualping
make install
```

To install to a custom location:

```bash
make install PREFIX=$HOME/.local
```

## Usage

```
visualping <source> [--position <position>] [--size <pixels>] [--screen <screen>]
```

**Arguments:**

| Argument | Description | Default |
|----------|-------------|---------|
| `source` | Keyword, URL, or local file path to a `.json` or `.lottie` animation | *(required)* |
| `--position` | Screen position (see below) | `center` |
| `--size` | Animation width and height in pixels | `300` |
| `--screen` | Target screen: `main`, `all`, or index (e.g. `2`) | `main` |

**Positions:** `center`, `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`

### Examples

```bash
# Play a built-in keyword animation
visualping done

# Play with position and size
visualping error --position top-right --size 200

# Play a local animation file
visualping animation.json

# Download and play from a URL
visualping https://example.com/alert.lottie --position top-right --size 200

# Play on all connected screens simultaneously
visualping done --screen all

# Play on the second screen only
visualping error --screen 2
```

## Keywords

Built-in keywords play bundled animations with no setup required:

| Keyword | Animation |
|---------|-----------|
| `done` | Checkmark / success |
| `error` | Error / failure |
| `attention` | Attention needed |

### Custom Keywords

Add custom keyword mappings in `~/.config/visualping/config.json`:

```json
{
  "animations": {
    "deploy": "/path/to/deploy-animation.json",
    "celebrate": "https://example.com/party.lottie"
  }
}
```

Config entries override built-in keywords. URL sources are cached in `~/.config/visualping/cache/`.

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [lottie-ios](https://github.com/airbnb/lottie-ios) | 4.6.0 | Lottie animation rendering |
| [swift-argument-parser](https://github.com/apple/swift-argument-parser) | 1.7.0 | CLI argument parsing |

## How It Works

1. Parses CLI arguments
2. Resolves the animation source (keyword → config/bundled, downloads if URL, reads if local path)
3. Creates a transparent, floating `NSWindow` at the specified screen position
4. Loads and plays the Lottie animation once
5. Terminates the process when playback completes

The app runs as a headless `NSApplication` — no app bundle, dock icon, or menu bar presence.

## License

MIT
