<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>stb-tester example script: Double carousel navigation</title>
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

<body id="find-player">

<div id="header">
  <h1>stb-tester example script: Double carousel navigation</h1>
  <p id="about">
    By <a href="http://david.rothlis.net">David Röthlisberger</a>.
    Last updated @UPDATED@.
  </p>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

The following `stb-tester`_ automated script knows how to navigate a set-top
box's double-carousel menu like a human user would: By identifying the current
selection and the target location, then pressing the appropriate keys to
navigate directly to the target.

This script navigates to the BBC iPlayer, then to the 4oD and Demand5 players:

.. container::

  .. raw:: html

    highlight:: from players import find_player
    highlight:: 
    highlight:: find_player("images/iPlayer-selected.png",
    highlight::             "images/iPlayer-unselected.png")
    highlight:: find_player("images/4oD-selected.png",
    highlight::             "images/4oD-unselected.png")
    highlight:: find_player("images/Demand5-selected.png",
    highlight::             "images/Demand5-unselected.png")

``find_player`` uses the *unselected* image to find the player's location on
the screen, and the *selected* image to know that it has reached the player.
Watch it in action:

.. raw:: html

    <iframe
    src="http://player.vimeo.com/video/53212708?title=0&byline=0&portrait=0"
    width="640" height="360" frameborder="0"
    webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

The implementation of ``find_player`` follows, with error-handling and support
for multiple pages removed for simplicity (or see the `full implementation`_).

.. container:: players-py

  .. raw:: html

    highlight:: import time
    highlight:: import stbt
    highlight:: 
    highlight:: def find_player(selected_image, unselected_image):
    highlight::     """Navigates to the specified player.
    highlight:: 
    highlight::     Precondition: In the OnDemand Players screen.
    highlight:: 
    highlight::     Uses `unselected_image` to find where the player is on screen;
    highlight::     navigates there;
    highlight::     uses `selected_image` to know that it has reached the player.
    highlight::     """
    highlight:: 
    highlight::     while not _player_selected(selected_image):
    highlight::         target = stbt.detect_match(unselected_image).next()
    highlight::         source = _matches("images/any-player-selected.png").next()
    highlight::         stbt.press(_next_key(source.position, target.position))
    highlight::         _wait_for_selection_to_move(source)
    highlight:: 
    highlight:: def _player_selected(image):
    highlight::     return stbt.detect_match(image).next().match
    highlight:: 
    highlight:: def _wait_for_selection_to_move(source):
    highlight::     for m in _matches("images/any-player-selected.png"):
    highlight::         if m.position != source.position:
    highlight::             break
    highlight::     # Wait for animation to end, so match position is stable
    highlight::     stbt.wait_for_match("images/any-player-selected.png",
    highlight::                         consecutive_matches=2)
    highlight:: 
    highlight:: def _matches(image):
    highlight::     """Like detect_match, but only yields matching results."""
    highlight::     for result in stbt.detect_match(image):
    highlight::         if result.match:
    highlight::             yield result
    highlight:: 
    highlight:: def _next_key(source, target):
    highlight::     """Returns the key to press to get closer to the target position."""
    highlight::     if _less(target.x, source.x):
    highlight::         return "CURSOR_LEFT"
    highlight::     if _less(source.y, target.y):
    highlight::         return "CURSOR_DOWN"
    highlight::     if _less(target.y, source.y):
    highlight::         return "CURSOR_UP"
    highlight::     if _less(source.x, target.x):
    highlight::         return "CURSOR_RIGHT"
    highlight:: 
    highlight:: def _less(a, b, tolerance=20):
    highlight::     """An implementation of '<' with a tolerance of what is considered equal."""
    highlight::     return a < (b - tolerance)


.. _stb-tester: http://stb-tester.com
.. _full implementation: players.py

<!-- End reStructuredText content -->

</div>

<div id="footer">
<p>
  This article copyright © 2012 <a href="http://david.rothlis.net">David
  Röthlisberger</a>.<br />
  The names and logos of BBC iPlayer, ITV Player, 4oD, Demand 5, NOW TV,
  and Milkshake! are trademarks of their respective owners.<br />
  Source code in this article is placed in the <a
  href="http://creativecommons.org/publicdomain/mark/1.0/">public domain</a>
  (if you live somewhere with totally braindead copyright laws, you can use the
  <a href="http://opensource.org/licenses/ISC">ISC</a> or <a
  href="http://creativecommons.org/publicdomain/zero/1.0">CC0</a> licenses,
  both of which are as close to the public domain as possible.)
</p>
</div>

</body>
</html>
