HYPRLAND_DIR := home/konrad/common/modules/desktop/ui/hyprland
QUICKSHELL_DIR := home/konrad/common/modules/desktop/ui/quickshell

# --others so a new file is checked before it is ever staged, and wildcard
# to drop what git still has in the index but is gone from disk
GIT_LS := git ls-files --cached --others --exclude-standard
NIX_FILES := $(wildcard $(shell $(GIT_LS) '*.nix'))
QML_FILES := $(wildcard $(shell $(GIT_LS) '$(QUICKSHELL_DIR)/*.qml'))

# an empty list would make the fmt checks pass over nothing at all
ifeq ($(NIX_FILES),)
$(error no nix files found, run make from the repo root)
endif
ifeq ($(QML_FILES),)
$(error no qml files found under $(QUICKSHELL_DIR))
endif

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
