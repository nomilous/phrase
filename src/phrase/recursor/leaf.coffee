exports.create = (root) -> 

    {util} = root

    detect: (phrase, isLeaf) -> 

        try if util.argsOf( phrase.fn )[0] == 'end'

            return isLeaf true 
            
        isLeaf false

