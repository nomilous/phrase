Phrase = require '../../phrase'

#
# Before Each (recursion hook)
#

exports.create = (root) -> 

    {context} = root
    {stack, emitter} = context

    (done, injectionControl) -> 

        #
        # injectionControl
        # ------
        # 
        # This object controls the behaviour of the async injection into 
        # the target function in recursor: 
        # 
        #      `(phraseString, phraseControl, nestedPhraseFn) -> `
        # 
        # * injectionControl.defer is a deferral held by the async controller
        #   that wraps the call to the injection target. Ordinarilly it would
        #   be passed into the injection target function as arg1 (done)
        #   
        #   But, instead, calling it out here...
        # 

        defer = injectionControl.defer

        #   ...prevents that behaviour.      And leaves the alternative 
        #                                    resolution mechanism up to
        #                                    the developer
        #
        #  
        #  * Resolving this deferral results in the 'flow of execution'
        #    proceeding into the next phrase.
        # 
        # 
        #  * TEMPORARY !!!  this deferral resolves here
        #               (pending unimplemented mechanism)
        # 
        defer.resolve()


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

        phrase = new Phrase 

            text:    phraseText
            control: phraseControl
            fn:      phraseFn

        stack.push phrase

        #
        # ensure args for injection (phraseString, phraseControl, nestedPhraseFn)
        #

        injectionControl.args[0] = phraseText
        injectionControl.args[1] = phraseControl
        injectionControl.args[2] = phraseFn



        done()

