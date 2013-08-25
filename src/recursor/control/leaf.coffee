exports.create = (root, control) -> 

    {util} = root

    detect: (phrase, isLeaf) -> 

        arg1 = try util.argsOf( phrase.fn )[0]

        if arg1? and control.leaf.indexOf( arg1 ) >= 0

            phrase.leaf = true
            return isLeaf true 

        phrase.leaf = false
        isLeaf false
