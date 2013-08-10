PhraseNode = require '../../phrase_node'
PhraseLeaf = require './leaf'

#
# Before Each (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context, util}  = root
    {stack, notice}  = context
    {control}        = parentControl

    phraseLeaf = PhraseLeaf.create root

    (done, injectionControl) -> 

        #
        # injectionControl
        # ----------------
        # 
        # This object controls the behaviour of the async injection into 
        # the target function for the recursor's 'first walk'
        # 
        # * injectionControl.defer is a deferral held by the async controller
        #   that wraps the call to the injection target. Ordinarilly it would
        #   be passed into the injection target function as arg1 (done)
        #   
        #   But, instead, calling it out here...
        # 

        deferral = injectionControl.defer

        #   ...prevents that behaviour.      And leaves the alternative 
        #                                    resolution mechanism up to
        #                                    the developer.
        # 
        #          Having suspended the call to this resolver allows the 
        #          recursor to suspend the call into the next phrase until
        #          all the children of this phrase have been traversed.
        #
        #          This resolver is called in the afterAll hook of the
        #          child injector. #GREP1
        #
        # 


        #
        # * injectionControl.args are the inbound args that were called into the 
        #   decorated function that was returned by inject.async.
        # 
        # * These args are used to assemble a Phrase to be pushed into the stack
        # 
        # * These args are then passed oneward to the injection target for recrsion.
        # 

        phraseText    = if typeof injectionControl.args[0] == 'function' then {} else injectionControl.args[0]
        phraseControl = if typeof injectionControl.args[1] == 'function' then {} else injectionControl.args[1]
        phraseFn      = injectionControl.args[2] || injectionControl.args[1] || injectionControl.args[0] || -> console.log 'NO ARGS'


        injectionControl.args[0] = phraseText
        injectionControl.args[1] = phraseControl
        injectionControl.args[2] = phraseFn

        #
        # phraseToken 
        # -----------
        # 
        # * is the signature name of the nested phrase recursor
        #  
        #     ie.    
        #           phrase 'text', (nest) -> 
        #                   
        #               #    
        #               # `nest` is now the phraseToken name
        #               # 
        #              
        # * is carried through the injection to become the phraseToken 
        #   associated with each nested child phrase
        #    

        if phraseControl? 

            phraseControl.phraseToken = name: util.argsOf( phraseFn )[0]


        #
        # inject new phrase into stack
        #

        stack.push phrase = new PhraseNode 

            text:     phraseText
            token:    control.phraseToken
            
            #
            # TODO: determine phrase line in source file
            #       
            #       1. IDE plugins could then interact
            #          directly with phrases
            # 
            #          eg. nez - test results in sublime furrow
            #                  - running single tests or context
            #                    groups by click or keystroke on
            #                    active line
            # 

            #
            # TODO: make these less exposed
            #

            hooks: 

                beforeAll:  injectionControl.beforeAll
                beforeEach: injectionControl.beforeEach
                afterEach:  injectionControl.afterEach
                afterAll:   injectionControl.afterAll

            # control:  phraseControl
            fn:       phraseFn
            deferral: deferral
            queue:    injectionControl.queue


        #
        # is this phrase a leaf
        #

        phraseLeaf.detect phrase, (leaf) -> 

            #
            # when this phrase is a leaf
            # --------------------------
            # 
            # * inject noop as phraseFn into the recursor instead of 
            #   the nestedPhraseFn that contains the recursive call
            # 
            # * TEMPORARY emit 'phrase::leaf:create' with text path and vertex map
            # 
            # * resolve the phraseFn promise so that the recusrion 
            #   control thinks it was run   
            # 

            if leaf 

                injectionControl.args[2] = ->

                #
                # TEMPORARY (or partially temporary)
                #

                notice.event 'phrase::leaf:create',

                    uuid:  phrase.uuid
                    path:  stack.map( (p) -> p.uuid ) # .filter (uuid) -> uuid != phrase.uuid
                    convenience: stack.map( (p) -> "/#{ p.token.name }/#{ p.text }" ).join ''

            finished = (result_or_error) -> 

                #
                # result / error from messenger pipeline
                #

                done()

                if leaf then process.nextTick -> 

                    #
                    # leaf node resolves self, there are
                    # no children to recurse into
                    # 
                    # #GREP1
                    #

                    deferral.resolve()

            notice.event( 'phrase::edge:create'

                #
                # trees as special case of graph, edge needs to know
                # 

                type: 'tree'
                leaf: leaf

                #
                # top two phraseNodes in the stack are parent and this
                #

                vertices: stack[ -2.. ]

            ).then finished, finished



