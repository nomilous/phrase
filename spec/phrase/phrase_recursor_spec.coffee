should              = require 'should'
PhraseRecursor      = require '../../lib/phrase/phrase_recursor'
PhraseRecursorHooks = require '../../lib/phrase/recursor/hooks'

describe 'PhraseRecursor', -> 

    context 'create()', -> 

        root  = undefined
        opts  = undefined
        swap1 = undefined
        asyncInjectionFn = ->


        beforeEach ->

            swap1 = PhraseRecursorHooks.bind

            root = require 'also'
            root.context = 
                stack:  []
                notice: 
                    event: -> then: (fn) -> fn()
                    info:  -> then: (fn) -> fn()     

            opts = 
                title: 'Title'
                uuid:  '00000'
                leaf: ['end']
                timeout: 1000

        afterEach -> 

            PhraseRecursorHooks.bind = swap1


        it 'creates recursion control hooks with root context and parent control', (done) -> 

            PhraseRecursorHooks.bind = (rooot, parent) -> 

                rooot.should.equal root
                done()
                throw 'go no further'

            try PhraseRecursor.create root, opts


        it 'assigns root token name and uuid from branch title', (done) -> 

            PhraseRecursorHooks.bind = (rooot, parent) -> 

                parent.phraseToken.name.should.equal 'Title'
                parent.phraseToken.uuid.should.equal '00000'
                done()
                throw 'go no further'

            try PhraseRecursor.create root, opts, 'phrase string', (nest) ->


        it 'assigns access to registered phrase hooks', (done) -> 
   
            PhraseRecursor.create root, opts, 'phrase string', (nest) ->
            before each: -> done()
            root.context.hooks.beforeEach[0].fn()


        xit 'TEMPORARY provides assess to stack', (done) -> 
            
            PhraseRecursor.create root, opts, 'phrase', (nested) -> 

                nested.stack.should.equal root.context.stack
                done()


        it 'recurses via the injector', (done) -> 

            CALLS = []

            root.inject.async = (Preparator, decoratedFn) -> -> 

                CALLS.push arguments
                args = [arguments[0], arguments[1], arguments[2]]
                args[2] = args[1] unless args[2]?
                decoratedFn.apply this, args

            PhraseRecursor.create root, opts, 'outer phrase string', (nested) ->

                nested 'nested phrase string', {}, (deeper) -> 

                    deeper '...', {}, ->

                        CALLS[0][0].should.equal 'outer phrase string'
                        CALLS[1][0].should.equal 'nested phrase string'
                        CALLS[2][0].should.equal '...'

                        done()


