should              = require 'should'
BoundryTokenFactory = require '../../lib/token/boundry_token'
ProcessToken        = require '../../lib/token/process_token'
BoundryToken           = undefined

describe 'BoundryToken', -> 

    before -> 

        process   = new ProcessToken require 'also'
        BoundryToken = BoundryTokenFactory.createClass process.root 'UUID'

    it 'has immutable type as leaf', (done) -> 

        token = new BoundryToken 
        token.type = 'edge'
        token.type.should.equal 'boundry'
        done()
