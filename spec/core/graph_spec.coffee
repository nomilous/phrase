should     = require 'should'
Graph      = require '../../lib/core/graph'
phrase     = require '../../lib/phrase'
TreeWalker = require '../../lib/recursor/tree_walker' 



describe 'Graph', -> 

    beforeEach -> 
        @walk = TreeWalker.walk

    afterEach -> 
        TreeWalker.walk = @walk

    it 'dangles a middleware onto the core', (done) -> 


        core = {}
        Graph.create core
        should.exist core.assembler
        done()


    context 'integrations', -> 

        it 'receives messages from all PhraseTrees', (done) -> 

            phrase1 = phrase.createRoot

                title: 'Phrase1'
                uuid:  'phrase1'

                (token, notice, root) -> 

                    i = 0
                    notice.use (msg, next) -> 

                        if msg.context.title == 'phrase::boundry:assemble'

                            #
                            # create new phrase on the call to boundry assemble
                            #

                            msg.phrase = 
                                title: msg.opts.filename.replace /\//g, '.'
                                control: uuid:  "0000000#{i++}"
                                fn: (nested) -> 
                                    nested 'phrase title', (deeper) -> 
                                        deeper 'phrase title', (end) -> 
                                            end()
                        
                        next()

                    token.on 'ready', ({tokens}) -> 

                        neuron = tokens['/Phrase1/test/nest/boundry phrase/edge/examples.neuron.coffee']

                        neuron.should.eql

                            signature: 'edge'
                            uuid: '00000001'
                            type: 'tree'
                            source: 
                                type: 'file'
                                filename: 'examples/neuron.coffee'

                        #
                        # the generated boundry reference phrase should be an insstance of 
                        # the PhraseNode definition from the boundry origin tree 
                        #

                        vertex = root.context.tree.vertices[neuron.uuid]
                        vertex.should.be.an.instanceof root.context.PhraseNode

                        #
                        # the generated token in the boundry phrase should be an instance 
                        # of the PhraseToken definition from the boundry origin tree 
                        #

                        neuron.should.be.an.instanceof root.context.PhraseToken




                        done()
                        
            
            phrase1 'test', (nest) -> 
                nest 'boundry phrase', (edge) ->

                    edge.link directory: './examples'
        
