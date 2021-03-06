Notice      = require 'notice'
PhraseNode  = require './node'
PhraseTree  = require './tree'
AccessToken = require '../token/access_token'
TreeWalker  = require '../recursor/tree_walker'
Job         = require '../runner/job'

exports.createClass = (root) -> 

    #
    # phrase
    # ======
    # 
    # API Entrypoint
    #

    {context, validate} = root

    root.context = context = {} unless context?



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
                $default: ['end', 'done']
                $description: """

                    This specifies an array of possible phraseFn arg1 signature names 
                    that are used to determine if the phrase function is a leaf.

                        eg. 

                        phraseRegistrar 'phrase title', (end) -> 

                            # 
                            # this is a leaf function
                            # 

                """

            boundry:
                $default: ['edge']
                $description: """

                    This specifies an array of possible phraseFn arg1 signature names 
                    that are used to determine if the phrase function is a boundry
                    link to another phrase tree.

                        eg. 

                        phraseRegistrar 'phrase title', (edge) -> 

                            # 
                            # TODO...
                            # 

                """

            timeout: 
                $default: 2000
                $description: """

                    This specifies how long to allow asynchronous hooks or leaves
                    to run before it is assumed they will not complete.

                    eg. 

                    before each: (done) -> 

                        #
                        # has the default 2 seconds to call done() or it will timeout
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

            context.notice = opts.notice || Notice.create opts.uuid

            context.notice.use root.assembler


            #
            # * used in hooks (TEMPORARY)
            #

            root.timeout = opts.timeout


            #
            # return phrase root registrar
            # 
         
            return (phraseRootString, phraseRootFn) -> 

                if context.walking?

                    throw new Error 'Phrase root registrar cannot perform concurrent walks'


                unless context.token?


                    #
                    # this is the first walk
                    # ======================
                    # 
                    # #DUPLICATE2
                    # 

                    # 
                    #
                    # create PhraseTree  (class definition)
                    # -------------------------------------
                    # 
                    # * Houses the set of vertexes and edges that define the phrase tree
                    # * Assembled (via message bus) by the 'first walk' of the phrase recursor
                    # * This is the PhraseTree definition (class)
                    # * Instance is managed in TreeWalker
                    # 

                    context.PhraseTree = PhraseTree.createClass root


                    #
                    # create PhraseNode (class definition)
                    # ------------------------------------
                    # 
                    # * A PhraseNode instance is created for each vertex (Node) 
                    #   in the phrase tree. 
                    # * They are stored in a collection in the PhraseTree  
                    #

                    context.PhraseNode = PhraseNode.createClass root
                  

                    #
                    # create Job (class definition)
                    # -----------------------------------
                    #
                    # * Job instances are created with each call to token.run
                    # * The class definition is instanciated here to enable root access
                    # 
                    # 

                    context.Job = Job.createClass root


                    #
                    # create AccessToken (instance)
                    # ----------------------------------
                    # 
                    # * This token is the primary interface into the phrase tree
                    # 

                    context.token = AccessToken.create root


                    #
                    # * Start 'first walk' to load the phrase tree
                    #

                    promise = TreeWalker.walk root, opts, phraseRootString, phraseRootFn


                    # 
                    # * Call the linker to assign external access to the 
                    #   phrase tree (via the token) and the message bus
                    #   

                    linkFn context.token, context.notice, root


                    #
                    # impart the return
                    # -----------------
                    # 
                    # * activate 'uncertainty shields'
                    # * activate 'duality field'
                    # * activate 'supersymmetry sensor array'
                    # * activate 'entanglment phase array'
                    # * activate 'causality phase array'
                    #

                    return promise

                    #
                    # the quantum flux has stabalized
                    # -------------------------------
                    #
                    # * rotate the 'chaos manifold'
                    # 

                    ; 


                #
                # not the first walk
                # ==================
                # 

                TreeWalker.walk root, opts, phraseRootString, phraseRootFn





