should              = require 'should'
Phrase              = require '../../lib/phrase_root'
PhraseRecursor      = require '../../lib/phrase/phrase_recursor'
PhraseHooks         = require '../../lib/phrase/phrase_hooks'

describe 'PhraseHooks', -> 

    it 'creates before and after hook registrars on the global scope', (done) -> 

        hooks = PhraseHooks.bind {}
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

        hooks.beforeAll[0].fn.should.equal beforeAll
        hooks.beforeAll[0].createdAt.should.equal  1375908472253
        hooks.beforeAll[0].runCount.should.equal  0 
        should.exist hooks.beforeAll[0].uuid

        hooks.beforeEach[0].fn.should.equal  beforeEach
        hooks.beforeEach[0].createdAt.should.equal  1375908472253
        hooks.beforeEach[0].runCount.should.equal  0
        should.exist hooks.beforeEach[0].uuid

        hooks.afterEach[0].fn.should.equal afterEach
        hooks.afterEach[0].createdAt.should.equal  1375908472253
        hooks.afterEach[0].runCount.should.equal  0
        should.exist hooks.afterEach[0].uuid

        hooks.afterAll[0].fn.should.equal afterAll
        hooks.afterAll[0].createdAt.should.equal  1375908472253
        hooks.afterAll[0].runCount.should.equal  0
        should.exist hooks.afterAll[0].uuid


        done()


    context 'run()', ->

        it 'increments the run count', (done) -> 


            tick = 0
            Date.now = -> ++tick
            hookFn = -> 'mooo'

            before each: hookFn

            hooks = PhraseHooks.bind {}
            hook  = hooks.beforeEach.pop()
            hook.runCount.should.equal 0
            hook.run()
            hook.run()

            hook.should.eql 

            hook.fn.should.equal hookFn
            hook.createdAt.should.equal 1
            hook.runCount.should.equal  2
            hook.lastRunAt.should.equal 3

            done()
