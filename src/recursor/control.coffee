#
# Recursor Control
# ================
#

BeforeAll      = require './control/before_all'  
BeforeEach     = require './control/before_each'
AfterEach      = require './control/after_each'
AfterAll       = require './control/after_all'

exports.bindControl = (root, control) -> 

    {util} = root

    control.isLeaf = (phrase) -> 

        arg1 = try util.argsOf( phrase.fn )[0]

        #
        # can override leaf detection list ['end', 'done']
        # at any depth in the tree, affecting the entire
        # branch
        #

        if arg1? and control.leaf.indexOf( arg1 ) >= 0

            phrase.leaf = true
            return true

        return false


    return {

        beforeAll:   BeforeAll.create root, control
        beforeEach:  BeforeEach.create root, control
        afterEach:   AfterEach.create root, control
        afterAll:    AfterAll.create root, control

    }