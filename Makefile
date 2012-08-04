description := A video-capture record/playback testing system

all: stbt.html release-notes.html introduction.html

stbt.html: stb-tester/README.rst stb-tester/VERSION docutils-html4css1.css stbt.css
	cat $< |\
	sed -e "s/@VERSION@/$$(cat stb-tester/VERSION)/" \
	    -e "/^:Manual section:/ d" \
	    -e "/^:Manual group:/ d" \
	    -e "s/Copyright (C)/Copyright ©/" |\
	rst2html --stylesheet=docutils-html4css1.css,stbt.css \
	    --title='stbt(1): $(description) -- man page' |\
	sed -e 's,<a class="reference external" href="file:/">file:/</a>,file:/,' \
	> $@

release-notes.html: release-notes.rst docutils-html4css1.css stbt.css
	rst2html --stylesheet=docutils-html4css1.css,stbt.css \
	    --initial-header-level=2 $< > $@

rst_markers := /Begin reStructuredText content/,/End reStructuredText content/
introduction.html: introduction.rst
	@[ -n "$$BASH_VERSINFO" ] && [ "$$BASH_VERSINFO" -ge 4 ] || { \
	    echo "ERROR: Requires bash version 4." >&2; \
	    echo "Use 'make SHELL=/path/to/bash'" >&2; exit 1; }
	cat $< |\
	sed -n -e '$(rst_markers) p' |\
	sed -e '/reStructuredText content/ d' |\
	rst2html --template=<(sed -e '$(rst_markers) d' $<) \
	    --initial-header-level=2 --footnote-references=superscript \
	> $@


# Requires a little manual intervention: `cd` to stb-tester and `git checkout`
# the most recent tag, so that version is "0.x" instead of "0.x-n-abcdefgh".
stb-tester/VERSION: | stb-tester
	$(MAKE) -C stb-tester stbt

stb-tester/README.rst: stb-tester

stb-tester:
	@echo "ERROR: Failed to find 'stb-tester' directory." >&2
	@echo "Please clone the 'stb-tester' repo here," >&2
	@echo "and checkout the most recent tag." >&2
	@exit 1

clean:
	rm -f stbt.html release-notes.html introduction.html
