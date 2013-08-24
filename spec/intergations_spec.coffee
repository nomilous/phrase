should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'updatability', (done) -> 

        arithmatic = PhraseRoot.createRoot

            title: 'Arithmatic'
            uuid:  '1'
            leaf: ['done']

            (token, notice) -> 

                token.on 'ready', (data) -> 

                    for path of data.tokens

                        add      = data.tokens[path] if path.match /add$/
                        subtract = data.tokens[path] if path.match /subtract$/

                    
                    token.run( add, input1: 7, input2: 3 ).then (result) ->

                        should.exist result.job
                        console.log result
                        done()


        arithmatic 'operations', (operation) -> 

            operation 'add', (done) -> 

                done()

            operation 'subtract', (done) -> 

                done()

