{defer, map} = require 'when'
sequence     = require 'when/sequence'

error = (code, message) -> Object.defineProperty (new Error message), 'code', value: code

api = 
    
    run: (root, opts) -> 

        {context} = root
        {graph}   = context
        {uuid}    = opts

        #
        # defer and promise the running phrase node
        #

        running = defer()
        process.nextTick -> 

            unless uuid? 
                return running.reject error 1, "missing opts.uuid"

            unless graph.vertices[uuid]?
                return running.reject error 2, "uuid: '#{uuid}' not in local tree"


        api.getSteps( root, opts, running ).then (steps) -> 

            #
            # got steps
            #
            

        
        return running.promise


    getSteps: (root, opts, running) ->

        {context} = root
        {graph}   = context
        {uuid}    = opts

        getting   = defer() 
        leaves    = graph.leavesOf uuid
        count     = leaves.length

        #
        # steps   - Is populated with the sequence of calls to make such that
        #           each leaf selected for running is processed, and all hooks
        #           are run appropriately before and after.
        # 
        # befores - Maintains beforeAll precedence during step accumulation by
        #           only recording each beforeAll hook as a step once, at the
        #           first encountered instance.
        # 
        # afters  - Maintains afterAll precedence during step accumulation by
        #           including every afterAll hook as a step and removing all
        #           previous instances of that hook to ensure that only the
        #           last encountered instance of each remains in the final  
        #           step sequence.
        #

        steps     = []
        befores   = {}
        afters    = {}

        recurse = -> 

            #
            # walk to and fro from root to each target leaf accumulating
            # calls into the step array
            #

            remaining = leaves.length

            return getting.resolve (steps.filter (s) -> s?) if remaining == 0 

                # #
                # # TEMPORARY - verify steps
                # #
                # steps.map (step) -> 
                #     if step.type == 'hook' 
                #         console.log HOOK: step.ref.fn.toString()
                #     else if step.type == 'leaf'
                #         console.log LEAF: step.ref.text, step.ref.fn.toString()
                # return


            leaf     = leaves.shift()
            path     = graph.tree.leaves[leaf.uuid].path
            outbound = []
            inbound  = path.map (uuid) -> 

                outbound.unshift graph.vertices[uuid]
                graph.vertices[uuid]

            sequence([

                #
                # inbound  (Array) Contains all the phrases along the path 
                #                  from root to this leaf. 
                # 
                #                  For queueing all before hooks.
                # 

                -> map inbound, (phrase) -> 

                    {beforeAll, beforeEach} = phrase.hooks

                    #
                    # queue only the first of each beforeAll
                    #
                   
                    if beforeAll? and not befores[beforeAll.uuid]?
                        position = steps.push( type: 'hook', ref: beforeAll ) - 1
                        befores[beforeAll.uuid] = position

                    #
                    # queue all beforeEachs
                    #

                    if beforeEach?
                        steps.push type: 'hook', ref: beforeEach
                        

                #
                # queue the leaf function
                #

                -> steps.push type: 'leaf', ref: leaf


                # 
                # outbound (Array) Contains all the phrases along the path
                #                  back to the root.
                # 
                #                  For queueing all the after hooks.
                #

                -> map outbound, (phrase) -> 

                    {afterEach, afterAll} = phrase.hooks

                    if afterEach?

                        steps.push type: 'hook', ref: afterEach

                    if afterAll?

                        #
                        # queue all afterAlls...
                        #

                        position = steps.push( type: 'hook', ref: afterAll ) - 1
                        if afters[ afterAll.uuid ]?

                            #
                            # but delete the previously queued instance 
                            # of each afterAll
                            #

                            oldPosition = afters[ afterAll.uuid ]
                            delete steps[ oldPosition ]
                            
                        afters[ afterAll.uuid ] = position


            ]).then recurse

        recurse()
        
        return getting.promise
        


module.exports = api
