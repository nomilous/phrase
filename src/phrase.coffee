module.exports = class Phrase

    constructor: (properties) -> 

        @[property] = properties[property] for property of properties
        @createdAt  = Date.now()
        @runCount   = 0

        # console.log "[#{ @token.name }] #{ @text }"