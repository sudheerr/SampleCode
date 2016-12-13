// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.form.field.IframeField', {
  extend: 'Ext.form.FieldContainer',
  mixins: ['Corefw.mixin.CoreField'],
  xtype: 'coreiframefield',
  frame: false,
  hideLabel: true,
  iframe: null,
  overflowX: 'auto',
  overflowY: 'auto',
  initComponent: function() {
    var comp, elemCache, elemData, iframeUrl, myHeight, myMaxHeight, myName, myWidth, _ref;
    myName = this.cache._myProperties.name;
    elemCache = this.element.cache;
    elemData = elemCache != null ? (_ref = elemCache._myProperties) != null ? _ref.data : void 0 : void 0;
    if (elemData) {
      iframeUrl = elemData[myName];
    }
    myMaxHeight = this.maxHeight - 5;
    myHeight = this.height;
    myWidth = this.width - 10;
    comp = Ext.create('Ext.ux.IFrame', {
      height: myHeight,
      maxHeight: myMaxHeight,
      maxWidth: myWidth,
      src: iframeUrl
    });
    this.iframe = comp;
    this.items = [comp];
    Corefw.customapp.Main.mainEntry('iframeInit', this);
    this.callParent(arguments);
  },
  onRender: function() {
    this.callParent(arguments);
  }
});