FROM ubuntu:latest
LABEL maintainer="Lucas Fernandes"

RUN apt-get update
RUN apt-get install -y openssl openssh-server vim curl git sudo gnupg2

RUN apt-get update
RUN apt-get install -y build-essential automake autoconf \
    bison libssl-dev libyaml-dev libreadline6-dev \
    zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
    gawk g++ gcc make libc6-dev patch libsqlite3-dev sqlite3 \
    libtool pkg-config libpq-dev nodejs ruby-full software-properties-common

RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo 'Banner /etc/banner' >> /etc/ssh/sshd_config

COPY etc/banner /etc/

RUN useradd -ms /bin/bash foo
RUN adduser foo sudo
RUN echo 'foo:foo' |chpasswd
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER foo

RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN sudo apt-add-repository -y ppa:rael-gc/rvm
RUN sudo apt-get update
RUN sudo apt-get install -y rvm
RUN sudo usermod -a -G rvm foo

USER root

EXPOSE 22

RUN mkdir /projects
VOLUME /projects

CMD ["/usr/sbin/sshd", "-D"]
