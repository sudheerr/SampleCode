// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.controller.Entitlement', {
  extend: 'Ext.app.Controller',
  init: function() {
    this.control({
      'field': {
        afterrender: this.entitlingComponent
      },
      'button': {
        afterrender: this.entitlingComponent
      },
      'htmleditor': {
        afterrender: this.entitlingComponent
      },
      'corecheckcolumn': {
        beforerender: function(comp) {
          var cm, fc, isProhibited;
          fc = comp.up('fieldcontainer');
          if (!fc) {
            return;
          }
          cm = Corefw.util.Common;
          isProhibited = cm.processProhibited(fc, true);
          comp.setDisableSelection(isProhibited);
        }
      },
      'treeview': {
        beforerender: function(comp) {
          var cm, fc, isProhibited;
          fc = comp.up();
          if (!fc) {
            return;
          }
          cm = Corefw.util.Common;
          isProhibited = cm.processProhibited(fc, true);
          comp.disableSelection = isProhibited;
        }
      }
    });
  },
  entitlingComponent: function(comp, eOpts) {
    var cm, isProhibited, parentXtype, _ref;
    if (comp.inlineFilter) {
      return;
    }
    cm = Corefw.util.Common;
    parentXtype = comp != null ? (_ref = comp.up()) != null ? _ref.xtype : void 0 : void 0;
    if (parentXtype === 'corepagingtoolbar') {
      return;
    }
    isProhibited = cm.processProhibited(comp);
    if (isProhibited) {
      if (comp.setReadOnly && comp.xtype !== 'coretoggleslidefield' && !comp.isLookup) {
        comp.setReadOnly(cm.processProhibited(comp));
      } else {
        comp.setDisabled(cm.processProhibited(comp));
      }
      comp.suspendEvents(false);
    }
  }
});
