{defer, map} = require 'when' 

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

            leaf    = leaves.shift()
            path    = graph.tree.leaves[leaf.uuid].path
            phrases = path.map (uuid) -> graph.vertices[uuid]

            #
            # phrases (Array) now contains all the phrases along the 
            # path from root to this leaf
            #

            map( phrases, (phrase) -> 
  
                console.log beforeAll: phrase.hooks.beforeAll
                console.log beforeEach: phrase.hooks.beforeEach 
                console.log FN: phrase.fn
                console.log afterEach: phrase.hooks.afterEach
                console.log afterAll: phrase.hooks.afterAll

                #
                # um... tricky! 
                # 
                # thinks about using the 'first walk' recursor
                # in non-'first walk' mode
                #

            ).then recurse

            

        recurse()

    running.promise
