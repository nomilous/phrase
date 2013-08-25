#
# After Each (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context}       = root
    {stack, notice} = context

    (done, injectionControl) -> 

        stack.pop()
        done()

