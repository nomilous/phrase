should             = require 'should'
RecursorBeforeAll  = require '../../../lib/phrase/recursor/before_all'

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


    it 'transfers any regisered hooks onto the injection control context and runs the beforeAll hook', (done) -> 

        hook = RecursorBeforeAll.create root

        root.context.hooks.beforeAll.push ->   done()
        root.context.hooks.beforeEach.push ->  'beforeEach'
        root.context.hooks.afterEach.push ->   'afterEach'
        root.context.hooks.afterAll.push ->    'afterAll'

        injectionControl = {}

        hook (->

            #
            # recursion control hook was resolved
            #

            #
            # and all phrase hooks were attached to the injectionControl
            # to be run by their corresponding recursion control hooks
            #

            console.log injectionControl
            injectionControl.beforeAll.should.be.an.instanceof Function
            injectionControl.beforeEach.should.be.an.instanceof Function
            injectionControl.afterEach.should.be.an.instanceof Function
            injectionControl.afterAll.should.be.an.instanceof Function

        ), injectionControl


