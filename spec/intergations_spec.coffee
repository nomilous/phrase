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

                            #result.job.answer.should.equal 10
                            #done()

                        (error)  -> 

                            console.log ERROR: error

                        (update) -> 

                            if update.state == 'run::step:failed'

                                # console.log update
                                
                                #
                                #  state: 'run::step:failed',
                                #  class: 'PhraseJob',
                                #  jobUUID: 'd254b360-0cbf-11e3-823a-01cf205a2ddf',
                                #  progress: { steps: 1, done: 0, failed: 1, skipped: 0 },
                                #  at: 1377350375835,
                                #  error: [Error: UnexpectedError caught inline],
                                #  step: 
                                #   { set: 1,
                                #     depth: 2,
                                #     type: 'leaf',
                                #     ref: 
                                #      { uuid: [Getter],
                                #        token: [Getter],
                                #        text: [Getter],
                                #        leaf: [Getter/Setter] },
                                #     fail: true },
                                #  originator: true }
                                #

                                ''

                    )

                    token.run( subtract, input1: 100000000000000000000, input2: 1 ).then (result) ->

                            console.log result
                            result.job.answer.should.equal 100000000000000000000 
                                                                    # 
                                                                    # javascript... :)
                                                                    #
                            done()


                    #
                    # add and subtract are also tokens
                    # --------------------------------
                    # 
                    # TODO: make them directly callable 
                    #     
                    #       but later... (because a future use case plays that hand very specifically)
                    #

                    # add( input1: 7, input2: 3 ).then -> 



        arithmatic 'operations', (operation) -> 

            operation 'add', (done) -> 

                @answer = @input1 + @input2

                #
                # TODO: KnownError pathway
                #

                done new Error 'KnownError via resolver'
                throw new Error 'UnexpectedError caught inline'
                

            operation 'subtract', (done) -> 

                done()
                @answer = @input1 - @input2
