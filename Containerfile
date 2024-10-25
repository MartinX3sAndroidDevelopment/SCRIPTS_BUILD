FROM docker.io/eclipse-temurin:23-jdk@sha256:e4674da1b96d287e8095b5503d7e3c48977ff6bbab2b61f00989d50326a9ce36

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

USER ubuntu

RUN git config --global user.email "ubuntu@example.com" \
    && git config --global user.name "ubuntu"

RUN mkdir ~/bin \
    && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo \
    && chmod a+x ~/bin/repo \
    && echo 'export PATH=~/bin:$PATH' >> ~/.bashrc

ENV PATH=~/bin:$PATH

WORKDIR /script

COPY . .
