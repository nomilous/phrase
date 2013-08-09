should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        root = PhraseRoot.createRoot 

            title: 'Phrase Title'
            uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

            (token, notice) -> 

                notice.use (msg, next) -> 

                    # console.log '\n', msg.context.title, '\n', msg

                    if msg.context.title == 'phrase::edge:create'

                        [v1, v2] = msg.vertices

                        console.log "\n[#{ try v1.uuid }]#{ try v1.text } - [#{ try v1.uuid }]#{try v2.text}"


                    next()

                setTimeout (->

                    console.log JSON.stringify token.edges, null, 2
                    done()

                ), 100

        root 'root phrase 1', (end) ->       
        root 'root phrase 2', (outer) -> 

            before all:  -> 
            before each: -> 
            after  each: -> 
            after  all:  -> 

            outer 'outer phrase', (inner) -> 

                inner 'inner phrase 1', (end) -> 
                inner 'inner phrase 2', (end) -> 


