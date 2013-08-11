should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'

describe 'integrations', -> 

    it 'stacks up', (done) -> 

        falcon = PhraseRoot.createRoot 

            title: 'Falcon'
            uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

            (token, notice) -> 

                notice.use (msg, next) -> 

                    console.log '\n', msg.context.title, '\n', msg

                    if msg.context.title == 'phrase::recurse:end'

                        # for uuid in token.graph.leaves
                        #     console.log LEAF: 
                        #         tokenName: token.graph.vertices[uuid].token.name
                        #         text: token.graph.vertices[uuid].text

                        console.log JSON.stringify token.graph.tree, null, 2

                        next()
                        done()

                    next()
      
        falcon 'Generic', (system) -> 

            before all:  -> 
            before each: -> 
            after  each: -> 
            after  all:  -> 

            system 'sensory', (subsystem) -> 

                subsystem 'vision', (component) -> 

                    component 'eyes', (end) ->

            system 'flight', (subsystem) ->

                subsystem '...', (end) -> 

            system 'navigation', (subsystem) -> 

                subsystem.requires 'sensory'
                subsystem '...', (end) -> 

            system 'hunt', (subsystem) -> 

                #
                # dependancy encapsulation
                # 
                # 'the big one'... from a systems management perspective
                #

                subsystem.requires 'flight', 'navigation'


        # #
        # # and possibly:
        # #

        # peregrine = PhraseRoot.extend falcon, 'Peregrine Falcon'

        # peregrine 'appearence', (bodypart) -> 

        #     bodypart 'cheek', (cheek, patternlib), -> 

        #         # 
        #         # ...
        #         # 

