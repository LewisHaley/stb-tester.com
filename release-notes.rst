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
  <a href="http://stb-tester.com" id="back">[Back to stb-tester.com]</a>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

..
  `cd stb-tester && git tag -l` to list the tags;
  `git show $tag` to see the date and the annotated tag message.

`stb-tester <http://stb-tester.com>`_ is in "beta" stage, in the sense that
interfaces may change from one release to the next, though stb-tester *is* used
in production by several companies so we do try to minimise incompatible
changes. The release notes always provide an exhaustive list of any changes.


0.15 `stbt power`; `stbt control` can be used with `stbt record`; test scripts can take command-line arguments; `stbt.press` shows key pressed in output video
--------------------------------------------------------------------------------------------------------------------------------------------------------------

`stbt power` is a new command-line tool to switch on and off a
network-controllable power supply. See `stbt power --help` for details.
`stbt power` currently supports the following devices:

 * IP Power 9258, a family of devices sold under various brand names, for
   example `Aviosys <http://www.aviosys.com/9258st.html>`_.
 * The KWX product line from `PDUeX
   <http://www.pdu-expert.eu/index.php/en/component/k2/itemlist/category/1>`_.

`stbt control`, the interactive keyboard-based remote control input, can now be
used as input for `stbt record`. Use `--control-recorder=stbt-control`. See the
stbt(1) man page and `stbt control --help` for details.

`stbt run` now passes excess command-line arguments on to the test script. This
allows you to run the same script with different arguments when you need to run
multiple permutations of a test case.

`stbt.press` now draws the name of the pressed key on the output video. This
makes it a lot easier to understand what is happening when watching a test run,
and more importantly, when triaging a failed test from its recorded video.

The `restart_source` behaviour of `stbt run` and `stbt record` now works
correctly with the Hauppauge HDPVR video-capture device. (This was broken since
0.14.)

Minor user-visible fixes:

 * `stbt.frames()` doesn't deadlock if called again when the iterator returned
   from a previous call is still alive.
 * `stbt run` and `stbt record` now honour `global.verbose` in the configuration
   file.
 * `stbt run` standard output includes the exception typename when a test script
   fails due to an unhandled exception.
 * `stbt record` fails immediately if no video is available (instead of failing
   after the second keypress of input).
 * `stbt control` now allows mapping the Escape key to a remote-control button.
 * `stbt control` displays a readable error message when the terminal is too
   small.
 * `stbt control` doesn't fail when you send keypresses too quickly.
 * `stbt tv` works correctly in a VirtualBox VM.
 * `stbt screenshot` takes an optional `filename` argument (overriding the
   default of `screenshot.png`).
 * `stbt screenshot` and `stbt templatematch` don't save a video if
   `run.save_video` is set in the user's configuration file.

Additionally, the following scripts are available from the source repository:

 * `extra/vm <https://github.com/drothlis/stb-tester/tree/master/extra/vm>`_
   contains scripts to set up a virtual machine with Ubuntu and stb-tester
   installed. These scripts use `vagrant <http://www.vagrantup.com>`_, a tool
   for automatically provisioning virtual machines. See `extra/vm/README.rst
   <https://github.com/drothlis/stb-tester/blob/master/extra/vm/README.rst>`_
   for instructions.
 * `extra/runner
   <https://github.com/drothlis/stb-tester/tree/master/extra/runner>`_ contains
   scripts that will run a set of stb-tester test scripts and generate an html
   report. See `"extra/runner: Bulk test running & reporting"
   <http://stb-tester.com/runner.html>`_.


0.14 Arbitrary image processing in user scripts; `stbt control`; `--save-video`; miscellaneous improvements
-----------------------------------------------------------------------------------------------------------

9 July 2013.

`stbt.frames` allows a user's script to iterate over raw video frames in
the OpenCV format (i.e. a numpy array). This allows a user's script to
perform arbitrary image processing using the OpenCV python bindings. For
an example see the self-test `"test_using_frames_to_measure_black_screen"
<https://github.com/drothlis/stb-tester/blob/0.14/tests/test-stbt-py.sh#L96>`_.
Note that `detect_match`, `wait_for_match`, `detect_motion`, etc. are
now implemented on top of `frames`.
`get_frame` and `save_frame` also return/operate on the OpenCV format.

`stbt control` is a new command-line tool to send remote control
commands programmatically (from a script) or interactively (with the PC
keyboard). The interactive mode requires a keymap file specifying the
keyboard keys that correspond to each remote-control button. See
`stbt control --help` for details.

`stbt run` accepts `--save-video` on the command line (or `[run]
save_video` in the config file) to record a video to disk. The video's
format is WebM, which is playable in web browsers that support the HTML5
video standard.

`stbt run` has always restarted the GStreamer source pipeline when video
loss is detected, to work around the behaviour of the Hauppauge HD PVR
video-capture device. Now this behaviour is configurable; if you use the
Hauppauge HD PVR you should set `restart_source = True` in the
`[global]` section of your stbt config file.

