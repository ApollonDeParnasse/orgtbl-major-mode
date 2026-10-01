EMACS ?= emacs
PKG = orgtbl-major-mode
LOAD_PATH  += -L .
LOAD_PATH  += -L ./tests

.PHONY: test init


clean: ## Clean up all temporary files created during testing/runtime.
	find . -name "*.elc" -type f -delete

init: ## initiate
init:
	$(EMACS) --batch -L . \
		 $(LOAD_PATH) \
		 -l init.el;

test: ## Run tests
test: clean
	$(EMACS) --batch -L . \
		 $(LOAD_PATH) \
		 -l orgtbl-major-mode-tests.el \
		 --eval "(generate-run-tests-batch-and-exit)";
