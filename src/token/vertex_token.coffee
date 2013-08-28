

exports.createClass = (root) -> 

    class VertexToken

        constructor: (params) -> 

            @type      = 'vertex'
            @uuid      = params.uuid
            @signature = params.signature


            #
            # immutables 
            #

            for property in ['type', 'uuid', 'signature']
                Object.defineProperty this, property, 
                    enumerable: true
                    writable: false