Minor user-visible fixes:

 - The default value for `wait_for_motion` `consecutive_frames` has
   changed from `10` to `"10/20"`, as promised in the 0.12 release notes.
   This shouldn't affect most users.

 - The `wait_for_motion` visualisation has improved: It now highlights in
   red the parts of the screen where motion was detected, instead of
   flashing the entire screen red when motion was detected.

 - `wait_for_match` (and `detect_match`, `wait_for_motion`, etc.) raise
   `stbt.NoVideo` instead of `stbt.MatchTimeout` (etc.) when there is no
   video available from the video-capture device.

 - The GLib main loop, and the source-restarting functionality, operate
   continuously, not just inside `wait_for_match` (etc). User scripts
   that expect momentary video loss (e.g. scripts that reboot the
   system-under-test) can now be written as::

       wait_for_match("splash.png", timeout_secs=30)

   instead of::

       time.sleep(30)
       wait_for_match("splash.png")

 - `stbt record` now has the same recover-from-video-loss capability that
   `stbt run` has.

 - `stbt.get_config` works from scripts run with `python` (not just from
   scripts run with `stbt run`).

 - `stbt.get_config` accepts an optional `default` parameter, to return
   the specified default value instead of raising `ConfigurationError` if
   the specified `section` or `key` are not found in the config file.

Major changes under the covers (not visible to end users):

 - The image processing algorithms are implemented in `stbt.py` using the
   OpenCV python bindings. Performance isn't significantly affected. This
   simplifies the code substantially; the `stbt-templatematch` and
   `stbt-motiondetect` GStreamer elements are no longer necessary.

 - `make check` runs the self-tests in parallel if you have GNU
   `parallel` installed (On Fedora: yum install parallel).


0.13 Image-matching algorithm is more configurable; changes to configuration API
--------------------------------------------------------------------------------

21 May 2013.

Various parameters that affect the image-matching algorithm were
previously hard-coded but are now configurable by the user. You can
customise these parameters in individual calls to `wait_for_match`,
`detect_match`, and `press_for_match`, or you can change the global
defaults in your `stbt.conf` file. A new variant of the algorithm
(`confirm_method="normed-absdiff"`) has also been added, though the
default algorithm remains unchanged. For details see the documentation
for `MatchParameters` in the
`"test script format" <http://stb-tester.com/stbt.html#test-script-format>`_
section of the stbt(1)
man page. See also http://stb-tester.com/match-parameters.html

The `noise_threshold` parameter to `wait_for_match`, `detect_match`, and
`press_for_match` is now deprecated. It will be removed in a future
release. Set the `confirm_threshold` field of `match_parameters`
instead.

`stbt run` and `stbt record` now support multiple LIRC-based USB
infra-red emitters and/or receivers. For details see
http://stb-tester.com/multi-lirc.html

Breaking change to the `stbt.conf` configuration file: If you have any
of the following entries in the `[run]` or `[record]` section, move them
to the `[global]` section:

 - control
 - source_pipeline
 - sink_pipeline
 - verbose

If you have the following entry in the `[global]` section, move it to
the `[run]` section:

 - script

If you have the following entries in the `[global]` section, move them
to the `[record]` section:

 - output_file
 - control_recorder

This change is unlikely to affect most users; it will only affect you if
you changed the above configuration entries from their default sections.
See commit `9283df1f <https://github.com/drothlis/stb-tester/commit/9283df1f>`_
for the rationale of this change.

Breaking API change to the python `stbt.get_config` function: The
function signature has changed from:

    stbt.get_config(key, section="global")

to:

    stbt.get_config(section, key)

This will only affect users who have written python libraries or
command-line tools that use `stbt.get_config` to access the `stbt.conf`
configuration file. See commit
`e87299a1 <https://github.com/drothlis/stb-tester/commit/e87299a1>`_ for
details.

Breaking change to the `stbt config` command-line tool: The command-line
interface has changed from:

    stbt config [section] key

to:

    stbt config section.key

This will only affect users who have written command-line tools that use
`stbt config` to access the `stbt.conf` configuration file. See commit
`f1670cbc <https://github.com/drothlis/stb-tester/commit/f1670cbc>`_ for
details.


0.12 New command-line tools; new `stbt.get_config` function; `wait_for_motion` non-consecutive frames
-----------------------------------------------------------------------------------------------------

14 Mar 2013.

New command-line tools:

 * stbt config: Print configuration value.
 * stbt screenshot: Capture a single screenshot.
 * stbt templatematch: Compare two images.
 * stbt tv: View live video on screen.

Use `stbt <command> --help` for usage details, and see the git commit
messages (e.g. `git log stbt-screenshot`) for the motivations behind
each tool.

New python function `stbt.get_config` for stbt scripts to read from the
stbt configuration file, using the search path documented in the
"configuration" section of the stbt(1) man page.

To avoid false positives, `wait_for_motion` looks for
`consecutive_frames` (10, by default) consecutive frames with motion.
However, this can give false negatives, so the `consecutive_frames`
parameter can now take a fraction given as a string, e.g. "10/20" looks
for at least 10 frames with motion out of a sliding window of 20.
In a future release we will probably make "10/20" the default.


0.11 Support for RedRat irNetBox-II; improved robustness after video loss; improved exception output
----------------------------------------------------------------------------------------------------

