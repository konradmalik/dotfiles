HYPRLAND_DIR := home/konrad/common/modules/desktop/ui/hyprland
QUICKSHELL_DIR := home/konrad/common/modules/desktop/ui/quickshell

FIND_SRC := find . -name .git -prune -o -name .direnv -prune -o
NIX_FILES := $(shell $(FIND_SRC) -name '*.nix' -print)
QML_FILES := $(shell find $(QUICKSHELL_DIR) -name '*.qml' -print)

.PHONY: check
check: check-fmt check-lint

.PHONY: fmt
fmt: fmt-nix fmt-lua fmt-qml

.PHONY: fmt-nix
fmt-nix:
	@nixfmt $(NIX_FILES)

.PHONY: fmt-lua
fmt-lua:
	@stylua $(HYPRLAND_DIR)

.PHONY: fmt-qml
fmt-qml:
	@qmlformat --inplace $(QML_FILES)

.PHONY: check-fmt
check-fmt: check-fmt-nix check-fmt-lua check-fmt-qml

.PHONY: check-fmt-nix
check-fmt-nix:
	@nixfmt --check $(NIX_FILES)

.PHONY: check-fmt-lua
check-fmt-lua:
	@stylua --check $(HYPRLAND_DIR)

# qmlformat has no --check, so compare what it would write against the file
.PHONY: check-fmt-qml
check-fmt-qml:
	@fail=0; for f in $(QML_FILES); do \
		qmlformat "$$f" | diff -q "$$f" - >/dev/null || { echo "would reformat: $$f"; fail=1; }; \
	done; exit $$fail

.PHONY: check-lint
check-lint: lint-lua lint-qml

.PHONY: lint-lua
lint-lua:
	@hyprland-lua-lint $(HYPRLAND_DIR)

.PHONY: lint-qml
lint-qml:
	@quickshell-lint $(QUICKSHELL_DIR)
