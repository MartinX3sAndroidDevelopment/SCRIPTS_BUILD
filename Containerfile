FROM docker.io/eclipse-temurin:22-jdk@sha256:765569cd83ecc47b87cc1b5c4d986f367edac0fad2979bd9e2dde99c211d3727

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && dpkg --add-architecture i386 \
    && apt update \
    && apt install -q -y bison \
        bc \
        curl \
        flex \
        g++-multilib \
        git \
        gperf \
        liblz4-tool \
        libncurses5 \
        libssl-dev \
        libxml2-utils \
        make \
        msmtp \
        python-is-python3 \
        rsync \
        zip \
        zlib1g-dev zlib1g-dev:i386 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY container/msmtprc /etc/msmtprc

RUN useradd -m -s /bin/bash -u 1000 builder

USER builder

RUN git config --global user.email "builder@example.com" \
    && git config --global user.name "builder"

RUN mkdir ~/bin \
    && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo \
    && chmod a+x ~/bin/repo \
    && echo 'export PATH=~/bin:$PATH' >> ~/.bashrc

ENV PATH=~/bin:$PATH

WORKDIR /script

COPY . .
