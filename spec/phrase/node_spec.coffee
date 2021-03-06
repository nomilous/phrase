should      = require 'should'
PhraseNode  = require '../../lib/phrase/node'
also        = require 'also'
PhraseToken = require( '../../lib/token/phrase_token' ).createClass {util: also.util}

describe 'PhraseNode', -> 

    before -> 

        @Node = PhraseNode.createClass {util: also.util}

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
                title:     'is a leaf phrase'
                leaf:      true

                #
                # not enumarable
                #

                fn: -> 
                hooks:    {}
                deferral: {}
                queue:    {}
                
            JSON.stringify( node ).should.equal '{"uuid":"123","token":{"name":"it","uuid":"123"},"title":"is a leaf phrase","leaf":true}'
            done()


        it 'immutable properties', (done) -> 


            node = new @Node

                uuid:      '123'
                token:     name: 'it'
                title:     'is a leaf phrase'

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
                title:     'is a leaf phrase'


            should.not.exist node.leaf
            node.leaf = true
            node.leaf = false
            node.leaf.should.equal true
            done()



    context 'getChanges()', ->

        xit 'returns changes' , (done) -> 

            oldFn         = -> 'OLD'
            oldBeforeAll  = -> 'OLD'
            newFn         = -> 'NEW'
            newBeforeEach = -> 'NEW'

            node1 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                timeout:   2000

                hooks: 
                    beforeAll: fn: oldBeforeAll
                    afterEach: timeout: 100, fn: ->
                fn: oldFn

            node2 = new @Node

                uuid:      'UUID2'
                token:     name: 'it'
                title:     'is a leaf phrase'
                timeout:   5000

                hooks: 
                    beforeEach: timeout: 1000, fn: newBeforeEach
                    afterEach: timeout: 200, fn: ->
                fn: newFn

            
            changes = node1.getChanges node2

            changes.target.uuid.should.equal 'UUID1'
            #changes.source.uuid.should.equal 'UUID2'

            changes.fn.should.eql 
                    from: oldFn
                    to:   newFn

            changes.timeout.should.eql 
                    from: 2000
                    to:   5000
                    
            changes.hooks.should.eql 
                    beforeAll: 
                        fn:
                            from: oldBeforeAll
                            to:   undefined
                    beforeEach:
                        fn: 
                            from: undefined
                            to:   newBeforeEach
                        timeout:
                            from: undefined
                            to:   1000
                    afterEach:
                        timeout:
                            from: 100
                            to:   200    
                    

            done()

        it 'detects changes to token type', (done) -> 

            node1 = new @Node

                uuid:      'UUID1'
                token:     signature: 'it', type: 'leaf'
                title:     'is a leaf phrase'
                timeout:   2000
                
                fn: ->

            node2 = new @Node

                uuid:      'UUID1'
                token:     signature: 'it', type: 'vertex'
                title:     'is not a leaf'
                timeout:   2000
                
                fn: ->

            node1.getChanges( node2 ).type.should.eql from: 'leaf', to: 'vertex'
            done() 


        xit 'returns undefined if no changes', (done) -> 

            node1 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                timeout:   2000

                hooks: beforeAll: fn: ->
                fn: ->

            node2 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                timeout:   2000

                hooks: beforeAll: fn: ->
                fn: ->

            should.not.exist node1.getChanges node2  
            done()




    context 'update()', -> 

        it 'applies change to fn', (done) -> 

            node1 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                
                fn: ->  'old'

            node2 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                
                fn: -> 'new'

            changes = node1.getChanges node2
            node1.update changes


            node1.fn().should.equal 'new'
            done()



        it 'applies change to timeout', (done) ->


            node1 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                timeout:   100
                fn: ->  'unchanged'

            node2 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                fn: -> 'unchanged'

            changes = node1.getChanges node2
            node1.update changes

            
            node1.timeout.should.equal 2000  # default was restored
            done()


        it 'applies changes to hooks (ONTO THE SPECIFIED TARGET)', (done) -> 


            node1 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                hooks: 
                    beforeAll:                fn: -> 1
                    beforeEach: timeout: 100, fn: -> 1
                    afterAll:                 fn: -> 1

                fn: ->  'unchanged'


            node2 = new @Node

                uuid:      'UUID1'
                token:     name: 'it'
                title:     'is a leaf phrase'
                hooks: 
                    beforeAll:                fn: -> 'UPDATED'
                    beforeEach: timeout: 200, fn: -> 1

                fn: -> 'unchanged'

            parentNode = new @Node

                uuid: 'parent'
                token:  name: 'context'
                title: 'parent phrase'
                fn: ->


            changes = node1.getChanges node2


            #
            # ONTO THE SPECIFIED TARGET
            # #GREP2 
            #
            # hook changes are reported associated to parent vertex
            # and will therefore be applied to parent when
            # the change set is run, 
            # 

            parentNode.update changes

            #
            # applied onto parent, changed node 1
            #

            node1.hooks.beforeAll.fn().should.equal 'UPDATED'
            node1.hooks.beforeEach.timeout.should.equal 200
            should.not.exist node1.hooks.afterAll
            done()


            #node1.update changes

        it 'applies changes to phrase type', (done) -> 

            node1 = new @Node

                uuid:      'UUID1'
                token:     new PhraseToken type: 'leaf', uuid: 'UUID1'
                title:     'is a leaf phrase'
                fn: ->  'unchanged'


            node2 = new @Node

                token:     new PhraseToken type: 'vertex'
                title:     'is a leaf phrase'
                fn: -> 'unchanged'


            changes = node1.getChanges node2
            node1.update changes
            done()



        it 'carries new hook uuid in on hook create', (done) -> 

            done()  # tested in change_set_spec




