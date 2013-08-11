should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        falcon = PhraseRoot.createRoot 

            title: 'Falcon'
            uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

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

                        ->
                        ->
                        (update) -> console.log '\n', update.state, update

                    )

      
        falcon 'Generic', (system) -> 

            before all:  -> 
                @value = """



                    CONTEXT


                """
            before each: -> 
            after  each: -> 
            after  all:  -> 

            system 'sensory', (subsystem) -> 

                subsystem 'vision', (component) -> 

                    component 'eyes', (end) ->

            system 'flight', (subsystem) ->

                subsystem 'left wing', (end) -> 
                subsystem 'right wing', (end) -> 

            system 'navigation', (subsystem) -> 

                subsystem 'gps', (end) -> 



                    console.log @value



            system 'hunt', (subsystem) -> 

                subsystem 'prey detection', (end) ->


