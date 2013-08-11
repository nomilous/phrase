

module.exports = class PhraseJob

    constructor: (opts = {}) -> 

        for property in ['steps', 'running']

                                #
                                # silent properties
                                #

            do (property) =>

                Object.defineProperty this, property,

                    enumerable: false
                    get: -> opts[property]
            

