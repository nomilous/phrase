### Version 0.0.1 (unstable)

`npm install phrase`

phrase
======

A describer.


Usage
-----

```coffee

root = require('phrase').create 

    title: 'Stem Loop'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (notice) -> 

        #
        # middlewares can register to receive phrase lifecycle and
        # activity events emanating from the tree defined below.
        #

        notice.use (msg, next) -> 

            #
            # be advised! phrase activity is suspended for as
            #             long as next() has not been called.
            # 

            next()







root 'phrase text', (nested) -> 

    before each: -> 

        #
        # do something before each nested phrase
        # 

    nested 'nested phrase 1 text', -> 
    nested 'nested phrase 2 text', -> 


```

