#
# RootGraph
# =========
# 
# * Stores the collection of boundry phrase edge references.
#

Notice      = require 'notice'
PhraseNode  = require '../phrase/node'
PhraseTree  = require '../phrase/tree'
TreeWalker  = require '../recursor/tree_walker'

module.exports.create = (core) -> 

    {util} = core

    core.assembler = (msg, next) -> 

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

        try console.log msg.context.title, UUID: msg.root.uuid
        catch error
            console.log msg.context.title

        return next() unless msg.context.title == 'boundry::edge:create'

        srcPhrase        = msg.vertices[0]
        srcControl       = msg.control
        srcRoot          = msg.root
        newPhraseTitle   = msg.vertices[1].phrase.title
        newPhraseControl = msg.vertices[1].phrase.control
        newPhraseUUID    = msg.vertices[1].phrase.control.uuid || util.uuid()
        newPhraseFn      = msg.vertices[1].phrase.fn
        assemblyOpts     = msg.vertices[1].opts

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
        # * inherit phrase control (opts) from the link origin but
        #   override where local phrase specifies
        #

        opts =
            title:   srcControl.phraseToken.signature
            uuid:    newPhraseUUID
            leaf:    newPhraseControl.leaf    || srcControl.leaf
            boundry: newPhraseControl.boundry || srcControl.boundry
            timeout: newPhraseControl.timeout || srcControl.timeout


        newRoot.context.notice.use (msg, next) -> 

            if msg.context.title == 'phrase::recurse:end'

                console.log '\nREFERRED_TITLE:',newPhraseTitle
                console.log path for path of msg.tokens

            next()

        #
        # TODO: assemblyOpts can specify 'do first walk' (or not) into the
        #       referred PhraseTree
        #

        TreeWalker.walk( newRoot, opts, newPhraseTitle, newPhraseFn ).then(

            (resolve) -> next()
            (reject)  -> console.log REJECT:  reject; next()
            

        )

        # console.log

        #     srcPhrase:     srcPhrase
        #     srcControl:    srcControl
        #     srcRoot:       srcRoot
        #     newPhraseDefn: newPhraseDefn
        #     newPhraseOpts: newPhraseOpts



    
