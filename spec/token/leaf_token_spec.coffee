should           = require 'should'
LeafTokenFactory = require '../../lib/token/leaf_token'
ProcessToken     = require '../../lib/token/process_token'
LeafToken        = undefined

describe 'LeafToken', -> 

    before -> 

        process   = new ProcessToken require 'also'
        LeafToken = LeafTokenFactory.createClass process.root 'UUID'

    it 'has immutable type, uuid, and signature', (done) -> 

        token = new LeafToken {}
        token.type = 'renamed token'
        token.type.should.equal 'leaf'
        done()
