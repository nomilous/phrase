should = require 'should'
phrase = require '../lib/phrase'

describe 'phrase.createRoot(opts, linkFunction)', -> 

    context 'multiple trees', -> 

        it 'allows multiple phrase trees', (done) -> 

            phraseOne = phrase.createRoot

                title: 'One'
                uuid:  '001'

                (@token1) =>

                    @token1.on 'ready', (data) ->

                        console.log PHRASE_1: data


            phraseTwo = phrase.createRoot

                title: 'Two'
                uuid:  '002'

                (@token2) =>

                    @token2.on 'ready', (data) ->

                        console.log PHRASE_1: data
                        done()


            phraseOne 'outer phrase', (nest) -> nest 'inner phrase', (end) ->

            phraseTwo 'outer phrase', (nest) -> nest 'inner phrase', (end) ->

            