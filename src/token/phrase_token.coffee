exports.createClass = (root) -> 

    class PhraseToken

        constructor: (params) -> 

            @type      = params.type
            @uuid      = params.uuid
            @signature = params.signature

            if @type == 'tree'

                @source = params.source
                @loaded = params.loaded


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

            return SERIALIZE_FROM_THIS: root.context.tree.vertices[@uuid]
