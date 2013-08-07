should              = require 'should'
Phrase              = require '../../lib/phrase_root'
PhraseRecursor      = require '../../lib/phrase/recursor'
PhraseHooks         = require '../../lib/phrase/phrase_hooks'

describe 'PhraseHooks', -> 

    it 'creates before and after hook registrars on the global scope', (done) -> 

        before.should.be.an.instanceof Function
        after.should.be.an.instanceof Function
        before.toString().should.match /opts.each/
        after.toString().should.match /opts.each/
        done()


    it 'binds access to registered hooks', (done) -> 

        hooks = PhraseHooks.bind {}
        hooks.beforeAll.should.eql  []
        hooks.beforeEach.should.eql []
        hooks.afterEach.should.eql  []
        hooks.afterAll.should.eql   []
        done()


    it 'registered hooks are accessable through the bind', (done) -> 

        Date.now = -> 1375908472253

        #
        # create an register some hooks
        # 

        beforeAll  = -> 
        beforeEach = -> 
        afterEach  = ->
        afterAll   = ->

        before 
            all:  beforeAll
            each: beforeEach
            
        after 
            each: afterEach
            all:  afterAll

        #
        # bind access to the hooks
        #

        hooks = PhraseHooks.bind {}

        hooks.should.eql 

            beforeAll: [ 
                fn: beforeAll
                createdAt: 1375908472253
                runCount: 0 
            ]

            beforeEach: [ 
                fn: beforeEach
                createdAt: 1375908472253
                runCount: 0 
            ]

            afterEach: [ 
                fn: afterEach
                createdAt: 1375908472253
                runCount: 0
            ]

            afterAll: [ 
                fn: afterAll
                createdAt: 1375908472253
                runCount: 0
            ] 

        done()