should         = require 'should'
Phrase         = require '../../lib/phrase'
Recursor       = require '../../lib/phrase/recursor'

describe 'Recursor', -> 

        root    = undefined
        emitter = undefined

        before (done) -> 

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (e) -> 

                    emitter = e
                    done()


        it 'was returned by the call to Phrase.create()', (done) ->

            should.exist root
            should.exist emitter
            done()


        it 'generates phrase::start (only once!) when called', (done) -> 

            emitter.on 'phrase::start', -> done()
            root ->
            root ->
            root ->


        it 'returns a promise', (done) -> 

            root().then.should.be.an.instanceof Function
            done()


        it 'calls the function passed as last arg', (done) -> 

            #
            # this forms the basis of the recursion that 
            # traverses the phrase tree
            #

            RUN = []
            root '', {}, -> RUN.push '3args'
            root '',     -> RUN.push '2args'
            root(       -> RUN.push '1args').then -> 

                RUN.should.eql [ '3args', '2args', '1args' ]
                done()
                

