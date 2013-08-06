should             = require 'should'
RecursorBeforeAll  = require '../../../lib/phrase/recursor/before_all'

describe 'RecursorBeforeAll', -> 

    root = context: emitter: emit: -> 

    it 'runs emits phrase::start event', (done) -> 

        root.context.emitter.emit = (event) -> 

            event.should.equal 'phrase::start'
            done()

        hook = RecursorBeforeAll.create root
        hook ->
