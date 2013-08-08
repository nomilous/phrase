should              = require 'should'
Phrase              = require '../../lib/phrase_root'
PhraseRecursor      = require '../../lib/phrase/recursor'
PhraseRecursorHooks = require '../../lib/phrase/recursor/hooks'

describe 'PhraseRecursor', -> 

    context 'create()', -> 

        root = undefined
        asyncInjectionFn = ->


        beforeEach ->

            root = 

                context: {}
                inject:  
                    async: -> 
                        return asyncInjectionFn

        it 'returns a function created by the async injection decorator', (done) -> 

            PhraseRecursor.create( root ).should.equal asyncInjectionFn
            done()


        it 'creates recursion control hooks with root context and parent control', (done) -> 

            rootControl = {}
            PhraseRecursorHooks.bind = (rooot, parent) -> 

                rooot.should.equal root
                parent.control.should.equal rootControl
                done()
                throw 'go no further'

            try PhraseRecursor.create root, rootControl


        it 'configures the injection decorator and assigns recursion control hooks', (done) -> 

            PhraseRecursorHooks.bind = -> 

                beforeAll: 'assigned beforeAll' 
                beforeEach:'assigned beforeEach'
                afterEach: 'assigned afterEach'
                afterAll:  'assigned afterAll'


            root.inject.async = (Preparator, decoratedFn) ->   

                Preparator.should.eql 

                    parallel:   false
                    beforeAll:  'assigned beforeAll' 
                    beforeEach: 'assigned beforeEach'
                    afterEach:  'assigned afterEach'
                    afterAll:   'assigned afterAll'

                done()

                throw 'go no further'

            try PhraseRecursor.create root

        it 'assigns access to registered phrase hooks', (done) -> 

            before each: -> done()
            try PhraseRecursor.create root
            root.context.hooks.beforeEach[0].fn()


        it 'provides assess to stack', (done) -> 

            root.context.stack = 'STACK'
            root.inject.async = (Preparator, decoratedFn) ->  return {}
            recursor = PhraseRecursor.create root
            recursor.stack.should.equal 'STACK'
            done()


        it 'recurses via the injector', (done) -> 

            CALLS = []

            root.inject.async = (Preparator, decoratedFn) -> -> 

                CALLS.push arguments
                decoratedFn.apply this, arguments

            recursor = PhraseRecursor.create root

            recursor 'outer phrase string', {}, (nested) ->

                nested 'nested phrase string', {}, (deeper) -> 

                    deeper '...', {}, ->

                        CALLS[0][0].should.equal 'outer phrase string'
                        CALLS[1][0].should.equal 'nested phrase string'
                        CALLS[2][0].should.equal '...'

                        done()


