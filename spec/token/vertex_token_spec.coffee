should             = require 'should'
VertexTokenFactory = require '../../lib/token/vertex_token'
ProcessToken       = require '../../lib/token/process_token'
VertexToken        = undefined

describe 'LeafToken', -> 

    before -> 

        process   = new ProcessToken require 'also'
        VertexToken = VertexTokenFactory.createClass process.root 'UUID'

    it 'has immutable type as vertex', (done) -> 

        token = new VertexToken 
        token.type = 'renamed token'
        token.type.should.equal 'vertex'
        done()
