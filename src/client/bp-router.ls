Router.configure do
  layout-template: 'layout'
  loding-template: 'loading'
  not-found-template: 'not-found'

filters = 
  n-progress-hook: ->
    if @ready!
      N-progress.done!
    else
      N-progress.start!
      @stop!

  reset-scroll: ->
    scroll-to = window.current-scroll or 0
    $ 'body' .scroll-top scroll-to
    $ 'body' .css 'min-height' 0

Router.before filters.n-progress-hook, except: []
    # only: []

Router.after  filters.reset-scroll, except: []
    # only: []


for published-name in BP.subscribed
  console.log "published-name: ", published-name
  Router.map ->
    @route published-name, do
      path: '/'+ published-name
      template: published-name + '-list'

Router.map ->
  @route 'default', do
    path: '/*'
    template: 'splash'
    # yield-templates:
