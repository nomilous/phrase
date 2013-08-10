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
    {graph}   = context

    #
    # TEMPORARY: direct access to graph
    #

    graph: graph

    run: (opts) -> 

        running = defer()
        process.nextTick -> running.resolve []
        running.promise

