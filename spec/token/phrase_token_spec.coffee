should             = require 'should'
PhraseTokenFactory = require '../../lib/token/phrase_token'
ProcessToken       = require '../../lib/token/process_token'
PhraseToken        = undefined

describe 'LeafToken', -> 

    before -> 

        process     = new ProcessToken require 'also'
        PhraseToken = PhraseTokenFactory.createClass process.root 'UUID'

    it 'has immutable type, uuid, and signature', (done) -> 

        token = new PhraseToken type: 'leaf'
        token.type = 'renamed token'
        token.type.should.equal 'leaf'
        done()
