

exports.createClass = (root) -> 

    class LeafToken

        constructor: (params) -> 

            @type      = 'leaf'
            @uuid      = params.uuid
            @signature = params.signature


            #
            # immutables 
            #

            for property in ['type', 'uuid', 'signature']
                Object.defineProperty this, property, 
                    enumerable: true
                    writable: false
