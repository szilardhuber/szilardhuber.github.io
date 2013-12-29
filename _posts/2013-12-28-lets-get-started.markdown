---
layout: post
title:  "Let's get started"
date:   2013-12-28 16:15:31
categories: jekyll update
---
After months (years?) of playing with the idea I finally got everything in place to start this blogging thing. My requirements were the following:

  - A decent (and <b>cheap / free</b>) Markdown editor with live preview mode.
  - Easily manageable Markdown-based static blogging engine.
  - Easy hosting

I came to the following solutions for my requirements:

  -  [LightPaper for Mac](http://clockworkengine.com/lightpaper-mac/) as the Markdown editor. Only using it for minutes now but already love it.
  -  [Github Pages](http://pages.github.com) just got some great docs and is an awesome static hosting platform.
  -  [Jekyll](http://jekyllrb.com/docs/home/) is a promising blogging engine for Github pages but I have already tried installing it a few times and always failed to do so. (Although I have to admit I did not put much effort into it.)

The first two steps goes like charm. I have the "Hello World" personal Github Page and have already started writing my first post in LightPaper. 
But for Jekyll I run into the same problem as I did the last time:

```
mbp@~/Developer/szilardhuber.github.io:(master)$ sudo gem install jekyll
Building native extensions.  This could take a while...
ERROR:  Error installing jekyll:
	ERROR: Failed to build gem native extension.

    /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby extconf.rb
mkmf.rb can't find header files for ruby at /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/lib/ruby/include/ruby.h


Gem files will remain installed in /Library/Ruby/Gems/2.0.0/gems/fast-stemmer-1.0.2 for inspection.
Results logged to /Library/Ruby/Gems/2.0.0/gems/fast-stemmer-1.0.2/ext/gem_make.out
```

Ok quick googling and I come to the following StackOverflow answer [suggesting installing Xcode](http://stackoverflow.com/questions/10725767/error-installing-jekyll-native-extension-build).

App Store starts to act weird as it seems like downloading Xcode but after some trying I figure out I have to manually click on the Update button in the Store despite it says it is being purchased right now. Ok now I remember this was where I gave up Jekyll before. So Xcode is installed and I still remember that it is not enough to install it, you need to start it at least once.

This time Jekyll installs successfully. 

Next step is creating a new post:

```
jekyll new . —force
```

I have the Jekyll boilerplate now. Let's just quickly copy the header from the sample post to this one, save this into the "_posts" folder, change the data in the header and [push everyting up to github](https://github.com/szilardhuber/szilardhuber.github.io/commit/37d1654556bba04787970a83fd998915ee31b3c0).

And now I see what was my other concern the last time I played with Jekyll. It is really-really ugly:

 ![Screenshot]({{site.url}}/assets/20131228.png)

After some searching around again I find [Minimal Mistakes](http://mmistakes.github.io/minimal-mistakes/) as the best starter Jekyll template. 

It is also good to memorise that every time I make changes to the "_config.yml" I need to restart the Jekyll watcher.

The other thing that causes me quite a long time to figure out is that in the template the Markdown parser is changed from default Maruku to kramdown and it uses somewhat different syntax so I change the parser back and delete the theme-setup.md as it has some syntax errors with the new parser.

Now after playing around with Grunt and LESS and CSS and such (nothing serious) it looks somewhat better:

 ![Screenshot]({{site.url}}/assets/20131228-2.png)
 
One would think that at this point everything is up and running and I can happily start blogging but it turns out that the main page of my site looking good at localhost has the same terrible look and feel on Github Pages. I have to admit it takes me hours (and some hours of sleep as I can't figure out the solution at night) to realize that I have an index.html from my previous design and localhost was served from "_site" but Github Pages is served from the root and the index.html is used there.

So deleting the former index.html everything is fine and I can move on.