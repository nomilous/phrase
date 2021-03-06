// Generated by CoffeeScript 1.6.3
exports.create = function(root, parentControl) {
  var context, hooks, notice;
  context = root.context;
  notice = context.notice, hooks = context.hooks;
  context.stack || (context.stack = []);
  return function(done, injectionControl) {
    var run;
    run = function() {
      var afterAll, afterEach, beforeAll, beforeEach;
      beforeAll = hooks.beforeAll.pop();
      beforeEach = hooks.beforeEach.pop();
      afterEach = hooks.afterEach.pop();
      afterAll = hooks.afterAll.pop();
      injectionControl.beforeEach = beforeEach;
      injectionControl.beforeAll = beforeAll;
      injectionControl.afterEach = afterEach;
      injectionControl.afterAll = afterAll;
      return done();
    };
    if (context.walking != null) {
      return run();
    }
    return notice.event('phrase::recurse:start', {
      root: {
        uuid: root.uuid
      }
    }).then(function() {
      context.walking = {
        startedAt: Date.now()
      };
      context.walking.first = context.walks == null;
      return run();
    });
  };
};
