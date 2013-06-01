<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Using the Unix Shell to run stb-tester scripts</title>
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

<body id="shell">

<div id="header">
  <h1>Using the Unix Shell to run stb-tester scripts</h1>
  <p id="about">
    By <a href="http://david.rothlis.net">David Röthlisberger</a>.
    Last updated @UPDATED@.
  </p>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

This article will teach you the bare minimum you need to know about the Unix
**shell** in order to use `stb-tester`_ effectively.

This assumes that your shell is **bash**, which is the default login shell on
most Linux systems and on OS X, but most of these concepts are the same in any
`POSIX`_ shell.


The ``STBT_CONFIG_FILE`` environment variable
---------------------------------------------

Before we begin, create a ``stbt`` configuration file with the correct
``source_pipeline``, ``sink_pipeline``, and ``control``. (If you're not sure
what these are, read `Getting started with stb-tester`_.)

In a terminal, set the environment variable ``STBT_CONFIG_FILE`` to the path of
the configuration file you just created::

  $ STBT_CONFIG_FILE=~/system-under-test-1.conf

To print the value of this variable::

  $ echo $STBT_CONFIG_FILE
  ~/system-under-test-1.conf

This variable is only visible to the current shell process. I'll prove it::

  $ bash -c 'echo .$STBT_CONFIG_FILE.'
  ..

To make the variable visible to sub-processes (like ``stbt``) you have to
*export* it::

  $ export STBT_CONFIG_FILE
  $ bash -c 'echo $STBT_CONFIG_FILE'
  ~/system-under-test-1.conf

You can set and export the variable all in one go::

  $ export STBT_CONFIG_FILE=~/system-under-test-1.conf

If you set the variable on the same line as a command, it only takes effect for
that command::

  $ STBT_CONFIG_FILE=~/system-under-test-2.conf stbt run my-test.py

After the above ``stbt run`` command finishes, ``STBT_CONFIG_FILE`` is back
to its original value.

If you only want to test one device, you can put your configuration file in
``~/.config/stbt/stbt.conf``, and you don't need to set ``STBT_CONFIG_FILE``.
But if you want to test multiple devices connected to the same PC (via multiple
video-capture cards) then the easiest way to manage is with a separate
configuration file for each device, and set ``STBT_CONFIG_FILE`` to the one you
want to test.


Redirecting standard output and standard error
----------------------------------------------

The debug output from ``stbt run --verbose`` goes to the *standard error*
("stderr") output stream. Any ``print`` statements in your python script go to
the *standard output* ("stdout") stream. By default, both stderr and stdout are
printed to the terminal screen, but you can redirect the two streams
separately::

  $ stbt run my-test.py > my-stdout-log 2> my-stderr-log

The above command sends all stdout output to the file ``my-stdout-log``
(instead of to the screen), and all stderr output to the file ``my-stderr-log``
(instead of to the screen).

You can redirect both stdout and stderr to the same file::

  $ stbt run my-test.py > my-log 2>&1

``2>&1`` means "redirect stderr to wherever stdout is going".

Using ``>>`` instead of ``>`` (or ``2>>`` instead of ``2>``) *appends* to the
file instead of overwriting it.

The *pipe* operator "``|``" connects the stdout of one command to the *standard
input* (stdin) of another command. For example, the ``tee`` command prints
everything it reads from its stdin to its stdout *and* to a specified file::

  $ stbt run my-test.py 2> my-stderr-log | tee my-stdout.log

It's `possible <http://stackoverflow.com/questions/9112979/>`_ to pipe stdout
and stderr separately to different commands, but it isn't easy.

Note that a program can print any type of output to stderr, not just *error*
messages.


Process exit status
-------------------

Each command you run from the shell will return an **exit status**. You can
experiment with ``true`` (a program that does nothing and reports success)
and ``false`` (a program that does nothing and reports failure)::

  $ true
  $ echo $?
  0
  $ false
  $ echo $?
  1

Note that ``$?`` holds the exits status of the last command. "0" is considered
success, and any other number is considered failure.

The ``&&`` (boolean "and") and ``||`` (boolean "or") operators act on the
previous command's exit status::

  $ true && echo hi
  hi
  $ false && echo hi
  $ true || echo hi
  $ false || echo hi
  hi

A **list** of commands is a sequence separated by ``&&``, ``||``, or ``;``. For
example::

  $ date; stbt run my-test.py && echo OK || echo FAIL; date
  Tue 28 May 2013 10:55:21 BST
  OK
  Tue 28 May 2013 10:56:02 BST

Note that ``stbt run`` returns a "failure" (non-zero) exit status if the python
test script raises an exception (for example, ``wait_for_match`` raises an
exception if it doesn't find a match).

A "list of commands" can also mean a single command (think of it as a list
containing a single element).

A list's exit status is the exit status of the last command in the list that
was actually run (if the list contains ``&&`` or ``||``, some commands might
not be run).

``while`` loops
---------------

The ``while`` command can be used to run a list of commands *as long as*
another list of commands succeeds::

  $ while stbt run my-test.py; do
  >   echo "mytest.py: OK"
  > done

The above will run the `stbt run`` command; if it succeeds, it will run the
``echo`` command; then it will try the ``stbt run`` command again, and so on
until it fails.

``for`` loops
-------------

You can use a ``for`` loop to run multiple different tests in order::

  $ for t in my-test.py my-other-test.py another-test.py; do
  >   echo $t
  >   stbt run $t > $t.log 2>&1 &&
  >     echo "OK" || echo "FAILED"
  > done

This will run the body of the loop 3 times, with ``t`` set to "my-test.py" the
first time, "my-other-test.py" the second time, and "another-test.py" the third
time.

You can use the shell's `filename expansion`_ to provide the loop's values. For
example, this runs all the tests ending in ".py" in the current directory::

  $ for t in *.py; do
  >   stbt run $t
  > done

Bringing it all together
------------------------

The following command will run a list of tests over and over until one of them
fails. The stdout output of each test is printed to the screen (so you can
monitor progress), whereas the stderr is saved to a log file. Each test run
overwrites the log file, so you only end up with the stderr output for the test
that *failed*.

::

  $ while true; do
  >   for t in *.py; do
  >     stbt run $t 2>stderr.log || break 2
  >   done
  > done



.. _stb-tester: http://stb-tester.com
.. _POSIX: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
.. _Getting started with stb-tester: getting-started.html
.. _filename expansion: http://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html

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
