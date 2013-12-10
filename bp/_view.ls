# 本文件命名加下划线，因为需要让Meteor在list-view.ls和detail-view.ls之前加载。
class @BP.View extends BP._View
  @doc-grouped-views = @_dgv = {}
  @transfer-state-between-views = new BP.State '_transfer-state' if Meteor.is-client

  @register-in-doc-grouped-views = (view)!->
    @_dgv[view.doc-name] ||= {}
    @_dgv[view.doc-name][view.type] = view

  @resume-views = !(jade-views, customized-view-class-name, type)->
    for view-name, jade-view of jade-views
      @registry[view-name] = view = @resume-view jade-view, customized-view-class-name, type
      @register-in-doc-grouped-views view
    # @create-referred-views!
    @wire-views-appearances! if Meteor.is-client

  @resume-view = (jade-view, customized-view-class-name, type)->
    view = (@create-view-by-type jade-view.type, customized-view-class-name, type) <<< jade-view
    view.init!
    @registry[view.name] = view
    
  @create-view-by-type = (type, customized-view-class-name, customized-type)->
    if customized-view-class-name and type is customized-type
      eval "view = new #{customized-view-class-name}();" 
    else
      view =  if type is 'list' then new BP.List-view! else new BP.Detail-view!
    view

  @create-referred-views = !->
    View = @
    (view, view-name)                             <-! _.each View.registry
    (reference-view-config, reference-view-name)  <-! _.each view.referred-views
    referred-view = View.create-referred-view reference-view-name, reference-view-config
    view.referred-views[reference-view-name] = referred-view # doc: referred views 不在 View#registry里面登记，通过bp-load-view的helper切换view，而不是Router切换。

  @create-referred-view = (name, config)->
    origin = @registry[config.referred-view-name]
    view = @create-view-by-type origin.type
    view.doc-name = origin.doc-name
    view.template-name = origin.template-name
    view.name = name
    view.is-referred = true
    view.query = config.query
    view.init!
    @@register-in-template-grouped-views view
    view

  @wire-views-appearances = !->
    for doc-name, {list, detail} of @doc-grouped-views
      list.add-links detail
      detail.add-links list

  init: ->
    @names = new BP.Names @doc-name
    @collection = BP.Collection.get @names.meteor-collection-name
    @create-pub-sub!
    if Meteor.is-client
      @links = {}
      @state = new BP.State @name
      @create-view-appearances! 
      @create-ui!


  publish-data: !->
    debugger
    view = @
    Meteor.publish view.pub-sub.name, (id)-> 
      eval "query = " + view.pub-sub.query
      cursor = view.collection.find query

    (referred-view, view-name) <-! _.each view.referred-views
    Meteor.publish referred-view.pub-sub.name, (id)->
      eval "query = " + referred-view.pub-sub.query
      cursor = collection.find query
      # Meteor.subscribe @pub-sub.name, @doc-id = params[@name + '_id'], !~>  # main view
      #   @retrieve-as-main-view!
      # (referred-view, view-name) <-! _.each @referred-views
      # Meteor.subscribe referred-view.pub-sub.name, !->
      #   referred-view.collection = BP.Collection.registry[referred-view.names.meteor-collection-name]
      #   referred-view.retrieve-as-referred-view!

  get-path: (link-name, doc-or-doc-id)->
    {view, appearance} = @links[link-name]
    view.get-appearance-path appearance, doc-or-doc-id

  change-to-appearance: (appearance-name, params)->
    @current-appearance-name = appearance-name
    # @state.set current-id: (params[@name + '_id'] or params.id)

  get-current-action: ~> @current-appearance-name

  current-action-checker: (action-name)~> action-name is @current-appearance-name
