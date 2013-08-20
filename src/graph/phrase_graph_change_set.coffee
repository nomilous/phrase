exports.createClass = (root) -> 

    #
    # PhraseGraphChangeSets (class factory)
    # =====================================
    #
    # * Stores the set of changes to be applied to a graph to 
    #   advance it to the next / previous version.
    # 
    # * And probably the corresponding inverse set, for retreat.
    # 
    # * And will probably store the these chane set pairs in the
    #   context.walks (history array) for sequenceing multiple
    #   changes.
    #   
    # * Also, 
    #      
    #        It's an obviously a 'complexity bomb' 
    # 
    #        And won't be fully implemented now, 
    # 
    #        ( just wanna clear up the phrase graph 
    #             definition for now, file's getting 
    #                too big... )
    # 

    class PhraseGraphChangeSet