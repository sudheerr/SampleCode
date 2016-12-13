// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.plugin.BufferedSelect', {
  extend: 'Ext.grid.plugin.BufferedRenderer',
  alias: 'plugin.corebufferedsel',
  init: function(grid) {
    this.grid = grid;
    return this.methodIntercept(grid);
  },
  methodIntercept: function(grid) {
    var postGeneratePostData, _generatePagingPostData, _generatePostData;
    _generatePostData = grid.generatePostData;
    _generatePagingPostData = grid.generatePagingPostData;
    postGeneratePostData = this.generatePostData;
    grid.generatePostData = function() {
      var postData;
      postData = _generatePostData.apply(grid, arguments);
      return postGeneratePostData.call(grid, postData);
    };
    return grid.generatePagingPostData = function() {
      var postData;
      postData = _generatePagingPostData.apply(grid, arguments);
      return postGeneratePostData.call(grid, postData);
    };
  },
  generatePostData: function(postData) {
    var bufferedPostData, gridProps, selColumn;
    selColumn = this.down('coreselectcolumn');
    if (selColumn) {
      return Ext.apply(selColumn.generatePostData(), postData);
    } else {
      gridProps = this.cache._myProperties;
      bufferedPostData = {
        selectedAll: gridProps.selectedAll,
        selectAllScope: gridProps.selectAllScope,
        deSelectingAll: false
      };
      return Ext.apply(bufferedPostData, postData);
    }
  }
});