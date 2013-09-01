Control        = require '../recursor/control' 
PhraseHook     = require '../phrase/hook'
PhraseTokenFactory = require '../token/phrase_token'

#
# TreeWalker
# ==========
# 
# * Performs a recursive 'walk' through the tree being passed to the rootRegistrar 
#   to assemble the PhraseGraph
#   
# * Does not run any of the hooks or leaf nodes in the tree.
# 

exports.walk = (root, opts, rootString, rootFn) ->

    {context, inject, util}             = root
    {stack, notice, graph, PhraseGraph} = context

    context.hooks       = PhraseHook.bind root
    context.PhraseToken = PhraseTokenFactory.createClass root

    if graph? 

        # 
        # root graph is already defined
        # -----------------------------
        # 
        # * create a new (orphaned) graph
        # * accessable at context.graphs.latest
        # 

        new PhraseGraph

    else

        #
        # create root graph
        # -----------------
        # 
        # * This graph houses the PhraseTree
        # * It is only ever created on the 'first walk'
        # TODO * Subsequent walks assemble a second graph
        # TODO * Second graph is merged into the first
        # TODO * Merge generates appropriate add/remove/change events on the root token
        # 

        context.graph = new PhraseGraph


    recursor = (parentPhraseString, parentPhraseControl) -> 

        #
        # This recursion is proxied through an async injector
        # ---------------------------------------------------
        # 
        # * It provides flow control.
        # * It provides argument injection.
        #

        recursionControl = Control.bindControl root, parentPhraseControl

        return inject.async

            #
            # inject.async() arg1 - Injection Preparator
            # ------------------------------------------
            # 

            parallel:   false
            beforeAll:  recursionControl.beforeAll
            beforeEach: recursionControl.beforeEach
            afterEach:  recursionControl.afterEach
            afterAll:   recursionControl.afterAll
            onError:    (done, injectionControl, error) -> 

                #
                # when using also.inject.async 
                # ----------------------------
                # 
                # * Each of the hooks and the injection target function receive as 
                #   first arg a customised resolver.
                # 
                #       eg: beforeAll: (done) -> done()
                # 
                # * Upon calling done with an Error instance the 'flow of execution'
                #   is passed into the errorHandler (this function)
                # 
                # * This error handler is also asynchronous. In other words the 'flow
                #   of execution' on the injection remains suspended until this 
                #   errorHandler calls done()
                # 
                # * So if a before all hook in the injection sequence calls done with
                #   an error, the flow will not proceed to the before each hook waiting
                #   behind it.
                # 
                # * Calling done in this error handler releases the flow and effectively
                #   ignores the error. 
                # 
                # * OR
                # 
                # * Included as arg2 to to this handler is the injectionControl object
                #   with access to the 'parent' deferral that is doing the holding of 
                #   the flow. 
                # 
                #       ie. injectionControl.defer (is the 'parent' deferral)
                # 
                # * Calling injectionControl.defer.reject( error ) will terminate the
                #   flow of this injection instance.
                # 
                # * BUT!!
                #
                # * It will also not proceed to any subsequent injections waiting in 
                #   the queue.
                # 
                #       ie. 
                #            fn = also.inject.async
                #                parallel: false  # causes the queueing
                #                beforeAll: (done) -> done()
                #                onError: (done, injectionControl, error) -> 
                #                (done) -> 
                #                   #
                #                   # injection target function
                #                   # 
                #                   done new Error 'Moo'
                # 
                #            fn()   # first call to the injection target is queued via the injector
                #            fn()   # ...second into queue
                #            fn()   # ...3rd
                #                   # 
                #            fn()   # all these calls to fn() are queueing up in the background
                #                   # ---------------------------------------------------------
                #                   # 
                                    # * None of them have actually run the injection target function
                                    #   because the de-queue is on nextTick
                                    # 
                                    # * By calling injectionControl.defer.reject() once underway the
                                    #   entire de-queue sequence will be rejected. All remaining calls
                                    #   to the injection target will go unmade.
                                    # 
                                    # * By calling injectionControl.defer.resolve() the flow will 
                                    #   proceed to the next queued call.
                                    # 


                # #GREP4
                # TODO: send error event via message bus
                #       --------------------------------
                #       * async, await ignore flag
                # 
                #

                #
                # TODO: send error event via token
                #       if not ignore
                # 

                # console.log error
                # console.log error.stack

                root.context.token.emit 'error', error
                
                #
                # TODO: terminate the recursor if not ignored
                #


            #
            # inject.async() arg2 - Injection Target (ThePhraseRecursor)
            # ----------------------------------------------------------
            # 
            # * It passes a new instance of the recursor (newRecursorFn) as arg1 to the 
            #   nested phrase function
            # 
            # * The new recursor becomes the phrase registrar for the nested phrases.
            #
            # * Calls to the new recursor queue in the injector.
            # 
            #   ie. 
            #         phrase 'phrase title', (arg1)
            #         
            #             arg1 'nested phrase test', (...) -> 
            #             arg1 'another nested phrase test', (...) -> 
            #             arg1 'these are queueing'
            #             arg1 'they run on nextTick'
            #             arg1 """
            #                   ie. * whenever next the flow of execution breaks out
            #                         and node decides which pending turn to run in
            #                         the reactor queue
            #             
            #                       * nextTicks are pushed to the front of the reactor 
            #                         queue
            #              """
            # 
            #

            (phraseString, phraseControl, nestedPhraseFn) -> 
                                                #
                                                # leaf and boundry phrases inject noop here
                                                #
                                                # TODO: quite possibly simply injecting null 
                                                #       and doing no recursion in that case
                                                #       will more appropriately achieve the 
                                                #       desired effect.
                                                #       


                args = util.argsOf nestedPhraseFn
                console.log """

                    This may prove trickier than i thought...
                    -----------------------------------------

                    * is this available in the job run?
                    * if not, make it so
                    * once so, ...

                          How to get it into context?
                          Because the vertex phrases 
                          are not run at jobtime. 

                          UM...


                """: args if args.length > 1

                newRecursorFn = recursor phraseString, phraseControl
                nestedPhraseFn newRecursorFn



    injector = recursor 'ROOT', 

        phraseToken: 

            #
            # root phrase token contains title and uuid 
            # of phrase tree, from phrase.createRoot()
            # 

            signature: opts.title
            uuid:      opts.uuid

        timeout: opts.timeout
        boundry: opts.boundry
        leaf:    opts.leaf

    injector rootString, rootFn
