### Version 0.0.3 (prerelease, unstable)

`npm install phrase`

phrase
======

What is it?
-----------

* A describer.
* A repeatable context assembler.
* ...
* A metadata enriched scope heap.
* **An Open Closure**.


Usage
-----

```coffee

root = require('phrase').createRoot

    title: 'Stem Loop'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    #
    # leaf (optional)
    # ---------------
    #
    # This is used to identify leaves on the phrase tree
    # See 'Leaf Phrase's below.
    # 
    # 

    #leaf: ['end']
    #timeout: 2000


    #
    # linker function (required, callback)
    # ------------------------------------
    # 
    # token  - Provides access to perfom actions in/on the phrase tree
    # 
    # notice - Message pipeline to which middleware can register to 
    #          receive phrase lifecycle and activity events emanating 
    #          from the phrase tree.
    # 
    #           ie. For tapping into chatter on the phrase tree's 
    #               internal message bus.
    # 

    (token, notice) -> 

        notice.use (msg, next) -> 

            #
            # be advised! 
            # -----------
            # 
            # Certain of the notifications traversing the messenger pipeline 
            # originate from processes that suspend their 'flow of execution' 
            # pending the completion of ALL registered middleware functions.
            #             
            #  ie. Some stuff that sends a message down the pipeline 
            #      into which this middleware is registered waits for 
            #      all middleware to call next() before resuming.
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

        #timeout: 100 

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
            # function.
            # 
            #  ie. You can do remote stuff here, like make database 
            #      calls to get things that the nested phrases need 
            #      and only call done() once you have them.
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
            # When the phrase tree is initialized a 'first walk'
            # is performed that does not execute any of the hooks
            # or any of the leaf nodes.
            # 
            # This 'first walk' assembles a graph† containing all 
            # the 'vertexes' and 'edges' that define the structure 
            # of the phrase tree.
            # 
            #           † http://en.wikipedia.org/wiki/Graph_theory
            # 
            # Once assembled, a phrase node (access) list is emitted 
            # onto the notification pipeline. At that point the phrase
            # tree is ready to recieve instructions via the token
            # that was passed into the link function.
            # 
            # The token can be used to...  (TODO)
            # 






    nested 'nested phrase 2 text', -> 


```

