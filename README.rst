.. meta::
   :description: Capture ACARS and VDL messages using an SDR and Docker.
   :keywords: ACARS, VDL, Raspberry Pi, SDR, Docker
   :locale: en_US
   :author: Michael Johnson
   :robots: index

=======================================================
Capture ACARS and VDL messages using an SDR and Docker.
=======================================================

.. contents::
   :depth: 2

Introduction
************

This is a project to capture `Aircraft Communications Addressing and Reporting
System (ACARS) <https://en.wikipedia.org/wiki/ACARS>`_ and `VHF Data Link (VDL) <https://en.wikipedia.org/wiki/VHF_Data_Link>`_ messages using a Software
Defined Radio (SDR) on a Raspberry Pi 4 using Docker containers and Docker
Compose.

The ACARS messages are captured and decoded using the `acarsdec
<https://github.com/TLeconte/acarsdec>`_ project.

VDL message capture and decoding is using the `vdlm2dec <https://github.com/TLeconte/vdlm2dec>`_ project.

Each process will be compiled and a container will be created for each.

Hardware
********

This project has been built and tested using the following equipment:

* `Raspberry Pi 4 model B <https://www.raspberrypi.org/products/raspberry-pi-4-model-b/>`_
* `CanaKit setup for the Raspberry Pi 4 <https://www.canakit.com/raspberry-pi-4-starter-kit.html>`_ (Note: Some of these kits include the Raspberry Pi 4 model B board)

 * Heatsinks
 * Fan
 * Power supply
 * Case

* An rtl-SDR for ACARS including an antenna
* An rtl-SDR for VDL including an antenna
* 32GB or larger "high endurance" microSD card

For the rtl-SDR devices, I used the `nooelec Nano 3 bundle <https://www.nooelec.com/store/sdr/sdr-bundles/other-sdr-bundles/stratux-bundle-nano-3.html>`_ as I 
had an extra one from my ADSB setup. It does not include the proper antenna
for ACARS or VDL, but will work (with a shorter range). Other Software Defined
Radios should work fine as long as they are rtl-SDR style.

Building the Containers
***********************

.. note::

  The included Dockerfiles are configured to build code optimized for the
  Raspberry Pi 4 board. If you are using a different version of the Raspbeery
  Pi, you may need to adjust or override the CFLAG settings being used.

Both the acarsdec and vdlm2dec directories contain a "build-me.sh" script and
the required Dockerfile. All of the images and code required will be downloaded
during the build process. Some components, such as the base image, will be
shared between the two containers.

You will need to edit the Dockerfile for each, replacing the "<VDL SDR ID/serial>" and "<ACARS SDR ID/serial>" with the radio ID or serial number of each
radio.

Running the Containers
**********************

To run the acarsdec container to test it out, you can run:

.. code-block:: bash

   docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb johnsom/acarsdec-docker:0.01

To run the vdlm2dec container to test it out, you can run:

.. code-block:: bash

   docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb johnsom/vdlm2dec-docker:0.01

Running with Docker Compose and Feeding AIRFRAMES
*************************************************

Disclaimers
***********

* Raspberry Pi is a trademark of the Raspberry Pi Foundation
* CanaKit is a registered trademark of CanaKit Corporation
* Nooelec is a registered trademark of Nooelec Inc.
* I did not get compensation from any of these companies for this project.
* This document comes without any warranty of any kind.
* Not intended for safety of life applications.
* The code provided in this repository is licensed under the GNU General
  Public License v3.0. See the included LICENSE for terms.
* This document is Copyright 2020 Michael Johnson
* This document is licensed under the Creative Commons Attribution-ShareAlike
  4.0 International Public License

.. raw:: html

   <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Text" property="dct:title" rel="dct:type">Capture ACARS and VDL messages using an SDR and Docker</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="https://github.com/johnsom" property="cc:attributionName" rel="cc:attributionURL">Michael Johnson</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
