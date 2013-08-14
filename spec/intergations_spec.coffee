should         = require 'should'
coffee         = require 'coffee-script'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        falcon = PhraseRoot.createRoot 

            title: 'Falcon'
            uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            #leaf: ['end', 'done']
            timeout: 1000

            (token, notice) -> 

                token.on 'ready', -> 

                    #
                    # TODO: this following is obviously not a particularly
                    #       sensible way to get things running...
                    #

                    vertices = token.graph.vertices
                    root = (for uuid of vertices
                        v = vertices[uuid]
                        continue unless v.text == 'Generic'
                        uuid
                    )[0]

                    token.run( uuid: root ).then( 

                        (result) -> 
                            console.log '\n', 'RESULT', '\n', result

                            
                            result.job.ultraviolet.should.equal 234
                            done()

                        (error) -> 
                            console.log '\n', 'ERROR',  '\n', error

                        (update) -> 
                            # console.log '\n', 'UPDATE', '\n', 
                            #     update.state || update.event, JSON.stringify update, null, 2

                    )

      
        falcon 'Generic', (system) -> 

            before all:  (done) -> done()
            before each: -> 
            after  each: ->  
            after  all:  ->  

                console.log 'afterall'
                setTimeout done, 500

            system 'sensory', (subsystem) -> 

                subsystem 'vision', (component) -> 

                    component 'left eye', (end) ->

                        console.log 'left eye'
                        @ultraviolet = 234
                        setTimeout end, 300


                    component 'right eye', (end) ->

                        #throw new Error 'mooo'

                        #1.should.equal 2

                        console.log 'left eye'
                        setTimeout end, 300



            system 'flight', (subsystem) ->

                before each: -> 1.should.equal 2

                subsystem 'left wing', (end) -> 

                    console.log 'left wing'
                    setTimeout end, 300

                subsystem 'right wing', (end) -> 

                    console.log 'right wing'
                    setTimeout end, 300

            # system 'navigation', (subsystem) -> 

            #     subsystem 'gps', (end) -> 

            #         console.log GPS: ''

            #         @location = [0.0,0.0,0.0]


            # system 'hunt', (subsystem) -> 

            #     subsystem 'prey detection', (end) ->


