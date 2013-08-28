

exports.createClass = (root) -> 

    class VertexToken

        constructor: -> 

            @type = 'vertex'

            #
            # immutables 
            #

            Object.defineProperty this, 'type', 
                enumerable: true
                writable: false
