

exports.createClass = (root) -> 

    class LeafToken

        constructor: -> 

            Object.defineProperty this, 'type', 
                enumerable: true
                get: -> 'leaf'
