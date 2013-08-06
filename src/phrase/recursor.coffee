RecursorHooks  = require './recursor/hooks' 

#
# phrase recursor
# ===============
# 

exports.create = (root) ->

    {context, inject} = root
    {stack, emitter}  = context

    recursor = (phraseString, parentControl) -> 

        #
        # create recursion control hooks 
        #

        hooks = RecursorHooks.create root

        #
        # recurse via async injector
        # 

        injector = inject.async
        

            parallel:   false
            beforeAll:  hooks.beforeAll
            beforeEach: hooks.beforeEach


            (phraseString, control, recursor) -> 

                recursor()

    #
    # return root recursor
    #

    return recursor 'ROOT', {} 
                



