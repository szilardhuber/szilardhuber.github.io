---
layout: post
title:  "Unit testing Coffeescript"
date:   2015-02-10 09:12:13
categories: coffeescript testing mocha
---

## Why CoffeScript? ##

While planning [VirtDB components](https://github.com/starschema?query=virtdb) we wanted to go on with technologies that we felt help us reach our goals the fastest. As such we decided to use C++ for the components were faster to create in it or that we expected to be performance heavy. (And also where there were no other viable APIs like connecting to SAP)

For all other components we decided to go on with Node.js and Javascript. We expected the following benefits of it:

  * **Rapid development** - We wanted a feature rich framework that makes it easy to create [web servers](http://expressjs.com/), native applications and [desktop user interfaces](https://github.com/atom/atom-shell). All of these are relatively easy with Node.js although we pivoted from our original plan of creating a standalone desktop application with GUI.
  * **NPM** - We didn't know much about Node.js but we did know for sure that there is a package for anything. (Even though it turned out that one has to be careful selecting the right package for production environments.)
  * **Performance** - Compared to other options (Java, Python, Rails) it seemed to have decent performance. And after spending half a year with developing components I still believe this is true.

This all happened before a wide support of ES6 so we chose [CoffeScript](http://coffeescript.org) from the many compile-to-javascript languages as I had some experience with it and I liked it a lot.

## Testing ##

There are several methods to test Javascript code but we wanted to write tests also in CoffeeScript and get the error reports also referring to the CoffeScript code. As a test runner [Mocha](http://mochajs.org/) turned out to be optimal for these requirements so I show you how easy it is to start testing with it.

Let's just install mocha and create a class with a test:

```npm install mocha```

```coolClass.coffee```:
{% highlight coffeescript linenos %}
class Sum
    @add: (a, b) => throw Error("not implemented")

module.exports = Sum
{% endhighlight %}

```test/test.coffee```:
{% highlight coffeescript linenos %}
assert = require "assert"

Sum = require "../coolClass"

describe "Sum", ->
    it "should add two positive numbers", ->
        assert.equal 3, Sum.add 1, 2
{% endhighlight %}

Runing the tests is as easy as:

```mocha --compilers=coffee:coffee-script/register test/*.coffee```

And we get the results:
![Tests fail](/assets/mochafail.png)

**Mission accompllished** pretty unit tests written in CoffeeScript with errors displayed in the ```.coffee``` files and not in the compiled Javascripts. I let you fix the test and see how it looks if everything is green.

## Continuous Integration ##

While writing and running unit tests is cool but as with almost everything, letting a machine do your job is even better. Mocha has lots of great features and one of these is being able to select from various reporters.  

We searched a lot how to integrate test report to our [Jenkins CI system](http://jenkins-ci.org/) and we ended up using [TAP](http://en.wikipedia.org/wiki/Test_Anything_Protocol).

First make sure test reports are created:

``` mocha --compilers=coffee:coffee-script/register test/*.coffee --reporter=tap > test-report.xml ```

Install [TAP plugin](https://wiki.jenkins-ci.org/display/JENKINS/TAP+Plugin) and add the publishing of the previously created ```xml``` as a post-build action.

![Jenkins TAP test settings](/assets/tapreportersettings.png)

Enjoy Jenkins test reports

![Jenkins TAP test results](/assets/tapjenkins.png)

So we have decent CI with unit testing and our code is safe from us. It is harder for us to screw things up and when something goes wrong we don't have to deal with compiled Javascripts.

In the next post we will look at how to add **code coverage** to our build process and after that I will show some more real-life tests with mocking.
