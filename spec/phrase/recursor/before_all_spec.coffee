should             = require 'should'
RecursorBeforeAll  = require '../../../lib/phrase/recursor/before_all'
{PhraseHook}       = require '../../../lib/phrase/phrase_hooks'

describe 'RecursorBeforeAll', -> 
    
    root = undefined

    beforeEach -> 

        root = 
            context: 
                notice: event: -> then: (resolve) -> resolve() 
                hooks: 
                    beforeAll: []
                    beforeEach: []
                    afterEach: []
                    afterAll: []


    it 'calls the recursion hook resolver', (done) -> 

        hook = RecursorBeforeAll.create root
        hook (
            -> done()
        ), {}


    it 'transfers any regisered hooks onto the injection control context', (done) -> 

        hook = RecursorBeforeAll.create root

        root.context.hooks.beforeAll.push  new PhraseHook root, 'beforeAll',  all:  -> 
        root.context.hooks.beforeEach.push new PhraseHook root, 'beforeEach', each: -> 
        root.context.hooks.afterEach.push  new PhraseHook root, 'afterEach',  each: -> 
        root.context.hooks.afterAll.push   new PhraseHook root, 'afterAll',   all:  -> 

        injectionControl = {}

        hook (->

            #
            # recursion control hook was resolved
            #

            #
            # and all phrase hooks were attached to the injectionControl
            # to be run by their corresponding recursion control hooks
            #

            injectionControl.beforeAll.should.be.an.instanceof PhraseHook
            injectionControl.beforeEach.should.be.an.instanceof PhraseHook
            injectionControl.afterEach.should.be.an.instanceof PhraseHook
            injectionControl.afterAll.should.be.an.instanceof PhraseHook

            done()

        ), injectionControl


    it 'generates "phrase::recurse:start" at the beginning of the "first walk" and marks the start', (done) -> 

        EVENT = undefined 
        Date.now = -> 1
        root.context.notice.event = (title) -> 

            EVENT = title
            then: (resolve) -> resolve()

        hook = RecursorBeforeAll.create root
        hook (->

            EVENT.should.equal 'phrase::recurse:start'
            root.context.walking.startedAt.should.equal 1
            done()

        ), {}
