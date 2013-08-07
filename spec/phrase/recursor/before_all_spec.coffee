should             = require 'should'
RecursorBeforeAll  = require '../../../lib/phrase/recursor/before_all'
{PhraseHook}       = require '../../../lib/phrase/phrase_hooks'

describe 'RecursorBeforeAll', -> 
    
    root = undefined

    beforeEach -> 

        root = 
            context: 
                emitter: emit: -> 
                hooks: 
                    beforeAll: []
                    beforeEach: []
                    afterEach: []
                    afterAll: []


    it 'emits phrase::start event', (done) -> 

        root.context.emitter.emit = (event) -> 

            event.should.equal 'phrase::start'
            done()

        hook = RecursorBeforeAll.create root
        hook (->), {}


    it 'calls the recursion hook resolver', (done) -> 

        hook = RecursorBeforeAll.create root
        hook (
            -> done()
        ), {}


    it 'transfers any regisered hooks onto the injection control context', (done) -> 

        hook = RecursorBeforeAll.create root

        root.context.hooks.beforeAll.push  new PhraseHook -> 
        root.context.hooks.beforeEach.push new PhraseHook ->
        root.context.hooks.afterEach.push  new PhraseHook -> 
        root.context.hooks.afterAll.push   new PhraseHook -> 

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


