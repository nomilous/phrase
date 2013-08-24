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

                    
                    token.run( add, input1: 7, input2: 3 ).then(

                        (result) ->

                            result.job.answer.should.equal 10
                            done()

                        (error)  -> 

                            console.log ERROR: error

                    )


        arithmatic 'operations', (operation) -> 

            operation 'add', (done) -> 

                @answer = @input1 + @input2
                done()

            operation 'subtract', (done) -> 

                done()

