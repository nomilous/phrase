

exports.createClass = (root) -> 

    class BoundryToken

        constructor: (params) -> 

            @type      = 'boundry'
            @uuid      = params.uuid
            @signature = params.signature


            #
            # immutables 
            #

            for property in ['type', 'uuid', 'signature']
                Object.defineProperty this, property, 
                    enumerable: true
                    writable: false
