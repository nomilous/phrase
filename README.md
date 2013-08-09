### Version 0.0.1 (unstable)

`npm install phrase`

phrase
======

A describer.


Usage
-----

```coffee

root = require('phrase').createRoot

    title: 'Stem Loop'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (token, notice) -> 

        #
        # middlewares can register to receive phrase lifecycle and
        # activity events emanating from the tree defined below.
        #

        notice.use (msg, next) -> 

            #
            # be advised! 
            # -----------
            # 
            # Certain of the notifications generated in the phrase tree 
            # suspend their 'flow of execution' pending the completion 
            # of ALL registered middleware functions.
            #             
            #  ie. Some stuff that sends a message down the pipeline 
            #      into which this middleware is registered waits for 
            #      next() before resuming.
            # 

            next()


#
# root phrase registrar
# ---------------------
#
# ... TODO
#

root 'phrase text', (nested) -> 
    
                        #
                        # nested phrase registrar
                        # -----------------------
                        # 
                        # ... TODO
                        #

    before 

        all: (done) -> 

            #
            # register a beforeAll hook 
            # -------------------------
            # 
            # This function will be called before (any of) the nested 
            # phrases are run.
            # 
            # It will be called only once, even if multiple nested 
            # phrases exist.
            # 
            # The running of the phrases themselves is suspended until 
            # done has been called to enable this hook to break out 
            # asynchronously and wait... to be completed (resolved) 
            # inside the callback that was handed to the asynchronous 
            # function
            # 

            done()

        each: -> 

            #
            # register a beforeEach hook 
            # --------------------------
            # 
            # Identical to the beforeAll hook except that it is run
            # before each nested phrase. (ie. not only once)
            # 

            done()

    #
    # register after hooks
    # --------------------
    #
    # Same as before, but after.
    # 

    after all:  (done) -> done()
    after each: (done) -> done()

    # 
    # IMPORTANT
    # ---------
    # 
    # The hooks ARE NOT RUN in the manner that one would 
    # naturally assume... 
    # 
    #         See 'Leaf Phrase's below.
    # 

    nested 'nested phrase 1 text', (deeper) -> 

        deeper 'deeper nested phrase', (end) -> 

            #
            # Leaf Phrase
            # -----------
            #
            # ... TODO
            # 





    nested 'nested phrase 2 text', -> 


```

