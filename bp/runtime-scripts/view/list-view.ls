class BP.List-view extends BP.View
  (@namespace, @doc-name) ->
    @type = 'list'
    @name = @template-name = new BP.Names @namespace, @doc-name .list-template-name
    super!

  create-data-manager: !-> 
    @data-manager = new BP.List-data-manager @

  create-faces: !-> 
    @faces-manager = new BP.List-faces-manager @ 
    @faces = @faces-manager.create-faces!

  create-ui: !->  @ui = new BP.Table @

  create-adapter: !->
    @adapter = new BP.List-template-adpater @

  add-links: (detail)!-> @links =
    go-create : view: detail, face: detail.faces.create
    go-update : view: detail, face: detail.faces.update
    'delete'  : view: @,      face: @faces.list

  add-relation-data-transfer: ->
    view = @
    [
      !-> $ 'a[class^="bp-"]' .filter ->
        view.is-link-to-cited-doc @
      .click (e)!->
        # alert('haha')
        view.save-data-for-relation-data-in-transferred-state e
    ]

  save-data-for-relation-data-in-transferred-state: _.once (e)!->
    clicked-link = $ e.current-target
    current-doc-id = clicked-link.closest '.current-doc-id' .attr 'bp-doc-id'
    current-doc = @data-manager.collection.find-one _id: current-doc-id
    @data-manager.set-transferred-state @names.doc-name, current-doc

  is-link-to-cited-doc: (link)->
    for {doc-name, query} in @data-manager.cited-data
      return true if ($ link .attr 'href' .index-of doc-name) >= 0
    false