should     = require 'should'
PhraseNode = require '../lib/phrase_node'

describe 'PhraseNode', -> 

    it 'has a uuid, runCount and createdAt', (done) -> 

        node = new PhraseNode

        should.exist node.uuid
        should.exist node.runCount
        should.exist node.createdAt
        done()


    it 'has READ ONLY uuid, runCount and createdAt'

    