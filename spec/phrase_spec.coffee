should = require 'should'
Phrase = require '../lib/phrase'

describe 'phrase', -> 

    context 'create()', ->

        it 'is a function', (done) ->  

            Phrase.create.should.be.an.instanceof Function
            done()

        it 'expects opts and eventFn', (done) -> 

            try Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            
            catch error

                error.should.match /phrase.create\(opts,eventFn\) expects eventFn/
                done()

        it 'calls eventFn', (done) -> 

            Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                -> done()

