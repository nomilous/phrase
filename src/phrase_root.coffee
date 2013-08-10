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
                phrase root. It receives the phrase tree access token and the
                messenger middleware registrar.

            """

        (opts, linkFn) -> 

            #
            # notice
            # -------
            #
            # * middlewares can register to receive phrase lifecycle and activity 
            #   events emanating from within the branch rooted at this phrase.
            # 

            context.notice = Notice.create opts.uuid

            #
            # * first middleware is graph assembler
            #

            context.notice.use context.graph.assembler


            #
            # callback with the message pipeline (notice)
            #

            linkFn context.token, context.notice


            #
            # return phrase recursor (root)
            # 
         
            return PhraseRecursor.create root, opts
