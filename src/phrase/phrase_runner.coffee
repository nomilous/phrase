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

            remaining = leaves.length
            state     = if remaining == 0 then 'done' else 'started'

            running.notify 
                timestamp:  Date.now()
                state:      state
                total:      count
                remaining:  remaining

            leaf = leaves.shift()




            return recurse() unless remaining == 0
            process.nextTick -> running.resolve results

        recurse()

    running.promise
