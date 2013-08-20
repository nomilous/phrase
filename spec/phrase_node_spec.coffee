should     = require 'should'
PhraseNode = require '../lib/phrase_node'

describe 'PhraseNode', -> 

    before -> 

        @Node = PhraseNode.createClass {}

    xcontext 'general', -> 

        it 'has a uuid', (done) -> 

            node = new @Node token: {}
            should.exist node.uuid
            done()


        it 'assign a uuid', (done) -> 

            node = new @Node uuid: '123', token: {}
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
                
            JSON.stringify( node ).should.equal '{"uuid":"123","token":{"name":"it","uuid":"123"},"text":"is a leaf phrase","leaf":true}'
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



    context 'getChanges()', ->

        it 'returns changes' , (done) -> 

            oldFn         = -> 'OLD'
            oldBeforeAll  = -> 'OLD'
            newFn         = -> 'NEW'
            newBeforeEach = -> 'NEW'

            node1 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                text:      'is a leaf phrase'
                timeout:   2000

                hooks: beforeAll: fn: oldBeforeAll
                fn: oldFn

            node2 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                text:      'is a leaf phrase'
                timeout:   5000

                hooks: beforeEach: fn: newBeforeEach
                fn: newFn

            
            node1.getChanges(  node2  ).should.eql 

                fn: 
                    from: oldFn
                    to:   newFn
                timeout:
                    from: 2000
                    to:   5000
                hooks:
                    beforeAll: 
                        from: oldBeforeAll
                        to:   undefined
                    beforeEach: 
                        from: undefined
                        to:   newBeforeEach
                    

            done()

