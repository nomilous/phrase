should = require 'should'
phrase = require '../lib/phrase'

describe 'phrase', -> 

    it 'defines create()', (done) -> 

        phrase.create.should.be.an.instanceof Function
        done()