should      = require 'should'
PhraseRoot  = undefined
TreeWalker  = require '../../lib/recursor/tree_walker'
also        = require 'also'
Notice      = require 'notice'

describe 'phrase', -> 

    phraseRecursor_swap = undefined
    
    beforeEach -> 

        also.context = {}
        also.assembler = ->
        PhraseRoot  = require('../../lib/phrase/root').createClass also
        phraseRecursor_swap = TreeWalker.walk 

    afterEach -> 

        TreeWalker.walk = phraseRecursor_swap


    context 'createRoot()', ->

        it 'is a function', (done) ->  

            PhraseRoot.createRoot.should.be.an.instanceof Function
            done()

        it 'expects opts and linkFn', (done) -> 

            try PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf99'
            
            catch error

                error.should.match /phrase.createRoot\(opts,linkFn\) expects linkFn/
                done()


        it 'can be initialized with existing messenger', (done) -> 

            existing = Notice(

                capsule: phrase: {}

            ).create 'origin name'

            registrar = PhraseRoot.createRoot

                title:  'Zero'
                uuid:   '000'
                notice: existing

                (accessToken, messageBus) -> 

                    messageBus.should.equal existing
                    done()


            registrar 'phraseTitle', (nest) -> nest 'phraseTitle', (end) ->


        context 'phrase root registrar', -> 


            it 'calls linkFn only once', (done) -> 

                count = 0

                registrar = PhraseRoot.createRoot

                    title:  'Phrase Title'
                    uuid:   '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'
                    (token, notice) -> count++

                registrar 'phrase title', (end) -> 
                registrar( 'phrase title', (end) -> ).then ->

                    count.should.equal 1
                    done()


            it 'creates a TreeWalker with root context', (done) -> 


                TreeWalker.walk = (root, opts) -> 

                    should.exist root.context
                    done()


                registrar = PhraseRoot.createRoot

                    title:  'Phrase Title'
                    uuid:   '63e2d6b0-f242-11e2-85ef-03366e5fcf9b'
                    (token, notice) -> 

                registrar 'phrase title', (end) -> 




            it 'does not allow concurrent walks', (done) -> 
                
                registrar = PhraseRoot.createRoot

                    title:  'Concurrent Test'
                    uuid:   '00000000-f242-11e2-85ef-03366e5fcf9c'
                    (token, notice) =>

                registrar 'phrase title', (nested) =>  

                    try registrar 'phrase title', (nested) ->  
                    catch error

                        error.should.match /Phrase root registrar cannot perform concurrent walks/
                        done()



        xit 'passes rootToken into linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9d'

                (token, notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()


        xit 'passes notifier into linkFn', (done) -> 

            PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9e'

                (token, notice) -> 

                    notice.use.should.be.an.instanceof Function
                    done()


        xit 'passes opts into the root phrase recursor', (done) -> 

            TreeWalker.walk = (root, opts) -> -> 

                opts.title.should.equal 'Phrase Title'
                opts.uuid.should.equal '63e2d6b0-f242-11e2-85ef-03366e5fcf9f'
                done()

            root = PhraseRoot.createRoot 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()
