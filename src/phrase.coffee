{EventEmitter} = require 'events'

require( 'also' ) exports, {}, (root) -> 

    #
    # phrase root
    # ===========
    # 
    #  ??? TODO
    #


    {context, inject, validate} = root


    #
    # stack
    # -----
    # 
    # * The stack of elements (sub phrases) that is pushed and popped
    #   as the 'flow of execution' traverses the phrase tree.
    # 
    # * Stack is directly attached to the `root.context`, this means that
    #   there can only be one root phrase per process.
    # 

    context.stack = []

    #
    # emitter
    # -------
    #
    # * Emits / publishes phrase lifecycle and activity events emanating from within
    #   the branch rooted at this phrase.
    # 

    context.emitter = new EventEmitter

    #
    # Phrase.create( opts, linkFn )
    # -----------------------------
    # 

    create: validate.args

        $address: 'phrase.create'

        opts: 

            title: {} 
            uuid: {} 

        linkFn: 

            $type: Function
            $description: """

                This callback is called immediately upon initialization of the
                phrase root. It receives an event publisher that can be used 
                to subscribe to phrase events from the local branch.

            """

        (opts, linkFn) -> 


            #
            # callback with the event publisher
            #

            linkFn context.emitter


            #
            # return root phrase registrar
            # ----------------------------
            # 
            # * root phrase registrar is an asynchronously embellished fanfare of revellers 
            #   allocating stray tinsel fillament scritinizers to their approximatly crowded 
            #   senses of self assembly.
            # 
            #                                  ie. burly christmas circus flea marshals
            #

            inject.async

                #
                # set the injector to run all calls made in sequence
                #

                parallel: false

                beforeAll: (done) -> 

                    context.emitter.emit 'phrase::start'
                    done()

                beforeEach: (done, inject) -> 

                    #
                    # inject
                    # ------
                    # 
                    # This object controls the behaviour of the async injection into
                    # the target function `(phrase, control, recursor) ->`
                    # 
                    # * Inject.defer is a deferral held by the async controller that
                    #   wraps the call to the injection target. Ordinarilly it would
                    #   be passed into the injection target function as arg1 (done)
                    #   
                    #   But, instead, calling it out here...
                    # 

                    defer = inject.defer

                    #   ...prevents that behaviour.      And leaves the alternative 
                    #                                    resolution mechanism up to
                    #                                    the developer
                    #
                    #  
                    #  * Resolving this deferral results in the 'flow of execution'
                    #    proceeding into the next phrase.
                    # 
                    # 
                    #  * TEMPORARY !!!  this deferral resolves in after each 
                    #                    (pending unimplemented mechanism)
                    # 
                    defer.resolve()


                    #
                    # * Inject.args are the inbound args that were called into the 
                    #   decorated function that was returned by inject.async.
                    # 
                    # * These args are passed oneward to the injection target but
                    #   can be modified as the pass through this beforeEach hook.
                    # 

                    # 
                    # manipulate phrase, control and recursor parametrs for injection
                    # ---------------------------------------------------------------
                    # 
                    # * expects last arg as the function to contain nested phrases, 
                    #   ensure it is at arg3
                    # 

                    unless inject.args[2]?

                        inject.args[2] = inject.args[1] || inject.args[0] || -> console.log 'NO ARGS'

                    done()




                (phrase, control, recursor) -> 

                    recursor()

                    




        
