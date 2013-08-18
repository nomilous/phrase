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
            leaf:      true

            #
            # not enumarable
            #

            fn: -> 
            hooks:    {}
            deferral: {}
            queue:    {}
            
        JSON.stringify( node ).should.equal '{"uuid":"123","token":{"name":"it"},"text":"is a leaf phrase","leaf":true}'
        done()


    it 'immutable properties', (done) -> 


        node = new @Node

            uuid:      '123'
            token:     name: 'it'
            text:      'is a leaf phrase'

            hooks: beforeAll: fn: -> 0

        node.token.name.should.equal 'it'
        node.token.name = 'Pepin of Landen'
        node.token.name.should.not.equal 'Pepin of Landen'


        node.hooks.beforeAll.fn().should.equal 0
        node.hooks.beforeAll = fn: -> 1
        node.hooks.beforeAll.fn().should.equal 0
        done()


    it 'leaf flag can only be set once', (done) -> 

        node = new @Node

            uuid:      '123'
            token:     name: 'it'
            text:      'is a leaf phrase'


        should.not.exist node.leaf
        node.leaf = true
        node.leaf = false
        node.leaf.should.equal true
        done()




    context 'isChanged()', ->

        it 'changed hook needs to mark parent node as changed'

            #
            # this may be handled in graph merge and not here
            #


    context 'merge()', -> 

