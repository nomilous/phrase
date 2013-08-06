should         = require 'should'
RecursorHooks  = require '../../../lib/phrase/recursor/hooks'

they = it

describe 'RecursorHooks', -> 

    they """

        control the flow of recursion to ensure that each phrase is run in sequence
        and all nested phrases are called before before proceeding to the next phr-
        ase

    """, ->

    context 'create()', -> 

        it """

            it is a factory function that transports the root context into an accessable
            position to be used by the hooks

        """, -> 

        it 'creates the necessary hooks', (done) -> 

            root  = context: emitter: emit: ->
            hooks = RecursorHooks.create root

            hooks.beforeAll.should.be.an.instanceof  Function
            hooks.beforeEach.should.be.an.instanceof Function
            hooks.afterEach.should.be.an.instanceof  Function
            hooks.afterAll.should.be.an.instanceof   Function

            done()
