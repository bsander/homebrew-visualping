> **Note:** This is the Homebrew tap branch. Source code and development happens on the [`main` branch](https://github.com/bsander/homebrew-visualping/tree/main).

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
visualping <source> [options]
```

**Arguments:**

| Argument | Description | Default |
|----------|-------------|---------|
| `source` | Keyword, URL, or local file path to a `.json` or `.lottie` animation | *(required)* |
| `--position` | Screen position (see below) | `top-right` |
| `--size` | Animation size in pixels (e.g. `150`) or percentage of screen height (e.g. `15%`) | `10%` |
| `--screen` | Target screen: `main`, `all`, or a 1-based index (e.g. `2`) | `main` |
| `--duration` | Animation duration in seconds | native length |
| `--label` | Text label displayed on a pill at the bottom of the animation | — |
| `--path` | Path whose last component is displayed as the label | — |

**Positions:** `center`, `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`

### Examples

```bash
# Play a built-in keyword animation
visualping done

# Play with position and size
visualping error --position top-right --size 200

# Play with a percentage size
visualping done --size 15%

# Play a local animation file
visualping animation.json

# Download and play from a URL
visualping https://example.com/alert.lottie --position top-right --size 200

# Play on all connected screens simultaneously
visualping done --screen all

# Play on the second screen only
visualping error --screen 2

# Show a label on the animation
visualping done --label "Build passed"

# Use a path to auto-generate a label from the last component
visualping attention --path /Users/me/projects/myapp
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

### Default Settings

Set persistent defaults in `~/.config/visualping/config.json` under a `"defaults"` key. All fields are optional — missing fields use hardcoded defaults.

```json
{
  "animations": {
    "deploy": "/path/to/deploy-animation.json"
  },
  "defaults": {
    "position": "top-right",
    "size": "15%",
    "screen": "all",
    "duration": 2.0,
    "fullscreen": false
  }
}
```

**Priority chain:** CLI flag > config file > hardcoded default

For example, with the config above, `visualping done` uses `top-right` position and `all` screens, while `visualping done --position center` overrides position to `center` but keeps the other config values.

## Agent Hook Integration

The `agent-hook` subcommand installs or removes visualping hooks for AI coding tools, so you get visual notifications on tool events:

```bash
# Install hooks for Claude Code
visualping agent-hook claude

# Install plugin for OpenCode
visualping agent-hook opencode

# Remove hooks
visualping agent-hook claude --uninstall
visualping agent-hook opencode --uninstall
```

Agent hooks use your config file defaults for position, screen, size, and duration — no need to hardcode these in hook commands.

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [lottie-ios](https://github.com/airbnb/lottie-ios) | ≥ 4.5.0 | Lottie animation rendering |
| [swift-argument-parser](https://github.com/apple/swift-argument-parser) | ≥ 1.3.0 | CLI argument parsing |

## How It Works

1. Parses CLI arguments
2. Resolves the animation source (keyword → config/bundled, downloads if URL, reads if local path)
3. Creates a transparent, floating `NSWindow` at the specified screen position
4. Loads and plays the Lottie animation once
5. Terminates the process when playback completes

The app runs as a headless `NSApplication` — no app bundle, dock icon, or menu bar presence.

## License

MIT
