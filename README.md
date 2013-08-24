### Version 0.0.3 (prerelease, unstable)

`npm install phrase`

phrase
======

What is it?
-----------

* A describer.
* A repeatable context assembler.
* ...
* A metadata enriched scope heap.
* **An Open Closure**.


Usage
-----

`rootRegistrar = require('phrase').createRoot( opts, linkFunction )`

```coffee

#
# fantasy example
# ---------------
#

neuron = require( 'phrase' ).createRoot

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

                "inputs ready (structure: count=#{ 

                    (path for path of data.tokens).length 

                })"

            # 
            # console.log data
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
            # TODO: Create output synapses.
            #  
            #       by ???
            #

            #
            # TODO: Join neural network.
            #  
            #       by attaching inputs (tokens) to other 
            #       neurons just like this one
            #


neuron 'soma', (dendrite) -> 

    before 

        all:  -> @accumulated    = 0
        each: -> @synapticWeight = Math.random()
        

    dendrite 'synapses', (input) -> 

        for i in [1..100] 

            input '' + i, (synapse) -> 

                #
                # TODO: transform function
                #


#
# TODO: A better example. 
# 
#       Possibly creating neural networks is entrely beside the point. 
#       At this time.
# 

    
```

* [closer the purpose of 'phrase'](./spec/intergations_spec.coffee)

