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