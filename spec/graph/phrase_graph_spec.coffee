should      = require 'should'
PhraseGraph = require '../../lib/graph/phrase_graph'

describe 'PhraseGraph', -> 


    root  = undefined
    Graph = undefined
    graph = undefined

    before -> 

        root = context: notice: use: ->
        Graph = PhraseGraph.createClass root
        graph = new Graph


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

            it 'removes old graphs from the collection', (done) -> 

                graph1 = new Graph
                graph2 = new Graph
                graph3 = new Graph

                should.exist     root.context.graphs.list[graph3.uuid]
                should.exist     root.context.graphs.list[graph2.uuid]
                should.not.exist root.context.graphs.list[graph1.uuid]
                done()


    context 'general', ->

        it 'has a uuid', (done) -> 

            should.exist graph.uuid
            done()

        it 'has a version', (done) -> 

            should.exist graph.version
            done()


        it 'is added to the graphs collection on the root context', (done) -> 

            g = new Graph
            g.should.equal root.context.graphs.list[ g.uuid ]
            done()


        it 'most recently created graph is set as latest in the graphs collection', (done) -> 

            one = new Graph
            root.context.graphs.latest.touch1 = 1
            two = new Graph
            root.context.graphs.latest.touch2 = 2

            should.exist one.touch1
            should.exist two.touch2
            should.not.exist one.touch2

            done()


        it 'provides access to vertices and edges lists', (done) -> 

            graph.vertices.should.eql {}
            graph.edges.should.eql {}
            done()     


    context 'assembler middleware', -> 

        before -> 

            @Graph = PhraseGraph.createClass context: notice: use: (@middleware) =>


        it 'registers on the message bus', (done) -> 

                # 
                # odd... Seems like a function returned by a property
                #        no longer appears to have a the same prototype
                #        instance as the function itself.
                # 
                # middleware.should.equal Graph.assembler
                # console.log middleware is Graph.assembler
                #

                @middleware.toString().should.equal @Graph.assembler.toString()
                done()          # 
                                # marginally pointless...
                                # 



        context 'registerEdge()', ->


            it 'is called by the assember at phrase::edge:create', (done) -> 

                graph = new @Graph

                graph.registerEdge = -> done()

                @Graph.assembler

                    context: title: 'phrase::edge:create'
                    ->


            it 'creates vertices', (done) -> 

                graph = new @Graph

                graph.registerEdge 

                    #
                    # mock 'phrase::edge:create' message
                    #

                    context: title: 'phrase::edge:create'
                    vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ]

                    -> 

                        graph.vertices.should.eql 

                            UUID1: uuid: 'UUID1', key: 'value1'
                            UUID2: uuid: 'UUID2', key: 'value2'
                        
                        done()


            it 'creates edges' , (done) ->

                graph = new @Graph

                graph.registerEdge 

                    #
                    # mock 'phrase::edge:create' message
                    #

                    context: title: 'phrase::edge:create'
                    vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ]

                    -> 

                        graph.edges.should.eql 

                            UUID1: [ { to: 'UUID2' } ]
                            UUID2: [ { to: 'UUID1' } ]
                        
                        done()


            it 'allows multiple edges per vertex', (done) -> 

                graph = new @Graph

                graph.registerEdge vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ],  ->

                graph.registerEdge vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->

                graph.edges.should.eql 

                    UUID1: [   { to: 'UUID2' }, { to: 'UUID3' }   ]
                    UUID2: [   { to: 'UUID1' }                    ]
                    UUID3: [   { to: 'UUID1' }                    ]

                
                done()

            it 'stores parent and child relations (if tree)', (done) -> 

                graph = new @Graph

                graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2' }
                ],  ->

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->


                graph.parent.should.eql 

                    UUID3: 'UUID1'
                    UUID2: 'UUID1'

                graph.children.should.eql 

                    UUID1: ['UUID2', 'UUID3']


                done()


            it 'stores a list of leaves if tree', (done) -> 

                #
                # vertices are flagged a leaf by the PhraseRecursor
                #

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2', leaf: true }
                    ],  ->

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID3', key: 'value3' }
                        { uuid: 'UUID4', key: 'value4', leaf: true }
                    ],  ->

                graph.leaves.should.eql ['UUID2', 'UUID4']

                done()


    context 'leavesOf(uuid)', -> 

        it 'returns the vertex at uuid if it is a leaf', (done) -> 

            graph = new @Graph

            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', arbkey: 'arbvalue', leaf: true }
                ],  ->

            graph.leavesOf( 'UUID2' )[0].arbkey.should.equal 'arbvalue'
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

            graph = new @Graph

            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID3', key: 'value3' }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID3', key: 'value3' }
                    { uuid: 'UUID4', key: 'value4' }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID3', key: 'value3' }
                    { uuid: 'UUID5', key: 'value5', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID4', key: 'value4' }
                    { uuid: 'UUID6', key: 'value6', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID4', key: 'value4' }
                    { uuid: 'UUID7', key: 'value7', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID8', key: 'value8', leaf: true }
                ],  ->


            graph.leavesOf( 'UUID4' ).should.eql [ 
                { uuid: 'UUID6', key: 'value6', leaf: true }
                { uuid: 'UUID7', key: 'value7', leaf: true }
            ]

            graph.leavesOf( 'UUID3' ).should.eql [ 
                { uuid: 'UUID6', key: 'value6', leaf: true }
                { uuid: 'UUID7', key: 'value7', leaf: true }
                { uuid: 'UUID5', key: 'value5', leaf: true } 
            ]

            graph.leavesOf( 'UUID1' ).should.eql [ 
                { uuid: 'UUID2', key: 'value2', leaf: true }
                { uuid: 'UUID6', key: 'value6', leaf: true }
                { uuid: 'UUID7', key: 'value7', leaf: true }
                { uuid: 'UUID5', key: 'value5', leaf: true } 
                { uuid: 'UUID8', key: 'value8', leaf: true }
            ]

            done()


    context 'createIndexes', -> 

        beforeEach -> 

            @graph = new @Graph

            @graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT', token: { name: 'context' }, text: 'the index' }
                    { uuid: 'CHILD1', token: { name: 'it' }, text: 'has map from path to uuid', leaf: true }
                ],  ->
            @graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT', token: { name: 'context' }, text: 'the index' }
                    { uuid: 'CHILD2', token: { name: 'it' }, text: 'has map from uuid to path', leaf: true }
                ],  ->

                    


        it 'creates index from path to uuid', (done) -> 

            @graph.createIndexes {}, =>

                @graph.path2uuid.should.eql 

                    '/context/the index':                               'PARENT'
                    '/context/the index/it/has map from path to uuid':  'CHILD1'
                    '/context/the index/it/has map from uuid to path':  'CHILD2'

                done()

        it 'creates index from uuid to path', (done) -> 

            @graph.createIndexes {}, =>

                @graph.uuid2path.should.eql 

                    'PARENT': '/context/the index'
                    'CHILD1': '/context/the index/it/has map from path to uuid'
                    'CHILD2': '/context/the index/it/has map from uuid to path'

                done()

        it 'creates index from parent to children', (done) -> 

            @graph.createIndexes {}, =>

                @graph.children['PARENT'].should.eql ['CHILD1', 'CHILD2']
                done()


        it 'creates index from children to parent', (done) -> 

            @graph.createIndexes {}, =>

                @graph.parent.should.eql
                    CHILD1: 'PARENT'
                    CHILD2: 'PARENT'

                done()


        it 'creates list of leaves', (done) -> 

            @graph.createIndexes {}, =>

                @graph.leaves.should.eql  ['CHILD1', 'CHILD2']
                done()


        it 'appends tokens to message', (done) -> 

            msg = {}
            @graph.createIndexes msg, =>

                msg.should.eql 

                    tokens: 
                        '/context/the index': { name: 'context' }
                        '/context/the index/it/has map from path to uuid': { name: 'it' }
                        '/context/the index/it/has map from uuid to path': { name: 'it' }

                done()

    context 'findRoute(uuidA, uuidB)', -> 

        #
        # only tree for now
        #

        beforeEach -> 

            @graph = new @Graph

            @graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT',      token: { name: 'context' }, text: 'the index' }
                    { uuid: 'CHILD1',      token: { name: 'context' }, text: 'has indexes'}
                ],  ->
            @graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'PARENT',      token: { name: 'context' }, text: 'the index' }
                    { uuid: 'CHILD2',      token: { name: 'it' }, text: 'has map from uuid to path', leaf: true }
                ],  ->

            @graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'CHILD1',      token: { name: 'context' }, text: 'has indexes'}
                    { uuid: 'GRANDCHILD1', token: { name: 'it' }, text: 'can get route (array of uuids)', leaf: true }
                ],  ->
           

        it 'returns array if vertex uuids from start to end (inclusive)', (done) ->

            @graph.createIndexes {}, =>

                @graph.findRoute( null, 'GRANDCHILD1' ).should.eql ['PARENT', 'CHILD1', 'GRANDCHILD1']
                done()

