RecursorHooks  = require './recursor/hooks' 

#
# phrase recursor
# ===============
# 

exports.create = (root) ->

    {context, inject} = root
    {stack, emitter}  = context

    recursor = (parentPhraseString, parentPhraseControl) -> 

        #
        # create recursion control hooks 
        #

        recursionControl = RecursorHooks.create root

        #
        # recurse via async injector
        # 

        injectionFn = inject.async


            parallel:   false
            beforeAll:  recursionControl.beforeAll
            beforeEach: recursionControl.beforeEach
            afterEach:  recursionControl.afterEach
            afterAll:   recursionControl.afterAll

            (phraseString, phraseControl, nestedPhraseFn) -> 

                nestedPhraseFn recursor phraseString, phraseControl

        #
        # access stack as property of injector function
        #

        Object.defineProperty injectionFn, 'stack', 

            get: -> stack 

        #
        # recursor( phraseString, phraseControl ) 
        # returns injector function
        #

        return injectionFn



    #
    # return root recursor (injectionFn)
    #

    return recursor 'ROOT', {} 
                
