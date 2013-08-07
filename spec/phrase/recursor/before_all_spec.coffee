should             = require 'should'
RecursorBeforeAll  = require '../../../lib/phrase/recursor/before_all'

describe 'RecursorBeforeAll', -> 
    
    root = undefined

    beforeEach -> 

        root = context: emitter: emit: -> 


    it 'emits phrase::start event', (done) -> 

        root.context.emitter.emit = (event) -> 

            event.should.equal 'phrase::start'
            done()

        hook = RecursorBeforeAll.create root
        hook ->


    it 'calls the hook resolver', (done) -> 

        hook = RecursorBeforeAll.create root
        hook -> done()
