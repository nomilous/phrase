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

                        leaves = TOKEN.graph.tree.leaves
                        LEAF_TWO = ( for uuid of leaves
                            continue unless leaves[uuid].convenience.match /LEAF_TWO/
                            uuid
                        )[0]
                        # NEST_ONE = ( for uuid of leaves
                        #     ### continue unless leaves[uuid].convenience.match /NEST_ONE/
                        #     uuid
                        # )[0]
                        done()

                    next()


        root 'PHRASE_ROOT', (nested) -> 

            nested 'NEST_ONE', (deeper) -> 

                deeper 'LEAF_ONE', (end) -> end()
                deeper 'LEAF_TWO', (end) -> end()

            nested 'LEAF_THREE', (end) -> end()

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

        it 'can run a leaf', (done) -> 

            MESSAGES = []

            TOKEN.run( uuid: LEAF_TWO ).then(

                (results) -> 

                    #
                    # overall results
                    #

                    console.log MESSAGES

                    # console.log RESULTS: results
                    # results.should.be.an.instanceof Array
                    done()

                (error)   ->

                    #
                    # catastrofic
                    #

                    console.log ERROR: error

                (notifiy) -> 

                    #
                    # per leaf results, including errors
                    #

                    console.log NOTIFY: notifiy
                    MESSAGES.push notify

            )


        it 'can run all leaves on a branch'
        it 'can run all leaves in the tree'


