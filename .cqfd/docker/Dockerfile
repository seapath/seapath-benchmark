# Copyright (C) 2024 Savoir-faire Linux, Inc.
# SPDX-License-Identifier: Apache-2.0
FROM ubuntu:24.04
RUN userdel -r ubuntu

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
	ansible \
	bash \
	fio \
	gnuplot \
	librsvg2-bin \
	locales \
	patch \
	php-xml \
	python3 \
	python3-pip \
	rsync \
	rt-tests \
	sudo \
	sysbench \
	vnstat \
	yamllint
RUN wget https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v10.8.4/phoronix-test-suite_10.8.4_all.deb
RUN apt install -y ./phoronix-test-suite_10.8.4_all.deb
RUN echo 'ALL    ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN sed -i "s/# en_US\.UTF-8 UTF-8/en_US\.UTF-8 UTF-8/" /etc/locale.gen
RUN locale-gen
RUN dpkg-reconfigure locales
ADD check_yaml.sh /usr/bin/check_yaml
