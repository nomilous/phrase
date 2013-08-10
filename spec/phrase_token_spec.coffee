should      = require 'should'
PhraseRoot  = require '../lib/phrase_root'
PhraseToken = require '../lib/phrase_token'

describe 'PhraseToken', -> 
    
    root       = undefined
    TOKEN      = undefined
    LEAF_UUID  = undefined

    beforeEach (done) -> 

        root = PhraseRoot.createRoot

            title: 'Title'
            uuid:  'ROOT-UUID'

            (token, notice) -> 

                TOKEN = token

                #
                # TODO: token.on 'ready' (or something: 'changed')
                # 
                #       instead of eaves dropping on the message bus
                #            
                #       bear in mind the intended goal of
                #       live reloadability for version 
                #       release toggling and such
                #

                notice.use (msg, next) -> 

                    if msg.context.title == 'phrase::recurse:end'

                        #
                        # tree is ready, locate UUID of nest TWO
                        #

                        leaves = TOKEN.graph.tree.leaves
                        LEAF_UUID = ( for uuid of leaves
                            continue unless leaves[uuid].convenience.match /TWO$/
                            uuid
                        )[0]
                        done()

                    next()


        root 'phrase', (nested) -> 

            nested 'nest ONE', (end) -> 
            nested 'nest TWO', (end) -> 



    context 'run()', -> 

        it 'is a function', (done) -> 

            TOKEN.run.should.be.an.instanceof Function
            done()

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
                    error.should.match /uuid: NO_SUCH_UUID not in local tree/
                    done()
            )






    xcontext 'integrations', -> 

        it 'can run a leaf', (done) -> 

            #console.log JSON.stringify TOKEN.graph.tree, null, 2

            #
            # get uuid for 'nest TWO'
            #

            
            TOKEN.run( uuid: uuid ).then(

                (results) -> 

                    #
                    # overall results
                    #

                    results.should.be.an.instanceof Array
                    done()

                (error)   ->

                    #
                    # catastrofic
                    #

                (notifiy) -> 

                    #
                    # per leaf results, including errors
                    #

            )


        it 'can run all leaves on a branch'
        it 'can run all leaves in the tree'


