should = require 'should'
phrase = require '../lib/phrase'

describe 'phrase.createRoot(opts, linkFunction)', -> 

    before (done) ->

        """

It provides a rootRegistrar for assembling a PhraseTree
-------------------------------------------------------

* For now the PhraseTree is a tree (only)

    ie. no complex pathways

* The rootRegistrar is returned by `phrase.createRoot( opts, linkFunction )`

    ie. `arithmatic` below

* It expects a string and a nested PhraseFunction to be passed

    ie. arithmatic 'operations', ( args ) -> 

        #
        # args?: see 'The PhraseFunction' below TODO
        #  


It calls the linkFunction with the PhraseTree root token
---------------------------------------------------------

* The link function is called when the PhraseTree is initialized

    ie. At the first call to rootRegistrar  (arithmatic)

* The token passed to the link function is an event emitter (pubsub)

    ie. token.on 'event', ( payload ) -> 

        #
        # event?, payload?: see 'The Root Token'  TODO
        # 


        """

        arithmatic = phrase.createRoot

            #
            # opts... 
            #

            title: 'Arithmatic'
            uuid:  '1'
            #
            # this is an implicit hash (coffee!) passed to createRoot(opts, linkFunction)
            #

            #
            # linkFunction
            #
            (@token, notice) => 

                @token.on 'ready', ({tokens}) => 

                    # console.log JSON.stringify tokens, null, 2

                    for path of tokens

                        @add      = tokens[path] if path.match /add$/
                        @subtract = tokens[path] if path.match /subtract$/

                    done()

                @token.on 'error', (error) -> 

                    console.log PHRASE_ERROR: error


        """

The PhraseFunction
------------------

TODO

        """

        arithmatic 'operations', (operation) -> 

            operation 'subtract', uuid: 900, (end) -> 

                @answer = @input1 - @input2
                end()

            operation 'boundry phrase', (edge) ->

                console.log 'BOUNDRY'

            operation 'just checking', (nested) -> 

                nested 'invalid / phrase title', (end) -> 

                nested 'still running', (nest) -> 

                    console.log still_running: true

                    nest 'deeper', (end) -> 

            operation 'add', (end) -> 

                #@answer = @input1 + @input2
                throw new Error 'UnexpectedError caught inline'
                                #=============================

                """

Leaf Exceptions
---------------

Related: 'Token Run Updates' (below)

* This step has now failed, But the token.run() **Has Not Failed**

* This error was passed into the token.run().then promise handler's
  notifier function (the 3rd function passed to then())
   
     ie. token.run( phraseOrBranchToken ).then(

          #
          # these three functions are the promise handler
          #   (see 'when' or 'q', node modules)
          # 

          (result) -> # final result from the entire run
          (error)  -> # a catastrophic error terminstes the run
          (update) -> # an event occurs in the run (eg. 'run::step:failed')

     )

* The error was passed into the handlers notifier to allow the token
  run to continue processing the remaining leaves on the phraseBranch
  that was called.


                """


                #
                # TODO: KnownError pathway
                #
                #  end new Error 'KnownError via resolver'
                

    it """

The Root Token
--------------

### run()

TODO


    """, (done) -> 

        @token.run( @subtract, input1: 10, input2: 3 ).then(

            (result) ->

                result.job.answer.should.equal 7
                done()

            (error)  -> 
            (update) -> 

        )


    it  """

Token Run Updates
-----------------

TODO


    """, (done) -> 


        @token.run( @add, input1: 7, input2: 3 ).then(

            (result) ->
            (error)  ->
            (update) ->

                if update.state == 'run::step:failed'
                            #
                            # TODO: rename to event
                            #

                    # console.log update

                    #
                    #  state: 'run::step:failed',
                    #  class: 'Job',
                    #  jobUUID: 'd254b360-0cbf-11e3-823a-01cf205a2ddf',
                    #  progress: { steps: 1, done: 0, failed: 1, skipped: 0 },
                    #  at: 1377350375835,
                    # 
                    # 
                    #  error: [Error: UnexpectedError caught inline],
                    #                 =============================
                    # 
                    #  step: 
                    #   { set: 1,
                    #     depth: 2,
                    #     type: 'leaf',
                    #     ref: 
                    #      { uuid: [Getter],
                    #        token: [Getter],
                    #        title: [Getter],
                    #        leaf: [Getter/Setter] },
                    #     fail: true },
                    #  originator: true }
                    #

                    done()



        )

        #
        # add and subtract are also tokens
        # --------------------------------
        # 
        # TODO: make them directly callable 
        #     
        #       but later... (because a future use case plays that hand very specifically)
        #

        # add( input1: 7, input2: 3 ).then -> 




    it """

The PhraseCache
---------------

    """



    it """

The RootCache
-------------

    """



    it """

The PhraseMetrics
-----------------

    """



    it """

The RootMetrics
---------------

    """
