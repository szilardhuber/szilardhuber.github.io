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

The first two steps went like charm. I had the "Hello World" personal Github Page and had already started writing my first post in LightPaper. 
But for Jekyll I just run into the same problem as I did the last time:

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

Ok quick googling and came to the following StackOverflow answer [suggesting installing Xcode](http://stackoverflow.com/questions/10725767/error-installing-jekyll-native-extension-build).

App Store starts to act weird as it seems like downloading Xcode but after some trying I figured out I had to manually click on the Update button in the Store despite it said it is being purchased right now. Ok now I remember this was where I gave up Jekyll the previous times. So Xcode is installed and I still remember that it is not enough to install it, you have to start it as well.

This time Jekyll installs successfully. 

Next step is creating a new post:

```
jekyll new . —force
```

I have the Jekyll boilerplate now. Let's just quickly copy the header from the sample post to this one, save this into the "_posts" folder, change the data in the header and [push everyting up to github](https://github.com/szilardhuber/szilardhuber.github.io/commit/37d1654556bba04787970a83fd998915ee31b3c0).

And now I see what was my other concern the last time I played with Jekyll. It is really-really ugly:

 ![Screenshot]({{site.url}}/assets/20131228.png)

After some searching around again I found [Minimal Mistakes](http://mmistakes.github.io/minimal-mistakes/) as the best starter Jekyll template. 

Some configuration changes later it turned out that kramdown needs to be installed and the Jekyll watcher must be restarted every time I make modifications to the "_config.yml". 

The other thing that caused me quite a long time to figure out was that in the template the Markdown parser is changed from default Maruku to kramdown and it uses somewhat different syntax so I changed the parser back and deleted the theme-setup.md as it had some syntax errors with the new parser.

Now after playing around with Grunt and LESS and CSS and such (nothing serious) it look somewhat better:

 ![Screenshot]({{site.url}}/assets/20131228-2.png)