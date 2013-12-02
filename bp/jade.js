// Generated by LiveScript 1.2.0
(function(){
  var fs, View, code;
  fs = require('fs');
  View = require('./navigation').View;
  module.exports = {
    getView: function(docName, templateName, templateType){
      return View.getView.apply(View, arguments);
    },
    setMainNav: function(templateNames){
      var i$, len$, name, results$ = [];
      for (i$ = 0, len$ = templateNames.length; i$ < len$; ++i$) {
        name = templateNames[i$];
        results$.push(View.registry[name].isMainNav = true);
      }
      return results$;
    },
    saveView: function(view){
      fs.writeFileSync('bp/main.ls', code + JSON.stringify(View.registry));
    }
  };
  code = ' \nif module\n  require! [fs, sugar, \'./Router\']\n\nBP ||= {}\nBP.Router ||= Router\n\ndebugger\nBP.Router.add-route-for-views views = ';
}).call(this);