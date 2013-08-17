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

        xit 'is a function', (done) ->  

            PhraseRoot.createRoot.should.be.an.instanceof Function
            done()

        xit 'expects opts and linkFn', (done) -> 

            try PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            
            catch error

                error.should.match /phrase.createRoot\(opts,linkFn\) expects linkFn/
                done()



        context 'phrase root registrar', -> 


            it 'is a function', (done) -> 

                registrar = PhraseRoot.createRoot

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (token, notice) ->


                registrar.should.be.an.instanceof Function
                done()


            it 'creates a PhraseRecursor with root context', (done) -> 

                registrar = PhraseRoot.createRoot

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (token, notice) ->


                PhraseRecursor.create = (root, opts) -> 

                    should.exist root.context
                    done()


                registrar 'phrase text', -> 


            it 'calls linkFn', (done) -> 
                
                registrar = PhraseRoot.createRoot

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (token, notice) -> 

                        token.on 'ready', done

                
                registrar 'phrase text', (end) -> 



            it 'does the first walk', (done) -> 

                registrar = PhraseRoot.createRoot

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (token, notice) ->

                        token.on 'ready', -> 

                            

                            vertex = token.graph.vertices[ token.graph.leaves[0] ]
                            vertex.fn.toString().should.match /NESTED PHRASE FN/
                            done()


                registrar 'phrase text', (nested) ->  

                    nested 'nested', (end) -> 

                        'NESTED PHRASE FN'

                        end()


            it 'does not allow a second walk', (done) -> 

                registrar = PhraseRoot.createRoot

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (token, notice) ->
     

                registrar 'phrase text', (nested) ->  

                    try registrar 'phrase text', (nested) ->  

                    catch error

                        error.should.match /Phrase root registrar cannot perform concurrent walks/
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
