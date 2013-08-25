should             = require 'should'
RecursorAfterEach  = require '../../../lib/recursor/control/after_each'

describe 'RecursorAfterEach', -> 

    root             = undefined
    #injectionControl = undefined

    beforeEach -> 

        root = context: 
            emitter: emit: ->
            stack: []
        # injectionControl = 
        #     defer: resolve: ->
        #     args: []

    it 'pops phrases from the stack', (done) -> 

        root.context.stack.pop = done
        hook = RecursorAfterEach.create root
        hook -> 

            
