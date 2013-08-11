should       = require 'should'
PhraseRoot   = require '../../lib/phrase_root'
PhraseToken  = require '../../lib/phrase_token'
PhraseRunner = require '../../lib/phrase/phrase_runner'

describe 'PhraseRunner', -> 

    root       = undefined
    TOKEN      = undefined
    NOTICE     = undefined
    GRAPH      = undefined
    LEAF_TWO   = undefined
    NEST_ONE   = undefined

    beforeEach (done) -> 

        root = PhraseRoot.createRoot

            title: 'Title'
            uuid:  'ROOT-UUID'

            (token, notice) -> 

                TOKEN  = token
                NOTICE = notice
                GRAPH  = token.graph

                notice.use (msg, next) -> 

                    return done() if LEAF_TWO?

                    if msg.context.title == 'phrase::recurse:end'

                        #
                        # tree is ready, locate UUIDs of test phrase nodes
                        #

                        vertices = TOKEN.graph.vertices
                        LEAF_TWO = ( for uuid of vertices
                            continue unless vertices[uuid].text == 'LEAF_TWO'
                            uuid
                        )[0]
                        NEST_ONE = ( for uuid of vertices
                            continue unless vertices[uuid].text == 'NEST_ONE'
                            uuid
                        )[0]
                        done()

                    next()

        before all:  ->  'BEFORE-ALL-OUTSIDE'
        before each: -> 'BEFORE-EACH-OUTSIDE'
        after  each: ->  'AFTER-EACH-OUTSIDE'
        after  all:  ->   'AFTER-ALL-OUTSIDE'
        root 'PHRASE_ROOT', (nested) -> 
            nested 'NEST_ONE', (deeper) -> 
                before all:  ->  'BEFORE-ALL-NESTED'
                before each: -> 'BEFORE-EACH-NESTED'
                after  each: ->  'AFTER-EACH-NESTED'
                after  all:  ->   'AFTER-ALL-NESTED'
                deeper 'LEAF_ONE', (end) ->
                    'RUN_LEAF_ONE' 
                    end()
                deeper 'NEST_TWO', (deeper) -> 
                    deeper 'NEST_THREE', (deeper) -> 
                        before all:  ->  'BEFORE-ALL-DEEP'
                        before each: -> 'BEFORE-EACH-DEEP'
                        after  each: ->  'AFTER-EACH-DEEP'
                        after  all:  ->   'AFTER-ALL-DEEP'
                        deeper 'NEST_FOUR', (deeper) -> 
                            deeper 'LEAF_TWO', (end) -> 
                                'RUN_LEAF_TWO' 
                                end()
                deeper 'LEAF_THREE', (end) -> 
                    'RUN_LEAF_THREE'
                    end()
            nested 'LEAF_FOUR', (end) -> end()



    context 'run()', ->

        it 'returns a promise', (done) -> 

            TOKEN.run().then.should.be.an.instanceof Function
            done()

        it 'reject if no target uuid was supplied', (done) -> 

            TOKEN.run().then(
                ->
                (error) -> 
                    error.code.should.equal 1
                    error.should.match /missing opts.uuid/
                    done()
            )
            
        it 'rejects on missing uuid', (done) -> 

            TOKEN.run( uuid: 'NO_SUCH_UUID' ).then(
                ->
                (error) -> 
                    error.code.should.equal 2
                    error.should.match /uuid: 'NO_SUCH_UUID' not in local tree/
                    done()
            )

        it 'calls get all steps to run', (done) -> 

            swap = PhraseRunner.getSteps
            PhraseRunner.getSteps = (root, opts) ->
                PhraseRunner.getSteps = swap
                opts.uuid.should.equal NEST_ONE
                done()
                then: ->

            TOKEN.run( uuid: NEST_ONE )



    context 'getSteps()', ->

        it 'collects the sequence of calls required to run all the leaves on any given branch', (done) -> 

            root     = context: graph: GRAPH
            opts     = uuid: NEST_ONE
            deferral = {}


            PhraseRunner.getSteps( root, opts, deferral ).then (steps) -> 

                # steps.map (step) -> 
                #     console.log FN: step.ref.fn.toString()

                i = 0
                steps[i++].ref.fn.toString().should.match /BEFORE-ALL-OUTSIDE/   # first all
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /BEFORE-ALL-NESTED/    # first all
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match                       /RUN_LEAF_ONE/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-OUTSIDE/
                # 
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-NESTED/
                # 
                steps[i++].ref.fn.toString().should.match /BEFORE-ALL-DEEP/      # first all
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-DEEP/
                steps[i++].ref.fn.toString().should.match                       /RUN_LEAF_TWO/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-DEEP/
                steps[i++].ref.fn.toString().should.match /AFTER-ALL-DEEP/       # last all
                # 
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-OUTSIDE/
                # 
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match                       /RUN_LEAF_THREE/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match /AFTER-ALL-NESTED/    # last all
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /AFTER-ALL-OUTSIDE/   # last all
                # 
                should.not.exist steps[i++]

                done()



        xit 'can run all leaves on a branch', (done) -> 

            MESSAGES = []
            tick     = 0
            Date.now = -> ++tick

            TOKEN.run( uuid: NEST_ONE ).then(

                (results) -> 

                    #
                    # overall results
                    #

                    MESSAGES.should.eql [

                        { timestamp: 1, state: 'running', total: 3, remaining: 3 }
                        { timestamp: 2, state: 'running', total: 3, remaining: 2 }
                        { timestamp: 3, state: 'running', total: 3, remaining: 1 }
                        { timestamp: 4, state: 'done',    total: 3, remaining: 0 }

                    ]

                    done()

                (error)   ->

                    #
                    # catastrofic
                    #

                    console.log ERROR: error

                (notify) -> 

                    #
                    # per leaf results, including errors
                    #
                    console.log '\n', notify
                    MESSAGES.push notify

            )

        it 'can run a single leaf'
        it 'can run all leaves on a branch'
        it 'can run all leaves in the tree'


