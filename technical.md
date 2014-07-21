# Technical challenges

## The language

Requirements: 
 * sandboxing (or only allow extremely trusted users to contribute)
 * serializable continuations (or write a state machine for every room) - this allows code to acquire user input and resume days/years later.

That leaves us with

* **Lua 5.1.4 + [Pluto](https://github.com/hoelzro/pluto)**
* Lua 5.2 + [Eris](https://github.com/fnuecke/eris)
* Rhino 1.7R2
* Scheme and LISP variants

Lua is really small, really popular in the game industry, and insanely fast. So we're using that. 

Rhino might have worked too, Ian Sollars is using it with [Scriptus]](http://ianso.github.io/scriptus/), which also depends on serializable coroutines. 

I don't know how to teach kids lisp.

## Hosting

Digital Ocean is cheap and fast





* http://stackoverflow.com/questions/5221175/is-rhino-the-only-interpreter-with-support-for-sandboxing-and-serializable-conti
* 

http://mikehadlow.blogspot.com/2013/04/serializing-lua-coroutines-with-pluto.html


http://ianso.github.io/scriptus/




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