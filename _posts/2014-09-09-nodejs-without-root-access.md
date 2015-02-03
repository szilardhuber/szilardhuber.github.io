---
layout: post
title:  "Node.js with npm without root permissions"
date:   2014-09-09 14:16:00
categories: node nodejs linux
---
Well seems like this blogging thing is not really a thing of mine but let's have another try.

For our development for virtdb we are playing around with Docker so that everyone can use the same development environment and we would never have to face the "but this worked at my PC" situations.

As a side effect while preparing the Docker images we decided to do it correctly and avoid being administrators on the containers. Everything went awesome until I set up our C++ components but when I started doing the same for node.js it became a hell.

Long story short. What I needed to get node up and running with proper npm:

  - Get node as [source](http://nodejs.org/download/).
  - Run  <code>./configure --prefix=/home/testuser/node</code>
  - Run <code>make</code>
  - Run <code>make install</code>
  - Make sure <code>HOME</code> environment variable is set as this is needed for <code>npm install</code>.

Without the last step I got the following error message (not too informative):
<code>Error: Attempt to unlock {package_name}, which hasn't been locked</code>

Google find tons of questions on the topic but only with solutions that require some kind of administrative rights.

In case anyone interested my Dockerfile doing this is the following:  

{% highlight dockerfile %}
FROM ubuntu:14.04

RUN apt-get update

RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y gyp
RUN apt-get install -y pkg-config
RUN apt-get install -y git
RUN apt-get install -y wget

RUN adduser --home /home/testuser --system --disabled-password --shell /bin/bash testuser
USER testuser
ENV HOME /home/testuser
WORKDIR /home/testuser

RUN wget http://nodejs.org/dist/v0.10.31/node-v0.10.31.tar.gz
RUN tar -xzf node-v0.10.31.tar.gz
WORKDIR /home/testuser/node-v0.10.31
RUN ./configure --prefix=/home/testuser/nodejs
RUN make
RUN make install
ENV PATH $PATH:/home/testuser/nodejs/bin
{% endhighlight %}