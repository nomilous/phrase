#
# phrase node
# ===========
# 
# A vertex in the phrase graph / tree
#

{v1} = require 'node-uuid'

module.exports = class PhraseNode

    constructor: (properties) -> 

        @[property] = properties[property] for property of properties
        @uuid       = v1()
        # console.log "[#{ @token.name }] #{ @text }"
