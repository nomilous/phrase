{defer} = require 'when' 

exports.run = (root, opts) -> 

    {context} = root
    {graph}   = context
    {uuid}    = opts
    
    running = defer()
    process.nextTick -> 

        unless uuid? 

            error = new Error "missing opts.uuid"
            error.code = 1
            return running.reject error

        unless graph.vertices[uuid]?

            error = new Error "uuid: '#{uuid}' not in local tree"
            error.code = 2
            return running.reject error

        running.resolve []

    running.promise
