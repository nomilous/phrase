should              = require 'should'
BoundryTokenFactory = require '../../lib/token/boundry_token'
ProcessToken        = require '../../lib/token/process_token'
BoundryToken           = undefined

describe 'BoundryToken', -> 

    before -> 

        process   = new ProcessToken require 'also'
        BoundryToken = BoundryTokenFactory.createClass process.root 'UUID'

    it 'has immutable type, uuid, and signature', (done) -> 

        token = new BoundryToken {}
        token.type = 'renamed token'
        token.type.should.equal 'boundry'
        done()
