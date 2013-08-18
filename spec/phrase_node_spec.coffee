should     = require 'should'
PhraseNode = require '../lib/phrase_node'

describe 'PhraseNode', -> 

    before -> 

        @Node = PhraseNode.createClass {}


    it 'has a uuid', (done) -> 

        node = new @Node {}
        should.exist node.uuid
        done()


    it 'assign a uuid', (done) -> 

        node = new @Node uuid: '123'
        node.uuid.should.equal '123'
        node.uuid = '            it cannot be changed'
        node.uuid.should.equal '123'
        done()


    it 'enumerable properties', (done) -> 

        node = new @Node

            uuid:      '123'
            token:     name: 'it'
            text:      'is a leaf phrase'

            #
            # not enumarable
            #

            fn: -> 
            hooks:    {}
            deferral: {}
            queue:    {}

            
        JSON.stringify( node ).should.equal '{"uuid":"123","token":{"name":"it"},"text":"is a leaf phrase"}'
        done()


    context 'isChanged()', ->

        it 'changed hook needs to mark parent node as changed'

            #
            # this may be handled in graph merge and not here
            #


    context 'merge()', -> 

