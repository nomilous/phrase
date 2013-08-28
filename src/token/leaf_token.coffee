

exports.createClass = (root) -> 

    class LeafToken

        constructor: -> 

            @type = 'leaf'

            #
            # immutables 
            #

            Object.defineProperty this, 'type', 
                enumerable: true
                writable: false
