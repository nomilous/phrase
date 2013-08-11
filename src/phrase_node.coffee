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
        @createdAt  = Date.now()
        @runCount   = 0

        # console.log "[#{ @token.name }] #{ @text }"


#
# TODO: phrase nodes and hooks carry checksum of the fn.toString()
# 
#       use case 1: 
#           nez objective / realizer interactions can
#           detect changed phrase functions and hooks
#           and re-run only the affected leaves
#
#       use case 2: (later)
#           systems whose services are defined by leaves
#           on a phrase tree could have each leaf running
#           in a separate process, identifying changed 
#           leaves at version release time has some notable
#           benefits, and if those service leaves are in
#           a properly crafted phrase tree, their context 
#           and scope heap may not need a restart. An eval
#           of the new leaf function can replace the previous
#           and continue to run in the scope/context of the 
#           existing runtime that was assembled by the hook 
#           ancestry when the service first started.
#          
