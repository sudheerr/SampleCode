// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.filter.CriteriaView', {
  extend: 'Corefw.view.filter.ViewBase',
  alias: 'widget.filterCriteriaView',
  requires: ['Corefw.view.filter.plugin.FilterViewDD', 'Corefw.view.filter.plugin.MenuFactory'],
  enabledPlugins: ['filterviewdragdrop', 'filtermenufactory'],
  allPlugins: {
    filterviewdragdrop: {
      ptype: 'filterviewdragdrop',
      enableDrag: true
    },
    filtermenufactory: {
      ptype: 'filtermenufactory',
      triggerEvent: null
    },
    gridviewdragdrop: {
      ptype: 'gridviewdragdrop',
      enableDrag: false,
      ddGroup: 'treeDrop'
    }
  },
  mixins: ['Corefw.mixin.Sharable'],
  deferEmptyText: false,
  maxHeight: 220,
  autoScroll: true,
  initComponent: function() {
    var plugin, _i, _len, _ref;
    this.plugins = [];
    _ref = this.enabledPlugins;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      plugin = _ref[_i];
      this.plugins.push(this.allPlugins[plugin]);
    }
    this.callParent(arguments);
    return this.on('afterrender', function() {
      return this.bindFilterStore(this.getStore());
    });
  },
  afterClickFilterIcon: function(record, item, position) {
    var criteria, param, underCollection;
    criteria = record.get('operandsString');
    underCollection = false;
    param = void 0;
    criteria = criteria.length === 0 ? [''] : criteria;
    if (criteria[0].operator) {
      underCollection = true;
    }
    param = {
      isMeasure: record.get('measure'),
      dataTypeString: record.get('dataTypeString'),
      pathString: record.get('pathString'),
      itemName: record.get('itemName'),
      showXY: position,
      underCollection: underCollection,
      triggerOwner: record
    };
    this.findPlugin('filtermenufactory').showFilterMenu(param, {
      domainName: this.getShared('domainName')
    });
  }
});