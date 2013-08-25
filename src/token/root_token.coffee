#
# root token
# ===========
# 
# 

{EventEmitter} = require 'events' 
Run            = require '../runner/run'

exports.create = (root) -> 

    {context}       = root
    {graph, notice} = context
    emitter         = new EventEmitter




    #
    # TEMPORARY: direct access to graph
    # =========
    #
    Object.defineProperty emitter, 'graph', 

        enumerable: false
        get: -> context.graph
    






    emitter.run = (args...) -> 

        #
        # TODO: (later) opts.uuid becomes optional, this (token)
        #               is assigned to a phrase, run that one.
        # 
        #                         # - talking about phrase token
        #                         # - does not fromally exist yet
        #                         # - psuedo token is attached to each phrase
        #                         # - they passed on the 'ready' event to link
        #

        [token, params] = args

        Run.start root, token, params

    notice.use (msg, next) -> 

        if msg.context.title == 'phrase::recurse:end'

            if msg.walk.first then emitter.emit 'ready', 

                walk:   msg.walk
                tokens: msg.tokens

            else 

                console.log 'TODO: changed payload'
                emitter.emit 'changed'




        next()


    return emitter
