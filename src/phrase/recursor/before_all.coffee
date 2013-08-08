#
# Before All (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context}       = root
    {notice, hooks} = context

    (done, injectionControl) ->

        # emitter.emit 'phrase::start'

        #
        # injectionControl
        # ----------------
        # 
        # InjectionControl is a common object passed as arg2 to each 
        # of the recursion control hooks.
        # 
        # * This first hook pops any phrase hooks that may have been 
        #   registered ahead of this phrase being called and places 
        #   them onto the injection control object so that they can
        #   be accumulated untill the 'flow of control' encounters
        #   a leaf phrase in the tree.
        # 

        beforeAll  = hooks.beforeAll.pop()
        beforeEach = hooks.beforeEach.pop()
        afterEach  = hooks.afterEach.pop()
        afterAll   = hooks.afterAll.pop()

        injectionControl.beforeEach = beforeEach
        injectionControl.beforeAll  = beforeAll
        injectionControl.afterEach  = afterEach
        injectionControl.afterAll   = afterAll

        done()
