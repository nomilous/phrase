should         = require 'should'
Phrase         = require '../lib/phrase_root'
PhraseRecursor = require '../lib/phrase/recursor'

describe 'phrase', -> 

    phraseRecursor_swap = undefined
    
    beforeEach -> 

        phraseRecursor_swap = PhraseRecursor.create 

    afterEach -> 

        PhraseRecursor.create = phraseRecursor_swap

    context 'create()', ->

        it 'is a function', (done) ->  

            Phrase.create.should.be.an.instanceof Function
            done()

        it 'expects opts and linkFn', (done) -> 

            try Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
            
            catch error

                error.should.match /phrase.create\(opts,linkFn\) expects linkFn/
                done()

        it 'calls linkFn', (done) -> 

            Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                -> done()


        it 'passes notifier into linkFn', (done) -> 

            Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()

        it 'returns the root phrase recursor ', (done) -> 

            PhraseRecursor.create = -> -> done()

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()


        it 'passes opts into the root phrase recursor', (done) -> 

            PhraseRecursor.create = (root, opts) -> -> 

                opts.title.should.equal 'Phrase Title'
                opts.uuid.should.equal '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
                done()

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()


    context 'integrations', -> 

        it 'stacks up', (done) -> 

            PhraseRecursor.create = phraseRecursor_swap

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (notice) -> 

                    notice.use (msg, next) -> 

                        #console.log '\n\n\n', msg
                        next()


            root 'root phrase text', (outer) -> 

                outer 'one last nest', (nest) -> 

                    setTimeout (->

                        nest 'text', (end) -> 

                    ), 500

                # before all:  -> console.log before: 'all'
                # before each: -> console.log before: 'each'
                # after  each: -> console.log after:  'each'
                # after  all:  -> console.log after:  'all'

                outer 'outer nested phrase 1 text', (inner) -> 

                    inner 'inner nested phrase 1 text', (end) -> 

                        end.stack[0].text.should.equal 'root phrase text'
                        end.stack[1].text.should.equal 'outer nested phrase 1 text'
                        end.stack[2].text.should.equal 'inner nested phrase 1 text'
                        end.stack[2].token.name.should.equal 'inner'
                        should.not.exist end.stack[3]

                        end()


                    inner 'inner nested phrase 2 text', (deeper) -> 

                        setTimeout (->

                            deeper.stack[0].text.should.equal 'root phrase text'
                            deeper.stack[1].text.should.equal 'outer nested phrase 1 text'
                            deeper.stack[2].text.should.equal 'inner nested phrase 2 text'
                            should.not.exist deeper.stack[3]

                            deeper 'deep phrase', (end) -> end()
                        

                        ), 500


                outer 'outer nested phrase 2 text', (end) -> end()
                outer 'outer nested phrase 3 text', (end) -> 

                        end.stack[0].text.should.equal 'root phrase text'
                        end.stack[1].text.should.equal 'outer nested phrase 3 text'
                        should.not.exist end.stack[2]
                        end()

                outer 'outer nested phrase 4 text', (end) -> end()


                
    



