should             = require 'should'
RecursorHooks      = require '../../../lib/phrase/recursor/hooks'
RecursorBeforeAll  = require '../../../lib/phrase/recursor/before_all'
RecursorBeforeEach = require '../../../lib/phrase/recursor/before_each'
RecursorAfterEach  = require '../../../lib/phrase/recursor/after_each'
RecursorAfterAll   = require '../../../lib/phrase/recursor/after_all'

they = it

describe 'RecursorHooks', -> 

    they """

        control the flow of recursion to ensure that each phrase is run in sequence
        and all nested phrases are called before before proceeding to the next phr-
        ase

    """, ->

    context 'bind()', -> 

        it """

            it is a factory function that transports the root context into an accessable
            position to be used by the hooks

        """, -> 

        it 'creates the necessry hooks with root and parent control', (done) -> 

            parent = control: {} 
            RUN    = [] 

            RecursorBeforeAll.create = (root, parentControl) ->
                parentControl.should.eql parent
                RUN.push 1
                ->

            RecursorBeforeEach.create = (root, parentControl) ->
                parentControl.should.eql parent
                RUN.push 2
                ->

            RecursorAfterEach.create = (root, parentControl) ->
                parentControl.should.eql parent
                RUN.push 3
                ->

            RecursorAfterAll.create = (root, parentControl) ->
                parentControl.should.eql parent
                RUN.push 4
                ->

            root   = context: emitter: emit: ->
            hooks  = RecursorHooks.bind root, parent

            RUN.should.eql [1, 2, 3, 4]
            done()


        it 'returns the necessary hooks', (done) -> 

            root   = context: emitter: emit: ->
            parent = control: {} 
            hooks  = RecursorHooks.bind root, parent

            hooks.beforeAll.should.be.an.instanceof  Function
            hooks.beforeEach.should.be.an.instanceof Function
            hooks.afterEach.should.be.an.instanceof  Function
            hooks.afterAll.should.be.an.instanceof   Function

            done() 
