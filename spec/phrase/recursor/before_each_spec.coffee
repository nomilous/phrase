should             = require 'should'
RecursorBeforeEach = require '../../../lib/phrase/recursor/before_each'
Phrase             = require '../../../lib/phrase'

describe 'RecursorBeforeEach', -> 

    root             = undefined
    injectionControl = undefined

    beforeEach -> 

        root = context: 
            emitter: emit: ->
            stack: []
        injectionControl = 
            defer: resolve: ->
            args: []


    it 'extracts the injection deferral', (done) -> 
        
        Object.defineProperty injectionControl, 'defer', 
            get: -> 
                done()
                throw 'go no further'

        hook = RecursorBeforeEach.create root
        try hook (->), injectionControl


    it 'calls the hook resolver', (done) -> 

        hook = RecursorBeforeEach.create root
        hook done, injectionControl


    xit 'should not resolve the deferral'


    it 'pushes the new phrase into the stack', (done) -> 

        nestedPhraseFn = -> 
        injectionControl.args = [ 'phrase text', { key: 'VALUE' }, nestedPhraseFn ]

        hook = RecursorBeforeEach.create root

        hook (-> 

            root.context.stack[0].should.be.an.instanceof Phrase
            root.context.stack[0].text.should.equal 'phrase text'
            root.context.stack[0].control.key.should.equal 'VALUE'
            root.context.stack[0].fn.should.equal nestedPhraseFn
            done()

        ), injectionControl



    it 'ensures function as lastarg is at arg3', (done) -> 

        nestedPhraseFn = -> 

        hook = RecursorBeforeEach.create root

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
