should      = require 'should'
PhraseTree  = require '../../lib/phrase/tree'

describe 'PhraseTree', -> 


    root  = undefined
    Tree  = undefined
    tree  = undefined

    before -> 

        root = context: notice: use: ->
        Tree = PhraseTree.createClass root
        tree = new Tree


    context 'change set', ->

        #
        # later
        # 

        it 'it not applied immediately'
        it 'informs messenger of readyness to swich version'
        it 'enables rolling version forward and back'


    context 'collection', -> 

            #
            # historyLength hardcoded to 2 for now
            #

            it 'removes old trees from the collection', (done) -> 

                tree1 = new Tree
                tree2 = new Tree
                tree3 = new Tree

                should.exist     root.context.trees.list[tree3.uuid]
                should.exist     root.context.trees.list[tree2.uuid]
                should.not.exist root.context.trees.list[tree1.uuid]
                done()


    context 'general', ->

        it 'has a uuid', (done) -> 

            should.exist tree.uuid
            done()

        it 'has a version', (done) -> 

            should.exist tree.version
            done()


        it 'is added to the trees collection on the root context', (done) -> 

            g = new Tree
            g.should.equal root.context.trees.list[ g.uuid ]
            done()


        it 'most recently created tree is set as latest in the trees collection', (done) -> 

            one = new Tree
            root.context.trees.latest.touch1 = 1
            two = new Tree
            root.context.trees.latest.touch2 = 2

            should.exist one.touch1
            should.exist two.touch2
            should.not.exist one.touch2

            done()


        it 'provides access to vertices and edges lists', (done) -> 

            tree.vertices.should.eql {}
            tree.edges.should.eql {}
            done()     


    context 'assembler middleware', -> 

        before -> 

            @Tree = PhraseTree.createClass context: notice: use: (@middleware) =>


        it 'registers on the message bus', (done) -> 

                # 
                # odd... Seems like a function returned by a property
                #        no longer appears to have a the same prototype
                #        instance as the function itself.
                # 
                # middleware.should.equal Tree.assembler
                # console.log middleware is Tree.assembler
                #

                @middleware.toString().should.equal @Tree.assembler.toString()
                done()          # 
                                # marginally pointless...
                                # 



        context 'registerEdge()', ->


            it 'is called by the assember at phrase::edge:create', (done) -> 

                tree = new @Tree

                tree.registerEdge = -> done()

                @Tree.assembler

                    context: title: 'phrase::edge:create'
                    ->


            it 'creates vertices', (done) -> 

                tree = new @Tree

                tree.registerEdge 

                    #
                    # mock 'phrase::edge:create' message
                    #

                    context: title: 'phrase::edge:create'
                    vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ]

                    -> 

                        tree.vertices.should.eql 

                            UUID1: uuid: 'UUID1', key: 'value1'
                            UUID2: uuid: 'UUID2', key: 'value2'
                        
                        done()


            it 'creates edges' , (done) ->

                tree = new @Tree

                tree.registerEdge 

                    #
                    # mock 'phrase::edge:create' message
                    #

                    context: title: 'phrase::edge:create'
                    vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ]

                    -> 

                        tree.edges.should.eql 

                            UUID1: [ { to: 'UUID2' } ]
                            UUID2: [ { to: 'UUID1' } ]
                        
                        done()


            it 'allows multiple edges per vertex', (done) -> 

                tree = new @Tree

                tree.registerEdge vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ],  ->

                tree.registerEdge vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->

                tree.edges.should.eql 

                    UUID1: [   { to: 'UUID2' }, { to: 'UUID3' }   ]
                    UUID2: [   { to: 'UUID1' }                    ]
                    UUID3: [   { to: 'UUID1' }                    ]

                
                done()

            it 'stores parent and child relations (if tree)', (done) -> 

                tree = new @Tree

                tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1', token: {              } }
                    { uuid: 'UUID2', key: 'value2', token: {              } }
                ],  ->

                tree.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1', token: {              } }
                        { uuid: 'UUID3', key: 'value3', token: {              } }
                    ],  ->


                tree.parent.should.eql 

                    UUID3: 'UUID1'
                    UUID2: 'UUID1'

                tree.children.should.eql 

                    UUID1: ['UUID2', 'UUID3']

                done()


            it 'stores a list of leaves if tree', (done) -> 

                #
                # vertices are flagged as leaf by the TreeWalker
                #

                tree.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1', token: {              } }
                        { uuid: 'UUID2', key: 'value2', token: { type: 'leaf' } }
                    ],  ->

                tree.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->

                tree.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID3', key: 'value3', token: {              } }
                        { uuid: 'UUID4', key: 'value4', token: { type: 'leaf' } }
                    ],  ->

                tree.leaves.should.eql ['UUID2', 'UUID4']

                done()


    context 'leavesOf(uuid)', -> 

        it 'returns the vertex at uuid if it is a leaf (per token type)', (done) -> 

            tree = new @Tree

            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', arbkey: 'arbvalue', token: { type: 'leaf' } }
                ],  ->

            tree.leavesOf( 'UUID2' )[0].arbkey.should.equal 'arbvalue'
            done()


        it 'returns array of leaf vertices nested (any depth) in the vertex at uuid', (done) -> 

            #
            # assemble tree
            # 
            #   1: 
            #      2: leaf
            #      3: 
            #         4: 
            #            6: leaf
            #            7: leaf
            #         5: leaf
            #      8: leaf
            # 
            #

            tree = new @Tree

            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2', token: { type: 'leaf' } }
                ],  ->
            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID3', key: 'value3' }
                ],  ->
            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID3', key: 'value3' }
                    { uuid: 'UUID4', key: 'value4' }
                ],  ->
            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID3', key: 'value3' }
                    { uuid: 'UUID5', key: 'value5', token: { type: 'leaf' } }
                ],  ->
            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID4', key: 'value4' }
                    { uuid: 'UUID6', key: 'value6', token: { type: 'leaf' } }
                ],  ->
            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID4', key: 'value4' }
                    { uuid: 'UUID7', key: 'value7', token: { type: 'leaf' } }
                ],  ->
            tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID8', key: 'value8', token: { type: 'leaf' } }
                ],  ->


            tree.leavesOf( 'UUID4' ).should.eql [ 
                { uuid: 'UUID6', key: 'value6', token: { type: 'leaf' } }
                { uuid: 'UUID7', key: 'value7', token: { type: 'leaf' } }
            ]

            tree.leavesOf( 'UUID3' ).should.eql [ 
                { uuid: 'UUID6', key: 'value6', token: { type: 'leaf' } }
                { uuid: 'UUID7', key: 'value7', token: { type: 'leaf' } }
                { uuid: 'UUID5', key: 'value5', token: { type: 'leaf' } } 
            ]

            tree.leavesOf( 'UUID1' ).should.eql [ 
                { uuid: 'UUID2', key: 'value2', token: { type: 'leaf' } }
                { uuid: 'UUID6', key: 'value6', token: { type: 'leaf' } }
                { uuid: 'UUID7', key: 'value7', token: { type: 'leaf' } }
                { uuid: 'UUID5', key: 'value5', token: { type: 'leaf' } } 
                { uuid: 'UUID8', key: 'value8', token: { type: 'leaf' } }
            ]

            done()


    context 'createIndexes', -> 

        beforeEach -> 

            @tree = new @Tree

            @tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT', token: { signature: 'context' }, title: 'the index' }
                    { uuid: 'CHILD1', token: { signature: 'it', type: 'leaf' }, title: 'has map from path to uuid' }
                ],  ->
            @tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT', token: { signature: 'context' }, title: 'the index' }
                    { uuid: 'CHILD2', token: { signature: 'it', type: 'leaf' }, title: 'has map from uuid to path' }
                ],  ->

                    


        it 'creates index from path to uuid', (done) -> 

            @tree.createIndexes {}, =>

                @tree.path2uuid.should.eql 

                    '/context/the index':                               'PARENT'
                    '/context/the index/it/has map from path to uuid':  'CHILD1'
                    '/context/the index/it/has map from uuid to path':  'CHILD2'

                done()

        it 'creates index from uuid to path', (done) -> 

            @tree.createIndexes {}, =>

                @tree.uuid2path.should.eql 

                    'PARENT': '/context/the index'
                    'CHILD1': '/context/the index/it/has map from path to uuid'
                    'CHILD2': '/context/the index/it/has map from uuid to path'

                done()

        it 'creates index from parent to children', (done) -> 

            @tree.createIndexes {}, =>

                @tree.children['PARENT'].should.eql ['CHILD1', 'CHILD2']
                done()


        it 'creates index from children to parent', (done) -> 

            @tree.createIndexes {}, =>

                @tree.parent.should.eql
                    CHILD1: 'PARENT'
                    CHILD2: 'PARENT'

                done()


        it 'creates list of leaves', (done) -> 

            @tree.createIndexes {}, =>

                @tree.leaves.should.eql  ['CHILD1', 'CHILD2']
                done()


        it 'appends tokens to message', (done) -> 

            msg = {}
            @tree.createIndexes msg, =>

                msg.should.eql 

                    tokens: 
                        '/context/the index': { signature: 'context' }
                        '/context/the index/it/has map from path to uuid': { signature: 'it', type: 'leaf' }
                        '/context/the index/it/has map from uuid to path': { signature: 'it', type: 'leaf' }

                done()

    context 'findRoute(uuidA, uuidB)', -> 

        #
        # only tree for now
        #

        beforeEach -> 

            @tree = new @Tree

            @tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT',      token: { signature: 'context' }, title: 'the index' }
                    { uuid: 'CHILD1',      token: { signature: 'context' }, title: 'has indexes'}
                ],  ->
            @tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT',      token: { signature: 'context' }, title: 'the index' }
                    { uuid: 'CHILD2',      token: { signature: 'it'      }, title: 'has map from uuid to path', type: 'leaf' }
                ],  ->

            @tree.registerEdge type: 'tree', vertices: [
                    { uuid: 'CHILD1',      token: { signature: 'context' }, title: 'has indexes'}
                    { uuid: 'GRANDCHILD1', token: { signature: 'it'      }, title: 'can get route (array of uuids)', type: 'leaf' }
                ],  ->
           

        it 'returns array if vertex uuids from start to end (inclusive)', (done) ->

            @tree.createIndexes {}, =>

                @tree.findRoute( null, 'GRANDCHILD1' ).should.eql ['PARENT', 'CHILD1', 'GRANDCHILD1']
                done()

