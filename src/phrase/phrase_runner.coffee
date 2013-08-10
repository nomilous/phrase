{defer, map} = require 'when'
sequence     = require 'when/sequence'

error = (code, message) -> Object.defineProperty (new Error message), 'code', value: code

exports.run = (root, opts) -> 

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


        leaves  = graph.leavesOf uuid
        count   = leaves.length
        results = []
        recurse = -> 

            #
            # recurse through the list of phrase leaves that
            # require processing
            #

            remaining = leaves.length
            state     = if remaining == 0 then 'done' else 'running'

            running.notify 
                timestamp:  Date.now()
                state:      state
                total:      count
                remaining:  remaining

            if remaining == 0 then return process.nextTick -> running.resolve results

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
                #                  For running all before hooks.
                # 

                -> map inbound, (phrase) -> 


                    # if remaining == count
                    #     #
                    #     # only run before alls on the first inbound pass
                    #     #
                    #     #
                    #     # TODO: BUGFIX: inverse of the problem outlined below
                    #     # 
                    #     console.log beforeAll: phrase.hooks.beforeAll


                    console.log beforeEach: phrase.hooks.beforeEach


                #
                # run the leaf function
                #

                -> console.log RUN_LEAF: leaf.text


                # 
                # outbound (Array) Contains all the phrases along the path
                #                  from leaf to root
                # 
                #                  For running all the after hooks.
                #

                -> map outbound, (phrase) -> 

                    console.log afterEach: phrase.hooks.afterEach


                    # if leaves.length == 0
                    #     #
                    #     # only run after alls on the final outbound
                    #     # (last leaf)
                    #     #
                    #     # TODO: BUGFIX: this mechanism won't run after alls
                    #     #               from deeper that the last target leaf
                    #     #
                    #     #               a problem if one of the earlier leaves
                    #     #               was much deeper in the tree
                    #     # 
                    #     console.log afterAll: phrase.hooks.afterAll


            ]).then recurse


        recurse()

    running.promise
