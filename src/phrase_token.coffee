#
# phrase token
# ============
# 
# A container / controller (resident in each phrase node) 
# to manage it's edges.  
# 

{defer} = require 'when' 

exports.create = (root) -> 

    {context, inject} = root
    {graph}           = context

    #
    # TEMPORARY: direct access to graph
    #

    api = 

        graph: graph

        run: (opts = {}) -> 

            running = defer()
            process.nextTick -> 

                unless opts.uuid? 

                    error = new Error "missing opts.uuid"
                    error.code = 1
                    return running.reject error

                unless graph.vertices[opts.uuid]?

                    error = new Error "uuid: #{opts.uuid} not in local tree"
                    error.code = 2
                    return running.reject error

                running.resolve []

            running.promise


    return api
