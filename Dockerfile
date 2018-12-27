From ubuntu:18.04

# Use third-party sources mirror
RUN apt-get update && apt-get install -y ca-certificates
COPY sources.list /etc/apt/sources.list
COPY lachesis.tar.gz /tmp/lachesis.tar.gz
COPY ax_lib_samtools.patch ax_lib_samtools.patch

# Requirements
RUN export DEBIAN_FRONTEND=noninteractiv \
  && apt-get update \
  && apt install -y build-essential libboost-filesystem-dev \
    libboost-program-options-dev libboost-regex-dev libboost-thread-dev \
    wget autoconf libncurses5-dev \
    r-cran-rcolorbrewer r-cran-ggplot2 r-cran-plyr r-cran-scales r-cran-reshape \
  && echo "Asia/Shanghai" > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata \
  && rm -rf /var/cache/apt/archives/ /var/lib/apt/lists

RUN wget https://github.com/samtools/samtools/archive/0.1.19.tar.gz \
  && tar -xvf 0.1.19.tar.gz && cd samtools-0.1.19 && make -j \
  && rm -rf /0.1.19.tar.gz \
  # samtools build done
  && export LACHESIS_SAMTOOLS_DIR=/samtools-0.1.19 \
  && export C_INCLUDE_PATH=/samtools-0.1.19 \
  && export CPLUS_INCLUDE_PATH=/samtools-0.1.19 \
  && export LIBRARY_PATH=/samtools-0.1.19 \
  # start compile lachesis
  && tar -xvf /tmp/lachesis.tar.gz && cd shendurelab-LACHESIS-2e27abb \
  && patch m4/ax_lib_samtools.m4 < /ax_lib_samtools.patch \
  && rm -rf /ax_lib_samtools.patch \
  && autoconf && ./configure LIBS=-lpthread \
  && sed -i -E 's/bam\///' src/include/gtools/SAMStepper.* \
  && make -j \
  && make install \
  && rm -rf /tmp/lachesis.tar.gz /ax_lib_samtools.patch /samtools-0.1.19
CMD ["Lachesis"]