27 Feb 2013.

The RedRat irNetBox is a rack-mountable network-controlled infrared
emitter. This release adds support for the irNetBox model II; previously
only model III was supported. Thanks to Emmett Kelly for the patch.

The first `wait_for_match` after restarting pipeline (due to video loss)
now obeys `timeout_secs`. Due to a bug, the total timeout in this
situation used to be the specified `timeout_secs` plus the time the
script had spent running so far (possibly many minutes!). See commit
`cf57a4c2 <https://github.com/drothlis/stb-tester/commit/cf57a4c2>`_ for
details.

Fixed bug observed with Blackmagic Intensity Pro video capture cards,
where restarting the pipeline (after momentary video loss) caused the
card to stop delivering timestamps in the video frames, causing `stbt
run` to hang. See commit
`53d5ecf3 <https://github.com/drothlis/stb-tester/commit/53d5ecf3>`_
for details.

`stbt run` now prints an exception's name & message, not just the stack
trace. Since version 0.10, `stbt` wasn't printing this information for
non-`MatchTimeout` exceptions.


0.10.1 Fix irNetBox connection retry
------------------------------------

14 Feb 2013.

Release 0.10 was supposed to fix the irNetBox connection retry on Linux,
but in fact broke it for everyone. This release fixes that, and also
adds static analysis to "make check" so that this type of error doesn't
happen again.


0.10 Fix irNetBox connection retry on Linux; other minor fixes
--------------------------------------------------------------

11 Feb 2013.

The irNetBox device only allows one TCP connection at a time, so when
multiple stbt tests are using the same irNetBox simultaneously, clashes
are inevitable. `stbt run` was supposed to retry refused connections,
but this was not working on Linux due to non-portable assumptions about
error numbers.

`stbt run` now saves a screenshot to disk for any exception with a
`screenshot` attribute, not just `stbt.MatchTimeout`.

The script generated by `stbt record` qualifies commands with `stbt.`
module, just to nudge people towards this best practice. In future we
might stop `stbt run` from implicitly importing `wait_for_match` etc.
into the top-level namespace, but for now the only change is to what
`stbt record` produces.

Other minor fixes:

 * Better build system error messages.
 * Minor fixes to the bash tab-completion script.


0.9 Support for RedRat irNetBox; `wait_for_motion` more tolerant to noise
-------------------------------------------------------------------------

7 Jan 2013.

The `RedRat irNetBox-III <http://www.redrat.co.uk/products/irnetbox.html>`_ is
a rack-mountable network-controlled infrared emitter with 16 separate outputs
and adjustable power levels to avoid infrared interference between the
systems-under-test. For further information see the `--control=irnetbox`
configuration in the
`stbt man page <http://stb-tester.com/stbt.html#global-options>`_,
and commit messages
`508941e <https://github.com/drothlis/stb-tester/commit/508941e>`_ and
`778d847 <https://github.com/drothlis/stb-tester/commit/778d847>`_.
Many thanks to Chris Dodge at RedRat for the donation of irNetBox hardware to
the stb-tester project and of his time in answering questions.

`wait_for_motion` now takes a
`noise_threshold <http://stb-tester.com/stbt.html#wait_for_motion>`_ parameter;
decrease `noise_threshold` to avoid false positives when dealing with noisy
analogue video sources.
Thanks to Emmett Kelly for the patch!

Other minor changes:

 * The remote control implementations of `stbt.press` (Lirc,
   VirtualRemote, irNetBox) try to re-connect if the connection (to
   lircd, to the set-top box, to the irNetBox, respectively) had been
   dropped.

 * Build/packaging fix: Always rebuild `stbt` (which reports the version
   with `stbt --version`) when the version changes.

 * Minor fixes to the tab-completion script, self-tests and
   documentation.


0.8 Bugfixes; `wait_for_match` returns the `MatchResult`; adds `get_frame`, `save_frame`, `debug`
-------------------------------------------------------------------------------------------------

21 Nov 2012.

`wait_for_match` and `press_until_match` now return the `MatchResult` object
for successful matches, and `wait_for_motion` returns the `MotionResult`. See
commit `540476ff <https://github.com/drothlis/stb-tester/commit/540476ff>`_ for
details.

New functions `get_frame` and `save_frame` allow capturing screenshots
at arbitrary points in the user's script. New function `debug` allows
user's scripts to print output only when stbt run "--verbose" was given.
Also documented the (existing) exception hierarchy in the README /
man-page.

Bugfixes:

 * Fixes a deadlock (introduced in 0.7) after GStreamer errors or video
   loss from the system under test.
 * Improves GStreamer pipeline restarting after transient video loss (see
   commit `2c434b2d
   <https://github.com/drothlis/stb-tester/commit/2c434b2d>`_ for details).
 * Fixes segfault in `stbt-motiondetect` GStreamer element when
   `debugDirectory` enabled with no mask.

Other minor changes:

 * The selftests now work correctly on OS X.
 * `make install` will rebuild `stbt` if given a different `prefix`
   directory than the `prefix` given to `make stbt`.


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
