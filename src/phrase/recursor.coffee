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

        injector = inject.async


            parallel:   false
            beforeAll:  recursionControl.beforeAll
            beforeEach: recursionControl.beforeEach
            afterEach:  recursionControl.afterEach
            afterAll:   recursionControl.afterAll

            (phraseString, phraseControl, nestedPhraseFn) -> 

                nestedPhraseFn recursor phraseString, phraseControl

    #
    # return root recursor
    #

    return recursor 'ROOT', {} 
                



