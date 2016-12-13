// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.form.ElementBar', {
  extend: 'Corefw.view.form.ElementForm',
  xtype: 'coreelementbar',
  additionalConfig: function() {
    var addlConfig;
    addlConfig = {
      title: '&nbsp;',
      header: true,
      closable: false,
      collapsible: false,
      collapsed: true,
      hideCollapseTool: true,
      isBarElement: true
    };
    Ext.apply(this, addlConfig);
  },
  updateUIData: function(cache) {
    var data, displayStr, fieldDef, fieldObj, header, key, props, su;
    su = Corefw.util.Startup;
    this.cache = cache;
    data = cache._myProperties.data;
    if (!data) {
      return;
    }
    header = this.down('header');
    if (!header) {
      return;
    }
    if (typeof header.removeAll === "function") {
      header.removeAll();
    }
    this.initializeConstants();
    for (key in cache) {
      fieldObj = cache[key];
      if (key !== '_myProperties') {
        props = fieldObj._myProperties;
        if (props.type === 'LINK') {
          fieldDef = this.genFieldDef(fieldObj);
          if (fieldDef) {
            fieldDef.labelAlign = 'left';
            fieldDef.value = data[key];
            fieldDef.flex = props.coordinate.xsize;
            header.add(fieldDef);
          }
        } else {
          if (su.getThemeVersion() === 2) {
            displayStr = "<span class=\"x-form-item-label\" style=\"text-transform: uppercase;margin-top: 2px;line-height:14px;color:#fff;font-size:14px;\" title= \"" + props.toolTip + "\">" + props.title + " <span style=\"font-weight:normal;\">" + data[key] + "</span></span>";
          } else {
            displayStr = "<span class=\"x-form-item-label\" title= \"" + props.toolTip + "\">" + props.title + " <span style=\"font-weight:normal;\">" + data[key] + "</span></span>";
          }
          header.add({
            xtype: 'container',
            html: displayStr,
            flex: props.coordinate.xsize
          });
        }
      }
    }
    this.deleteConstants();
  },
  afterRender: function() {
    this.callParent(arguments);
    this.updateUIData(this.cache);
  },
  generatePostData: function() {
    var postData;
    postData = {
      name: this.cache._myProperties.name
    };
    return postData;
  }
});
