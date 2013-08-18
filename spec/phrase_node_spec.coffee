should     = require 'should'
PhraseNode = require '../lib/phrase_node'

describe 'PhraseNode', -> 

    before -> 

        @Node = PhraseNode.createClass {}

    it 'has a uuid, runCount and createdAt', (done) -> 

        node = new @Node

        should.exist node.uuid
        done()


    it 'has READ ONLY uuid, runCount and createdAt'

    context 'isChanged()', ->

    context 'merge()', -> 

