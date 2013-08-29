

exports.createClass = (root) -> 

    class LeafToken

        constructor: (params) -> 

            @type      = 'root'
            @uuid      = params.uuid
            @signature = params.signature


            #
            # immutables 
            #

            for property in ['type', 'uuid', 'signature']
                Object.defineProperty this, property, 
                    enumerable: true
                    writable: false

