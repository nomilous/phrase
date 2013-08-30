exports.createClass = (root) -> 

    class PhraseToken

        constructor: (params) -> 

            @type      = params.type
            @uuid      = params.uuid
            @signature = params.signature


            #
            # immutables 
            #

            for property in ['uuid', 'signature']
                Object.defineProperty this, property, 
                    enumerable: true
                    writable: false

        serialize: -> 

            #
            # serialize the branch of the PhraseTree rooted at this node
            # ----------------------------------------------------------
            #
            # * include only vertices
            # 

            return SERIALIZE_FROM_THIS: root.context.graph.vertices[@uuid]
