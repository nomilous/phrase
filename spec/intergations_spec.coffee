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

                    if msg.context.title == 'phrase::recurse:end'

                        for uuid in token.graph.leaves

                            console.log LEAF: 
                                tokenName: token.graph.vertices[uuid].token.name
                                text: token.graph.vertices[uuid].text

                        next()
                        done()

                    next()
      
        root 'root phrase', (outer) -> 

            before all:  -> 
            before each: -> 
            after  each: -> 
            after  all:  -> 

            outer 'outer phrase 1', (inner) -> 

                inner 'inner phrase 1', (end) -> 
                inner 'inner phrase 2', (end) -> 

            outer 'another leaf', (end) -> end()
