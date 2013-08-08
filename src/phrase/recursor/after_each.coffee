#
# After Each (recursion hook)
#

exports.create = (root) -> 

    {context}       = root
    {stack, notice} = context

    (done) -> 

        stack.pop()

        done()

