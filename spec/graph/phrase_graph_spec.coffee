should      = require 'should'
PhraseGraph = require '../../lib/graph/phrase_graph'

describe 'PhraseGraph', -> 

    root  = undefined
    graph = undefined

    beforeEach -> 

        root  = {}
        graph = PhraseGraph.create root

    it 'provides access to vertices list as property', (done) -> 

        graph.vertices.should.eql {}
        done()


    context 'assembler middleware', -> 

        it 'registers edges', (done) ->

            graph.assembler 

                #
                # mock 'phrase::edge:create' message
                #

                context: title: 'phrase::edge:create'
                vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2' }
                ]

                -> 

                    should.exist graph.vertices.UUID1
                    should.exist graph.vertices.UUID2
                    done()


    context 'register edge', -> 

        it 'registers vertices into the list', (done) -> 

            graph.registerEdge

                vertices: [

                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2' }

                ]

                ->

            graph.vertices.should.eql 

                UUID1: uuid: 'UUID1', key: 'value1'
                UUID2: uuid: 'UUID2', key: 'value2'

            done()

        
        it 'registers edges into the list', (done) -> 

            graph.registerEdge

                vertices: [

                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2' }

                ]

                ->


            graph.edges.should.eql 

                UUID1: [ connect: 'UUID2' ]
                UUID2: [ connect: 'UUID1' ]

            done()


        it 'allows multiple edges per vertex', (done) -> 

            graph.registerEdge vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2' }
                ],  ->

            graph.registerEdge vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID3', key: 'value3' }
                ],  ->

            graph.edges.should.eql 

                UUID1: [ { connect: 'UUID2' }, { connect: 'UUID3' }]
                UUID2: [ { connect: 'UUID1' }                      ]
                UUID3: [ { connect: 'UUID1' }                      ]

            

            done()


        it 'stores parent and child relations if tree', (done) -> 

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

            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2', leaf: true }
                ],  ->

            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID3', key: 'value3' }
                ],  ->

            graph.leaves.should.eql ['UUID2']

            done()

    context 'register leaf', -> 

        it 'stores registered leaves and provides access to the list via tree.leaves', (done) ->

            graph.registerLeaf 

                uuid: 'UUID3'
                path: ['UUID1', 'UUID2']

                -> 
                    graph.tree.leaves.UUID3.should.eql 

                        uuid: 'UUID3'
                        path: ['UUID1', 'UUID2']

                    done()


    context 'leavesOf(uuid)', -> 

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



