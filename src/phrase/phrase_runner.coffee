{defer} = require 'when' 

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
            # phrases (Array) now contains the all phrases 
            # from root to this leaf 
            #

            console.log leaf.text, phrase_depth: phrases.length



            recurse()
            

        recurse()

    running.promise
