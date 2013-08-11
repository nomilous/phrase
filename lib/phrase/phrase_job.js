// Generated by CoffeeScript 1.6.3
var PhraseJob, v1;

v1 = require('node-uuid').v1;

module.exports = PhraseJob = (function() {
  function PhraseJob(opts) {
    var localOpts, property, _fn, _i, _len, _ref,
      _this = this;
    if (opts == null) {
      opts = {};
    }
    opts.running || (opts.running = {
      notify: function(update) {
        return console.log('PhraseJob:', JSON.stringify(update));
      }
    });
    opts.uuid || (opts.uuid = v1());
    localOpts = {
      progress: {
        steps: opts.steps != null ? opts.steps.length : 0,
        done: 0
      }
    };
    _ref = ['uuid', 'steps', 'running', 'done', 'progress'];
    _fn = function(property) {
      return Object.defineProperty(_this, property, {
        enumerable: false,
        get: function() {
          return opts[property] || localOpts[property];
        }
      });
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      property = _ref[_i];
      _fn(property);
    }
  }

  PhraseJob.prototype.start = function() {
    return this.running.notify({
      "class": this.constructor.name,
      uuid: this.uuid,
      action: 'start',
      progress: this.progress,
      at: Date.now()
    });
  };

  return PhraseJob;

})();