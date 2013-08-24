should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it """

It provides a rootRegistrar for assembling a PhraseGraph
--------------------------------------------------------

* For now the PhraseGraph is a tree (only)

    ie. no complex pathways

* The rootRegistrar is returned by `PhraseRoot.createRoot( opts, linkFunction )`

    ie. `arithmatic` below

* It expects a string and a nested PhraseFunction to be passed

    ie. arithmatic 'operations', ( args ) -> 

        #
        # args?: see 'The PhraseFunction' below TODO
        #  


It calls the linkFunction with the PhraseGraph root token
---------------------------------------------------------

* The link function is called when the PhraseGraph is initialized

    ie. At the first call to rootRegistrar  (arithmatic)

* The link function is an event emitter (pubsub)

    ie. token.on 'event', ( payload ) -> 

        #
        # event?, payload?: see 'The Root Token'  TODO
        # 


    """, (done) -> 

        arithmatic = PhraseRoot.createRoot

            title: 'Arithmatic'
            uuid:  '1'
            leaf: ['done']

            (token) -> 

                token.on 'ready', (data) -> 

                    """

The Root Token
--------------

TODO




                    """

                    for path of data.tokens

                        add      = data.tokens[path] if path.match /add$/
                        subtract = data.tokens[path] if path.match /subtract$/

                    
                    token.run( add, input1: 7, input2: 3 ).then(

                        (result) ->

                            #result.job.answer.should.equal 10
                            #done()

                        (error)  -> 

                            console.log ERROR: error

                        (update) -> 

                            if update.state == 'run::step:failed'

                                # console.log update
                                
                                #
                                #  state: 'run::step:failed',
                                #  class: 'PhraseJob',
                                #  jobUUID: 'd254b360-0cbf-11e3-823a-01cf205a2ddf',
                                #  progress: { steps: 1, done: 0, failed: 1, skipped: 0 },
                                #  at: 1377350375835,
                                #  error: [Error: UnexpectedError caught inline],
                                #  step: 
                                #   { set: 1,
                                #     depth: 2,
                                #     type: 'leaf',
                                #     ref: 
                                #      { uuid: [Getter],
                                #        token: [Getter],
                                #        text: [Getter],
                                #        leaf: [Getter/Setter] },
                                #     fail: true },
                                #  originator: true }
                                #

                                ''

                    )

                    token.run( subtract, input1: 100000000000000000000, input2: 1 ).then (result) ->

                            # console.log result
                            result.job.answer.should.equal 100000000000000000000 
                                                                    # 
                                                                    # javascript... :)
                                                                    #
                            done()


                    #
                    # add and subtract are also tokens
                    # --------------------------------
                    # 
                    # TODO: make them directly callable 
                    #     
                    #       but later... (because a future use case plays that hand very specifically)
                    #

                    # add( input1: 7, input2: 3 ).then -> 



        arithmatic 'operations', (operation) -> 

            """

The PhraseFunction
------------------

TODO


            """

            operation 'add', (done) -> 

                #@answer = @input1 + @input2
                throw new Error 'UnexpectedError caught inline'

                #
                # Important
                # ---------
                # 
                # * This step has now failed, But the token.run() **Has Not Failed**
                # 
                # * This error was passed into the token.run().then promise handler's
                #   notifier function (the 3rd function passed to then())
                #    
                #      ie. token.run( phraseOrBranchToken ).then(
                # 
                #           #
                #           # these three functions are the promise handler
                #           #   (see 'when' or 'q', node modules)
                #           # 
                # 
                #           (result) -> # final result from the entire run
                #           (error)  -> # a catastrophic error terminstes the run
                #           (update) -> # an event occurs in the run (eg. 'run::step:failed')
                #
                #      )
                # 
                # * The error was passed into the handlers notifier to allow the token
                #   run to continue processing the remaining leaves on the phraseBranch
                #   that was called.
                # 


                #
                # TODO: KnownError pathway
                #
                #  done new Error 'KnownError via resolver'
                

            operation 'subtract', (done) -> 

                done()
                @answer = @input1 - @input2


    it """

The PhraseCache
---------------

    """



    it """

The RootCache
-------------

    """
