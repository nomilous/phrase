sequence            = require 'when/sequence'
PhraseTokenFactory  = require '../../token/phrase_token'
{v1}                = require 'node-uuid'

#
# Before Each (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context, util}  = root
    {stack, notice, PhraseNode, PhraseToken} = context

    #phraseLeaf = PhraseLeaf.create root, parentControl

    


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
        phraseControl.boundry  ||= parentControl.boundry
        phraseControl.timeout  ||= parentControl.timeout
        injectionControl.args[0] = phraseText
        injectionControl.args[1] = phraseControl
        injectionControl.args[2] = phraseFn

        try  

            if phraseControl? 

                phraseControl.phraseToken = signature: util.argsOf( phraseFn )[0]

            #
            # create phraseToken according to phraseType
            # ------------------------------------------
            #

            phraseType = parentControl.phraseType phraseFn

            if stack.length == 0

                phraseType  = 'root'
                uuid  = parentControl.phraseToken.uuid

            else 

                uuid = phraseControl.uuid

            phraseToken = new PhraseToken

                type: phraseType

                uuid: uuid || v1()

                #
                # * signature is the signature name of the recursor that 
                #   created the phrase assiciated with the token. 
                # 
                #   ie. 
                # 
                #     recurse 'this phrase has token signature "recurse"', (nest) -> 
                # 
                #         nest 'this phrase has token signature "nest"', (end) -> 
                #

                signature: parentControl.phraseToken.signature


            stack.push phrase = new PhraseNode 

                text:     phraseText
                token:    phraseToken

                #
                # TEMPORARY
                #
                uuid:     phraseToken.uuid

                #
                # TEMPORARY
                #
                # leaf:     phraseType == 'leaf'

                timeout:  phraseControl.timeout
                hooks: 
                                            #
                                            # copying the same instance of the phase hooks 
                                            # into each nested phase has lead to some 
                                            # undesired complexity  #GREP3
                                            #
                                            # correcting it will affect how the AccessToken's 
                                            # call to run a phrase assembels the step sequence 
                                            # to pass to the Job, specifically the mechanisms 
                                            # for not repeating the 'All' hook steps
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

            done error



        # parentControl.detectLeaf phrase, (leaf) -> 

        #     #
        #     # when this phrase is a leaf
        #     # --------------------------
        #     # 
        #     # * inject noop as phraseFn into the recursor instead of 
        #     #   the nestedPhraseFn that contains the recursive call
        #     # 
        #     # * emit 'phrase::edge:create' for the graph assembler
        #     # 
        #     # * resolve the phraseFn promise so that the recusrion 
        #     #   control thinks it was run
        #     # 

        if phraseType == 'leaf' then injectionControl.args[2] = ->

        run = sequence [

            ->  

                notice.event 'phrase::edge:create',

                    #
                    # trees as special case of graph, edge needs to know
                    # 

                    type: 'tree'

                    #
                    # top two phraseNodes in the stack are parent and this
                    #

                    vertices: stack[ -2.. ]

        ]

        run.then -> 

            done()

            if phraseType == 'leaf' then process.nextTick -> 

                #
                # leaf node resolves self, there are
                # no children to recurse into
                # 
                # #GREP1
                #

                deferral.resolve()


            if phraseType == 'boundry'

                #
                # TEMPORARY: boundry node runs the phrase function 
                #

                result = phrase.fn -> 

                deferral.resolve()



