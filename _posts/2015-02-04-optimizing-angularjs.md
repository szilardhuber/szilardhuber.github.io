---
layout: post
title:  "Optimizing AngularJS (with React)"
date:   2015-02-04 08:13:22
categories: angularjs optimization frontend
---
In [VirtDB](http://www.virtdb.com) [frontend](http://www.github.com/starschema/virtdb-gui) we display a brief preview of the data tables from the source systems which can be a little larger than small. I don't want to write big here as big data definitely does not start with a ```SELECT * FROM BSEG LIMIT 20;``` query. Although the ```BSEG``` table in ```SAP``` has 337 columns so displaying the first 20 rows is more than 6500 records.

## AngularJS ##
At first we implemented everything in [AngularJS](https://angularjs.org/) which is an awesome tool. Let's see how we achieved this (with some cuts to eliminate complexity of dealing with multiple providers and multiple tables but the main table control is the same.)

In the html code we need to do some AngularJS magic so that the selection of data columns become highlighted (```ng-init```, ```ng-click```, ```ng-class``` attributes) and we use a nested ```ng-repeat``` for the actual data display.

{% gist 48d911bcc5220e172f80 angular.html %}

The Javascript code is pretty straightforward and actually is a bit more complex than in reality because we compose imaginary table names here as they are loaded by a different module in our product but I didn't want to mix that here.

{% gist 48d911bcc5220e172f80 angular.js %}

This solution worked but did not give the user experience we like. To make situation even worse we added a new feature which allows users to transpose tha data as we think it is more natural way to get the big picture about what is in the selected table. I leave this feature out from this post but practically we achieved it by using ```ng-show```/```ng-hide``` and added both the display methods to our HTML. This more than doubled the time to render our page which at this point got to 10 seconds on a 2014 Macbook Air.

## React to the help ##

We did not ditch AngularJS completely as we wanted to keep its great functionalities and rewriting our whole UI was out of the question. By doing some search I found out that the best "price/value" ratio of optimization may be achieved by replacing the rendering of our table snapshots to [React](http://http://facebook.github.io/react/) a great framework created by Facebook.

We started with the [great article](http://www.williambrownstreet.net/blog/2014/04/faster-angularjs-rendering-angularjs-and-reactjs/) and sample code of Thierry Nicola. The html code couldn't be any smaller as the whole data display logic is hidden by a new tag: ```fast-repeat```.

{% gist d33263ff29fb9389aa9a react.html %}

As everything has its price, the Javacript code is a bit more complex as we have to create the directive and render the html elements of the table on our own, but I think there is nothing extraordinary in it except for the usage of React components. I did not have any former knowledge of the React library but finished the whole optimization in a day. And most of this day was spent with separating the data display to a new project so that I can measuse it separately from other parts of the page.

{% gist d33263ff29fb9389aa9a react.js %}

## The results ##

I already mentioned that in the real life scenario it took more than 10 seconds to display the first 20 rows of the ```BSEG``` table with using only AngularJS. This was reduced to around 900ms with the help of React which is pretty amazing. Actually I tend to beleive that we could be misusing AngularJS in our first implementation but I couldn't find out how and it appeared to be easier for us to integrate React than it would have been to find out what we did wrong with AngularJS (if at all).

For the examples above (5 measurements, best and worst elminated and the average of the middle three):  

|                    | XHR Load and Javacript process | Recalculate Style | Layout | Overall |
| ---------------    | ------------------------------ | ----------------- | ------ | ------- |
| AngularJS only     |        1.05                    |         0.03      |  0.1   | 1.18    |
| React + AngularJS  |        0.30                    |         0.04      |  0.11  | 0.45    |

That's **61.86%** speed gain with only a day of work. I think this is awesome. :)

#### This took 10 seconds before optimization: ####
![This took 10 seconds before](/assets/7DouJPnYwg.gif)

#### The cool transpose feature I mentioned: ####
![This took 10 seconds before](/assets/8Ps7Sz4QbH.gif)
