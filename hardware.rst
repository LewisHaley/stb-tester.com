<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Video-capture hardware used with stb-tester</title>
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

<body id="hardware">

<div id="header">
  <h1>Video-capture hardware</h1>
  <p id="about">
    By <a href="http://david.rothlis.net">David Röthlisberger</a>.
    Last updated @UPDATED@.
  </p>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

Experience reports of video-capture hardware used with `stb-tester`_. (If you
have worked with hardware not on this list, please `send me`_ details and I
will add it to this list with due credit.)

Hauppauge HD PVR
----------------

The `Hauppauge HD PVR`_ is an inexpensive external video-capture device. It
takes component video, and hardware-encodes into H.264 MPEG-TS delivered to the
PC over USB. The HD PVR has an open-source driver (not written by Hauppauge)
already present in recent versions of the Linux kernel.

For an example `source-pipeline` to use with `stbt`, see the stb-tester
`Getting started`_ article.

Note that the HD PVR is being discontinued by Hauppauge in favour of the
`HD PVR 2`_ which does *not* have a Linux driver, but the original HD PVR can
still be purchased in bulk orders direct from the manufacturer.

The HD PVR works well as the capture device for a developer writing tests with
`stbt record`. But for *running* tests continuously in an automated test rig,
it is quite unreliable: After a while it locks up and stops providing video,
with the message "libv4l2: error getting pixformat: Bad address".

I have been told that in this scenario (recording for short amounts of time,
with frequent starting & stopping) the HD PVR is unreliable on Windows too,
which implies a problem in the hardware or firmware, rather than the Linux
driver software.

We tried all sorts of experiments: Adding a better heatsink to the H.264
encoder chip; adding a heatsink to the A/D chip; different kernel versions;
multiple HD PVRs connected to a single PC versus a single one. The only
significant improvement we found was from removing the lid and `adding fans`_
directly over the circuit board, but this doesn't cure the problem completely,
it only increases the time-to-failure. We've measured the surface temperature
of the encoder chip's heatsink, and of the A/D chip, and neither one was ever
observed to exceed 40°C (with the fan); but the HD PVR still fails.

Our measurements:

=================  ===========  ===========  ============  ===========  ==========  ===========  ===========
Time-to-failure in hours: Average (StdDev) /Samples                     Simultaneous HDPVRs
----------------------------------------------------------------------  ------------------------------------
PC                 Fan          No fan       Kernel 3.6.6  <3.6         1           2            3
=================  ===========  ===========  ============  ===========  ==========  ===========  ===========
dev1                            14 (10) /9   12 (8) /4     16 (13) /5               14 (10) /9
dev2                            15 (13) /9   8 (8) /4      22 (15) /5   16 (14) /9
stb-tester-slave1  33 (43) /10  12 (8) /12   20 (26) /5    22 (33) /17  9 (4) /5    4 (1) /2     28 (36) /15
stb-tester-slave2               20 (18) /20  25 (14) /4    19 (21) /16  18 (13) /7  22 (23) /13
stb-tester-slave5               37 (36) /12  42 (24) /2    36 (39) /10  21 (24) /5  50 (41) /7
=================  ===========  ===========  ============  ===========  ==========  ===========  ===========

* All tests were run using `gst-launch-start-stop.sh`_.
* "Failure" means a permanent lock-up; I ignored transient failures where the
  HDPVR continued working after stopping & re-starting recording.
* The runs with 3 simultaneous HDPVRs tended to also be the runs with fans,
  which could explain the longer running times. Of the 3 HDPVRs, the first to
  fail was usually one of the 2 on the same USB controller. Note that we did
  observe failures with the fan and a single HDPVR per PC.


Blackmagic Intensity Pro
------------------------

The `Blackmagic Intensity Pro`_ is an inexpensive PCIe video-capture card. It
takes HDMI (non HDCP), component, composite, or S-Video and delivers raw video.
The Intensity Pro has a (closed source) Linux driver. Note that the external
USB models like the Intensity Shuttle do *not* have a Linux driver.

The Intensity Pro is much more stable than the HD PVR, but does occasionally
suffer from lockups that crash the entire PC — a reboot is required to recover.
Anecdotally, using two cards simultaneously on a single PC increases the crash
rate significantly. We are gathering more data.


BT878
-----

I know of one organisation successfully using `BT878`_ analogue video decoders
with stb-tester (though they say they haven't stressed this card as much as we
have the HD PVR). The signal is a bit noisy but this can be overcome by
tweaking stb-tester's `image-matching parameters`_.


Software capture
----------------

This is the very opposite of video-capture *hardware*, but I'll mention it here
anyway. If you can install GStreamer on your system-under-test, you can write a
GStreamer element to grab video directly from the framebuffer and stream it to
a GStreamer network source on the test-runner PC.

For an example see the `DirectFB surface source`_ element.


.. _stb-tester: http://stb-tester.com
.. _send me: mailto:david@rothlis.net
.. _Hauppauge HD PVR: http://www.hauppauge.com/site/products/data_hdpvr.html
.. _HD PVR 2: http://www.hauppauge.com/site/products/data_hdpvr2-gaming.html
.. _Getting started: http://stb-tester.com/getting-started.html#using-a-real-video-source
.. _adding fans: hdpvr-fan.jpg
.. _gst-launch-start-stop.sh: https://github.com/drothlis/hdpvr-stability-tests
.. _Blackmagic Intensity Pro: http://www.blackmagicdesign.com/products/intensity/
.. _BT878: http://www.linuxtv.org/wiki/index.php/Brooktree_Bt878
.. _image-matching parameters: http://stb-tester.com/match-parameters.html
.. _DirectFB surface source: https://bugzilla.gnome.org/show_bug.cgi?id=685877


<!-- End reStructuredText content -->

</div>

<div id="footer">
<p>
  This article copyright © 2012 <a href="http://www.youview.com">YouView TV
  Ltd</a>.<br />
  Licensed under a <a rel="license"
  href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons
  Attribution-ShareAlike 3.0 Unported license</a>.
</p>
</div>

</body>
</html>
