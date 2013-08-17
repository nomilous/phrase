should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'
PhraseRecursor = require '../lib/phrase/phrase_recursor'

describe 'phrase', -> 

    phraseRecursor_swap = undefined
    
    beforeEach -> 

        phraseRecursor_swap = PhraseRecursor.create 

    afterEach -> 

        PhraseRecursor.create = phraseRecursor_swap


    context 'create()', ->

        it 'is a function', (done) ->  

            PhraseRoot.createRoot.should.be.an.instanceof Function
            done()

        it 'expects opts and linkFn', (done) -> 

            try PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            
            catch error

                error.should.match /phrase.createRoot\(opts,linkFn\) expects linkFn/
                done()



        context 'phrase root registrar', -> 


            before (done) -> 

                @linked = undefined

                #
                # create rootFn
                #  
            
                @rootFn = PhraseRoot.createRoot

                    #
                    # opts
                    #

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    #
                    # linkFn
                    #

                    (token, notice) => 

                        @linked = 

                            token:  token
                            notice: notice

                done()

            beforeEach -> 

                @linked = undefined


            it 'is a function', (done) -> 

                @rootFn.should.be.an.instanceof Function
                done()


            it 'creates a PhraseRecursor with root context', (done) -> 

                PhraseRecursor.create = (root, opts) -> 

                    should.exist root.context
                    done()

                @rootFn 'phrase text', -> 


            it 'calls linkFn', (done) -> 

                should.not.exist @linked

                @rootFn 'phrase text', -> 
                should.exist @linked.token
                should.exist @linked.notice
                done()



            it 'does the first walk', (done) -> 


                @rootFn 'phrase text', (nested) ->  

                    nested 'nested', (end) -> 

                        'NESTED PHRASE FN'

                        end()

                graph = @linked.token.graph

                @linked.token.on 'ready', -> 

                    vertex = graph.vertices[ graph.leaves[0] ]
                    vertex.fn.toString().should.match /NESTED PHRASE FN/
                    done()






        xit 'passes rootToken into linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (token, notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()


        xit 'passes notifier into linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (token, notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()


        xit 'passes opts into the root phrase recursor', (done) -> 

            PhraseRecursor.create = (root, opts) -> -> 

                opts.title.should.equal 'Phrase Title'
                opts.uuid.should.equal '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
                done()

            root = PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()
