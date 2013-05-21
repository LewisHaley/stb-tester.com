description := A video-capture record/playback testing system

ARTICLES := release-notes.html introduction.html getting-started.html
ARTICLES += find-player.html jenkins.html hardware.html
ARTICLES += match-parameters.html multi-lirc.html

SHELL := bash

all: index.html stbt.html $(ARTICLES)

deploy: index.html stbt.html $(ARTICLES) \
  stb-tester.css stb-tester-350px.svg stb-tester-160px.svg \
  stb-tester.atom atom.png \
  video-introduction-thumbnail.jpg \
  videotestsrc.png videotestsrc-templatematch.png \
  find-player-4oD-selected.png find-player-4oD-unselected.png \
  find-player-Demand5-selected.png find-player-Demand5-unselected.png \
  find-player-any-player-selected.png \
  find-player-iPlayer-selected.png find-player-iPlayer-unselected.png \
  players.py \
  stb-tester+jenkins+setup.svg jenkins+jobs.png jenkins+build+now.png \
  jenkins+xunit+graph.png jenkins+xunit+results.png jenkins+artifacts.png \
  hdpvr-mp4-pipeline.svg hdpvr-fan.jpg \
  match-parameters-banner-low-threshold-absdiff.png \
  match-parameters-banner-template.png \
  match-parameters-bunny-template.png \
  match-parameters-graphic.png \
  match-parameters-match-method1.png \
  match-parameters-match-method3.png \
  match-parameters-match-method5.png \
  match-parameters-noisy-source.png \
  match-parameters-noisy-thick-border-bunny-source.png \
  match-parameters-rotated-sun-absdiff-normalized.png \
  match-parameters-rotated-sun-absdiff-threshold-2-erodes.png \
  match-parameters-rotated-sun-absdiff-threshold-erode.png \
  match-parameters-rotated-sun-absdiff-threshold.png \
  match-parameters-rotated-sun-absdiff.png \
  match-parameters-rotated-sun-source-roi-gray-normalized.png \
  match-parameters-rotated-sun-source-roi-gray.png \
  match-parameters-rotated-sun-source-roi.png \
  match-parameters-rotated-sun-template-gray-normalized.png \
  match-parameters-rotated-sun-template-gray.png \
  match-parameters-rotated-sun-template.png \
  match-parameters-test-source.png \

	mkdir static
	cp $^ static
	trap 'rm -rf static' EXIT; \
	rev="$$(git log -n1 --format=format:%h HEAD)"; \
	git checkout gh-pages && \
	for f in $^; do cp static/$$f .; git add $$f; done && \
	git commit -m "Static site from master $$rev" && \
	echo "*** Review the last commit, then: git push origin gh-pages " \
	     "&& git checkout master ***"


index.html: index.html.in stb-tester/VERSION
	cat $< |\
	sed -e "s/@VERSION@/$$(cat stb-tester/VERSION)/" \
	> $@

stbt.html: stb-tester/README.rst stb-tester/VERSION stbt.html.template
	cat stb-tester/README.rst |\
	sed -e "s/@VERSION@/$$(cat stb-tester/VERSION)/" \
	    -e "/^:Manual section:/ d" \
	    -e "/^:Manual group:/ d" \
	    -e "s/Copyright (C)/Copyright ©/" \
	    -e "/^\.\. image:: https:..travis-ci.org/,/:target:/ d" |\
	rst2html --template=stbt.html.template --initial-header-level=2 \
	    --title='stbt(1): $(description) -- man page' |\
	sed -e 's,<a class="reference external" href="file:/">file:/</a>,file:/,' \
	    -e "/<start python docs>/,/<end python docs>/ \
	            s,<dt>\([a-z_]*\)(,<dt id='\1'>\1(," \
	    -e "/<start python docs>/,/<end python docs>/ \
	            s,<dt>class \([A-Za-z]*\),<dt id='\1'>class \1," \
	> $@

rst_markers := /Begin reStructuredText content/,/End reStructuredText content/
release-notes.html: article_postprocess := | sed -e 's,<h2>\([0-9.]*\),<h2 id="\1">\1,'

$(ARTICLES): %.html: %.rst
	cat $< |\
	sed -n -e '$(rst_markers) p' |\
	sed -e '/reStructuredText content/ d' |\
	./highlight |\
	rst2html \
	    --template=<( \
	        cat $< |\
	        sed -e '$(rst_markers) d' \
	            -e "s/@UPDATED@/$$( \
	                git log -n1 --format=format:'%cD' $< |\
	                awk '{print $$2, $$3, $$4}')/") \
	    --initial-header-level=2 --footnote-references=superscript \
	    --strip-comments \
	$(article_postprocess) \
	> $@

find-player.html: highlight

jenkins.html: hdpvr-mp4-pipeline.svg
hdpvr-mp4-pipeline.svg: hdpvr-mp4-pipeline.dot
	dot -Tsvg -o $@ $<


# Requires a little manual intervention: `cd` to stb-tester and `git checkout`
# the most recent tag, so that version is "0.x" instead of "0.x-n-abcdefgh".
stb-tester/VERSION: stb-tester
	$(MAKE) -C stb-tester stbt

stb-tester/README.rst: stb-tester

stb-tester:
	@echo "ERROR: Failed to find 'stb-tester' directory." >&2
	@echo "Please clone the 'stb-tester' repo here," >&2
	@echo "and checkout the most recent tag." >&2
	@exit 1

clean:
	rm -f index.html stbt.html $(ARTICLES)

.DELETE_ON_ERROR:
