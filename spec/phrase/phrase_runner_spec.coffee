should       = require 'should'
PhraseRoot   = require '../../lib/phrase_root'
PhraseToken  = require '../../lib/phrase_token'
PhraseRunner = require '../../lib/phrase/phrase_runner'

describe 'PhraseRunner', -> 

    root       = undefined
    TOKEN      = undefined
    NOTICE     = undefined
    LEAF_TWO   = undefined
    NEST_ONE   = undefined

    beforeEach (done) -> 

        root = PhraseRoot.createRoot

            title: 'Title'
            uuid:  'ROOT-UUID'

            (token, notice) -> 

                TOKEN  = token
                NOTICE = notice

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


        before each: ->
        after each: ->
        root 'PHRASE_ROOT', (nested) -> 
            before each: ->
            after each: ->
            nested 'NEST_ONE', (deeper) -> 
                before each: ->
                after each: ->
                deeper 'LEAF_ONE', (end) -> end()
                deeper 'NEST_TWO', (deeper) -> 
                    before each: ->
                    after each: ->
                    deeper 'NEST_THREE', (deeper) -> 
                        before each: ->
                        after each: ->
                        deeper 'NEST_FOUR', (deeper) -> 
                            before each: ->
                            after each: ->
                            deeper 'LEAF_TWO', (end) -> end()
                deeper 'LEAF_THREE', (end) -> end()
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

        it 'can run all leaves on a branch', (done) -> 

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
                    console.log notify
                    MESSAGES.push notify

            )

        it 'can run a single leaf'
        it 'can run all leaves on a branch'
        it 'can run all leaves in the tree'


