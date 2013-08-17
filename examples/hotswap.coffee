#!/usr/bin/env coffee

coffee  = require 'coffee-script'
hotswap = require( '../lib/phrase_root' ).createRoot

    title: 'Hotswap'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (token, notice) -> 

        token.on 'ready', -> 

            token.run uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'


            vertices = token.graph.vertices
            setTimeout (->


                console.log """

                #
                # fake an upgrade deployment
                # 

                """

                #
                # modify beforeEach hook to migrate context data from version 1 to version 2
                # 

                vertices['63e2d6b0-f242-11e2-85ef-03366e5fcf9a'].hooks.beforeEach.fn = eval coffee.compile """ 

                    -> 

                        @choices = ['rock', 'paper', 'scissors']
                        @version  = 2 
                        @interval = 490


                """, bare: true
                token.run uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

            ), 1000



before 

    each: -> 
    
        @version  = 1
        @interval = 1500

        #
        # version 1 was discovered to be leaning little in paper's favour
        #

        @choices = ['rock', 'paper']


hotswap 'the process containing this phrase', (can) -> 

    can 'remain', (running) -> 

        after each: -> 

            clearInterval @repeat

        running 'while portions are updgraged', (done) -> 

            console.log "Player: #{@uuid}    (version #{@version})"

            @repeat = setInterval ( =>

                console.log "deciding...   (version #{@version})"

            ), 100

            setTimeout done, @interval

        running 'a second step', (end) -> 

            console.log "Player: #{@uuid} Choice: #{ @choices[  Math.floor Math.random() * @choices.length  ] }  \t(version #{@version})"
                
            end()
