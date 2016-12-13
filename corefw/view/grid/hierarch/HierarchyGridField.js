// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.hierarch.HierarchyGridField', {
  extend: 'Corefw.view.grid.ObjectGrid',
  xtype: 'corehierarchygrid',
  onRender: function() {
    this.callParent(arguments);
    this.grid.maxHeight = this.maxHeight - 10;
    this.grid.setHeight(this.maxHeight - 10);
  },
  generatePostData: function(expandedRowIndex, selectedRecord) {
    var cache, cm, item, postData, postItem, subGridItem, subGridWithIndex, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    postData = this.grid.generatePostData();
    cm = Corefw.util.Common;
    cache = cm.objectClone(this.cache);
    subGridWithIndex = {};
    _ref = cache._myProperties.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (!item.subGrid) {
        return postData;
      }
      subGridWithIndex[item.index] = item.subGrid;
    }
    _ref1 = postData.items;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      postItem = _ref1[_j];
      postItem.subGrid = subGridWithIndex[postItem.index];
      _ref2 = postItem.subGrid.items;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        subGridItem = _ref2[_k];
        if (selectedRecord && expandedRowIndex === postItem.index && subGridItem.index === selectedRecord.index) {
          subGridItem.selected = true;
        }
        delete subGridItem.messages;
      }
    }
    return postData;
  }
});
