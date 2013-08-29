should             = require 'should'
PhraseTokenFactory = require '../../lib/token/phrase_token'
ProcessToken       = require '../../lib/token/process_token'
PhraseToken        = undefined

describe 'LeafToken', -> 

    before -> 

        process     = new ProcessToken require 'also'
        PhraseToken = PhraseTokenFactory.createClass process.root 'UUID'

    it 'has immutable uuid, and signature', (done) -> 

        token = new PhraseToken type: 'leaf', uuid: 'UUID', signature: 'signature'
        
        token.uuid = 9
        token.signature = '®†∑´®œ√œ'
        token.should.eql type: 'leaf', uuid: 'UUID', signature: 'signature'
        done()
