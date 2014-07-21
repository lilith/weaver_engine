# Weaver Engine

For building MMORPG games which

* Support collaborative editing of the universe
* Are primarily text-based and story-centric
* Can be played with simple controls, such as navigation and action 'choices'
* Are mobile-friendly
* Are highly accessible

[Read more about the genre](genre.md)

## Writing vs Coding

Staying in the creative flow means you need frictionless editing and replay. That means having an "Add Choice" and and "Edit text" option.

Collaborating means sharing a link to what you're working on, while you're working on it.

Multiple branches, multiple 'working trees'. Operational transforms for realtime editing.



We must allow branching and merging/rebasing, or there will be a wall before users can contribute.


Describing each step as a JSON object permits us to allow both real-time editing (using operational transforms) - and later automated merging of changes. Automated merging is very important if users (who have branched the world) are ever to see other's changes again.

Converting the resultant JSON to YAML for readable serialization to GitHub can allow for more complex (or manual) merging.


http://nodeca.github.io/js-yaml/


## Formats and editing

Every 'location' is just a data structure within a room file. Optionally, code can be added separately to modify how that location structure is processed. 

I.e, 

room.yaml
room.lua (or room.moon)

The web editors can edit the yaml (converted to json) easily. The .lua files only contain the code, so that can be edited in plain-text form.

https://github.com/share/ottypes/wiki/JSON-operations

https://github.com/sveith/jinfinote

https://github.com/share/ShareJS


## Collaboration 

Code changes need a more formal merge strategy, but immediate merging of the story data structures is important.

Rollback is needed for bad errors. Immediate editing is good for collaboration. Change visualization is important. Vector-based edits could work since the data is structured.

Saving both an OT (operational transform) log, and a text dump should enable this.

http://sharejs.org/




## Choice of languages: Lua + (Ruby
Lua is the only great choice for a (non-lisp) language that supports continuations and serialization of them. Rhino could too, in theory (didn't get it working), but Lua is extremely fast to start/stop, and likely to scale much better. It's also the incumbent in the game space for similar reasons.

We could compile Moonscript or any syntax to Lua to achieve the style we want - or use its metaprogramming abilities.

What Lua offers in game scripting wisdom, it lacks in web development community size. Pairing it with Ruby or even Node for the client wrappers and editing tools could help with this.

Running the API within Lua, but the containing website in Ruby makes a lot of sense.





fog.io - cloud agnostic API


http://www.codecommit.com/blog/java/understanding-and-applying-operational-transformation

http://kkovacs.eu/cassandra-vs-mongodb-vs-couchdb-vs-redis

Redis - has lua scripting!

Riak
Postgres to start


http://mikehadlow.blogspot.com/2013/04/serializing-lua-coroutines-with-pluto.html



http://olivinelabs.com/busted/
https://github.com/pkulchenko/ZeroBraneStudio

https://github.com/leafo/lapis
https://github.com/kikito/middleclass
https://github.com/leafo/moonscript

https://github.com/kernelsauce/turbo