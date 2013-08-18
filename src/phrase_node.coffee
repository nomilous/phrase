#
# phrase node
# ===========
# 
# A vertex in the phrase graph / tree
#

{v1} = require 'node-uuid'

exports.createClass = (root) -> 

    #
    # PhraseNode (class factory)
    # ==========================
    # 

    class PhraseNode

        constructor: (properties) -> 

            @[property] = properties[property] for property of properties
            @uuid     ||= v1()
            # console.log "[#{ @token.name }] #{ @text }"





#         #
#         # inject new phrase into stack
#         #
# 
#         stack.push phrase = new PhraseNode 
# 
#             text:     phraseText
#             token:    parentControl.phraseToken
#             uuid:     if stack.length == 0 then parentControl.phraseToken.uuid else undefined
#                                     #
#                                     # only assign parent token uuid as 
#                                     # phrase uuid on root node
#                                     # 
# 
#             #
#             # TODO: configurable timeout on phraseNode
#             #
# 
#             timeout: phraseControl.timeout
#             
#             #
#             # TODO: determine phrase line in source file
#             #       
#             #       1. IDE plugins could then interact
#             #          directly with phrases
#             # 
#             #          eg. nez - test results in sublime furrow
#             #                  - running single tests or context
#             #                    groups by click or keystroke on
#             #                    active line
#             # 
# 
#             hooks: 
# 
#                 beforeAll:  injectionControl.beforeAll
#                 beforeEach: injectionControl.beforeEach
#                 afterEach:  injectionControl.afterEach
#                 afterAll:   injectionControl.afterAll
# 
#             fn:       phraseFn
#             deferral: deferral
#             queue:    injectionControl.queue
# 
# 