should             = require 'should'
RecursorBeforeEach = require '../../../lib/recursor/control/before_each'
PhraseNode         = require '../../../lib/phrase_node'

describe 'RecursorBeforeEach', -> 

    root             = undefined
    injectionControl = undefined
    parent           = undefined

    beforeEach -> 

        root = 
            context: 
                stack: []

                #
                # mock notice pipeline
                #
                notice: 
                    info: -> then: (resolve) -> resolve()
                    event: -> then: (resolve) -> resolve()

                PhraseNode: PhraseNode.createClass root

            util: require('also').util

        injectionControl = 
            defer: resolve: ->
            args: ['phrase text', {}, (nested) -> ]

        parent = 
            phraseToken: name: 'it'
            detectLeaf: (phrase, isLeaf) -> isLeaf true 

    it 'extracts the injection deferral', (done) -> 
        
        Object.defineProperty injectionControl, 'defer', 
            get: -> 
                done()
                throw 'go no further'

        hook = RecursorBeforeEach.create root, parent
        try hook (->), injectionControl


    it 'calls the hook resolver', (done) -> 

        hook = RecursorBeforeEach.create root, parent
        hook done, injectionControl


    it 'pushes the new phrase into the stack and resolves the injection deferral if leaf', (done) -> 

        nestedPhraseFn = ->
        phraseHookFn = ->

        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, nestedPhraseFn ]
        parent.phraseToken = name: 'it', uuid: 'uuid'
        injectionControl.beforeEach = phraseHookFn
        
        injectionControl.defer = 

            resolve: -> 

                # 
                # the pushed phrase contains the injection deferral that the 
                # async injector wrapped around the pending call to phraseFn
                # 
                # beforeEach recursion control hook should have created the 
                # new Phrase with reference to that deferral (this mock)
                #
                # ensure that it did.....
                # 

                done()

        hook = RecursorBeforeEach.create root, parent

        hook (-> 

            root.context.stack[0].should.be.an.instanceof root.context.PhraseNode

            root.context.stack[0].text.should.equal 'phrase text'
            root.context.stack[0].uuid.should.equal 'uuid'  # only in case of root phrase
            root.context.stack[0].fn.should.equal nestedPhraseFn
            root.context.stack[0].token.name.should.equal 'it'
            root.context.stack[0].hooks.beforeEach.should.equal phraseHookFn


        ), injectionControl


    it 'hands error into injectionControl deferral if phraseText contains /', (done) -> 

        root.context.stack.push new root.context.PhraseNode

            token: name: 'context'
            text: 'the parent phrase'
            fn: ->

        parent.phraseToken = name: 'it'
        hook = RecursorBeforeEach.create root, parent
        injectionControl.args = [ 'does not allow / in phraseText', { uuid: 'UUID' }, (end) -> ]

        hook ( (result) ->

            result.should.be.an.instanceof Error
            result.should.match /INVALID text/
            done()

        ), injectionControl


    it 'can assign uuid from phraseControl for non root phrases', (done) -> 

        root.context.stack.push new root.context.PhraseNode

            token: name: 'context'
            text: 'the parent phrase'
            fn: ->

        injectionControl.args = [ 'is a leaf phrase', { uuid: 'UUID' }, (end) -> ]
        parent.phraseToken = name: 'it'
        hook = RecursorBeforeEach.create root, parent

        hook (-> 

            root.context.stack[1].uuid.should.equal 'UUID'
            done()

        ), injectionControl


    it 'does not assign uuid from parent phraseToken if not root phrase', (done) -> 

        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, -> ]
        parent.phraseToken = name: 'it', uuid: 'UUID'
        root.context.stack[0] = new root.context.PhraseNode

            token: name: 'describe'
            text: 'use case one'
            uuid: '000000'
            fn: ->

        injectionControl.defer = resolve: ->

        hook = RecursorBeforeEach.create root, parent
        hook (->

            root.context.stack[1].uuid.should.not.equal 'UUID'
            done()

        ), injectionControl


    it 'emits "phrase::edge:create" into the middleware pipeline', (done) -> 

        #
        # existing stack elements
        #

        root.context.stack.push new root.context.PhraseNode

            token: name: 'describe'
            text: 'use case one'
            fn: ->

        root.context.stack.push new root.context.PhraseNode

            token: name: 'context'
            text: 'the parent phrase'
            fn: ->

        #
        # pending new stack element
        #
        parent.phraseToken = name: 'it'
        injectionControl.args      = [ 'has this child in', {}, -> ]
        SEQUENCE = []
        EVENTS = {}
        root.context.notice.event = (event, payload) -> 

            SEQUENCE.push event
            EVENTS[event] = payload
            return then: (resolve) -> resolve() 

        hook = RecursorBeforeEach.create root, parent
        hook (->

            SEQUENCE.should.eql [ 'phrase::edge:create' ]

            should.exist event1 = EVENTS['phrase::edge:create']
            event1.type.should.equal 'tree'
            event1.leaf.should.equal true
            event1.vertices[0].text.should.equal 'the parent phrase'
            event1.vertices[1].text.should.equal 'has this child in'

            done()

        ), injectionControl


    it 'attaches phraseToken to phraseControl for injection at arg2', (done) -> 

        parentPhraseFn = (glia) -> 

        injectionControl.args = [ 'parent phrase text', { key: 'VALUE' }, parentPhraseFn ]
        hook = RecursorBeforeEach.create root, parent

        hook (-> 

            injectionControl.args[1].phraseToken.name.should.equal 'glia'
            done()

        ), injectionControl


    it 'tests if the phrase is a leaf', (done) -> 

        nestedPhraseFn = -> 
        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, nestedPhraseFn ]

        parent.detectLeaf = (phrase, isLeaf) ->

            phrase.fn.should.equal nestedPhraseFn
            done()

        hook = RecursorBeforeEach.create root, parent
        hook (->), injectionControl


    it 'ensures injection function as lastarg is at arg3 if phrase is not a leaf', (done) -> 

        nestedPhraseFn = -> 
        parent.detectLeaf = (phrase, isLeaf) -> isLeaf false

        hook = RecursorBeforeEach.create root, parent

        injectionControl.args = [ 'phrase text', { phrase: 'control' }, nestedPhraseFn ]
        hook (-> 
            injectionControl.args[2].should.equal nestedPhraseFn
        ), injectionControl


        injectionControl.args = [ 'phrase text', nestedPhraseFn ]
        hook (-> 
            injectionControl.args[2].should.equal nestedPhraseFn
        ), injectionControl


        injectionControl.args = [ nestedPhraseFn ]
        hook (-> 
            injectionControl.args[2].should.equal nestedPhraseFn
            done()
        ), injectionControl


    it 'replaces injection function with noop if phrase is a leaf', (done) -> 

        nestedPhraseFn = -> 'not noop'
        hook = RecursorBeforeEach.create root, parent
        injectionControl.args = [ 'phrase text', { phrase: 'control' }, nestedPhraseFn ]
        hook (-> 

            injectionControl.args[2].toString().should.match /function \(\) {}/
            done()

        ), injectionControl


