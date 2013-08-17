#!/usr/bin/env coffee

#
# Exploring some ideas here... despite the 'possible' dissarangement 
# of having an inprocess state machine managing incident lifecycle 
# without any 'sign' of a persistance layer.
#


Notice = require 'notice'
Noc    = require( '../lib/phrase_root' ).createRoot 
    
    title: 'Network Operations Center'
    uuid:  '63e2d6b0-f242-11e2-85ef-03366e5fcf9a'

    (tree, notice) -> 

        tree.on 'ready', -> 

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
                    address: '10.0.0.10'
                    transport: 'https'


                (error, alerts) -> 

                    #
                    # Connection to Alert Hub established
                    #

                    alerts.use (alert, next) -> 

                        #
                        # An alert has arrived, call the phrase branch
                        #

                        tree.run( uuid: alert.uuid ).then(

                            (resolve) ->
                            (error)   -> 
                            (notify)  ->

                        )

                        next()


#
# NOC Phrase Tree
# 

Noc 'Duties', (duty) -> 

    
    duty 'System Alerts (Front line)', (alert, KnowledgeBase) -> 

        #
        # KnowledgeBase is injected by the 'first walk' of
        # the Phrase Tree (at initialization)
        #

        KnowledgeBase.SystemAlerts.find().map (a) -> 

                            
                                    #
                                    # insert a branch for each known alert and 
                                    # associate with the alert's assigned uuid 
                                    #
                                    # 
                                    # 
                                    # 
            alert a.title, uuid: a.uuid, (step) -> 


                                                #
                                                # each step may have a breech time
                                                #
                                                # 
                                                #
                step 'acknowledge', timeout: a.SLA1, (acknowledge) -> 
  
                    acknowledge a.uuid, (end) -> 




                step 'escalate', timeout: a.SLA2, (escalate) -> 

                    escalate a.uuid, (end) -> 




                step.or 'resolve', timeout: a.SLA3, (resolve) -> 

                    resolve a.uuid, (end) -> 

