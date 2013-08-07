should              = require 'should'
Phrase              = require '../../lib/phrase'
PhraseRecursor      = require '../../lib/phrase/recursor'
PhraseHooks         = require '../../lib/phrase/phrase_hooks'

describe 'PhraseHooks', -> 

    it 'creates before and after properties in global scope', (done) -> 

        before.toString().should.match /opts.each/
        before.toString().should.match /opts.each/
        done()


    it 'enables access to the registered hooks', (done) -> 

        hooks = PhraseHooks.create {}

        hooks.beforeAll.should.eql  []
        hooks.beforeEach.should.eql []
        hooks.afterEach.should.eql []
        hooks.afterAll.should.eql   []
        done()


    it 'populated the hook arrays', (done) -> 

        before 
            each: -> 'beforeEach'
            all:  -> 'beforeAll'

        after 
            each: -> 'afterEach'
            all:  -> 'afterAll'


        hooks = PhraseHooks.create {}

        hooks.beforeAll[0]().should.equal 'beforeAll'
        hooks.beforeEach[0]().should.equal 'beforeEach'
        hooks.afterEach[0]().should.equal 'afterEach'
        hooks.afterAll[0]().should.equal 'afterAll'
        done()