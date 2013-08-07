should         = require 'should'
Phrase         = require '../lib/phrase_root'
PhraseRecursor = require '../lib/phrase/recursor'
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

        it 'returns the root phrase recursor ', (done) -> 

            PhraseRecursor.create = -> -> done()

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()


    context 'integrations', -> 

        root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

        root 'root phrase text', (outer) -> 

            before all: -> console.log before: 'all'

            outer 'outer nested phrase text', (inner) -> 

                inner 'inner nested phrase text', (done) -> 

                    done()

