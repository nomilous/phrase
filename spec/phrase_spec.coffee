should = require 'should'
Phrase = require '../lib/phrase'

describe 'phrase', -> 

    context 'create()', ->

        it 'is a function', (done) ->  

            Phrase.create.should.be.an.instanceof Function
            done()
            

        context 'opts as arg1', -> 

            it 'has mandatories', (done) -> 

                try  Phrase.create()
                catch error

                    error.should.match /expects\s+opts\.title/
                    done()

