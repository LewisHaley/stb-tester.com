description := A video-capture record/playback testing system

all: index.html stbt.html release-notes.html introduction.html

deploy: index.html stbt.html release-notes.html introduction.html \
  stb-tester.css stb-tester-350px.svg stb-tester-160px.svg \
  video-introduction.png video-introduction-thumbnail.png
	mkdir static
	cp $^ static
	trap 'rm -rf static' EXIT; \
	rev="$$(git log -n1 --format=format:%h HEAD)"; \
	git checkout gh-pages && \
	for f in $^; do cp static/$$f .; git add $$f; done && \
	git commit -m "Static site from master $$rev" && \
	echo "*** Review the last commit, then: git push origin gh-pages " \
	     "&& git checkout master ***"


index.html: index.html.in release-notes.rst
	cat $< |\
	sed -e "s/@VERSION@/$$(cat stb-tester/VERSION)/" \
	> $@

stbt.html: stb-tester/README.rst stb-tester/VERSION stbt.html.template
	cat stb-tester/README.rst |\
	sed -e "s/@VERSION@/$$(cat stb-tester/VERSION)/" \
	    -e "/^:Manual section:/ d" \
	    -e "/^:Manual group:/ d" \
	    -e "s/Copyright (C)/Copyright ©/" |\
	rst2html --template=stbt.html.template --initial-header-level=2 \
	    --title='stbt(1): $(description) -- man page' |\
	sed -e 's,<a class="reference external" href="file:/">file:/</a>,file:/,' \
	> $@

rst_markers := /Begin reStructuredText content/,/End reStructuredText content/
introduction.html release-notes.html: %.html: %.rst
	@[ -n "$$BASH_VERSINFO" ] && [ "$$BASH_VERSINFO" -ge 4 ] || { \
	    echo "ERROR: Requires bash version 4." >&2; \
	    echo "Use 'make SHELL=/path/to/bash'" >&2; exit 1; }
	cat $< |\
	sed -n -e '$(rst_markers) p' |\
	sed -e '/reStructuredText content/ d' |\
	rst2html \
	    --template=<( \
	        cat $< |\
	        sed -e '$(rst_markers) d' \
	            -e "s/@UPDATED@/$$( \
	                git log -n1 --format=format:'%cD' $< |\
	                awk '{print $$2, $$3, $$4}')/") \
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
	rm -f index.html stbt.html release-notes.html introduction.html
