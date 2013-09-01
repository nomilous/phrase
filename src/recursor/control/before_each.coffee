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

        phraseTitle   = if typeof injectionControl.args[0] == 'function' then '' else injectionControl.args[0]
        phraseControl = if typeof injectionControl.args[1] == 'function' then {} else injectionControl.args[1]
        phraseFn      = injectionControl.args[2] || injectionControl.args[1] || injectionControl.args[0] || -> console.log 'NO ARGS'

        phraseControl          ||= {}
        phraseControl.leaf     ||= parentControl.leaf      # inherites
        phraseControl.boundry  ||= parentControl.boundry   # unless 
        phraseControl.timeout  ||= parentControl.timeout   # defined

        # 
        # * Assign final args to be injected into ThePhraseRecursor.
        # 

        injectionControl.args[0] = phraseTitle
        injectionControl.args[1] = phraseControl
        injectionControl.args[2] = phraseFn  # becomes noop for leaf or boundry phrases


        #
        # Phrase and Token assembly
        # -------------------------
        # 
        # * This pushes the stack from which 'phrase::edge:create' events are 
        #   transmitted into the PhraseGraph.assemble via the message bus.
        # 
        # * The stack is popped on the return walk (in recursor/control/after_each)
        #

        try  

            if phraseControl? 

                phraseControl.phraseToken = signature: util.argsOf( phraseFn )[0]

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

                title:     phraseTitle
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
                # * inject noop into 'ThePhraseRecursor', (no children)
                #   #GREP1
                #

                injectionControl.args[2] = ->
                done()
                deferral.resolve()


            if actualPhraseType == 'boundry'

                #
                # * Call the phaseFn and accumulate the calls it makes to link
                #

                linkQueue = []
                phrase.fn link: (opts) -> linkQueue.push opts

                if linkQueue.length == 0 then return process.nextTick ->

                    #
                    # * empty boundry phrase, same as leaf. 
                    #

                    injectionControl.args[2] = -> 
                    done()
                    deferral.resolve()

                
                sequence( for opts in linkQueue

                    #
                    # * Each call to BoundryHandler returns the promise necessary 
                    #   for the sequence's flow control.
                    #

                    do (opts) -> -> BoundryHandler.link root, opts

                ).then(

                    #
                    # * All boundry links have been processed.
                    # 

                    (boundries) -> 

                        #
                        # * boundries is an array of arrays, reduce it to
                        #   arrays by boundry mode
                        # 

                        #
                        # Boundry Mode
                        # ------------
                        # 
                        # Refers to how the PhraseTree on the other side of the boundry is attached 
                        # to this PhraseTree
                        # 
                        # ### refer 
                        # 
                        # `boundry token carries reference to the 'other' tree`
                        # 
                        # Each PhraseTree from across the boundry is built onto a new root on the 
                        # core and a reference if placed into this PhraseTree at the vertex where
                        # the link was called.
                        # 
                        # ### nest
                        # 
                        # `graph assembly continues with recrsion across the phrase boundry`
                        # 
                        # Each PhraseTree from the other side of the boundry is grafted into this
                        # PhraseTree at the vertex where the link was called. 
                        #  
                        #  
                        
                        phrases = refer: [], nest: []

                        boundries.reduce( (a, b) -> a.concat b ).map (boundry) -> 

                            phrases[ boundry.opts.mode ].push 

                                opts: boundry.opts
                                phrase: boundry.phrase


                        sequence([


                            #
                            # TODO: handle refer boundry mode
                            # -------------------------------
                            # 
                            # * create new phrase tree for each boundy phrass
                            # 
                            # * push a phrase containing reference to the new tree's root
                            #   into the local stack 
                            #  
                            # * send phrase::edge:create onto the bus so that the local graph
                            #   stores the reference to another tree as a local leaf
                            # 
                            # * pop the stack (and repeat for each boundry phrase)
                            # 

                            #-> if phrases.refer.length > 0
                                



                            #
                            # handle nest boundry mode
                            # ------------------------------    
                            #  
                            # * pass local closure containing assembled phrases into the recursor 
                            #   as a phrase of nested phrases
                            # 

                            -> if phrases.nest.length > 0

                                injectionControl.args[2] = (recursor) -> 

                                    phrases.nest.map ({opts, phrase}) -> 

                                        recursor phrase.title, phrase.control, phrase.fn


                        ]).then(

                            -> done()
                            (reject) -> done( reject )


                        )

                    #
                    # TODO: one boundry hander error terminates the entire sequence
                    #       should it? && ?fix it
                    #
                        
                    (reject)  -> done reject 

                )

                return



            #
            # vertex or root phrases, continue to injection recursor
            #

            done()

                    

            

