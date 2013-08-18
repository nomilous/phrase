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


    it 'has a uuid', (done) -> 

        should.exist graph.uuid
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
                # vertexes are flaggeg a leaf by the PhraseRecursor
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


    xcontext 'register leaf', -> 

        it 'stores registered leaves and provides access to the list via tree.leaves', (done) ->

            graph.registerLeaf 

                uuid: 'UUID3'
                path: ['UUID1', 'UUID2']

                -> 
                    graph.tree.leaves.UUID3.should.eql 

                        uuid: 'UUID3'
                        path: ['UUID1', 'UUID2']

                    done()


    xcontext 'leavesOf(uuid)', -> 

        it 'returns the vertex at uuid if it is a leaf', (done) -> 

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



