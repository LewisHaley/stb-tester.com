<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>stb-tester image matching parameters</title>
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

<body id="templatematch">

<div id="header">
  <h1>stb-tester image matching parameters</h1>
  <p id="about">
    By <a href="http://lewishaley.co.uk">Lewis Haley</a>.
    Last updated @UPDATED@.
  </p>
  <a href="http://stb-tester.com" id="back">[Back to stb-tester.com]</a>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

Since **stb-tester** 0.13, the previously hard-coded parameters for stbt's
image processing algorithm have been exposed to allow the user to customise
them either via a global configuration or on a per-match basis (see the
documentation for `wait_for_match <stbt.html#wait_for_match>`_ and
`MatchParameters <stbt.html#MatchParameters>`_). This article
will attempt to explain the effects of the various parameters and why you might
want to change them.

.. image:: match-parameters-graphic.png

To see the intermediate steps of the template matching process, you can run
stbt in "extra verbose" mode which will save out copies of the intermediate
images. To do this, use ``stbt run -vv`` or ``stbt templatematch -v``. This
will create a directory called **stbt-debug**, which in turn contains
**detect_match** and **detect_motion** directories. The contents of
**stbt-debug/templatematch** will be the most recent match performed,
regardless of success or failure (so make copies of the images if you don't
want to lose them!).

.. container:: clear

   .. figure:: match-parameters-true-source.png

      source.png

   .. figure:: match-parameters-template.png

      template.png

   For demonstration, we shall be searching for this **template** image
   within this **source** image. Below we'll show the debug images created
   as a result of running the following command:

.. container:: clear

    ::

       stbt templatematch -v source.png template.png

.. container:: clear

   .. figure:: match-parameters-true-source_matchtemplate.png

      source_matchtemplate.png

   **source_matchtemplate.png** is the result of running OpenCV's
   ``matchTemplate`` function with the template and source images as inputs.
   Each pixel it contains indicates the relative strength-of-match of the
   template against the source image at that pixel's given position, where
   the pixel's coordinates are the coordinates of the template's top left
   corner on the source image. Using ``match_method="sqdiff-normed"``
   (the default) will give an image where the best match is represented by
   the darkest pixel; for ``"ccorr-normed"`` and ``"ccoeff-normed"``, the
   brightest pixel is the best match. The value of the best matching pixel
   must be greater than the ``match_threshold`` value for the matching
   process to proceed further. By default this is ``0.8``. Note that if
   ``match_method="sqdiff-normed"``, then the best value is ``1 -
   <pixel_value>``. As such, the greater the ``match_threshold``, the greater
   certainty we have of the match at that location. Note that, in practice, a
   perfect match of ``1.0`` is never found because of how the ``matchTemplate``
   function works.

.. container:: clear

   .. figure:: match-parameters-true-source_roi.png

      source_roi.png

   .. figure:: match-parameters-true-source_roi_gray.png

      source_roi_gray.png

   .. figure:: match-parameters-template_gray.png

      template_gray.png

   Although the previous step gives us a *fairly* good idea of whether we
   have found a match, it is not 100% reliable because sometimes it can
   report a strong match value between a template and source which *should
   not* match. Because of this, we do a second "confirmation" match of the
   template, but this time only against the area of the image which the
   previous step thinks is where the match is located. This is called the
   *region of interest*, or *ROI*. This second pass uses grayscaled
   versions of the template and source-roi images. Note that these and all
   subsequent images are only created if the match gets through the first
   pass.

.. container:: clear

   .. figure:: match-parameters-true-absdiff.png

      asbdiff.png

   A match between the grayscaled template and source-roi is determined by
   calculating the *absolute difference* between their corresponding pixels.
   In the resultant image, the brighter the pixel, the greater the difference
   between the template and source at that point. There are 3
   ``confirm_methods``: ``"none"``, ``"absdiff"`` and ``"normed-absdiff"``.
   ``"absdiff"`` is default. ``"none"`` means, don't perform the confirmation
   step, just return a positive match result. An example of using
   ``"normed-absdiff"`` is given later in this article.

.. container:: clear

   .. figure:: match-parameters-true-absdiff_threshold.png

      absdiff_threshold.png

   The "absdiff" image is thresholded, which means that all pixels below a
   certain value become black, and the rest become white. The
   ``confirm_threshold`` parameter controls the dividing point for the
   threshold operation. A smaller value means there is less leniency for
   difference (e.g. noise, gamma variation, antialiased text) whilst a
   greater value means that more difference is ignored. A value of 1.0 will
   return a positive match everytime.

