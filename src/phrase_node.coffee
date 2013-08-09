#
# phrase node
# ===========
# 
# A vertex in the phrase graph / tree
#

module.exports = class PhraseNode

    constructor: (properties) -> 

        @[property] = properties[property] for property of properties
        @createdAt  = Date.now()
        @runCount   = 0

        # console.log "[#{ @token.name }] #{ @text }"