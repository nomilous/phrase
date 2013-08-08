should         = require 'should'
Phrase         = require '../lib/phrase_root'
PhraseRecursor = require '../lib/phrase/recursor'
{EventEmitter} = require 'events'

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


        it 'passes an event emitter into linkFn', (done) -> 

            Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

                    emitter.should.be.an.instanceof EventEmitter
                    done()

        it 'returns the root phrase recursor ', (done) -> 

            PhraseRecursor.create = -> -> done()

            root = Phrase.create 

                title: 'Phrase Title'
                uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                (emitter) -> 

            root()


    context 'integrations', -> 

        it 'stacks up', (done) -> 

            root = Phrase.create 

                    title: 'Phrase Title'
                    uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

                    (emitter) -> 

                        emitter.on 'phrase::start', (payload...) -> 
                            console.log PHRASE_START: payload




            root 'root phrase text', (outer) -> 

                before all:  -> console.log before: 'all'
                before each: -> console.log before: 'each'
                after  each: -> console.log after:  'each'
                after  all:  -> console.log after:  'all'

                outer 'to squiz at queued peers', key: 'VALUE', (recursor) -> 

                    #console.log recursor.stack[1].queue

                    #
                    # 4 further calls to outer() remain to follow this
                    #

                    recursor.stack[1].queue.remaining.should.equal 4
                    done()


                outer 'outer nested phrase 1 text', (inner) -> 

                    inner 'inner nested phrase 1 text', (end) -> 

                        end.stack[0].text.should.equal 'root phrase text'
                        end.stack[1].text.should.equal 'outer nested phrase 1 text'
                        end.stack[2].text.should.equal 'inner nested phrase 1 text'
                        should.not.exist end.stack[3]

                    inner 'inner nested phrase 2 text', (end) -> 

                        end.stack[0].text.should.equal 'root phrase text'
                        end.stack[1].text.should.equal 'outer nested phrase 1 text'
                        end.stack[2].text.should.equal 'inner nested phrase 2 text'
                        should.not.exist end.stack[3]
                        end()

                outer 'outer nested phrase 2 text', (end) -> end()
                outer 'outer nested phrase 3 text', (end) -> 

                        end.stack[0].text.should.equal 'root phrase text'
                        end.stack[1].text.should.equal 'outer nested phrase 3 text'
                        should.not.exist end.stack[2]
                        end()

                outer( 'outer nested phrase 4 text', (end) -> end()

                ).then -> 

                    done() 
                    console.log outer.stack
    



