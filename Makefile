PREFIX ?= /usr/local
BINARY_NAME = visualping
BUILD_DIR = .build/release

.PHONY: build install dev uninstall clean help

build: ## Build release binary
	swift build -c release

install: build ## Copy binary to PREFIX/bin (used by Homebrew)
	install -d $(PREFIX)/bin
	install $(BUILD_DIR)/$(BINARY_NAME) $(PREFIX)/bin/$(BINARY_NAME)

dev: build ## Symlink binary to PREFIX/bin (for local development)
	install -d $(PREFIX)/bin
	ln -sf $(realpath $(BUILD_DIR)/$(BINARY_NAME)) $(PREFIX)/bin/$(BINARY_NAME)

uninstall: ## Remove binary from PREFIX/bin
	rm -f $(PREFIX)/bin/$(BINARY_NAME)

clean: ## Remove build artifacts
	swift package clean
	rm -rf .build

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
