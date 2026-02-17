.PHONY: test

SHELL := /bin/bash

test:
	./lib/bashunit test/ --coverage --coverage-paths bin/tmux-nerd-font-window-name,bin/generate-tmux-format --coverage-report coverage/lcov.info
