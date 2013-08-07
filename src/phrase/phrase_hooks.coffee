exports.PhraseHook = class PhraseHook

    constructor: (@fn) -> 

        @createdAt = Date.now()
        @runCount  = 0

# 
# create before() and after() hook registrars on global scope
# -----------------------------------------------------------
#  

beforeHooks = each: [], all: []
afterHooks  = each: [], all: []

Object.defineProperty global, 'before',
    enumerable: false
    get: -> (opts = {}) -> 

        beforeHooks.each.push new PhraseHook opts.each if typeof opts.each == 'function'
        beforeHooks.all.push  new PhraseHook opts.all  if typeof opts.all  == 'function'


Object.defineProperty global, 'after',
    enumerable: false
    get: -> (opts = {}) -> 

        afterHooks.each.push new PhraseHook opts.each if typeof opts.each == 'function'
        afterHooks.all.push  new PhraseHook opts.all  if typeof opts.all  == 'function'


exports.bind = (root) -> 
    
    beforeAll:   beforeHooks.all
    beforeEach:  beforeHooks.each
    afterEach:   afterHooks.each
    afterAll:    afterHooks.all

