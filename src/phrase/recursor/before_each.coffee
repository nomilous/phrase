PhraseLeaf = require './leaf'
sequence   = require 'when/sequence'

#
# Before Each (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context, util}  = root
    {stack, notice, PhraseNode} = context

    phraseLeaf = PhraseLeaf.create root, parentControl

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

        phraseText    = if typeof injectionControl.args[0] == 'function' then '' else injectionControl.args[0]
        phraseControl = if typeof injectionControl.args[1] == 'function' then {} else injectionControl.args[1]
        phraseFn      = injectionControl.args[2] || injectionControl.args[1] || injectionControl.args[0] || -> console.log 'NO ARGS'


        #
        # inherit parent control unless re-defined and assign injection args
        #

        phraseControl          ||= {}
        phraseControl.leaf     ||= parentControl.leaf
        phraseControl.timeout  ||= parentControl.timeout
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

        if stack.length == 0 

            #
            # root node is assigned uuid of the phrase tree
            #

            uuid = parentControl.phraseToken.uuid 

        else 

            #
            # others can optionally be set on the phraseControl
            # 
            #    nested 'phrase text', uuid: '123', (end) -> 
            #

            uuid = phraseControl.uuid


        #console.log TODO: 'allow no / in phraseString'

        try 

            stack.push phrase = new PhraseNode 

                text:     phraseText
                token:    parentControl.phraseToken
                uuid:     uuid
                timeout:  phraseControl.timeout
                hooks: 
                                            #
                                            # copying the same instance of the phase hooks 
                                            # into each nested phase has lead to some 
                                            # undesired complexity  #GREP3
                                            #
                                            # correcting it will affect how the PhraseRunner
                                            # assembels the step sequence to pass to the
                                            # PhraseJob, specifically the mechanisms for 
                                            # not repeating the 'All' hooks.
                                            #
                                            
                    beforeAll:  injectionControl.beforeAll
                    beforeEach: injectionControl.beforeEach
                    afterEach:  injectionControl.afterEach
                    afterAll:   injectionControl.afterAll

                fn:       phraseFn
                deferral: deferral
                queue:    injectionControl.queue

        catch error

            #
            # could not create new phrase
            #

            return done error


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
            # * emit 'phrase::edge:create' for the graph assembler
            # 
            # * resolve the phraseFn promise so that the recusrion 
            #   control thinks it was run
            # 

            if leaf then injectionControl.args[2] = ->

            run = sequence [

                ->  

                    notice.event 'phrase::edge:create',

                        #
                        # trees as special case of graph, edge needs to know
                        # 

                        type: 'tree'
                        leaf: leaf

                        #
                        # top two phraseNodes in the stack are parent and this
                        #

                        vertices: stack[ -2.. ]

            ]

            run.then -> 

                done()

                if leaf then process.nextTick -> 

                    #
                    # leaf node resolves self, there are
                    # no children to recurse into
                    # 
                    # #GREP1
                    #

                    deferral.resolve()

