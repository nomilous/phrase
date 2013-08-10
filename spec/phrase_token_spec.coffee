should       = require 'should'
PhraseRoot   = require '../lib/phrase_root'
PhraseToken  = require '../lib/phrase_token'
PhraseRunner = require '../lib/phrase/phrase_runner'

describe 'PhraseToken', -> 
    
    root       = undefined
    TOKEN      = undefined
    NOTICE     = undefined
    LEAF_TWO   = undefined
    NEST_ONE   = undefined

    beforeEach (done) -> 

        PhraseRoot.createRoot

            title: 'Title'
            uuid:  'ROOT-UUID'

            (token, notice) -> 

                TOKEN  = token
                NOTICE = notice
                done()

    context 'eventProxy', (done) -> 

        it 'proxies phrase::recurse:end from the message bus to local token event "ready"', (done) -> 

            TOKEN.on 'ready', -> done()
            NOTICE.event 'phrase::recurse:end'


    context 'run()', -> 

        it 'is a function', (done) -> 

            TOKEN.run.should.be.an.instanceof Function
            done()

        it 'returns a promise', (done) -> 

            TOKEN.run().then.should.be.an.instanceof Function
            done()

        it 'calls the phrase runner', (done) -> 

            swap = PhraseRunner.run
            PhraseRunner.run = -> 
                PhraseRunner.run = swap
                done()

            TOKEN.run()
