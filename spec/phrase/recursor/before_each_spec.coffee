should             = require 'should'
RecursorBeforeEach = require '../../../lib/phrase/recursor/before_each'
PhraseLeaf         = require '../../../lib/phrase/recursor/leaf'
Phrase             = require '../../../lib/phrase'

describe 'RecursorBeforeEach', -> 

    root             = undefined
    injectionControl = undefined
    parent           = undefined

    beforeEach -> 

        root = 
            context: 
                emitter: emit: ->
                stack: []
            util: require('also').util

        injectionControl = 
            defer: resolve: ->
            args: ['phrase text', {}, (nested) -> ]

        parent = control: {}

        PhraseLeaf_swap = PhraseLeaf.create
        PhraseLeaf.create = -> detect: (phrase, isLeaf) -> isLeaf true 

    afterEach: -> 

        PhraseLeaf.create = PhraseLeaf_swap


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
        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, nestedPhraseFn ]
        PhraseLeaf.create = -> detect: (phrase, isLeaf) -> isLeaf true
        
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

            root.context.stack[0].should.be.an.instanceof Phrase
            root.context.stack[0].text.should.equal 'phrase text'
            #root.context.stack[0].control.key.should.equal 'VALUE'
            root.context.stack[0].fn.should.equal nestedPhraseFn

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
        PhraseLeaf.create = -> detect: (phrase) -> 

            phrase.fn.should.equal nestedPhraseFn
            done()

        hook = RecursorBeforeEach.create root, parent
        hook (->), injectionControl


    it 'ensures injection function as lastarg is at arg3 if phrase is not a leaf', (done) -> 

        nestedPhraseFn = -> 
        PhraseLeaf.create = -> detect: (phrase, isLeaf) -> isLeaf false

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
        PhraseLeaf.create = -> detect: (phrase, isLeaf) -> isLeaf true

        hook = RecursorBeforeEach.create root, parent

        injectionControl.args = [ 'phrase text', { phrase: 'control' }, nestedPhraseFn ]
        hook (-> 

            injectionControl.args[2].toString().should.match /function \(\) {}/
            done()

        ), injectionControl



