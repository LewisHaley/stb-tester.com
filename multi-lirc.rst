<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>stb-tester: Using multiple LIRC infra-red transceivers</title>
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

<body id="multi-lirc">

<div id="header">
  <h1>Using multiple LIRC infra-red transceivers with stb-tester</h1>
  <p id="about">
    By Máté Szendrő
    and <a href="http://david.rothlis.net">David Röthlisberger</a>.
    Last updated @UPDATED@.
  </p>
</div>

<div id="content">

%(body)s

<!-- Begin reStructuredText content -->

To use multiple `LIRC`_ infra-red transmitters and/or receivers connected to
the same host:

1. Stop and disable the ``lirc`` service: [#lirc-service]_

   ::

     sudo systemctl stop lirc.service
     sudo systemctl disable lirc.service

2. Run multiple ``lircd`` instances, and set the TCP ports that each device
   listens on::

     sudo lircd --device=/dev/lirc0 \
         --pidfile=/var/run/lirc/lirc0.pid \
         --listen=8700 \
         --connect=localhost:8700 \
         --output=/var/run/lirc/lircd
     sudo lircd --device=/dev/lirc1 \
         --pidfile=/var/run/lirc/lirc1.pid \
         --listen=8701 \
         --connect=localhost:8701 \
         --output=/var/run/lirc/lircd

   ``/dev/lirc0`` and ``/dev/lirc1`` can now be addressed individually using
   the assigned TCP ports.

3. Test by sending a LIRC command string [#irsend]_ to the TCP port::

     echo "SEND_ONCE <remote name> <key name>" | \
     nc localhost 8700

   `<remote name>` and `<key name>` are names from your lirc configuration
   file in ``/etc/lirc/lircd.conf``.

   It's also possible to output infra-red signals via a LIRC device on a remote
   computer.

4. Specify the TCP port in the ``--control`` and ``--control-recorder``
   arguments to ``stbt run`` and ``stbt record`` (or ``control`` and
   ``control_recorder`` in `stbt.conf`_)::

     stbt record \
         --control-recorder=lirc:8700:<remote name> \
         --control=lirc:8701:<remote name>

   See `Options`_ in the stbt(1) man page for full details of the `--control`
   and `--control-recorder` arguments.


.. container:: footnotes

  .. [#lirc-service]
     Alternately, you could continue to use the system's default lirc service
     for ``/dev/lirc0`` (and use stbt's ``--control=lirc::<remote name>``), and
     use TCP-based controls for ``/dev/lirc1`` and any further devices.

  .. [#irsend]
     See the `irsend(1)`_ man page.


udev configuration
------------------

.. _assigns:

To auto-launch lircd when a new device is attached, add the following to
``/etc/udev/rules.d/20-lirc.rules`` [#udev]_::

  ACTION=="add", KERNEL=="lirc*", RUN+="/usr/bin/sh -c '/usr/sbin/lircd --device=/dev/$kernel --listen=$((8700 + $number)) --connect=localhost:$((8700 + $number)) --pidfile=/var/run/lirc/$kernel.pid 2>&1 | xargs -rL1 logger'"

It starts lircd listener on port (8700 + N) where 'N' is the device
number as in /dev/lircN. Errors are logged to /var/log/messages.

.. _removes:

To auto-kill lircd when a device is removed, add the following::

  ACTION=="remove", KERNEL=="lirc*", RUN+="/usr/bin/sh -c 'kill $(</var/run/lirc/$kernel.pid) 2>&1 | xargs -rL1 logger'"

Make sure not to break a rule to multiple lines.

To ensure that an emitter plugged into a particular USB port is always
assigned the same TCP port, even across reboots of the PC, perform the
following steps.

1. Connect the emitter to a selected USB port.

2. List activity log::

    sudo tail /var/log/messages

   Look for a message similar to the following::

    kernel: [261678.058509] rc32: RedRat3-II Infrared Remote Transceiver (112a:0005)
    as /devices/pci0000:00/0000:00:1d.7/usb2/2-1/2-1.7/2-1.7:1.0/rc/rc32

   This example uses a RedRat3-II_ infra-red emitter.

3. List the ``udev`` properties of the devce using the path of the device from
   the activity log::

    udevadm info -a -p \
        /devices/pci0000:00/0000:00:1d.7/usb2/2-1/2-1.7/2-1.7:1.0/rc/rc33

   Expect something like the following output::

    looking at device '/devices/pci0000:00/0000:00:1d.7/usb2/2-1/2-1.7/2-1.7:1.0/rc/rc33':
        KERNEL=="rc33"
        SUBSYSTEM=="rc"
        DRIVER==""
        ATTR{protocols}=="[rc-5] nec rc-6 jvc sony sanyo mce_kbd lirc"

    looking at parent device '/devices/pci0000:00/0000:00:1d.7/usb2/2-1/2-1.7/2-1.7:1.0':
        KERNELS=="2-1.7:1.0"
        SUBSYSTEMS=="usb"
        DRIVERS=="redrat3"
        ...

4. Assign a static port number to the emitter connected to that specific USB
   port. To identify the USB port, we are using the ``KERNELS`` parameter that
   matches the ``KERNEL`` parameter of the parent USB controller [#udev]_.

   Add the following to ``/etc/udev/rules.d/20-lirc.rules`` (and don't forget
   to remove the rule that assigns_ port numbers dynamically)::

    ACTION=="add", KERNEL=="lirc*", KERNELS=="2-1.7:1.0", RUN+="/usr/bin/sh -c '/usr/sbin/lircd --device=/dev/$kernel --listen=8700 --connect=localhost:8700 --pidfile=/var/run/lirc/$kernel.pid 2>&1 | xargs -rL1 logger'"

   This example always starts the listener on port 8700 if the emitter is
   plugged to USB port ``2-1.7:1.0``. Again, make sure not to break the rule
   to multiple lines.

   Repeat the steps to set up additional emitters. The rule that removes_
   devices stays the same.


(These instructions were tested with Fedora 17; details may vary for other
Linux distributions and other operating systems.)


.. container:: footnotes

  .. [#udev]
     See the `udev(7)`_ man page for parameter descriptions and the
     `udev(8)`_ man page for rules file format description.


.. _LIRC: http://www.lirc.org
.. _irsend(1): http://www.lirc.org/html/irsend.html
.. _stbt.conf: stbt.html#configuration
.. _Options: stbt.html#options
.. _RedRat3-II: http://www.redrat.co.uk/products/
.. _udev(7): http://linux.die.net/man/7/udev
.. _udev(8): http://linux.die.net/man/8/udev

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
