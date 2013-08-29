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

            Atokens = undefined

            @tokenA.on 'ready', ({tokens}) -> Atokens = tokens



                # console.log A: tokens
                #
                # '/A/outer A':                                       { name: ...
                # '/A/outer A/phraseA/nested 1 A':                    { name: ...
                # '/A/outer A/phraseA/nested 1 A/deeperA/deeper 1 A': { name: ...
                #

            @tokenB.on 'ready', ({tokens}) => 

                Btokens = tokens

                # console.log B: tokens
                #
                # '/B/outer B':                                       { name: ...
                # '/B/outer B/phraseB/nested 1 B leaf':               { name: ...
                # '/B/outer B/phraseB/nested 2 B':                    { name: ...
                # '/B/outer B/phraseB/nested 2 B/deeperB/deeper 1 B': { name: ...
                #

                require('when/sequence')([

                    => @tokenB.run Btokens['/B/outer B/phraseB/nested 1 B leaf']
                    => @tokenA.run Atokens['/A/outer A/phraseA/nested 1 A/deeperA/deeper 1 A']
                    => @tokenB.run Btokens['/B/outer B/phraseB/nested 2 B/deeperB/deeper 1 B']

                ]).then(

                    (results) -> 

                        #
                        # did straight forward hook registration work? 
                        #

                        # console.log results[0].job
                        results[0].job.should.eql 

                            RAN_before_all_nested_n_B: true
                            RAN_nested_n_B_leaf: true


                        #
                        # FAILS more complex hook registration
                        # -----
                        #
                        # * should have run all hooks
                        #

                        # console.log results[1].job
                        results[1].job.should.eql

                            ####RAN_before_all_nested_n_B: true
                            RAN_before_deeper_1_AB: true
                            RAN_deeperA: true


                        #
                        # FAILS
                        # -----
                        #
                        # console.log results[2].job
                        results[2].job.should.eql

                            RAN_before_all_nested_n_B: true
                            ####RAN_before_deeper_1_AB: true
                            RAN_deeperB: true


                        console.log 'TODO: fix limited hook functionality on multiwalk'
                        #
                        # * need a cleverer hook registration mechanism
                        # * currently they're popped of a shallow stack
                        #   by the next recursor
                        # * if A pops first then B gets none
                        #
                        # * first consider: how 'should' it behave 
                        #        (there's a catch 21.999999999993)
                        # 

                        done()


                    (error)  -> console.log ERROR: error
                    (notify) -> # NOISE!! console.log NOTIFY: notify

                )


            #
            # continue the walk into A
            #

            @phraseA 'nested 1 A', uuid: 0, (deeperA) =>

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

                @phraseB 'nested 1 B leaf', uuid: 1, (end) -> 

                    #console.log RUNNING: 'nested 1 B leaf'
                    @RAN_nested_n_B_leaf = true
                    end()

                @phraseB 'nested 2 B', uuid: 2, (deeperB) -> 

                    #
                    # * register before each on A and B vertices
                    # 

                    before each: (done) -> 

                        @RAN_before_deeper_1_AB = true
                        done()

                    deeperA 'deeper 1 A', uuid: 3, (end) -> 

                        @RAN_deeperA = true
                        end()

                    deeperB 'deeper 1 B', uuid: 4, (end) -> 

                        @RAN_deeperB = true
                        end()
