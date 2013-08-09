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

                        console.log '\n', msg.context.title, '\n', msg

                        try

                            console.log msg.stack[1].hooks
                            msg.stack[1].hooks.afterAll.fn  -> 'PRETEND RESOLVER FN'

                        console.log '\n'
                        next()

            root 'root phrase 1', (end) ->       
            root 'root phrase 2', (outer) -> 

                before all:  -> 
                before each: -> 
                after  each: -> 
                after  all:  (arg) -> 

                    arg().should.equal 'PRETEND RESOLVER FN'
                    done()

                outer 'outer phrase', (inner) -> 
                    inner 'inner phrase', (end) -> 



                

            