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

Both processes use `libacars <https://github.com/szpajder/libacars>`_ for
message decoding and `librtlsdr <http://git.osmocom.org/rtl-sdr>`_ for
connecting to the SDR.

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

Both the acarsdec and vdlm2dec directories contain a "build-me.sh" script and
the required Dockerfile. All of the images and code required will be downloaded
during the build process. Some components, such as the base image, will be
shared between the two containers.

You will need to edit the Dockerfile for each, replacing the "<VDL SDR ID/serial>" and "<ACARS SDR ID/serial>" with the radio ID or serial number of each
radio.

Note: The included Dockerfiles are configured to build code optimized for the
Raspberry Pi 4 board. If you are using a different version of the Raspberry
Pi, you may need to adjust or override the CFLAG settings being used.
For example, to build for a Raspberry Pi 3, you would add the --build-arg
option.

.. code-block:: bash

  docker build --build-arg CFLAGS="-mcpu=cortex-a53+crypto -mtune=cortex-a53" -t johnsom/acarsdec-docker:0.01 .

Rebuilding the Container Images
*******************************

You may want to rebuild the container images from scratch to pull in new
versions of the software used in the containers. You can do this by adding the
"--no-cache" argument to the "docker build" command:

.. code-block:: bash

  docker build --no-cache -t johnsom/acarsdec-docker:0.01 .

Optionally, if you know it is just a specific package that needs to update,
you can trigger a rebuild from that point in the Dockerfile by adding an
'ARG BUILD="here"' line temporarily above it and running the build command
again.

Running the Containers
**********************

The containers are setup to simply output received messages to the console.
They are also configured for frequencies in the USA. You may need to change
the frequencies the SDRs are listening on for your region. See the
`AIRFRAMES website <https://app.airframes.io/about>`_ for information on
the appropriate frequencies for your area. Each can handle up to eight
frequencies as long as they are within the same 2Mhz range.

To run the acarsdec container to test it out, you can run:

.. code-block:: bash

   docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb johnsom/acarsdec-docker:0.01

To run the vdlm2dec container to test it out, you can run:

.. code-block:: bash

   docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb johnsom/vdlm2dec-docker:0.01

Running with Docker Compose and Feeding AIRFRAMES
*************************************************

When you are ready to start feeding `AIRFRAMES <https://app.airframes.io/>`_
you can use the included docker-compose.yml file to have Docker Compose manage
running both containers.

Edit the docker-compose.yml file to configure your station identifier by
replacing the "<your ACARS ID here>" and "<your VDL ID here>" fields. Each
process should have a unique name, preferably by using the
`AIRFRAMES guidance <https://app.airframes.io/about>`_. Next, configure each
container to point to the appropriate SDR by replacing the
"<VDL SDR ID/serial>" and "<ACARS SDR ID/serial>" with the radio ID or serial
number of each radio.
You may need to adjust the frequencies here as you did above for the individual
containers.

The docker-compose file is already configured to start feeding
`AIRFRAMES <https://app.airframes.io/>`_.

Starting the Containers with the Console Attached
-------------------------------------------------

From the directory that contains the docker-compose.yml file:

.. code-block:: bash

  docker-compose up

Control-C can be used to exit the console.

Starting the Containers with the Console Detached
-------------------------------------------------

From the directory that contains the docker-compose.yml file:

.. code-block:: bash

  docker-compose up -d

This will also setup the containers to restart on a host reboot.

While the containers are running in detached (background) mode, you can see
the console output by running the docker-compose logs command:

.. code-block:: bash

  docker-compose logs -f

The "-f" option tells the command to follow the updates and output new lines.

Control-C can be used to exit follow mode.

Stopping the Containers
-----------------------

From the directory that contains the docker-compose.yml file:

.. code-block:: bash

  docker-compose down

Validating Your Feeder
**********************

Once your feeder is up and running, you can visit the `AIRFRAMES stations <https://app.airframes.io/stations>`_ page to see how many messages have been
received from each of your processes.
Note: You might not receive any messages right away.

Troubleshooting
***************

If you need to get inside one of the containers, you can run the following
commands:

.. code-block:: bash

  docker ps
  docker exec -it <container_id_or_name> bash

The "docker ps" command will list the containers running on your host.
The "docker exec" command will launch a bash shell inside the container.

References
**********

* `acarsdec <https://github.com/TLeconte/acarsdec>`_
* `AIRFRAMES <https://app.airframes.io/about>`_
* `libacars <https://github.com/szpajder/libacars>`_
* `librtlsdr <http://git.osmocom.org/rtl-sdr>`_
* `vdlm2dec <https://github.com/TLeconte/vdlm2dec>`_

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
