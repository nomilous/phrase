should           = require 'should'
RootTokenFactory = require '../../lib/token/root_token'
ProcessToken     = require '../../lib/token/process_token'
RootToken        = undefined

describe 'LeafToken', -> 

    before -> 

        process   = new ProcessToken require 'also'
        RootToken = RootTokenFactory.createClass process.root 'UUID'

    it 'has immutable type, uuid, and signature', (done) -> 

        token = new RootToken {}
        token.type = 'renamed token'
        token.type.should.equal 'root'
        done()
