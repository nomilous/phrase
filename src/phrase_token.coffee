#
# phrase token
# ============
# 
# A container / controller (resident in each phrase node) 
# to manage it's edges.  
# 

{EventEmitter} = require 'events' 
PhraseRunner   = require './phrase/phrase_runner'

exports.create = (root) -> 

    {context} = root
    {graph}   = context
    emitter   = new EventEmitter

    #
    # TEMPORARY: direct access to graph
    #

    emitter.graph = graph

    emitter.run = (opts = {}) -> 

        #
        # TODO: (later) opts.uuid becomes optional, this (token)
        #               is assigned to a phrase, run that one.
        #

        PhraseRunner.run root, opts

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
