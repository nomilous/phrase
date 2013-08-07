RecursorHooks  = require './recursor/hooks' 
PhraseHooks    = require './phrase_hooks'

#
# phrase recursor
# ===============
# 

exports.create = (root) ->

    {context, inject} = root
    {stack, emitter}  = context
    context.hooks     = PhraseHooks.bind root

    recursor = (parentPhraseString, parentPhraseControl) -> 

        #
        # create recursion control hooks 
        #

        recursionControl = RecursorHooks.bind root

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
            enumarable: false
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
                
