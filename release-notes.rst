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

0.7 Exposes `detect_match` and `detect_motion`; removes `directory` argument, changes image search path
-------------------------------------------------------------------------------------------------------

21 October 2012.

New functions `detect_match` and `detect_motion` provide low-level
access to all the information provided by the `stbt-templatematch` and
`stbt-motiondetect` GStreamer elements for each frame of video processed.
To keep your test scripts readable, I recommend against using
`detect_match` and `detect_motion` directly; they are intended for you
to write helper functions that you can then use in your scripts. For an
example see `wait_for_match` and `wait_for_motion` in stbt.py: They are
now implemented in terms of `detect_match` and `detect_motion`.

`wait_for_match`, `press_until_match` and `wait_for_motion` no longer
accept the optional `directory` argument. In most cases the correct
upgrade path is simply to not give the `directory` argument from your
scripts. These functions (plus `detect_match` and `detect_motion`) now
search for specified template or mask images by looking in their
caller's directory, then their caller's caller's directory, etc.
(instead of looking only in their immediate caller's directory, or the
directory specified as an argument). This allows you to write helper
functions that take an image filename and then call `wait_for_match`.
See commit message
`4e5cd23c <https://github.com/drothlis/stb-tester/commit/4e5cd23c>`_
for details.

Bugfixes and minor changes:

 * `stbt run` no longer requires an X-Windows display (unless you're
   using an X-Windows sink in your pipeline).
 * wait_for_motion and detect_motion visualisation: Detected motion is
   highlighted in red in the output video, and masked-out portions of
   the frame are darkened.
 * Additional wait_for_motion logging with `stbt run -vv`.
 * wait_for_motion fails immediately if a mask is given but not found
   on the filesystem.
 * Send an end-of-stream event in the pipeline teardown; this avoids
   corrupted videos when using a source or sink pipeline that records
   video to disk.
 * Reset wait_for_match after it fails. (If the user's script caught the
   MatchTimeout exception and continued, the stbt-templatematch element
   used to remain active, consuming CPU and showing the search rectangle
   on the output video.) Same fix for wait_for_motion, detect_motion,
   etc.
 * `stbt record` now accepts `-v` (or `--verbose`) command-line option
   (`stbt run` already did).
 * `stbt run` throws exceptions for all error conditions (instead of
   exiting with `sys.exit(1)` in some cases).
 * `stbt run` exposes the following exceptions directly in the script's
   namespace (so the script can say `except MatchTimeout` instead of
   `import stbt; except stbt.MatchTimeout`): UITestError, UITestFailure,
   MatchTimeout, MotionTimeout, ConfigurationError.
 * All functions and classes exposed to user scripts are now fully
   documented in the man page.
 * Fixes to the self-tests: `test_record` wasn't reporting failures;
   `test_wait_for_match_nonexistent_{template,match}` were failing
   intermittently.
 * RPM spec file in extras/


0.6 Improves templatematch, adds `--verbose` flag, `certainty` renamed to `noise_threshold`
-------------------------------------------------------------------------------------------

5 September 2012.

The templatematch algorithm is more precise (see commit
`ee28b8e <https://github.com/drothlis/stb-tester/commit/ee28b8e>`_ for
details). Taking advantage of this, `wait_for_match` now waits by
default for only one match.

The optional parameter `certainty` of `wait_for_match` and
`press_until_match` has been removed. Since 0.4 it actually didn't have
any effect. It has been replaced with the parameter `noise_threshold`,
a floating-point value between 0 and 1 that defaults to 0.16. Increase
it to be more tolerant to noise (small differences between the desired
template and the source video frame).

Debug output is disabled by default; use `--verbose` or `-v` to enable.
Use `-v -v` (or `-vv`) to enable additional debug, including dumping of
intermediate images by the stbt-templatematch and stbt-motiondetect
GStreamer elements (this is extremely verbose, and isn't intended for
end users).

libgst-stb-tester.so's `stbt-templatematch` element can now be installed
alongside libgstopencv.so's `templatematch` element.

MatchTimeout is reported correctly if the GStreamer pipeline failed to
start due to a v4l2 error (even better would be to detect the v4l2 error
itself).

Limit the maximum attempts to restart the pipeline in case of underrun
(e.g. on loss of input video signal). Previously, `stbt run` attempted
to restart the pipeline infinitely.

Fix `make install` with Ubuntu's shell (dash).

Other non-user-visible and trivial changes since 0.5:

* stbt-templatematch bus message's parameter `result` is renamed to
  `match` and is now a boolean.
* `make check` returns the correct exit status for failing self-tests.
* The bash-completion script completes the `--help` flag.
* Fix "unknown property debugDirectory" warning from
  `stbt-templatematch` element.


0.5 `make install` installs stbt{-run,-record,.py} into $libexecdir
-------------------------------------------------------------------

14 August 2012.

The only difference from 0.4 is this change to install locations,
for the benefit of packagers.


0.4 Adds gstreamer plugin, improved templatematch, motion detection
-------------------------------------------------------------------

14 August 2012.

New "libgst-stb-tester.so" gstreamer plugin with stbt-templatematch
(copied from gst-plugins-bad and improved) and stbt-motiondetect
elements.

stbt scripts can use "wait_for_motion" to assert that video is playing.
"wait_for_motion" takes an optional "mask" parameter (a black-and-white
image where white pixels indicate the regions to check for motion).

The improved templatematch is more robust in the presence of noise, and
can detect small but significant changes against large template images.

Other changes since 0.3:

* Bash-completion script for stbt.
* stbt no longer reads configuration from $PWD/stbt.conf.
* extra/jenkins-stbt-run is a shell script that illustrates how to use
  Jenkins (a continuous-integration system with a web interface) to
  schedule stbt tests and report on their results. See commit message
  `d5e7983 <https://github.com/drothlis/stb-tester/commit/d5e7983>`_
  for instructions.


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
