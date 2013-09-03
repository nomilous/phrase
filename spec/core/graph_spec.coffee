should   = require 'should'
Graph = require '../../lib/core/graph'

describe 'Graph', -> 

    it 'dangles a middleware onto the core', (done) -> 


        core = {}
        Graph.create core
        should.exist core.assembler
        done()
