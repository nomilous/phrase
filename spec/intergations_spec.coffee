should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        falcon = PhraseRoot.createRoot 

            title: 'Falcon'
            uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            #leaf: ['end', 'done']
            timeout: 1000

            (token, @notice) => 

                @notice.use (msg, next) -> 

                    if msg.context.title == 'inline notification'

                        console.log MESSAGE: msg
                        setTimeout next, msg.waitForNotice
                        return

                    if msg.context.title == 'progress'

                        console.log msg

                    next()



                token.on 'ready', (data) -> 

                    console.log JSON.stringify data.tokens, null, 2
                    #done()

                    #
                    # TODO: a way to call runs on branch or leaf
                    #       (While the uuid is not known)
                    #
                    

                    # console.log token.graph.vertices

                    # token.run( uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a' ).then( 

                    #     (result) -> 
                    #         console.log '\n', 'RESULT', '\n', result

                            
                    #         result.job.ultraviolet.should.equal 234
                    #         # done()

                    #     (error) -> 
                    #         console.log '\n', 'ERROR',  '\n', error

                    #     (update) -> 
                    #         # console.log '\n', 'UPDATE', '\n', 
                    #         #     update.state || update.event, JSON.stringify update, null, 2

                    # )

      
        falcon 'Generic', (system) -> 

            before all:  (done) -> done()
            before each: -> 
            after  each: ->  
            after  all:  ->  

                console.log 'afterall'
                #setTimeout done, 500

            system 'sensory', (subsystem) -> 

                subsystem 'vision', (component) -> 

                    component 'left eye', (end) ->

                        console.log 'left eye'
                        @ultraviolet = 234
                        setTimeout end, 10


                    component 'right eye', (end) ->

                        #throw new Error 'mooo'

                        # 1.should.equal 2

                        console.log 'left eye'
                        setTimeout end, 10



            system 'flight', (subsystem) ->

                before each: (done) -> done() 

                subsystem 'left wing', (end) -> 

                    console.log 'left wing start'

                    @notice.info( 'inline notification',

                        handy: true
                        waitForNotice:  10

                    ).then -> 

                        console.log 'left wing done'
                        end()


                subsystem 'right wing', (end) -> 

                    @notice.info( 'progress', @progress() ).then -> 

                        console.log 'right wing'
                        end()

            # system 'navigation', (subsystem) -> 

            #     subsystem 'gps', (end) -> 

            #         console.log GPS: ''

            #         @location = [0.0,0.0,0.0]


            # system 'hunt', (subsystem) -> 

            #     subsystem 'prey detection', (end) ->


        setTimeout (=>

            console.log 'redefine falcon'


            falcon 'Generic', (system) -> 

                system 'sensory', (subsystem) -> 

                    subsystem 'vision', (component) -> 

                        component 'left eye', (end) ->

                            end()

                        component 'right eye', (end) ->

                            end()


        ), 500



