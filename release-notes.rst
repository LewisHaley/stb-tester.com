<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>stb-tester release notes</title>
  <link href="stb-tester.css" media="all" rel="stylesheet" type="text/css" />

  <script type="text/javascript">
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-34036034-1']);
    _gaq.push(['_trackPageview']);
    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
  </script>

</head>

<body id="release-notes">

<div id="header">
  <h1>stb-tester release notes</h1>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

..
  `cd stb-tester && git tag -l` to list the tags;
  `git show $tag` to see the date and the annotated tag message.

0.3 Fixes `stbt run` freezing on loss of input video.
-----------------------------------------------------

24 July 2012.

You will still see the blue screen when input video cuts out, but now
`stbt run` should recover after 5 - 10 seconds and continue running the
test script.

Other changes since 0.2:

* Fix VirtualRemote recorder.
* Clearer error messages on VirtualRemote failure to connect.
* Added `certainty` optional argument to `press_until_match`
  (`wait_for_match` already takes `certainty`).
* `man stbt` documents the optional arguments to `wait_for_match` and
  `press_until_match`.

0.2 Adds configurability, IR blaster support.
---------------------------------------------

6 July 2012.

Major changes since 0.1.1:

* The source & sink gstreamer pipelines, the input & output remote control,
  and the input & output script filename, are all configurable.
* Support for LIRC-based infrared emitter & receiver hardware.
* Handle gstreamer errors.
* Automated self-tests.

0.1.1 Initial internal release, with packaging fixes.
-----------------------------------------------------

21 June 2012.

The difference from 0.1 is that `make install` now works correctly from
a dist tarball.

0.1 Initial internal release.
-----------------------------

21 June 2012.

<!-- End reStructuredText content -->

</div>
</body>
</html>
