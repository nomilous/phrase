

exports.createClass = (root) -> 

    class BoundryToken

        constructor: -> 

            @type = 'boundry'

            #
            # immutables 
            #

            Object.defineProperty this, 'type', 
                enumerable: true
                writable: false
