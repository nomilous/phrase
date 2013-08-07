should             = require 'should'
RecursorBeforeEach = require '../../../lib/phrase/recursor/before_each'

describe 'RecursorBeforeEach', -> 

    root             = undefined
    injectionControl = undefined

    beforeEach -> 

        root = context: emitter: emit: ->
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

    it ''

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
