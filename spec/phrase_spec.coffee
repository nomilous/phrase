should         = require 'should'
Phrase         = require '../lib/phrase'
{EventEmitter} = require 'events'

describe 'phrase', -> 

    context 'create()', ->

        it 'is a function', (done) ->  

            Phrase.create.should.be.an.instanceof Function
            done()

        it 'expects opts and linkFn', (done) -> 

            try Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            
            catch error

                error.should.match /phrase.create\(opts,linkFn\) expects linkFn/
                done()

        it 'calls linkFn', (done) -> 

            Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                -> done()


        it 'passes an event emitter into linkFn', (done) -> 

            Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

                    emitter.should.be.an.instanceof EventEmitter
                    done()

        it 'returns a function', (done) -> 

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root.should.be.an.instanceof Function
            done()


    context 'phrase registrar (root)', -> 

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
                



