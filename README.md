> **Note:** This is the Homebrew tap branch. Source code and development happens on the [`main` branch](https://github.com/bsander/homebrew-visualping/tree/main).

# visualping

<img src="assets/demo.gif" alt="visualping demo" width="600">

A macOS CLI tool that displays Lottie animations as transparent, click-through desktop overlays. Play an animation once and exit — perfect for non-intrusive visual notifications.

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
visualping <animation> [options]
```

**Arguments:**

| Argument | Description | Default |
|----------|-------------|---------|
| `animation` | Keyword, URL, or local file path to a `.json` or `.lottie` animation | *(required)* |
| `--position` | Screen position | `top-right` |
| `--size` | Animation size in pixels (e.g. `150`) or percentage of screen height (e.g. `15%`) | `10%` |
| `--screen` | Target screen: `main`, `all`, or a 1-based index (e.g. `2`) | `main` |
| `--duration` | Animation duration in seconds | native length |
| `--label` | Text label displayed on a pill at the bottom of the animation | — |
| `--path` | Path whose last component is displayed as the label | — |
| `--fullscreen` | Fill the entire screen with the animation (use `--no-fullscreen` to disable) | `false` |

### Examples

```bash
# Play a keyword animation with options
visualping done --position center --size 200 --duration 3

# Play a local file with a label
visualping animation.json --label "Build passed"

# Play fullscreen on all screens
visualping done --screen all --fullscreen
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
  "defaults": {
    "position": "top-right",
    "size": "15%",
    "screen": "all",
    "duration": 2.0,
    "fullscreen": false
  },
  "animations": {
    "deploy": "/path/to/deploy-animation.json"
  }
}
```

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

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [lottie-ios](https://github.com/airbnb/lottie-ios) | ≥ 4.5.0 | Lottie animation rendering |
| [swift-argument-parser](https://github.com/apple/swift-argument-parser) | ≥ 1.3.0 | CLI argument parsing |

## License

MIT
