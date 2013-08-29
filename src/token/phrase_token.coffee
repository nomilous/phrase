exports.createClass = (root) -> 

    class PhraseToken

        constructor: (params) -> 

            @type      = params.type
            @uuid      = params.uuid
            @signature = params.signature


            #
            # immutables 
            #

            for property in ['type', 'uuid', 'signature']
                Object.defineProperty this, property, 
                    enumerable: true
                    writable: false
