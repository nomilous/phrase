should      = require 'should'
PhraseGraph = require '../../lib/graph/phrase_graph'

describe 'PhraseGraph', -> 

    root  = undefined
    graph = undefined

    beforeEach -> 

        root  = {}
        graph = PhraseGraph.create root

    context 'assembler middleware', -> 

        it 'registers edges', (done) ->

            graph.registerEdge = (msg) -> 

                should.exist msg.$type
                should.exist msg.$leaf
                should.exist msg.vertices
                done()

            graph.assembler 

                #
                # mock 'phrase::edge:create' message
                #

                context: title: 'phrase::edge:create'
                $type: 'tree'
                $leaf: true
                vertices: []

                -> 

    context 'register edge', -> 

        it ''
