---
layout: post
title:  "Learning game programming with Defold #2 - main menu and loader"
date:   2020-05-26 13:55:22
categories: defold game
---

In the [previous post](http://szilardhuber.github.io/defold/game/learnin-game-programming-with-defold) I got to the point where I had some minimal game with tile-based collisions and random opponent generation. To improve user experience I need to add a main menu so that the player can exit from the game or start a new round.

For this we need to add two more collections to the project. Let's rename the existing one from main to level as it contains objects related to our one and only yet level. The first we add is the main menu. It has a new gui component and a gui_script. I'm still not sure why do we need to distinguish gui_scripts from scripts but let's just accept this for now. (UPDATE: I just needed to search for it. This is explained in the [documentation](https://defold.com/manuals/gui-script/).) For the gui I followed the steps from the tutorial where we added the score to the screen. I added three nodes: two for the menu items and an other for the score of the previous game. 

{% gist 038972e6bc4881d882df7e8d5e9627d2 menu.gui_script.lua %}

We need to implement two handlers. The `on_message` is for handling the `score` message and updating the text of the score node. This message will be sent from the loader component. The `on_input` is responsible for detecting `click` events on the menu items. The way to exit the game seems to be sending a message to the `@system:` url but I also saw a `sys.exit` call and I'm not sure what's the reason of the ambiguity here. The message sent when clicked on the start menu is the way we can handle multiple screens but let's cover that in the loader.script.

{% gist 038972e6bc4881d882df7e8d5e9627d2 loader.script.lua %}

Add the loader collection as well. This should contain a game object with a script file and two CollectionProxy elements. Collection proxies are components that can be used to load different scenes or worlds of you game. So add two proxies to our loader one for the main menu and one for the level. The only relevant property of a proxy right now is the url for the collection it proxies so fill that accordingly for both objects.

The loader script seems a bit more complicated but it basically does nothing else but posts messages to the proxies. On init it loads the main menu and when getting a start_game of game_over message it activates the right screen.

The [documentation](https://defold.com/manuals/collection-proxy/) covers what messages to send to activate a world but basically you need to load it and when loading is finished, enable it.

The player.script also needs to be changed to send the game_over message to the loader instead of deleting the player and sending the message to the gui on the level.
```
-- ...
	elseif message_id == hash("game_over") then
		msg.post("loader:/loader#loader", "game_over", { score = self.score }) 
	end
-- ...
``` 
