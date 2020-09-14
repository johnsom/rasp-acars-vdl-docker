FROM ubuntu:20.04 as scratch

ARG TZ=America/Los_Angeles
RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" TZ=$TZ apt install -y \
      gcc \
      git \
      cmake \
      make \
      build-essential \
      debhelper \
      libusb-1.0-0-dev \
      zlib1g-dev \
      libxml2-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

RUN git clone git://git.osmocom.org/rtl-sdr.git /rtl-sdr
WORKDIR /rtl-sdr
ARG CFLAGS="-mcpu=cortex-a72+crypto -mtune=cortex-a72"
RUN CFLAGS=$CFLAGS dpkg-buildpackage -b -us -uc -nc
RUN dpkg --install /librtlsdr-dev_0.6_arm64.deb /librtlsdr0_0.6_arm64.deb

RUN git clone https://github.com/szpajder/libacars /libacars
RUN mkdir -p /libacars/build
WORKDIR /libacars/build
RUN CFLAGS=$CFLAGS cmake ../
RUN CFLAGS=$CFLAGS make
RUN make install
RUN ldconfig

RUN git clone https://github.com/TLeconte/vdlm2dec.git /vdlm2dec
RUN mkdir -p /vdlm2dec/build
WORKDIR /vdlm2dec/build
RUN CFLAGS=$CFLAGS cmake -Drtl=ON ../
RUN CFLAGS=$CFLAGS make

FROM ubuntu:20.04

RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" TZ=$TZ apt install -y \
      zlib1g \
      libxml2 \
      libusb-1.0-0 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=scratch /librtlsdr0_0.6_arm64.deb /librtlsdr0_0.6_arm64.deb
RUN dpkg --install /librtlsdr0_0.6_arm64.deb
RUN rm /librtlsdr0_0.6_arm64.deb

# Install libacars
RUN mkdir -p /usr/local/lib
COPY --from=scratch /libacars/build/libacars/libacars-2.so.2 /usr/local/lib/libacars-2.so.2
RUN ln -s /usr/local/lib/libacars-2.so.2 /usr/local/lib/libacars-2.so
RUN mkdir -p /usr/local/include/libacars-2/libacars
COPY --from=scratch /libacars/libacars/*.h /usr/local/include/libacars-2/libacars/
RUN mkdir -p /usr/local/lib/pkgconfig/
COPY --from=scratch /libacars/build/libacars/libacars-2.pc /usr/local/lib/pkgconfig/libacars-2.pc
RUN mkdir -p /usr/local/include/libacars-2/libacars/asn1
COPY --from=scratch /libacars/libacars/asn1/*.h /usr/local/include/libacars-2/libacars/asn1/
RUN mkdir -p /usr/local/bin
COPY --from=scratch /libacars/build/examples/adsc_get_position /usr/local/bin/adsc_get_position
COPY --from=scratch /libacars/build/examples/cpdlc_get_position /usr/local/bin/cpdlc_get_position
COPY --from=scratch /libacars/build/examples/decode_acars_apps /usr/local/bin/decode_acars_apps
RUN ldconfig

# Install vdlm2dec
COPY --from=scratch /vdlm2dec/build/vdlm2dec /usr/local/bin/vdlm2dec

ENTRYPOINT ["/usr/local/bin/vdlm2dec"]
CMD ["-v", "-G", "-E", "-U", "-r", "<VDL SDR ID/serial>", "136.600", "136.650", "136.700", "136.800", "136.925", "136.975"]
