description := A video-capture record/playback testing system

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
	rm -f stbt.html
