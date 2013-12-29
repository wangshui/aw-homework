## Component是BP数据（collection）展示和操作的基本单位。Component有list和detail两种view，对一种数据（doc）进行展示和操作。

top = @
class @BP.Collection
  @registry = {}
  @get = (collection-name)->
    @registry[collection-name] ||= new Meteor.Collection collection-name
    top[collection-name] = @registry[collection-name] # 开发时暴露出来，便于插入数据和调试。

  @get-by-doc-name = (doc-name)->
    collection-name = new BP.Names doc-name .meteor-collection-name
    @get collection-name

class @BP.Component
  @main-nav-paths = []

  @create-components-from-jade-views =  (jade-views)->
    # debugger
    BP.View.resume-views jade-views
    (view, view-name)  <~! _.each BP.View.registry
    component = new BP.Component view

  (@view)-> # template-name, template-adapter, views
    if Meteor.is-client
      @create-template-adpater!
      @add-main-navs!
      @view.route!

    if Meteor.is-server 
      # debugger
      @view.data-manager.publish!

  create-template-adpater: !->
    @adapter = BP.Template-adapter.get @view

  add-main-navs: !->
    if @view.is-main-nav
      for face-name, path-pattern of @view.faces
        if face-name is 'list'
          path-name = @view.faces-manager.get-path-name face-name
          @add-to-main-nav @view, path-name 

  add-to-main-nav: (view, path-name)!->
    @@main-nav-paths.push {name: view.name, path: path-name}


