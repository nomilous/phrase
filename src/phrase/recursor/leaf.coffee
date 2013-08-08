exports.create = (root) -> 

    {util} = root

    detect: (phrase, isLeaf) -> 

        try if util.argsOf( phrase.fn )[0] == 'end'

            phrase.leaf = true
            return isLeaf true 

        phrase.leaf = false
        isLeaf false
