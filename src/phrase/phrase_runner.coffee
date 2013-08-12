{defer}      = require 'when'
pipeline     = require 'when/pipeline'

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


        pipeline([

            (     ) -> api.getSteps root, opts, running
            (steps) -> 

                #
                # TODO: - keep track of running jobs
                #       - configable maximum allowed
                #       - configable one at a timeness
                #       - message bus chatter for use
                #         on a webui dashboard
                #       - stop making lists...
                #       - [rubina](http://www.youtube.com/watch?v=a5xzSjgatP8)
                #

                job = new context.PhraseJob

                    steps: steps
                    deferral: running

                job.run()

        ]).then( 

            (result) -> running.resolve result
            (error)  -> running.reject error
            (update) -> running.notify update

        )
        
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

        start = recurse = -> 

            #
            # walk to and fro from root to each target leaf accumulating
            # calls into the step array
            #

            remaining = leaves.length

            if remaining == 0 

                steps = steps.filter (s) -> s?

                running.notify

                    state:  'scan::complete'
                    at:     Date.now()
                    steps:  steps.length
                    leaves: count

                return getting.resolve steps


            leaf     = leaves.shift()
            path     = graph.tree.leaves[leaf.uuid].path
            outbound = []
            inbound  = path.map (uuid) -> 

                outbound.unshift graph.vertices[uuid]
                graph.vertices[uuid]

            #
            # inbound  (Array) Contains all the phrases along the path 
            #                  from root to this leaf. 
            # 
            #                  For queueing all before hooks.
            # 

            inbound.map (phrase) -> 

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

            steps.push type: 'leaf', ref: leaf


            # 
            # outbound (Array) Contains all the phrases along the path
            #                  back to the root.
            # 
            #                  For queueing all the after hooks.
            #

            outbound.map (phrase) -> 

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

            recurse()

        running.notify 

            state: 'scan::starting'
            at:    Date.now()

        start()
        
        return getting.promise
        


module.exports = api
