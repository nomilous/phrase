should             = require 'should'
RecursorBeforeAll  = require '../../../lib/recursor/control/before_all'
{PhraseHook}       = require '../../../lib/phrase/hook'
also               = require 'also'

describe 'RecursorBeforeAll', -> 
    
    root = undefined

    beforeEach -> 

        root = 
            uuid: 'ROOTUUID'
            util: also.util
            context: 
                notice: phrase: -> then: (resolve) -> resolve() 
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


    it 'generates "phrase::recurse:start" at the beginning of the first walk and flags as first', (done) -> 

        EVENT   = undefined
        PAYLOAD = undefined
        Date.now = -> 1
        root.context.notice.phrase = (title, payload) -> 

            EVENT   = title
            PAYLOAD = payload
            then: (resolve) -> resolve()

        hook = RecursorBeforeAll.create root
        hook (->

            EVENT.should.equal 'phrase::recurse:start'
            PAYLOAD.root.uuid.should.equal 'ROOTUUID'
            root.context.walking.startedAt.should.equal 1
            root.context.walking.first.should.equal true
            done()

        ), {}

    it 'flags and not first walk if context.walks has acucmulated a history', (done) -> 


        EVENT = undefined 
        Date.now = -> 1
        root.context.notice.phrase = (title) -> 

            EVENT = title
            then: (resolve) -> resolve()

        root.context.walks = []
        hook = RecursorBeforeAll.create root
        hook (->

            EVENT.should.equal 'phrase::recurse:start'
            root.context.walking.startedAt.should.equal 1
            root.context.walking.first.should.equal false
            done()

        ), {}

