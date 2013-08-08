#
# After All (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context}        = root
    {stack, notice}  = context

    (done, injectionControl) -> 

        parent = stack[ stack.length - 1 ]
        parent.deferral.resolve() if parent?

        done()
