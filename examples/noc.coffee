#!/usr/bin/env coffee

#
# Exploring some ideas here... despite the 'possible' dissarangement 
# of having an inprocess state machine managing incident lifecycle 
# without any 'sign' of a persis†ance layer.
#


Notice = require 'notice'
Noc    = require( '../lib/phrase_root' ).createRoot 
    
    title: 'Network Operations Center'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (token, notice) -> 

        token.on 'ready', -> 

            #
            # NOC Phrase Tree is initialized
            #

            Notice.connect 'Network Operations Center', 

                #
                # Attach to the network alerts notification hub
                #

                connect:

                    secret:      '◊'
                    port:       10101
                    address:    alerts.aggregator.local
                    transport: 'https'


                (error, alerts) -> 

                    #
                    # Connection to Alert Hub established
                    #

                    alerts.use (alert, next) -> 

                        #
                        # An alert has arrived, call the phrase branch
                        #

                        token.run( uuid: alert.uuid, data: alert  ).then(
                                     #                  #
                                     #                  #
                                     #                  #
                                     # 
                                     # finds and runs the branch on the tree 
                                     # that was created with this uuid 
                                     #
                                                        #
                                                        # assigns @data for use in the
                                                        # resulting PhraseJob instance
                                                        # 
                                                        # TODO: This very useful feature
                                                        # 
                            (resolve) ->   
                            (error)   ->   
                            (notify)  ->   


                                if notify.state 'alert::escalate' 

                                    #
                                    # escalate
                                    #

                           

                        )

                        next()


#
# NOC Phrase Tree
# 

Noc 'Duties', (duty) -> 
                                            #
                                            # TODO: these injections
                                            #
                                            #
    
    duty 'Handle System Alerts', (alert, KnowledgeBase, TeamHubs, Escalate) -> 

        #
        # KnowledgeBase and TeamHub are local libs injected by the 'first walk' of
        # the Phrase Tree (at initialization)
        #

        KnowledgeBase.SystemAlerts.find().map (a) -> 

                                    # 
                                    #
                                    # insert a branch for each known alert and 
                                    # associate with the alert's assigned uuid 
                                    # 
                                    #  `token.run( uuid: alert.uuid ).then...`
                                    #        
                                    #        from above, at alert time,     
            before all: ->          #        finds and runs this 
                                    #        phrase branch
                                    # 
                #
                # create array storage to log the notification 
                # chatter generated throughout the handling 
                # of this alert process
                #
                # @variables are stored on the PhraseJob instance
                # that is created at token.run(...)
                # 
                                    # 
                @log = []           # 
                                    #
                                    #
            alert a.title, uuid: a.uuid, (step) -> 


                                                #
                                                # each step may have a breech time
                                                # defined in the knowledge base
                                                # 
                                                # 
                                                #
                step 'acknowledge', timeout: a.SLA1, (acknowledge) -> 
  
                    acknowledge a.uuid, (done) -> 

                        TeamHubs.Noc.event( 'new alert', 

                            #
                            # send the alert to the noc 
                            # -------------------------
                            # 
                            # alert - contains the alert definition per the knowledge base, 
                            #         hopefully with some guidance / memory jog notes.
                            # 
                            # data  - contains the 'instance of' the alert, ie. related data
                            #         that arrived when the alert was received from the 
                            #         alert.aggregator hub

                            alert: a 
                            data:  @data

                        ).then (acknowledgement) =>  

                            #
                            # received acknowledgement from someone on the noc team web
                            # app / mobile client,
                            # 
                            # assign respondent messenger onto `this` (PhraseJob instance)
                            # ---------------------------
                            #

                            @assigned = acknowledgement.source

                            #
                            # and proceed to next step.
                            #

                            done()


                step 'resolve', timeout: a.SLA3, (resolve) -> 

                    resolve a.uuid, (done) -> 

                        @assigned.use (msg, next) => 

                            #
                            # log all notification / status updates from 
                            # the respondent onto `this` (PhraseJob instance)
                            #

                            @log.push msg.content  # probably needs a deep copy!


                            #
                            # monitor for specific events
                            #

                            switch msg.context.title

                                when 'alert::resolved' 

                                    done()

                                when 'alert::escalate'

                                    #
                                    # initialize a new Escalation 
                                    # from `this` (PhraseJob instance)
                                    #

                                    done new Escalation @


    duty 'Assist Support Desk' # ...

    duty '...'


# 
# † persistance could be an integrated plugin, it would need to 
#   re-initialize all state after service hups / crashes
# 