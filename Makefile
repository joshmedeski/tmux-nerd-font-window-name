.PHONY: test

test:
	./lib/bashunit test/ --coverage --coverage-paths bin/tmux-nerd-font-window-name --coverage-report coverage/lcov.info
