should      = require 'should'
PhraseGraph = require '../../lib/graph/phrase_graph'

describe 'PhraseGraph', -> 

    root  = undefined
    graph = undefined

    beforeEach -> 

        root  = {}
        graph = PhraseGraph.create root

    context 'assembler middleware', -> 

        