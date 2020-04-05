FROM ubuntu:eoan
MAINTAINER matterbeam <mb@matterbeam.com>

# Dockerfile with the instructions to build an image suitable for playing CTF
# With the TOOLS build argument you can specify a list of tools to be installed
# in the image (those tools need to be available inside this repository).

# zsh, python and golang environments will be always installed

ENV LC_CTYPE C.UTF-8

COPY .docker/apt-get-install /usr/local/bin/apt-get-install
RUN chmod +x /usr/local/bin/apt-get-install

RUN dpkg --add-architecture i386 && \
    apt-get-install build-essential libtool g++ gcc curl wget automake autoconf \
    git unzip p7zip-full sudo ca-certificates strace ltrace ruby-dev libssl-dev \
    zsh libffi-dev libc6:i386 libncurses5:i386 libstdc++6:i386

RUN useradd -d /home/ctf -m -s /bin/zsh ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

COPY .git /home/ctf/tools/.git

WORKDIR /home/ctf/tools
RUN git checkout .

COPY bin/manage /home/ctf/tools/manage
RUN chown -R ctf:ctf /home/ctf/tools

USER ctf
ARG TOOLS
ENV PATH="/home/ctf/tools/bin:${PATH}"
RUN bin/manage -S install zsh python golang $TOOLS

WORKDIR /home/ctf