.. container:: clear

   .. figure:: match-parameters-true-absdiff_threshold_erode.png

      absdiff_threshold_erode.png

   At the very end of the matching process, we analyse the resulting black
   and white binary image for any white pixels. If we find *any* white
   pixels, then a negative match is reported. Before this though, we perform
   an erode pass over the image. This removes the outer layer of white pixels
   from any area of the image where there is a white pixel. (Imagine a 3x3
   square of white pixels. The erode pass removes the outer layer, leaving
   the one remaining central white pixel.) The ``erode_passes`` parameter
   controls the number of times the erode pass is performed. By default, this
   value is 1 to account for incidental noise that is often present. Note
   that increasing the number of ``erode_passes`` is a lot more destructive
   than increasing the ``confirm_threshold``. Ideally this value should be
   zero. Note that this example matches well enough that there are no white
   pixels remaining to be eroded; please see the next examples.


False positives
---------------

.. container:: clear

   .. figure:: match-parameters-false-source.png

      source.png

   .. figure:: match-parameters-template.png

      template.png

   Here are the debug images from a different source where we expect *no
   match*, but where we in fact get a *false positive match*.

.. container:: clear

   .. figure:: match-parameters-false-source_matchtemplate.png

      source_matchtemplate.png

   The darkest spot in **source_matchtemplate.png** indicates a likely match
   in the center-left area of the source image. Note that the
   ``first_pass_result`` (see the documentation for `MatchResult
   <stbt.html#MatchResult>`_) is 0.83 for this match, which is just above the
   default ``match_threshold`` of 0.80, whereas the previous example gave a
   strong ``first_pass_result`` of 0.95.

.. container:: clear

   .. figure:: match-parameters-false-source_roi.png

      source_roi.png

   .. figure:: match-parameters-false-source_roi_gray.png

      source_roi_gray.png

   .. figure:: match-parameters-template_gray.png

      template_gray.png

.. container:: clear

   .. figure:: match-parameters-false-absdiff.png

      absdiff.png

   The absolute difference indicates there is a fair amount of difference
   between template and source, but...

.. container:: clear

   .. figure:: match-parameters-false-absdiff_threshold.png

      absdiff_threshold.png

   ...once thresholded we see that none of the pixels exceeded the
   ``confirm_threshold`` value...

.. container:: clear

   .. figure:: match-parameters-false-absdiff_threshold_erode.png

      absdiff_threshold_erode.png

   ...and once again, despite the obvious difference between template and
   source to the human eye, the erode step has nothing to do, and this match
   goes on to return a (false) positive result.

The "normed-absdiff" confirm method
-----------------------------------

Here is the same match, but this time running the command as::

    stbt templatematch -v source.png template.png \
        confirm_method=normed-absdiff

.. container:: clear

   .. figure:: match-parameters-normed-absdiff-source_roi_gray_normalized.png

      source_roi_gray_normalized.png

   .. figure:: match-parameters-normed-absdiff-template_gray_normalized.png

      template_gray_normalized.png

   When using "normed-absdiff", the template and the
   source image are normalized prior to the absolute difference being
   calculated. This helps to exaggerate differences when the template and
   source images have small, similar ranges of pixel brightness, as the
   ranges are transformed to occupy the maximum range of [0..255].

.. container:: clear

   .. figure:: match-parameters-normed-absdiff-absdiff.png

      absdiff.png

   This time, we see a significant amount of difference arise from the
   absolute difference operation...

.. container:: clear

   .. figure:: match-parameters-normed-absdiff-absdiff_threshold.png

      absdiff_threshold.png

   ... and after being thresholded, there *are* pixels which exceeded the
   ``confirm_threshold`` value, and so there are white artifacts remaining...

.. container:: clear

   .. figure:: match-parameters-normed-absdiff-absdiff_threshold_erode.png

      absdiff_threshold_erode.png

   ... which even after being eroded, persist, meaning that the result is
   accurately reported as a negative match.

<!-- End reStructuredText content -->

</div>

<div id="footer">
<p>
  This article copyright © 2013 <a href="http://www.youview.com">YouView TV
  Ltd</a>.<br />
  Licensed under a <a rel="license"
  href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons
  Attribution-ShareAlike 3.0 Unported license</a>.
</p>
</div>

</body>
</html>
