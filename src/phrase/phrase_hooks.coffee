# 
# create before() and after() registrars on global scope
# ------------------------------------------------------
#  

beforeHooks = each: [], all: []
afterHooks  = each: [], all: []

Object.defineProperty global, 'before',
    enumerable: false
    get: -> (opts = {}) -> 

        beforeHooks.each.push opts.each if typeof opts.each == 'function'
        beforeHooks.all.push  opts.all  if typeof opts.all  == 'function'


Object.defineProperty global, 'after',
    enumerable: false
    get: -> (opts = {}) -> 

        afterHooks.each.push opts.each if typeof opts.each == 'function'
        afterHooks.all.push  opts.all  if typeof opts.all  == 'function'


#
# phrase hooks
# ============
#

exports.create = (root) -> 
    
    beforeAll:   beforeHooks.all
    beforeEach:  beforeHooks.each
    afterEach:   afterHooks.each
    afterAll:    afterHooks.all

