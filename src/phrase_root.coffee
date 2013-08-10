Notice         = require 'notice'
PhraseToken    = require './phrase_token'
PhraseGraph    = require './graph/phrase_graph'
PhraseRecursor = require './phrase/phrase_recursor'

require( 'also' ) exports, {}, (root) -> 

    #
    # phrase
    # ======
    # 
    # API Entrypoint
    #

    {context, validate} = root

    #
    # graph
    # -----
    # 
    # * Houses the set of vertexes and edges that define the phrase tree
    # 
    # * Assembled by the 'first walk' of the phrase recursor.
    #

    context.graph = PhraseGraph.create root
  

    #
    # token
    # -----
    #
    # * A control / attachmant point to initiate actions into 
    #   this phrase tree.
    # 

    context.token = PhraseToken.create root

    #
    # stack
    # -----
    # 
    # * The stack of elements (sub phrases) that is pushed and popped
    #   as the 'first walk' traverses the phrase tree.
    # 

    context.stack = []



    #
    # Phrase.createRoot( opts, linkFn )
    # ---------------------------------
    # 

    createRoot: validate.args

        $address: 'phrase.createRoot'

        opts: 

            title: {} 
            uuid: {} 
            leaf: 
                $default: ['end']
                $description: """

                    This specifies an array of possible phraseFn arg1 signature names 
                    that are used to determine if the phrase function is a leaf.

                        eg. 

                        phraseRegistrar 'phrase text', (end) -> 

                            # 
                            # this is a leaf function
                            # 

                """
                

        linkFn: 

            $type: Function
            $description: """

                This callback is called immediately upon initialization of the
                phrase root. It receives the phrase tree access token and a
                middleware registrar that enables tapping into the chatter 
                traversing the phrase tree's internal message bus.

            """

        (opts, linkFn) -> 

            #
            # * create the message bus
            # 

            context.notice = Notice.create opts.uuid

            #
            # * first middleware is graph assembler
            #

            context.notice.use context.graph.assembler


            #
            # * callback with token and messenger
            #

            linkFn context.token, context.notice


            #
            # return phrase recursor (root registrar)
            # 
         
            return PhraseRecursor.create root, opts
