// Generated by LiveScript 1.2.0
(function(){
  var Path, View;
  Path = (function(){
    Path.displayName = 'Path';
    var prototype = Path.prototype, constructor = Path;
    function Path(destinationViewName, type){
      this.destinationViewName = destinationViewName;
      this.type = type;
      this.composedPaths = [];
      this.patterns = {};
    }
    prototype.createPattern = function(){
      var name, ref$, pattern, path;
      if (this.type === 'list') {
        this.patterns['list'] = '/' + this.destinationViewName;
        this.patterns['reference'] = '/' + this.destinationViewName + '/reference';
      } else if (this.type === 'detail') {
        this.idPlaceHolder = ':' + this.destinationViewName + '-id';
        this.patterns['create'] = '/' + this.destinationViewName + '/create';
        this.patterns['update'] = '/' + this.destinationViewName + '/' + this.idPlaceHolder + '/update';
        this.patterns['view'] = '/' + this.destinationViewName + '/' + this.idPlaceHolder + '/view';
        this.patterns['reference'] = '/' + this.destinationViewName + '/' + this.idPlaceHolder + '/reference';
      } else {
        throw new Error("this '" + this + "type' is not supported yet.");
      }
      if (this.composedPaths.length > 0) {
        for (name in ref$ = this.patterns) {
          pattern = ref$[name];
          this.patterns[name] = pattern + (fn$.call(this));
        }
      }
      function fn$(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = this.composedPaths).length; i$ < len$; ++i$) {
          path = ref$[i$];
          results$.push(path.patterns['reference']);
        }
        return results$;
      }
    };
    prototype.getPath = function(action, id){
      var path;
      if (id) {
        return path = this.patterns.replace(this.idPlaceHolder, id);
      } else {
        return path = this.patterns;
      }
    };
    return Path;
  }());
  View = (function(){
    View.displayName = 'View';
    var isAllResolved, wireViewsGoto, prototype = View.prototype, constructor = View;
    View.registry = {};
    View.getView = function(docName, viewName, type){
      if (!this.registry[viewName]) {
        this.registry[viewName] = new View(docName, viewName, type);
      }
      return this.registry[viewName];
    };
    View.resumeViews = function(views){
      var viewName, view;
      for (viewName in views) {
        view = views[viewName];
        View.registry[viewName] = this.resumeView(view);
      }
    };
    View.resumeView = function(view){
      var resumedView;
      view.path = import$(new Path(), view.path);
      return resumedView = import$(new View(), view);
    };
    View.createAllViewsPathPattern = function(){
      var views, total, resolvedViews, i$, len$, view, j$, ref$, len1$, composedView;
      views = Object.values(this.registry);
      total = views.length;
      resolvedViews = [];
      while (resolvedViews.length !== total) {
        for (i$ = 0, len$ = views.length; i$ < len$; ++i$) {
          view = views[i$];
          if (view !== null && isAllResolved(view.composedViews)) {
            for (j$ = 0, len1$ = (ref$ = Object.values(view.composedViews)).length; j$ < len1$; ++j$) {
              composedView = ref$[j$];
              view.path.composedPaths.push(composedView.path);
            }
            view.path.createPattern();
            resolvedViews.push(view);
            view = null;
          }
        }
      }
    };
    isAllResolved = function(composedViews){
      var viewName, composedViewOrName;
      for (viewName in composedViews) {
        composedViewOrName = composedViews[viewName];
        if (typeof composedViewOrName === 'object') {
          continue;
        }
        if (!constructor.registry[composedViewOrName]) {
          return false;
        }
        composedViews[viewName] = constructor.registry[composedViewOrName].clone(viewName);
      }
      return true;
    };
    wireViewsGoto = function(){
      var viewName, ref$, view;
      for (viewName in ref$ = this.registry) {
        view = ref$[viewName];
        view.wireGoto();
      }
    };
    function View(docName, name, type){
      this.docName = docName;
      this.name = name;
      this.type = type;
      this.path = new Path(this.name, this.type);
      this.isMainNav = false;
      this.composedViews = {};
      this.gotos = {};
    }
    prototype.addComposedView = function(viewName, composedViewName){
      this.composedViews[viewName] = composedViewName;
    };
    prototype.clone = function(newViewName){
      var newView;
      newView = constructor.resumeView(JSON.parse(JSON.stringify(this)));
      newView.name = newViewName;
      newView.path.destinationViewName = newViewName;
      newView.path.createPattern();
      return newView;
    };
    prototype.wireGoto = function(){
      if (this.type === 'detail') {
        this.leavingActions = ['next', 'previous', 'submit', 'delete'];
        this.goto['next'] = {
          helperName: 'bp-'
        };
      }
    };
    return View;
  }());
  if (module) {
    module.exports = {
      View: View
    };
  } else {
    BP.View = View;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);