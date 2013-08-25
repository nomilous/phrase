should       = require 'should'
PhraseHooks  = require '../../lib/phrase/phrase_hooks'

describe 'PhraseHooks', -> 

    hooks = PhraseHooks.bind timeout: 200

    it 'creates before and after hook registrars on the global scope', (done) -> 
 
        before.should.be.an.instanceof Function
        after.should.be.an.instanceof Function
        before.toString().should.match /opts.each/
        after.toString().should.match /opts.each/
        done()


    it 'binds access to registered hooks', (done) -> 

        hooks.beforeAll.should.eql  []
        hooks.beforeEach.should.eql []
        hooks.afterEach.should.eql  []
        hooks.afterAll.should.eql   []
        done()


    it 'registered hooks are accessable through the bind', (done) -> 

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

        hooks.beforeAll[0].fn.should.equal beforeAll
        should.exist hooks.beforeAll[0].uuid

        hooks.beforeEach[0].fn.should.equal  beforeEach
        should.exist hooks.beforeEach[0].uuid

        hooks.afterEach[0].fn.should.equal afterEach
        should.exist hooks.afterEach[0].uuid

        hooks.afterAll[0].fn.should.equal afterAll
        should.exist hooks.afterAll[0].uuid


        done()


    it 'default hook timeout from root timeout', (done) -> 

        
        before 
            all: (done) -> done()

        hooks.beforeAll.pop().timeout.should.equal 200
        done()


    it 'allows local timeout override', (done) -> 


        before 
            timeout: 2
            all: (done) -> done()

        hooks.beforeAll.pop().timeout.should.equal 2
        done()