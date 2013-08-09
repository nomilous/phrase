#
# After All (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context}        = root
    {stack, notice}  = context

    (done, injectionControl) -> 

        parent = stack[ stack.length - 1 ]

        done()

        process.nextTick -> 

            #
            # This is the injection deferral that suspended
            # the completion of the 'first walk's traversal
            # of the parent phrase.
            # 
            # Calling it now releases that suspension and 
            # allows the 'first walk' to proceed into the
            # next sibling of the parent phrase.
            #
            # It is called on the nextTick to ensure that 
            # any functionality still pending at this depth
            # ( that follows done() ) occurrs before the 
            # parent resolution.
            # 
            # 
            #  #GREP1
            # 

            parent.deferral.resolve() if parent?

        
