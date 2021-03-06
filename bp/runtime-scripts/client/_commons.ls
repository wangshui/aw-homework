
/* --------------------- Iron Router的配置和B+ Components之外的Routes --------------- */
do config-and-static-route = !~>
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

  Router.map ->
    @route 'default', do
      path: '/'
      template: 'splash'
      # yield-templates:

/* --------------------- Meteor Account 的配置 --------------- */
Accounts.ui.config password-signup-fields: 'USERNAME_ONLY'



/* --------------------- Utility Functions ------------------ */
@BP ||= {}
vendor-prefix = ["webkit", "moz", "MS", "o", ""]
BP.utils =
  addVendorPrefixEvents: (element, event-name, callback)!->
    for prefix in vendor-prefix
      element.add-event-listener (prefix + event-name.to-lower-case!), callback, false
