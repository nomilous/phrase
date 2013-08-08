exports.create = (root) -> 

    {util} = root

    detect: (phrase, isLeaf) -> 

        return isLeaf true if util.argsOf( phrase.fn )[0] == 'end'
        isLeaf false

