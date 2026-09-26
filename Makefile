HYPRLAND_DIR := home/konrad/common/modules/desktop/ui/hyprland
QUICKSHELL_DIR := home/konrad/common/modules/desktop/ui/quickshell

# --others so a new file is checked before it is ever staged, and wildcard
# to drop what git still has in the index but is gone from disk
GIT_LS := git ls-files --cached --others --exclude-standard
LUA_FILES := $(wildcard $(shell $(GIT_LS) '*.lua'))
NIX_FILES := $(wildcard $(shell $(GIT_LS) '*.nix'))
QML_FILES := $(wildcard $(shell $(GIT_LS) '$(QUICKSHELL_DIR)/*.qml'))
SH_FILES := $(wildcard $(shell $(GIT_LS) '*.sh'))
# whatever the lists above do not already cover.
# .prettierignore keeps it off the sops secrets.
PRETTIER_FILES := $(wildcard $(shell $(GIT_LS) '*.json' '*.md' '*.yaml' '*.yml'))

# an empty list would make a fmt check pass over nothing at all
$(foreach v,LUA_FILES NIX_FILES QML_FILES SH_FILES PRETTIER_FILES,\
  $(if $(strip $($(v))),,$(error $(v) is empty, run make from the repo root)))

.PHONY: check
check: check-fmt check-lint

.PHONY: fmt
fmt: fmt-nix fmt-lua fmt-qml fmt-sh fmt-prettier

.PHONY: fmt-nix
fmt-nix:
	@nixfmt $(NIX_FILES)

.PHONY: fmt-lua
fmt-lua:
	@stylua $(LUA_FILES)

.PHONY: fmt-qml
fmt-qml:
	@qmlformat --inplace $(QML_FILES)

.PHONY: fmt-sh
fmt-sh:
	@shfmt -w $(SH_FILES)

.PHONY: fmt-prettier
fmt-prettier:
	@prettier --write --log-level warn $(PRETTIER_FILES)

.PHONY: check-fmt
check-fmt: check-fmt-nix check-fmt-lua check-fmt-qml check-fmt-sh check-fmt-prettier

.PHONY: check-fmt-nix
check-fmt-nix:
	@nixfmt --check $(NIX_FILES)

.PHONY: check-fmt-lua
check-fmt-lua:
	@stylua --check $(LUA_FILES)

# qmlformat has no --check, so compare what it would write against the file
.PHONY: check-fmt-qml
check-fmt-qml:
	@fail=0; for f in $(QML_FILES); do \
		qmlformat "$$f" | diff -q "$$f" - >/dev/null || { echo "would reformat: $$f"; fail=1; }; \
	done; exit $$fail

# shfmt takes its indent from .editorconfig, same as the editor does
.PHONY: check-fmt-sh
check-fmt-sh:
	@shfmt -d $(SH_FILES)

.PHONY: check-fmt-prettier
check-fmt-prettier:
	@prettier --check --log-level warn $(PRETTIER_FILES)

.PHONY: check-lint
check-lint: lint-lua lint-qml lint-sh

# the lua here is linted against hyprland's own `hl` stubs, which is why this
# takes the directory rather than LUA_FILES: .nvim.lua is neovim's, not its
.PHONY: lint-lua
lint-lua:
	@hyprland-lua-lint $(HYPRLAND_DIR)

.PHONY: lint-qml
lint-qml:
	@quickshell-lint $(QUICKSHELL_DIR)

.PHONY: lint-sh
lint-sh:
	@shellcheck $(SH_FILES)
