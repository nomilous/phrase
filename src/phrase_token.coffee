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
    emitter.graph = graph






    emitter.run = (opts = {}) -> 

        #
        # TODO: (later) opts.uuid becomes optional, this (token)
        #               is assigned to a phrase, run that one.
        #

        PhraseRunner.run root, opts

    notice.use (msg, next) -> 

        emitter.emit 'ready' if msg.context.title == 'phrase::recurse:end'
        next()


    return emitter
