#!/usr/bin/env coffee

#
# Exploring some ideas here... despite the 'possible' dissarangement 
# of having an inprocess state machine managing incident lifecycle.
#


Notice = require 'notice'
Noc    = require( '../lib/phrase' ).createRoot 
    
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

                    alerts.use (next, capsule, context) -> 

                        #
                        # An alert has arrived, call the phrase branch
                        #

                        token.run

                            uuid: alert.uuid  # ##1 requires all possible alerts predefined in the KnowledgeBase
                            capsule: capsule
                            context: context

                        next()


#
# NOC Phrase Tree
# 

Noc 'Duties', (duty) -> 
                                            #
                                            # TODO: these injections
                                            #
                                            #
    
    duty 'Handle System Alerts', (handle, KnowledgeBase) -> 

        #
        # KnowledgeBase is a local lib injected by the 'first walk' of
        # the Phrase Tree
        #

        KnowledgeBase.SystemAlerts.find().map (alert) -> 

                                    # 
                                    # ##1 
                                    # 
                                    # insert a branch onto the phrase tree for
                                    # each known alert and associate with the 
                                    # alert's assigned uuid 
                                    # 
                                    #  `token.run( uuid: alert.uuid ).then...`
                                    #        
                                    #        from above, at alert time,     
                                    #        finds and runs this 
                                    #        phrase branch
                                    # 
            
            handle alert.title, uuid: alert.uuid, (step) -> 
                    #
                    # not unique... MAKE PLAN
                    # 


                step 'classify',   (done) -> done()
                step 'prioritize', (done, DependancyMatrix, KnowledgeBase) -> 

                    KnowledgeBase.ActiveAlerts.query( 

                        DependancyMatrix.generateQuery @uuid, @capsule, @context

                    ), (err, rootCauses) => 






                                                #
                                                # each step may have a breech time
                                                # defined in the knowledge base
                                                # 
                                                # 
                                                #
                step 'acknowledge', timeout: alert.SLA1, (acknowledge) -> 
  
                    acknowledge alert.uuid, (done) -> 

                        TeamHubs.Noc.event( 'new alert', 

                            #
                            # send the alert to the noc 
                            # -------------------------
                            # 
                            # meta  - contains the 'definition of' the alert per the knowledge base, 
                            #         hopefully with some guidance / memory jog notes.
                            # 
                            # data  - contains the 'instance of' the alert, ie. related data
                            #         that arrived when the alert was received from the 
                            #         alert.aggregator hub

                            meta:  alert
                            data:  @data

                        ).then (acknowledgement) =>  

                            #
                            # received acknowledgement from someone on the noc team web
                            # app / mobile client,
                            # 
                            # assign respondent messenger onto `this` (Job instance)
                            # ---------------------------
                            #

                            @assigned = acknowledgement.source

                            #
                            # and proceed to next step.
                            #

                            done()


                step 'resolve', timeout: alert.SLA3, (resolve) -> 

                    resolve alert.uuid, (done) -> 

                        @assigned.use 

                            title: 'alert resolver'

                            (next, capsule) => 

                                #
                                # log all notification / status updates from 
                                # the respondent onto `this` (Job instance)
                                #

                                @log.push msg.content  # probably needs a deep copy!


                                #
                                # monitor for specific events
                                #

                                switch capsule.event

                                    when 'alert::resolved' 

                                        done()

                                    when 'alert::escalate'

                                        #
                                        # initialize a new Escalation 
                                        # from `this` (Job instance)
                                        #

                                        done()
                                        #done new Escalation @


    duty 'Assist Support Desk' # ...

    duty '...'


# 
# † persistance could be an integrated plugin, it would need to 
#   re-initialize all state after service hups / crashes
# 