should         = require 'should'
coffee         = require 'coffee-script'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        falcon = PhraseRoot.createRoot 

            title: 'Falcon'
            uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            leaf: ['end', 'done']
            timeout: 100

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

                            
                            console.log result.job.ultraviolet.should.equal 234
                            done()

                        (error) -> 
                            console.log '\n', 'ERROR',  '\n', error

                        (update) -> 
                            console.log '\n', 'UPDATE', '\n', 
                                update.state, JSON.stringify update, null, 2

                    )

      
        falcon 'Generic', (system) -> 

            before all:  (done) -> done()
            before each: -> 
            after  each: -> 
            after  timeout: 1800, all:  (done) -> 

            system 'sensory',

                #
                # redefined leaf match and timeout for all subnodes
                #

                leaf: ['blink']
                timeout: 1000

                (subsystem) -> 

                    subsystem 'vision', (component) -> 

                        component 'eyes', (blink) ->

                            console.log END: blink

                            @ultraviolet = 234

            # system 'flight', (subsystem) ->

            #     subsystem 'left wing', (end) -> 
            #     subsystem 'right wing', (end) -> 

            # system 'navigation', (subsystem) -> 

            #     subsystem 'gps', (end) -> 

            #         console.log GPS: ''

            #         @location = [0.0,0.0,0.0]


            # system 'hunt', (subsystem) -> 

            #     subsystem 'prey detection', (end) ->


