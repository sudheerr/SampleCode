Ext.define 'Corefw.controller.Entitlement',
  extend: 'Ext.app.Controller'

  init: ->
    @control
      'field':
        afterrender: @entitlingComponent
      'button':
        afterrender: @entitlingComponent
      'htmleditor':
        afterrender: @entitlingComponent
      'corecheckcolumn':
        beforerender: (comp) ->
          fc = comp.up('fieldcontainer')
          return if not fc
          cm = Corefw.util.Common
          isProhibited = cm.processProhibited fc, true
          comp.setDisableSelection isProhibited
          return
#      'gridview':
#        beforerender: (comp) ->
#          fc = comp.up()
#          return if not fc
#          cm = Corefw.util.Common
#          isProhibited = cm.processProhibited fc, true
#          comp.disableSelection = isProhibited
#          return
      'treeview':
        beforerender: (comp) ->
          fc = comp.up()
          return if not fc
          cm = Corefw.util.Common
          isProhibited = cm.processProhibited fc, true
          comp.disableSelection = isProhibited
          return
    return

  entitlingComponent: (comp, eOpts) ->
    #	ignore fields in inline filter
    return if comp.inlineFilter
    cm = Corefw.util.Common
    parentXtype = comp?.up()?.xtype
    return if parentXtype is 'corepagingtoolbar'
    isProhibited = cm.processProhibited comp
    if isProhibited
      if comp.setReadOnly and comp.xtype isnt 'coretoggleslidefield' and not comp.isLookup
        comp.setReadOnly cm.processProhibited comp
      else
        comp.setDisabled cm.processProhibited comp
      comp.suspendEvents false
    return