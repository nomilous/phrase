#
# bind all recusrion ControlHooks to root context
#

BeforeAll      = require './before_all'  
BeforeEach     = require './before_each'
AfterEach      = require './after_each'
AfterAll       = require './after_all'

exports.bind = (root, parent) -> 

    beforeAll:   BeforeAll.create root, parent
    beforeEach:  BeforeEach.create root, parent
    afterEach:   AfterEach.create root, parent
    afterAll:    AfterAll.create root, parent
