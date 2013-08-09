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

            graph.registerEdge = (msg) -> 

                should.exist msg.type
                should.exist msg.leaf
                should.exist msg.vertices
                done()

            graph.assembler 

                #
                # mock 'phrase::edge:create' message
                #

                context: title: 'phrase::edge:create'
                type: 'tree'
                leaf: true
                vertices: []

                -> 

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

