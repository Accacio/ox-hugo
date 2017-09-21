# Time-stamp: <2017-09-20 23:29:05 kmodi>

# Makefile to export org documents to md for Hugo from the command line
# Run just "make" to see usage examples.

# Function to be run in emacs --batch
FUNC=

# Port for hugo server
PORT=1337

# ox-hugo test directory; also contains the setup-ox-hugo.el
OX_HUGO_TEST_DIR=$(shell pwd)/test

# Base directory for the Hugo example site
OX_HUGO_TEST_SITE_DIR=$(OX_HUGO_TEST_DIR)/example-site

# Directory containing test Org files for example-site
OX_HUGO_TEST_ORG_DIR=$(OX_HUGO_TEST_SITE_DIR)/content-org

# Path to the Org file relative to $(OX_HUGO_TEST_ORG_DIR)
ORG=

# Directory where the required elisp packages are auto-installed
OX_HUGO_ELPA=/tmp/$(USER)/ox-hugo-dev/

.PHONY: help mdtree mdfile vcheck hugo serve server diff \
	test vcheck testmkgold \
	test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 \
	test11 test12 test13 \
	ctemp diffgolden clean

help:
	@echo "Help for command-line Org->Markdown for Hugo Exporter"
	@echo "====================================================="
	@echo " make mdtree ORG=example.org   <-- Export the Subtrees in the .org file to Markdown file(s)"
	@echo " make mdfile ORG=example.org   <-- Export the .org File to a single Markdown file"
	@echo " make vcheck                   <-- Print emacs, Org, hugo versions"
	@echo " make hugo                     <-- Run hugo"
	@echo " make serve                    <-- Run the hugo server on http://localhost:$(PORT)"
	@echo " make diff                     <-- Run git diff"
	@echo " make test                     <-- Run test"
	@echo " make clean                    <-- Delete the Hugo public/ directory and auto-installed elisp packages"
	@echo " make                          <-- Show this help"

# Note: The Org file from $(ORG) is loaded *after* the --eval section
# gets evaluated i.e. --eval '(progn ..)' $(ORG) If the order is
# reversed i.e. i.e.$(ORG) --eval '(progn ..)', the act of loading
# the $(ORG) file first will load the older Org version that ships
# with Emacs and then run the stuff in --eval that loads the new Org
# version.. and thus we'll end up with mixed Org in the load-path.
emacs-batch:
	@emacs --batch --eval "(progn\
	(setenv \"OX_HUGO_ELPA\" \"$(OX_HUGO_ELPA)\")\
	(load-file (expand-file-name \"setup-ox-hugo.el\" \"$(OX_HUGO_TEST_DIR)\"))\
	)" $(OX_HUGO_TEST_ORG_DIR)/$(ORG) \
	-f $(FUNC) \
	--kill

mdtree:
	@echo "[ox-hugo] Exporting Org to Md in 'Subtree' mode .."
	@$(MAKE) emacs-batch FUNC=org-hugo-export-all-subtrees-to-md
	@echo "[ox-hugo] Done"

mdfile:
	@echo "[ox-hugo] Exporting Org to Md in 'File' mode .."
	@$(MAKE) emacs-batch FUNC=org-hugo-export-to-md
	@echo "[ox-hugo] Done"

vcheck:
	@emacs --batch \
	--eval "(message \"[Version checks] Emacs: %s, Org: %s\" emacs-version (org-version))" \
	--kill
	@hugo version

hugo: vcheck
	@hugo

serve server: vcheck
	@echo "Serving the site on http://localhost:$(PORT) .."
	@hugo server \
	--buildDrafts \
	--buildFuture \
	--navigateToChanged \
	--baseURL http://localhost \
	--port $(PORT)

diff:
	@git diff

# Wed Sep 20 13:35:54 EDT 2017 - kmodi
# - Cannot run test11 because the lastmod field will always get updated.
# - Cannot run test12 and test13 because they set the org-hugo-footer using Local Variables.
test: vcheck testmkgold \
	test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 \
	diffgolden

# https://stackoverflow.com/a/16589534/1219634
testmkgold:
	@git checkout --ignore-skip-worktree-bits -- $(OX_HUGO_TEST_SITE_DIR)/content
	@rm -rf $(OX_HUGO_TEST_SITE_DIR)/content-golden
	@cp -rf $(OX_HUGO_TEST_SITE_DIR)/content{,-golden}

test1:
	@$(MAKE) mdtree ORG=all-posts.org
	@$(MAKE) diffgolden

test2:
	@$(MAKE) mdtree ORG=construct-hugo-front-matter-from-menu-meta-data.org

test3:
	@$(MAKE) mdtree ORG=src-blocks-with-highlight-shortcode.org

test4:
	@$(MAKE) mdtree ORG=mandatory-EXPORT_FILE_NAME-for-subtree-export.org

test5:
	@$(MAKE) mdtree ORG=hugo-menu-as-keyword.org

test6:
	@$(MAKE) mdtree ORG=tags-keyword.org

test7:
	@$(MAKE) mdtree ORG=hugo-weight-as-keyword-auto-calc.org

test8:
	@$(MAKE) mdfile ORG=single-posts/post-toml.org

test9:
	@$(MAKE) mdfile ORG=single-posts/post-yaml.org

test10:
	@$(MAKE) mdfile ORG=single-posts/post-draft.org

# Cannot run test11 because the lastmod field will always get updated.
test11:
	@$(MAKE) mdtree ORG=auto-set-lastmod.org

# Cannot run test12 it sets the org-hugo-footer using Local Variables.
test12:
	@$(MAKE) mdtree ORG=screenshot-subtree-export-example.org

# Cannot run test13 because it sets the org-hugo-footer using Local Variables.
test13:
	@$(MAKE) mdfile ORG=writing-hugo-blog-in-org-file-export.org

ctemp:
	@find $(OX_HUGO_TEST_SITE_DIR)/content -name "*.*~" -delete

diffgolden: ctemp
	@diff -rq $(OX_HUGO_TEST_SITE_DIR)/content $(OX_HUGO_TEST_SITE_DIR)/content-golden

clean: ctemp
	@rm -rf $(OX_HUGO_TEST_SITE_DIR)/public/ $(OX_HUGO_TEST_SITE_DIR)/content-golden
	@rm -rf $(OX_HUGO_ELPA)
