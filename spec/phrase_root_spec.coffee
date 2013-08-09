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


        it 'returns the root phrase recursor ', (done) -> 

            PhraseRecursor.create = -> -> done()

            root = PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
                -> 

            root()


        it 'calls linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                -> done()


        it 'passes rootToken into linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (token, notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()


        it 'passes notifier into linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (token, notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()


        it 'passes opts into the root phrase recursor', (done) -> 

            PhraseRecursor.create = (root, opts) -> -> 

                opts.title.should.equal 'Phrase Title'
                opts.uuid.should.equal '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
                done()

            root = PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()
