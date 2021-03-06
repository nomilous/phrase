// Generated by CoffeeScript 1.6.3
var PhraseHook, afterHooks, beforeHooks;

exports.PhraseHook = PhraseHook = (function() {
  function PhraseHook(root, type, opts) {
    this.type = type;
    this.fn = (function() {
      switch (type) {
        case 'beforeEach':
        case 'afterEach':
          return opts.each;
        case 'beforeAll':
        case 'afterAll':
          return opts.all;
      }
    })();
    this.uuid = root.util.uuid();
    this.timeout = opts.timeout || root.timeout || 2000;
  }

  return PhraseHook;

})();

beforeHooks = {
  each: [],
  all: []
};

afterHooks = {
  each: [],
  all: []
};

exports.bind = function(root) {
  try {
    Object.defineProperty(global, 'before', {
      enumerable: false,
      get: function() {
        return function(opts) {
          if (opts == null) {
            opts = {};
          }
          if (typeof opts.each === 'function') {
            beforeHooks.each.push(new PhraseHook(root, 'beforeEach', opts));
          }
          if (typeof opts.all === 'function') {
            return beforeHooks.all.push(new PhraseHook(root, 'beforeAll', opts));
          }
        };
      }
    });
  } catch (_error) {}
  try {
    Object.defineProperty(global, 'after', {
      enumerable: false,
      get: function() {
        return function(opts) {
          if (opts == null) {
            opts = {};
          }
          if (typeof opts.each === 'function') {
            afterHooks.each.push(new PhraseHook(root, 'afterEach', opts));
          }
          if (typeof opts.all === 'function') {
            return afterHooks.all.push(new PhraseHook(root, 'afterAll', opts));
          }
        };
      }
    });
  } catch (_error) {}
  return {
    beforeAll: beforeHooks.all,
    beforeEach: beforeHooks.each,
    afterEach: afterHooks.each,
    afterAll: afterHooks.all
  };
};
