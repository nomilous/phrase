should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        root = PhraseRoot.createRoot 

            title: 'Phrase Title'
            uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

            (token, notice) -> 

                notice.use (msg, next) -> 

                    console.log '\n', msg.context.title, '\n', msg

                    done() if msg.context.title == 'phrase::recurse:end'
                    next()

        root 'root phrase 1', (end) ->       
        root 'root phrase 2', (outer) -> 

            before all:  -> 
            before each: -> 
            after  each: -> 
            after  all:  -> 

            outer 'outer phrase', (inner) -> 

                inner 'inner phrase 1', (end) -> 
                inner 'inner phrase 2', (end) -> 


