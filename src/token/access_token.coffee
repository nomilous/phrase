#
# Access Token
# ============
# 
# Interface into the PhraseTree
# 

{EventEmitter} = require 'events' 
Run            = require '../runner/run'

exports.create = (root) -> 

    {context}       = root
    {tree, notice} = context
    emitter         = new EventEmitter




    # #
    # # TEMPORARY: direct access to tree
    # # =========
    # #

    # console.log 'DELETE'
    # Object.defineProperty emitter, 'tree', 

    #     enumerable: false
    #     get: -> context.tree
    






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


    notice.use 

        title: 'token emitter proxy'
        (next, capsule) -> 

            if capsule.phrase == 'phrase::recurse:end'

                if capsule.walk.first then emitter.emit 'ready', 

                    walk:   capsule.walk
                    tokens: capsule.tokens

                else 

                    emitter.emit 'changed', 'TODO: changed payload'




            next()


    return emitter
