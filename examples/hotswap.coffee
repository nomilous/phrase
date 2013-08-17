#!/usr/bin/env coffee

coffee  = require 'coffee-script'
hotswap = require( '../lib/phrase_root' ).createRoot

    title: 'Hotswap'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (token, notice) -> 

        token.on 'ready', -> 

            #
            # start first player on version 1
            #

            token.run uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

            #
            # perform upgrade after 1 second
            #

            vertices = token.graph.vertices
            setTimeout (->


                console.log """

                #
                # fake an upgrade deployment
                # 

                """

                #
                # modify beforeEach of can/remain/running to migrate context data from version 1 to version 2
                # 

                for uuid of vertices

                    continue unless vertices[uuid].text == 'remain'

                    vertices[uuid].hooks.beforeEach.fn = eval coffee.compile """ 

                    -> 

                        @choices = ['rock', 'paper', 'scissors']
                        @version  = 2 
                        @interval = 490


                """, bare: true

                #
                # start second player on version 2
                #

                token.run uuid: '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

            ), 1000


        notice.use (msg, next) -> 

            if msg.context.title == 'choice'

                console.log "Choice: #{ msg.choice }    \tPlayer: #{msg.player} (version: #{msg.version})"

            next()


hotswap 'the process containing this phrase', (can) -> 

    before 

        each: -> 
        
            @version  = 1
            @interval = 1500

            #
            # version 1 was discovered to be leaning a little in paper's favour
            #

            @choices = ['rock', 'paper']


    can 'remain', (running) -> 

        after each: -> 

            clearInterval @repeat

        running 'while portions are updgraged', (done) -> 

            console.log "Player: #{@uuid}    (version #{@version})"

            @repeat = setInterval ( =>

                console.log "deciding...   (version #{@version})"

            ), 100

            setTimeout done, @interval

        running 'a second step', (done) -> 

            @notice.event( 'choice', 

                player:  @uuid
                choice:  @choices[  Math.floor Math.random() * @choices.length  ]
                version: @version

            ).then done
