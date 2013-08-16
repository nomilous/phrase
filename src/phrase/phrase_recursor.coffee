RecursorHooks  = require './recursor/hooks' 
PhraseHooks    = require './phrase_hooks'

#
# phrase recursor
# ===============
# 
# Performs the 'first walk' of the tree, to assemble. Does not
# run any of the hooks or leaf nodes.
# 

exports.create = (root, opts) ->

    {context, inject} = root
    {stack, notice}   = context
    context.hooks     = PhraseHooks.bind root

    recursor = (parentPhraseString, parentPhraseControl) -> 

        # console.log arguments

        #
        # create recursion control hooks 
        # 

        #parent = control: parentPhraseControl
        recursionControl = RecursorHooks.bind root, parentPhraseControl

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
        # TEMPORARY: access stack as property of injector function
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

    return recursor 'ROOT', 

        phraseToken: 

            #
            # root phrase token contains title and uuid 
            # of phrase tree, from phrase.createRoot()
            # 

            name: opts.title
            uuid: opts.uuid

        timeout: opts.timeout
        leaf: opts.leaf
