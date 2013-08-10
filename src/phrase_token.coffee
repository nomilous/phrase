#
# phrase token
# ============
# 
# A container / controller (resident in each phrase node) 
# to manage it's edges.  
# 

{EventEmitter} = require 'events' 
{defer}        = require 'when' 

exports.create = (root) -> 

    {context, inject} = root
    {graph}           = context
    emitter           = new EventEmitter

    #
    # TEMPORARY: direct access to graph
    #

    emitter.graph = graph

    emitter.run = (opts = {}) -> 

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


    Object.defineProperty emitter, 'eventProxy', 

        enumerable: false

        #
        # TODO: (later) All phrase nodes will be assigned a token...
        # 
        #               This hidden property is a workaround to 
        #               dodge the problem of the rootToken being 
        #               initialized before the message bus, having
        #               an instance of this middleware registered 
        #               for every phrase in the tree may introduce 
        #               a workload issue on the bus.
        #

        
        get: -> (msg, next) -> 

            emitter.emit 'ready' if msg.context.title == 'phrase::recurse:end'
            next()


    return emitter
