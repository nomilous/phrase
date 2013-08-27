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


    context 'interspercement', -> 

        before (done) -> 

            #
            # attach phraseRegistrars and tokens 
            # for two separate trees onto 'this'
            #

            phrase.createRoot( 
                title: 'A', uuid: 'aaa', (@tokenA) => 
            ) 'outer A', (@phraseA) =>

            phrase.createRoot( 
                title: 'B', uuid: 'bbb', (@tokenB) => 
            ) 'outer B', (@phraseB) => done()


        it 'hook registrations survive intersperced walk', (done) -> 

            #
            # await tokens from both A and B
            #

            @tokenA.on 'ready', ({tokens}) -> 

                # console.log A: tokens
                #
                # '/A/outer A':                                       { name: ...
                # '/A/outer A/phraseA/nested 1 A':                    { name: ...
                # '/A/outer A/phraseA/nested 1 A/deeperA/deeper 1 A': { name: ...
                #

            @tokenB.on 'ready', ({tokens}) => 

                # console.log B: tokens
                #
                # '/B/outer B':                                       { name: ...
                # '/B/outer B/phraseB/nested 1 B leaf':               { name: ...
                # '/B/outer B/phraseB/nested 2 B':                    { name: ...
                # '/B/outer B/phraseB/nested 2 B/deeperB/deeper 1 B': { name: ...
                #

                require('when/sequence')([

                    => @tokenB.run tokens['/B/outer B/phraseB/nested 1 B leaf']

                ]).then(

                    (results) -> 

                        #
                        # did straight forward hook registration work? 
                        #

                        results[0].job.should.eql 

                            RAN_before_all_nested_n_B: true
                            RAN_nested_n_B_leaf: true


                        done()


                    (error)  -> console.log ERROR: error
                    (notify) -> # NOISE!! console.log NOTIFY: notify

                )


            #
            # continue the walk into A
            #

            @phraseA 'nested 1 A', (deeperA) =>

                #
                # continue the walk into B
                # ------------------------
                # 
                # * inside A
                # * with a before all hook
                #

                before all: (done) -> 

                    #console.log RUNNING: 'before_nested_1_B'
                    @RAN_before_all_nested_n_B = true
                    done()

                @phraseB 'nested 1 B leaf', (end) -> 

                    #console.log RUNNING: 'nested 1 B leaf'
                    @RAN_nested_n_B_leaf = true
                    end()

                @phraseB 'nested 2 B', (deeperB) -> 

                    #
                    # * register before each on A and B vertices
                    # 

                    before each: (done) -> 

                        @before_deeper_1_AB = true

                    deeperA 'deeper 1 A', (end) ->
                    deeperB 'deeper 1 B', (end) ->
















