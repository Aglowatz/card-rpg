.PHONY: import test check run editor

GODOT ?= godot

# Run after creating or modifying any .tscn, .tres, or asset. Without a
# populated .godot/ directory, class_name scripts aren't registered and
# type annotations referencing your own classes fail to resolve.
import:
	$(GODOT) --headless --import --path .

test: import
	GODOT_DISABLE_LEAK_CHECKS=1 $(GODOT) --headless -d -s addons/gut/gut_cmdln.gd --path . -gdir=res://test -gexit

# Usage: make check FILE=res://src/core/effects/deal_damage.gd
check:
	$(GODOT) --headless --path . --check-only --script $(FILE)

run: import
	$(GODOT) --path .

editor:
	$(GODOT) --editor --path .
