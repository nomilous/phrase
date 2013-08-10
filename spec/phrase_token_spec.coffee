should      = require 'should'
PhraseRoot  = require '../lib/phrase_root'
PhraseToken = require '../lib/phrase_token'

describe 'PhraseToken', -> 

    context 'run()', -> 

        it 'is a function', (done) -> 

            token = PhraseToken.create context: graph: {}
            token.run.should.be.an.instanceof Function
            done()

        it 'returns a promise', (done) -> 

            token = PhraseToken.create 
                context: 
                    graph: {}
                inject: require('also').inject

            token.run().then.should.be.an.instanceof Function
            done()


    context 'integrations', -> 

        root  = undefined
        TOKEN = undefined 

        beforeEach (done) -> 

            root = PhraseRoot.createRoot

                title: 'Title'
                uuid:  'ROOT-UUID'

                (token, notice) -> 

                    TOKEN = token

                    notice.use (msg, next) -> 

                        done() if msg.context.title == 'phrase::recurse:end'
                        next()

            root 'phrase', (nested) -> 

                nested 'nest ONE', (end) -> 
                nested 'nest TWO', (end) -> 


        it 'can run a leaf', (done) -> 

            #console.log JSON.stringify TOKEN.graph.tree, null, 2

            #
            # get uuid for 'nest TWO'
            #

            leaves = TOKEN.graph.tree.leaves

            uuid = ( for uuid of leaves

                continue unless leaves[uuid].convenience.match /TWO$/
                uuid

            )[0]

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


