#!/usr/bin/env coffee

neuron = require( '../lib/phrase' ).createRoot

    #
    # opts.
    #
    
    title:       'Neuron'
    uuid:        '00000000-0700-0000-0000-fffffffffff0'
    leaf:        ['synapse']
    

    #
    # linkFunction.
    #

    (token) -> 

        token.on 'ready', (data) -> 

            console.log 'INIT (1 OF 3) -', 

                "synaptic inputs ready (structure: count=#{ 

                    ((path for path of data.tokens).filter (path) -> path.match /\d$/ ).length 

                })"

            # 
            console.log data
            # 
            # { walk: { startedAt: 1377384696287, first: true, duration: 118 },
            # tokens: 
            #  { '/Neuron/soma': { name: [Getter], uuid: [Getter] },
            #    '/Neuron/soma/dendrite/synapses': { name: [Getter], uuid: [Getter] },
            #    '/Neuron/soma/dendrite/synapses/input/1': { name: [Getter], uuid: [Getter] },
            #    '/Neuron/soma/dendrite/synapses/input/2': { name: [Getter], uuid: [Getter] },
            #    '/Neuron/soma/dendrite/synapses/input/3': { name: [Getter], uuid: [Getter] },
            #    '/Neuron/soma/dendrite/synapses/input/4': { name: [Getter], uuid: [Getter] },
            # 
            #  ...
            # 

            #
            # TODO: Output Synapses
            #  
            #       by ???
            #
            #
            # TODO: Join neural network 
            #  
            #       by attaching the synaptic inputs (tokens) to
            #          synaptic outputs from other neurons 
            #          just like this one
            # 
            #          and presenting this neurons outputs for 
            #          attachment at inputs to other neurons
            #
            # 
            # TODO: Learn
            # 
            #       by ??? (adjusting the synaptic weight)
            # 


neuron 'soma', (dendrite) -> 

    before 

        all:  -> @accumulated    = 0
        each: -> @synapticWeight = Math.random()
        

    dendrite 'synapses', (input) -> 

        #
        # initialize a random number (<100) of input synapses
        #

        for i in [1..(Math.floor Math.random() * 100)] 

            do (i) -> 

                receptorName = "#{  i  }"

                input receptorName, (synapse) -> 

                    #
                    # from this point onward: things become largely theoretical...
                    #

                    @notice.event( 'free::dentrite', 

                        #
                        # inform the controller
                        #

                        Wanted:   'axon synapse for coupling'
                        Likes:    'long walks on the beach'
                        Dislikes: 'electro-shock therapy'


                    ).then (pending) -> 

                        pending.on 'free::axon', (address) -> 

                            #
                            # controller has located ideal free::axon
                            #

                            require('notice').connect receptorName, 

                                connect: address
                                
                                (error, socket) -> 

                                    socket.use (msg, next) -> 

                                        #
                                        # a new payload has crossed the synaptic cleft
                                        #

                                        next()



#
# TODO: A better example. 
# 
#       Possibly creating neural networks is entrely beside the point. 
#       At this time.
# 