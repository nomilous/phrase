#
# Before All (recursion hook)
#

exports.create = (root) -> 

    {context}        = root
    {emitter, hooks} = context

    (done, injectionControl) ->

        emitter.emit 'phrase::start'

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
        #   each be run by the corresponding recursion control hook.
        #
        # * Then it runs the beforeAll hook (if present)
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

