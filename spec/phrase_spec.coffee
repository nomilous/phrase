should = require 'should'
phrase = require '../lib/phrase'

describe 'phrase.createRoot(opts, linkFunction)', -> 

    context 'multiple trees', -> 

        before (done) -> 

            phraseOne = phrase.createRoot

                title: 'One'
                uuid:  '001'

                (@token1, notice) =>

                    @token1.on 'ready', ({tokens}) =>

                        @tokens1 = tokens

                    @token1.on 'error', (error) ->

                        console.log PHRASE_1_ERROR: error


            phraseTwo = phrase.createRoot

                title: 'Two'
                uuid:  '002'

                (@token2) =>

                    @token2.on 'ready', ({tokens}) =>

                        @tokens2 = tokens
                        done()

                    @token2.on 'error', (error) ->

                        console.log PHRASE_2_ERROR: error



            phraseOne '1 outer phrase', (nest) -> 

                nest '1 inner phrase', (end) ->



            phraseTwo '2 outer phrase', (nest) -> 

                nest '2 inner phrase', (end) ->

            
        it 'allows multiple phrase trees', (done) -> 

            should.exist @tokens1['/One/1 outer phrase/nest/1 inner phrase']
            should.exist @tokens2['/Two/2 outer phrase/nest/2 inner phrase']
            done()

