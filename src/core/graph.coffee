#
# RootGraph
# =========
# 
# * Stores the collection of boundry phrase edge references.
#

module.exports.create = (core) -> 

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

        if msg.context.title == 'boundry::edge:create'

            srcPhrase     = msg.vertices[0]
            srcControl    = msg.control
            srcRoot       = msg.root
            newPhraseDefn = msg.vertices[1].phrase
            newPhraseOpts = msg.vertices[1].opts

            console.log

                srcPhrase:     srcPhrase
                srcControl:    srcControl
                srcRoot:       srcRoot
                newPhraseDefn: newPhraseDefn
                newPhraseOpts: newPhraseOpts



        next()
