should              = require 'should'
RecursorBeforeEach  = require '../../../lib/recursor/control/before_each'
PhraseNode          = require '../../../lib/phrase/node'
LeafTokenFactory    = require '../../../lib/token/leaf_token' 
VertexTokenFactory  = require '../../../lib/token/vertex_token' 
BoundryTokenFactory = require '../../../lib/token/boundry_token' 

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
            phraseToken: signature: 'it'
            phraseType: -> 'leaf' 

        @leafToken    = LeafTokenFactory.createClass
        @vertexToken  = VertexTokenFactory.createClass
        @boundryToken = BoundryTokenFactory.createClass

    afterEach ->

        LeafTokenFactory.createClass    = @leafToken
        VertexTokenFactory.createClass  = @vertexToken
        BoundryTokenFactory.createClass = @boundryToken


    it 'creates LeafToken class with current root context', (done) -> 

        LeafTokenFactory.createClass = (rooot) -> 
            root.should.equal root
            done()

        hook = RecursorBeforeEach.create root, parent
        try hook (->), injectionControl

    it 'creates BoundryToken class with current root context', (done) -> 

        BoundryTokenFactory.createClass = (rooot) -> 
            root.should.equal root
            done()

        hook = RecursorBeforeEach.create root, parent
        try hook (->), injectionControl

    it 'creates VertexToken class with current root context', (done) -> 

        VertexTokenFactory.createClass = (rooot) -> 
            root.should.equal root
            done()

        hook = RecursorBeforeEach.create root, parent
        try hook (->), injectionControl


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


    it 'gets the phrase type', (done) -> 

        nestedPhraseFn = -> 
        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, nestedPhraseFn ]

        parent.phraseType = (fn) ->

            fn.should.equal nestedPhraseFn
            done()

        hook = RecursorBeforeEach.create root, parent
        hook (->), injectionControl


    it 'creates each phrase a Token according to type with signature and uuid', (done) -> 

        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, -> ]
        parent.phraseToken = signature: 'it', uuid: 'uuid'
        hook = RecursorBeforeEach.create root, parent
        hook (->

            root.context.stack[0].token.type.should.equal      'leaf'
            root.context.stack[0].token.signature.should.equal 'it'
            root.context.stack[0].token.uuid.should.equal      'uuid'
            done()

        ), injectionControl



    it 'pushes the new phrase into the stack and resolves the injection deferral if leaf', (done) -> 

        nestedPhraseFn = ->
        phraseHookFn = ->

        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, nestedPhraseFn ]
        parent.phraseToken = signature: 'it', uuid: 'uuid'
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

            #root.context.stack[0].should.be.an.instanceof root.context.PhraseNode

            root.context.stack[0].text.should.equal 'phrase text'
            root.context.stack[0].uuid.should.equal 'uuid'  # only in case of root phrase
            root.context.stack[0].fn.should.equal nestedPhraseFn
            root.context.stack[0].token.signature.should.equal 'it'
            root.context.stack[0].hooks.beforeEach.should.equal phraseHookFn


        ), injectionControl


    it 'hands error into injectionControl deferral if phraseText contains /', (done) -> 

        root.context.stack.push new root.context.PhraseNode

            token: signature: 'context'
            text: 'the parent phrase'
            fn: ->

        parent.phraseToken = signature: 'it'
        hook = RecursorBeforeEach.create root, parent
        injectionControl.args = [ 'does not allow / in phraseText', { uuid: 'UUID' }, (end) -> ]

        hook ( (result) ->

            result.should.be.an.instanceof Error
            result.should.match /INVALID text/
            done()

        ), injectionControl


    it 'can assign uuid from phraseControl for non root phrases', (done) -> 

        root.context.stack.push new root.context.PhraseNode

            token: signature: 'context'
            text: 'the parent phrase'
            fn: ->

        injectionControl.args = [ 'is a leaf phrase', { uuid: 'UUID' }, (end) -> ]
        parent.phraseToken = signature: 'it'
        hook = RecursorBeforeEach.create root, parent

        hook (-> 

            root.context.stack[1].uuid.should.equal 'UUID'
            done()

        ), injectionControl


    it 'does not assign uuid from parent phraseToken if not root phrase', (done) -> 

        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, -> ]
        parent.phraseToken = signature: 'it', uuid: 'UUID'
        root.context.stack[0] = new root.context.PhraseNode

            token: signature: 'describe'
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

            token: signature: 'describe'
            text: 'use case one'
            fn: ->

        root.context.stack.push new root.context.PhraseNode

            token: signature: 'context'
            text: 'the parent phrase'
            fn: ->

        #
        # pending new stack element
        #
        parent.phraseToken = signature: 'it'
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

            injectionControl.args[1].phraseToken.signature.should.equal 'glia'
            done()

        ), injectionControl


    it 'ensures injection function as lastarg is at arg3 if phrase is not a leaf', (done) -> 

        nestedPhraseFn = -> 
        parent.phraseType = -> 'vertex'

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



