module.exports = class Phrase

    constructor: (properties) -> 

        @[property] = properties[property] for property of properties

        console.log "[#{ @token.name }] #{ @text }"