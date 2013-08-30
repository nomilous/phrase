should             = require 'should'
PhraseTokenFactory = require '../../lib/token/phrase_token'
ProcessToken       = require '../../lib/token/process_token'
PhraseToken        = undefined
phrase             = require '../../lib/phrase'

describe 'PhraseToken', -> 

    before -> 

        process     = new ProcessToken require 'also'
        PhraseToken = PhraseTokenFactory.createClass process.root 'UUID'

    it 'has immutable uuid, and signature', (done) -> 

        token = new PhraseToken type: 'leaf', uuid: 'UUID', signature: 'signature'
        
        token.uuid = 9
        token.signature = '®†∑´®œ√œ'
        token.should.eql type: 'leaf', uuid: 'UUID', signature: 'signature'
        done()


    it 'can serialize its branch', (done) -> 


        innerBeforeAll   = (done) -> 'innerBeforeAll  '; done()
        innerAfterAll    = (done) -> 'innerAfterAll   '; done()
        deeperBeforeEach = (done) -> 'deeperBeforeEach'; done()
        deeperBeforeAll  = (done) -> 'deeperBeforeAll '; done()
        leaf1            = (done) -> 'leaf1           '; done()
        leaf2            = (done) -> 'leaf2           '; done()
        leaf3            = (done) -> 'leaf3           '; done()


        test = (serialized) -> 

            console.log serialized
            serialized.should.eql {}
            
            done()


        recursor = phrase.createRoot
            title: 'Test'
            uuid:  'ROOT'
            (accessToken) -> 
                accessToken.on 'ready', ({tokens}) ->
                    test tokens['/Test/outer phrase'].serialize()

        recursor 'outer phrase', (nested) -> 
            before all: innerBeforeAll
            after  all: innerAfterAll
            nested 'inner phrase 1', (deeper) -> 
                before 
                    all:  deeperBeforeAll
                    each: deeperBeforeEach
                deeper 'deeper phrase 1', leaf1
                deeper 'deeper phrase 2', leaf2
            nested 'inner phrase 2', leaf3



        