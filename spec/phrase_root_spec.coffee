should         = require 'should'
PhraseRoot     = require '../lib/phrase_root'
PhraseRecursor = require '../lib/phrase/phrase_recursor'

describe 'phrase', -> 

    phraseRecursor_swap = undefined
    
    beforeEach -> 

        phraseRecursor_swap = PhraseRecursor.walk 

    afterEach -> 

        PhraseRecursor.walk = phraseRecursor_swap


    context 'createRoot()', ->

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


            before -> 

                @count = 0

                @registrar = PhraseRoot.createRoot

                    title: 'Phrase Title'
                    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (token, notice) =>

                        @count++
                        @token  = token
                        @notice = notice

                @registrar 'phrase text', (end) -> 


            afterEach -> 

                @token.removeAllListeners()


            it 'calls linkFn', (done) -> 

                # 
                # @registrar 'phrase text', (end) -> 
                #

                should.exist @token
                done()


            it 'calls linkFn only once', (done) -> 

                @count.should.equal 1
                done()


            it 'creates a PhraseRecursor with root context', (done) -> 


                PhraseRecursor.walk = (root, opts) -> 

                    should.exist root.context
                    done()


                @registrar 'phrase text', -> 



            xit 'does the first walk', (done) -> 

                @token.on 'ready', => 

                    vertex = @token.graph.vertices[ @token.graph.leaves[0] ]
                    vertex.fn.toString().should.match /NESTED PHRASE FN/
                    done()


                @registrar 'phrase text', (nested) ->  

                    nested 'nested', (end) -> 

                        'NESTED PHRASE FN'

                        end()


            it 'does not allow concurrent walks', (done) -> 
                
                ERROR = undefined

                @registrar 'phrase text', (nested) =>  

                    try @registrar 'phrase text', (nested) ->  

                    catch error

                        ERROR = error


                    nested 'n', (end) ->

                        
                @token.on 'ready', -> 

                    ERROR.should.match /Phrase root registrar cannot perform concurrent walks/
                    done()



            xit 'has accumulated dead leaves', (done) -> 


                #
                # and should not have...
                #


                @token.on 'ready', => 

                    console.log @token.graph.tree.leaves
                    console.log @token.graph.leaves

                    @token.graph.leaves.length.should.equal 2
                    done()


                @registrar 'entirely new tree', (that) -> 

                    that 'has one leaf', (end) ->

                        end()

                    that 'has another leaf', (end) ->

                        end()



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

            PhraseRecursor.walk = (root, opts) -> -> 

                opts.title.should.equal 'Phrase Title'
                opts.uuid.should.equal '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
                done()

            root = PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()
