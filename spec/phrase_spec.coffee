should = require 'should'
Phrase = require '../lib/phrase'

describe 'phrase', -> 

    context 'create()', ->

        it 'is a function', (done) ->  

            Phrase.create.should.be.an.instanceof Function
            done()
            
