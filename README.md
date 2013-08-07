### Version 0.0.1 (unstable)

`npm install phrase`

phrase
======

A describer.


Usage
-----

```coffee

root = require('phrase').create 

    title: 'Title'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (emitter) -> 

        #
        # eg. emitter.on 'phrase::start', (payload...) -> 
        #





root 'phrase text', (nested) -> 

    before all: -> 

        #
        # do something before each nested phrase
        # 

    nested 'nested phrase 1 text', -> 
    nested 'nested phrase 2 text', -> 


```

