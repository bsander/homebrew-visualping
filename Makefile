PREFIX ?= /usr/local
BINARY_NAME = visualping
BUILD_DIR = .build/release

.PHONY: build install uninstall clean help

build: ## Build release binary
	swift build -c release

install: build ## Build and install to PREFIX/bin (default: /usr/local)
	install -d $(PREFIX)/bin
	install -m 755 $(BUILD_DIR)/$(BINARY_NAME) $(PREFIX)/bin/$(BINARY_NAME)

uninstall: ## Remove binary from PREFIX/bin
	rm -f $(PREFIX)/bin/$(BINARY_NAME)

clean: ## Remove build artifacts
	swift package clean
	rm -rf .build

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
