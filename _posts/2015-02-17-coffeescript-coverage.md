---
layout: post
title:  "Code coverage with CoffeeScript"
date:   2015-02-17 15:49:21
categories: coffeescript testing coverage mocha
---

In the [last post](http://szilardhuber.github.io/coffeescript/testing/mocha/coffeescript-testing/) I explained why we chose CoffeeScript and how to put together a Continuous Integration solution with unit testing of CoffeScript codes and I promised to go on with code coverage.

We will use [Gulp](http://gulpjs.com/) and [Istanbul](https://github.com/gotwarlost/istanbul) for that.

Let's first install everything we will need:

```npm install --save-dev gulp coffee-script gulp-mocha gulp-coffee-istanbul```

Create the Gulpfile:

{% highlight coffeescript linenos %}
gulp = require 'gulp'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-coffee-istanbul'

sourceFiles = ['coolClass.coffee']
specFiles = ['test/*.coffee']

gulp.task 'coverage', ->
    gulp.src sourceFiles
    .pipe istanbul
        includeUntested: false
    .pipe istanbul.hookRequire()
    .on 'finish', ->
        gulp.src specFiles
        .pipe mocha
            reporter: 'spec'
        .pipe istanbul.writeReports
            dir: '.'
            reporters: ['text-summary', 'cobertura']

gulp.task 'default', ['coverage']
{% endhighlight %}

And run ```gulp```. Now if you did your homework in my previous post and fixed the code so that the test is green, you see something like this:

![The result](/assets/coverage.png)

As in the Gulpfile I asked istanbul to generate the cobertura report as well we can use it in [Jenkins](http://jenkins-ci.org/).

First make sure Cobertura Coverage Plugin is installed and add the publishing of the coverage results as a post-build action.

![Cobertura settings](/assets/coberturasettings.png)

And voila you have the coverage set up in Jenkins. You can create rules on how much coverage is needed for different build health states so you can make the build fail is coverage is less than a treshhold.

![Cobertura results](/assets/coberturaresults.png)

We are pretty much done here but I noticed some strange behaviour you should be aware of before using this method:

  - In the coverage report **only the lines** refer really to the **CoffeeScript** code, functions, statements and branches refer to the compiled Javascript.
  - If there is a className.js file in the same location where className.coffee is located the test runner will use the Javascript file instead of the CoffeeScript. This can be really tricky.

In the next part of the CoffeeScript testing series we will look at some more realistic examples.
