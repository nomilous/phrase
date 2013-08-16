should              = require 'should'
PhraseRecursor      = require '../../lib/phrase/phrase_recursor'
PhraseRecursorHooks = require '../../lib/phrase/recursor/hooks'

describe 'PhraseRecursor', -> 

    context 'create()', -> 

        root = undefined
        opts = undefined
        asyncInjectionFn = ->


        beforeEach ->

            root = 
                context: {}
                inject:  
                    async: -> 
                        return asyncInjectionFn

            opts = 
                title: 'Title'
                uuid:  '00000'
                leaf: ['end']
                timeout: 1000

        it 'returns a function created by the async injection decorator', (done) -> 

            PhraseRecursor.create( root, opts ).should.equal asyncInjectionFn
            done()


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

            try PhraseRecursor.create root, opts



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

            try PhraseRecursor.create root, opts

        it 'assigns access to registered phrase hooks', (done) -> 

            before each: -> done()
            try PhraseRecursor.create root, opts
            root.context.hooks.beforeEach[0].fn()


        it 'provides assess to stack', (done) -> 

            root.context.stack = 'STACK'
            root.inject.async = (Preparator, decoratedFn) ->  return {}
            recursor = PhraseRecursor.create root, opts
            recursor.stack.should.equal 'STACK'
            done()


        it 'recurses via the injector', (done) -> 

            CALLS = []

            root.inject.async = (Preparator, decoratedFn) -> -> 

                CALLS.push arguments
                decoratedFn.apply this, arguments

            recursor = PhraseRecursor.create root, opts

            recursor 'outer phrase string', {}, (nested) ->

                nested 'nested phrase string', {}, (deeper) -> 

                    deeper '...', {}, ->

                        CALLS[0][0].should.equal 'outer phrase string'
                        CALLS[1][0].should.equal 'nested phrase string'
                        CALLS[2][0].should.equal '...'

                        done()


