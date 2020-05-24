---
layout: post
title:  "Learning game programming with Defold #1 - first steps"
date:   2020-05-24 13:55:22
categories: defold game
---
I like learning things. I like starting something and I always dream of even finishing that (notice that finishing is mostly a dream here :) ). I became a software developer because I fell in love with computers the moment I saw the first one. I still remember the feeling and the smells. I was a young kid and I went in to the public library of my hometown where my sister worked as an intern and I found her in a room where she organized some event where "old folks" (I guess they were way younger than I am now :) ) played with a computer game. This was a place and a time when computers were not something every family had a couple of. In fact there were about 20 guys in the room with a single Commodore 64 and they all took turns on who plays a round on that. From that time I know I want to spend my time with these marvellous machines.

![Commodore 64](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Commodore-64-Computer-FL.jpg/600px-Commodore-64-Computer-FL.jpg)

And I remember when I got my own Commodore 64 from my parents a lot of time after this first meet, the first program I wrote was also some kind of a game. I created a trivia like game about at that time my favourite sport (handball) for my family. They would get a question and have 4 answers and they would need to guess the correct answer to win the game.

So since then I spent a significant amount of my time playing video games and I became a software developer so you would assume I happened to learn game programming but for some reason it always avoided me. Every once in a while I stumbled upon a game development book or article, some blog posts or even a game development engine but there always was something that prevented me from really starting it.

A couple of days ago however I read a [post on Hacker News](https://news.ycombinator.com/item?id=23232648) that the Defold game engine had become open source. I had't even heard about this game engine before but I had some spare time so I checked the post, I even looked at the Defold homepage and I even installed the engine. And then something happened :) They have so nice tutorials, that are not too trivial to be boring but not too complex so that I get overwhelmed so I finished the [War Battles tutorial](https://defold.com/tutorials/war-battles/). 

I don't really want to replicate anything from that tutorial, you should go and finish that on your own as it is very entertaining.

When you finish this you have a single scene with a map where you have a player who moves with the arrow keys, can even shoot rockets and there is a tank that can be fired at and that explodes if hit. You even have a score displayed on the top of the screen and they give you some good suggestions on how to move forward with this. However by the time I came here I had at least 3 copmletely different directions I wanted to go and tons of ideas on what games I would like to create so let's see together if I can finish a game until published and what that game will look like. To be honest in this moment I can only guess with both questions. :)

![My first game](/assets/defold1.png)

So as a first development let's add more tanks so that we can get more score than the 100 from the tutorial. I only have two game objects in my collection so I need to add the code for spawning the tanks either to the tank.script or to the player.script. It would seem natural for me to put it in the code for tanks but as they are the dynamically created instances it would happen that I don't have any objects to run my timer. So decorate the player object even more it is already the one responsible for most of the logic but for now this should do. I assume at a later point I will need to add a level.script or logic.script to the collection but at this point I still don't know enough about the engine to decide where is the best place for general game logic.

{% gist fddae384a6b57cac419b25a05b2006af player.lua %}

So at fist I add two "constants" to the script the Spawn Interval (this will be the time interval between two spawns of a tank) and the Max Speed which is the running speed of the player that has nothing to do with this modification but while I'm here I feel I should refactor it to a property as well. By defining a `go.property` you can use that in the code `self.spawn_interval` and `self.max_speed` and also you can edit these values in the editor with the nice property pane that already has properties for all kind of stuff.
