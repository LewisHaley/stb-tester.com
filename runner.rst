<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>stb-tester/extra/runner: Scripts for bulk test running & reporting</title>
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

<body id="runner">

<div id="header">
  <h1>stb-tester/extra/runner: Scripts for bulk test running & reporting</h1>
  <p id="about">
    By <a href="http://david.rothlis.net">David Röthlisberger</a>.
    Last updated @UPDATED@.
  </p>
  <a href="http://stb-tester.com" id="back">[Back to stb-tester.com]</a>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

`extra/runner`_ in the stb-tester source repository contains a shell script
that will run a set of test scripts with ``stbt run``, automatically triage
known failure reasons, and generate an html report.

.. image:: runner-report.png
   :target: runner_example/index.html

The above report shows the result of running a simple stb-tester test script
that uses GStreamer's ``videotestsrc`` as the video input. The first time the
test was run (the red row in the report) it failed due to a bug in the test.
The next run passed because the test had been fixed (note the change in the
"commit" column, showing the revision of the test). The last run failed because
the user interrupted it with Control-C.

Features:

 * Clicking on a row shows detailed logs for that test run.
 * The up/down arrow keys select the previous/next test run.
 * A screenshot is taken if the test failed.
 * A video of each test run is captured. The video's format is HTML5 compatible,
   so it is playable in most modern browsers (it doesn't work in Safari but
   Firefox, Chrome and VLC all play it).
 * The runner script detects why the test failed and logs this failure reason
   in the "exit status" column of the report. If the runner can be *sure* that
   the failure wasn't caused by a defect in the system under test, the row is
   coloured yellow instead of red.
 * Users can provide their own custom classification scripts via hooks specified
   in the stbt configuration file.
 * Running the optional ``server`` script allows interactive manual editing of
   the "failure reason" and "notes" fields. This isn't enabled in the example
   report above.

For details see the README file under `extra/runner`_ in the stb-tester source
repository. These scripts aren't installed by ``make install`` or by the
stb-tester `Fedora packages`_; for now they are only available from the source
repository.


.. _extra/runner: https://github.com/drothlis/stb-tester/tree/master/extra/runner
.. _Fedora packages: http://stb-tester.com/getting-started.html#install-stb-tester-from-pre-built-packages

<!-- End reStructuredText content -->

</div>

<div id="footer">
<p>
  This article copyright © 2013 <a href="http://david.rothlis.net">David
  Röthlisberger</a>.
  <br />
  Licensed under a <a rel="license"
  href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons
  Attribution-ShareAlike 3.0 Unported license</a>.
</p>
</div>

</body>
</html>
