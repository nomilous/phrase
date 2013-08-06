should              = require 'should'
Phrase              = require '../../lib/phrase'
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


        it 'creates recursion control hooks with root context', (done) -> 

            PhraseRecursorHooks.create = (r) -> 

                r.should.equal root
                done()
                throw 'go no further'

            try PhraseRecursor.create root


        it 'configures the injection decorator and assigns recursion control hooks', (done) -> 

            PhraseRecursorHooks.create = -> 

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

            PhraseRecursor.create root


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


