RecursorHooks  = require './recursor/hooks' 
PhraseHooks    = require './phrase_hooks'

#
# phrase recursor
# ===============
# 
# Performs the 'first walk' of the tree, to assemble. Does not
# run any of the hooks or leaf nodes.
# 

exports.walk = (root, opts, rootString, rootFn) ->

    {context, inject}                   = root
    {stack, notice, graph, PhraseGraph} = context

    context.hooks  = PhraseHooks.bind root


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

        recursionControl = RecursorHooks.bind root, parentPhraseControl

        #
        # recurse via async injector
        # 

        injectionFn = inject.async

            parallel:   false
            beforeAll:  recursionControl.beforeAll
            beforeEach: recursionControl.beforeEach
            afterEach:  recursionControl.afterEach
            afterAll:   recursionControl.afterAll
            onError:    (done, injectionControl, error) -> 

                console.log 

                    CONTROL: injectionControl
                    ERROR:   error

                console.log error.stack

                #
                # TODO: send error event via message bus
                #       --------------------------------
                #       * async, await ignore flag
                #

                #
                # TODO: send error event via token
                #       if not ignore
                # 
                
                #
                # TODO: terminate the recursor if not ignored
                #


            (phraseString, phraseControl, nestedPhraseFn) -> 

                nestedPhraseFn recursor phraseString, phraseControl


        #
        # recursor( phraseString, phraseControl ) 
        # returns injector function
        #

        return injectionFn


    injector = recursor 'ROOT', 

        phraseToken: 

            #
            # root phrase token contains title and uuid 
            # of phrase tree, from phrase.createRoot()
            # 

            name: opts.title
            uuid: opts.uuid

        timeout: opts.timeout
        leaf: opts.leaf

    injector rootString, rootFn
