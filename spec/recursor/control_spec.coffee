should             = require 'should'
RecursorControl    = require '../../lib/recursor/control'
PhraseNode         = require '../../lib/phrase/node'
RecursorBeforeAll  = require '../../lib/recursor/control/before_all'
RecursorBeforeEach = require '../../lib/recursor/control/before_each'
RecursorAfterEach  = require '../../lib/recursor/control/after_each'
RecursorAfterAll   = require '../../lib/recursor/control/after_all'



describe 'RecursorControl', -> 

    context 'isLeaf()', ->

        root    = undefined
        control = undefined

        beforeEach -> 

            root = 

                util: require('also').util
                context:
                    notice: {}

            @Node = PhraseNode.createClass root

            control = 
                leaf:    ['end', 'done', 'slurp']
                boundry: ['fingertip']

        it 'detects leaf phrases when phrase fn arg1 is in control.leaf', (done) -> 
        
            phrase = new @Node 
                token: {}
                title: ''
                uuid: '1111'
                fn: (slurp) -> 

            RecursorControl.bindControl root, control
            control.phraseType( phrase.fn ).should.equal 'leaf'
            done()

        it 'detects boundry phrases when phrase fn arg1 is in control.boundry', (done) -> 
        
            phrase = new @Node 
                token: {}
                title: ''
                uuid: '1111'
                fn: (fingertip) -> 

            RecursorControl.bindControl root, control
            control.phraseType( phrase.fn ).should.equal 'boundry'
            done()

        it 'defaults to vertex phrase', (done) ->

            phrase = new @Node 
                token: {}
                title: ''
                uuid: '1111'
                fn: (other) -> 
            RecursorControl.bindControl root, control
            control.phraseType( phrase.fn ).should.equal 'vertex'
            done()


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

            control = {} 
            RUN     = [] 

            swap1 = RecursorBeforeAll.create
            swap2 = RecursorBeforeEach.create
            swap3 = RecursorAfterEach.create
            swap4 = RecursorAfterAll.create

            RecursorBeforeAll.create = (root, parentControl) ->
                RecursorBeforeAll.create = swap1
                parentControl.should.eql control
                RUN.push 1
                ->

            RecursorBeforeEach.create = (root, parentControl) ->
                RecursorBeforeEach.create = swap2
                parentControl.should.eql control
                RUN.push 2
                ->

            RecursorAfterEach.create = (root, parentControl) ->
                RecursorAfterEach.create = swap3
                parentControl.should.eql control
                RUN.push 3
                ->

            RecursorAfterAll.create = (root, parentControl) ->
                RecursorAfterAll.create = swap4
                parentControl.should.eql control
                RUN.push 4
                ->

            root   = context: emitter: emit: ->
            hooks  = RecursorControl.bindControl root, control

            RUN.should.eql [1, 2, 3, 4]
            done()


        it 'returns the necessary hooks', (done) -> 

            root    = context: emitter: emit: ->
            control = {} 
            hooks   = RecursorControl.bindControl root, control

            #console.log hooks

            hooks.beforeAll.should.be.an.instanceof  Function
            hooks.beforeEach.should.be.an.instanceof Function
            hooks.afterEach.should.be.an.instanceof  Function
            hooks.afterAll.should.be.an.instanceof   Function

            done() 
