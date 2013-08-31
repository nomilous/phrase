sequence            = require 'when/sequence'
PhraseTokenFactory  = require '../../token/phrase_token'
BoundryHandler      = require '../boundry_handler'
{v1}                = require 'node-uuid'

#
# Before Each (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context, util}  = root
    {stack, notice, PhraseNode, PhraseToken} = context

    (done, injectionControl) -> 

        #
        # injectionControl
        # ----------------
        # 
        # * injectionControl.defer is a deferral held by the async controller
        #   that wraps the call to the injection target. Ordinarilly it would
        #   be passed into the injection target function (ThePhraseRecursor) 
        #   as arg1 `(done) ->`
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
        # injectionControl.args
        # ---------------------
        #
        # * injectionControl.args are the inbound args that were called into the 
        #   decorated function that was returned by inject.async.
        # 
        # * These args are used to assemble a Phrase to be pushed into the stack
        #   for PhraseTree assembly.
        #

        phraseText    = if typeof injectionControl.args[0] == 'function' then '' else injectionControl.args[0]
        phraseControl = if typeof injectionControl.args[1] == 'function' then {} else injectionControl.args[1]
        phraseFn      = injectionControl.args[2] || injectionControl.args[1] || injectionControl.args[0] || -> console.log 'NO ARGS'

        phraseControl          ||= {}
        phraseControl.leaf     ||= parentControl.leaf      # inherites
        phraseControl.boundry  ||= parentControl.boundry   # unless 
        phraseControl.timeout  ||= parentControl.timeout   # defined

        # 
        # * Assign final args to be injected into ThePhraseRecursor.
        # 

        injectionControl.args[0] = phraseText
        injectionControl.args[1] = phraseControl
        injectionControl.args[2] = phraseFn  # becomes noop for leaf or boundry phrases

        try  

            if phraseControl? 

                phraseControl.phraseToken = signature: util.argsOf( phraseFn )[0]

            #
            # create phraseToken according to phraseType
            # ------------------------------------------
            #

            phraseType = actualPhraseType = parentControl.phraseType phraseFn
                                #
                                # needed if root is also a leaf or boundy
                                #

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
            # ---------------------------
            # 
            # * Errors are passed into the TreeWalkers error handler
            # * It has capacity to terminate the recursion of the current phrase
            # 
            # #GREP4
            #

            #SUSPECT1 done error
            # 
            # - not clear on how this affects the recursion 
            #  (or how it 'should' affect it)
            # 
            return done error


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

            if phraseType == 'leaf' then return process.nextTick -> 

                #
                # * inject noop into 'ThePhraseRecursor'
                #

                injectionControl.args[2] = ->

                #
                # leaf node resolves self, there are
                # no children to recurse into
                # 
                # #GREP1
                #

                done()
                deferral.resolve()


            if actualPhraseType == 'boundry'

                injectionControl.args[2] = -> 

                #
                # * Call the phaseFn and accumulate the calls it makes to link
                #

                linkQueue = []
                phrase.fn link: (opts) -> linkQueue.push opts

                sequence( for opts in linkQueue

                    #
                    # * Each call to BoundryHandler returns the promise necessary 
                    #   for the sequence's flow control.
                    #

                    do (opts) -> -> BoundryHandler.link root, opts

                ).then(

                    #
                    # * All boundries handled successfully
                    # * Dont send resolve (result array) to injection resolver.
                    #

                    (resolve) -> done()

                    #
                    # TODO: one boundry hander error terminates the entire sequence
                    #       should it? && ?fix it
                    #
                        
                    # (reject)  -> done reject 
                    done #GREP4

                    (notify)  -> # console.log NOTIFY: notify

                )

                return



            #
            # vertex or root phrases, continue to injection recursor
            #

            done()

                    

            

