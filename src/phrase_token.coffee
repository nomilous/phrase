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

        [token] = args

        PhraseRunner.run root, token

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
