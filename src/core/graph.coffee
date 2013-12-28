#
# RootGraph
# =========
# 
# * http://www.youtube.com/watch?v=jgmNpBEiLPc
# * Stores the collection of boundry phrase edge references.
#

Notice      = require 'notice'
PhraseNode  = require '../phrase/node'
PhraseTree  = require '../phrase/tree'
TreeWalker  = require '../recursor/tree_walker'

module.exports.create = (core) -> 

    {util} = core

    core.assembler = (next, capsule) -> 


        #
        # The 'first walk' has encoundered a boundry phrase
        # -------------------------------------------------
        # 
        # 
        #     phraseRecursor 'phraseTitle', (edge) -> 
        # 
        #         edge.link directory: './more/phrase/trees'
        # 
        # 
        # * The specified path has been recursed and each found file 
        #   has been converted into a phrase definition by assembly
        #   line (middleware) responding to 'phrase::boundry:assemble'.
        # 
        # * The assembly has specified (left default) the boundry mode
        #   as 'refer'. This means that a new PhraseTree should be 
        #   created and reference to it should be nested into the 
        #   boundry leaf at the link origin.
        # 
        # 
        # 
        # TODO: fix "if nothing handled 'phrase::boundry:assemble' 
        #       then this blows up!"
        # 
        # 
        #

        return next() unless capsule.phrase == 'boundry::edge:create'

        srcPhrase        = capsule.vertices[0]
        srcControl       = capsule.control
        srcRoot          = capsule.root
        newPhraseTitle   = capsule.vertices[1].phrase.title
        newPhraseControl = capsule.vertices[1].phrase.control
        newPhraseUUID    = capsule.vertices[1].phrase.control.uuid || util.uuid()
        newPhraseFn      = capsule.vertices[1].phrase.fn
        assemblyOpts     = capsule.vertices[1].opts

        #
        # * Create and configure new root to house the referred PhraseTree
        #   #DUPLICATE2
        # 

        newRoot = core.root newPhraseUUID
        newRoot.context = {}

        #
        # * Has isolated message bus 
        # 
        # TODO: this bus needs be externally accessed somewhere
        #

        newRoot.context.notice     = Notice.create newPhraseUUID
        newRoot.context.PhraseTree = PhraseTree.createClass newRoot
        newRoot.context.PhraseNode = PhraseNode.createClass newRoot


        #
        # Loading the 'remote' tree is optional
        # -------------------------------------
        # 
        # * The assembly pipeline middlewares (phrase::boundry:assemble) can 
        #   configure capsule.opts.loadTree = false to prevent the loading of the 
        #   boundry tree.
        # 
        # * The reference token nested at link origin in the primary tree will 
        #   still refer to the newRoot, but the phraseFn defining the new 
        #   tree will not be walked, leaving the newRoot unpopulated.
        #
        # * The default is to load the tree
        # 

        if assemblyOpts.loadTree is false

            OriginPhraseToken = core.root( capsule.root.uuid ).context.PhraseToken
            OriginPhraseNode = core.root( capsule.root.uuid ).context.PhraseNode

            #
            # * create reference phrase to nest into the boundry
            #   leaf at the link origin
            #

            capsule.assemble = new OriginPhraseNode
                title: newPhraseTitle
                uuid: newPhraseUUID
                token: new OriginPhraseToken
                    signature: srcControl.phraseToken.signature
                    uuid: newPhraseUUID
                    type: 'tree'
                    loaded: false
                    source:
                        type: 'file'
                        filename: assemblyOpts.filename
                fn: (end) -> end()    

            return next()

        #
        # Walk the boundry phrase to assemble the referred PhraseTree
        # -----------------------------------------------------------
        #
        # * inherit phrase control (opts) from the link origin but
        #   override where local phrase specifies
        #

        opts =
            title:   srcControl.phraseToken.signature
            uuid:    newPhraseUUID
            leaf:    newPhraseControl.leaf    || srcControl.leaf
            boundry: newPhraseControl.boundry || srcControl.boundry
            timeout: newPhraseControl.timeout || srcControl.timeout


        newRoot.context.notice.use 

            title: 'this is a complicated way to log something, delete?'
            (next, capsule) -> 

                # if capsule.context.title == 'phrase::recurse:end'

                #     console.log '\nREFERRED TREE:',newPhraseTitle
                #     console.log path for path of capsule.tokens

                next()

        #
        # TODO: assemblyOpts can specify 'do first walk' (or not) into the
        #       referred PhraseTree
        #

        TreeWalker.walk( newRoot, opts, newPhraseTitle, newPhraseFn ).then(

            (resolve) -> 

                #
                # * create reference phrase to nest into the boundry
                #   leaf at the link origin
                #

                OriginPhraseToken = core.root( capsule.root.uuid ).context.PhraseToken
                OriginPhraseNode = core.root( capsule.root.uuid ).context.PhraseNode

                capsule.assemble = new OriginPhraseNode
                    title: newPhraseTitle
                    uuid: newPhraseUUID
                    token: new OriginPhraseToken
                        signature: srcControl.phraseToken.signature
                        uuid: newPhraseUUID
                        type: 'tree'
                        loaded: true
                        source:
                            type: 'file'
                            filename: assemblyOpts.filename
                    fn: (end) -> end()    

                next()

            (reject)  -> console.log REJECT:  reject; next()
            

        )
