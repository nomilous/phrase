should       = require 'should'
PhraseRoot   = require('../../lib/phrase/root').createClass require 'also'
AccessToken  = require '../../lib/token/access_token'
Run          = require '../../lib/runner/run'

describe 'PhraseToken', -> 
    
    root       = undefined
    TOKEN      = undefined
    NOTICE     = undefined
    LEAF_TWO   = undefined
    NEST_ONE   = undefined

    # console.log before.toString()

    before (done) -> 

        root = PhraseRoot.createRoot

            title: 'Title'
            uuid:  'ROOT-UUID'
            notice: 
                use: ->
                phrase: ->

            (token, notice) -> 

                TOKEN  = token
                NOTICE = notice
                done()

        root 'phrase', (end) -> end()


    context 'run()', -> 

        it 'is a function', (done) -> 

            TOKEN.run.should.be.an.instanceof Function
            done()

        it 'returns a promise', (done) -> 

            TOKEN.run({}).then.should.be.an.instanceof Function
            done()

        it 'calls the phrase runner', (done) -> 

            swap = Run.start
            Run.start = -> 
                Run.start = swap
                done()

            TOKEN.run()


    context 'events', (done) -> 

        before -> 
            @token = AccessToken.create 
                context: 
                    notice: 
                        use: (@opts, @middleware) =>

        afterEach -> 

            @token.removeAllListeners() 


        context 'event "ready"', ->


            it 'is proxied from phrase::recurse:end', (done) -> 

                @token.on 'ready', (data) -> done()

                @middleware (->),

                    #
                    # send mock phrase::recurse:end
                    #

                    phrase: 'phrase::recurse:end'
                    walk: first: true
                    


            it 'is only proxied on the first walk', (done) ->

                @token.on 'ready', -> 

                    throw 'SHOULD NOT RUN'

                @middleware done, 

                    event: 'phrase::recurse:end'
                    walk: first: false


