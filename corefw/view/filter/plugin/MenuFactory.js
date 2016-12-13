// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.filter.plugin.MenuFactory', {
  extend: 'Ext.AbstractPlugin',
  alias: 'plugin.filtermenufactory',
  triggerEvent: 'itemdblclick',
  beforecreate: null,
  extraParams: null,
  menuInstances: {},
  init: function(client) {
    this.client = client;
    this.client.bindFilterStore = function(store) {
      return this.filterStore = store;
    };
    if (this.triggerEvent) {
      return this.client.on(this.triggerEvent, this.createHandler, this);
    }
  },
  createHandler: function() {
    var fn;
    if (!this.client.filterStore) {
      Corefw.Msg.alert('Error', 'Filter store is not bound, cannot create filter menu.');
      return;
    }
    if (this.beforecreate && !this.beforecreate.apply(this.client, arguments)) {
      return;
    }
    fn = this["on" + this.triggerEvent];
    if (fn) {
      return fn.apply(this, arguments);
    }
  },
  onitemdblclick: function(view, record, item, index, e, eOpts) {
    var extraParams, param;
    param = {
      isMeasure: record.isMeasure(),
      dataTypeString: record.get('dataTypeString'),
      pathString: record.get('path'),
      showXY: [25, e.getY() + 10],
      itemName: record.get('text'),
      underCollection: record.get('underCollection'),
      repetitiveRatio: record.get('repetitiveRatio')
    };
    extraParams = this.extraParams;
    if (Ext.isFunction(extraParams)) {
      extraParams = extraParams.apply(this.client, arguments);
    }
    return this.showFilterMenu(param, extraParams);
  },
  showFilterMenu: function(param, extraParams) {
    var dataTypeString, filterStore, isDate, isMeasure, isTimeMark, menu, pathString, repetitiveRatio, showXY, triggerOwner, underCollection;
    isMeasure = param.isMeasure;
    dataTypeString = param.dataTypeString;
    pathString = param.pathString;
    showXY = param.showXY;
    underCollection = param.underCollection;
    triggerOwner = param.triggerOwner;
    repetitiveRatio = param.repetitiveRatio;
    menu = void 0;
    filterStore = this.client.filterStore;
    isTimeMark = filterStore.isTimeMarkPath(pathString) || filterStore.isTimeMarkCriteriaPath(pathString);
    isDate = dataTypeString === 'date';
    if (underCollection) {
      menu = this.getMenu('Corefw.view.filter.menu.Collection');
    } else if (isTimeMark) {
      menu = this.getMenu('Corefw.view.filter.menu.TimeMark');
    } else if (isDate) {
      menu = this.getMenu('Corefw.view.filter.menu.Date');
    } else if (Ext.Array.contains(["int", "float"], dataTypeString)) {
      menu = this.getMenu('Corefw.view.filter.menu.Number');
    } else {
      menu = this.getMenu('Corefw.view.filter.menu.String');
      menu.setCurrentColumnPath(pathString);
    }
    Ext.apply(menu, {
      criteriaStore: filterStore
    });
    menu.clearMenu();
    menu.setFilterMenuComboStore(menu, pathString, extraParams);
    if (param.triggerOwner instanceof CorefwFilterModel) {
      menu.setRecord(param.triggerOwner);
    } else if (param.record instanceof CorefwFilterModel) {
      menu.setRecord(param.record);
    }
    menu.setFilterPath(pathString);
    menu.setItemName(param.itemName ? param.itemName : '');
    menu.dataTypeString = dataTypeString;
    menu.triggerOwner = triggerOwner;
    menu.showAt(showXY);
    return menu.repetitiveRatio = repetitiveRatio;
  },
  getMenu: function(menuType) {
    if (!this.menuInstances[menuType]) {
      this.menuInstances[menuType] = Ext.create(menuType);
    }
    return this.menuInstances[menuType];
  },
  destroy: function() {
    var menu, menuType, _ref, _results;
    _ref = this.menuInstances;
    _results = [];
    for (menuType in _ref) {
      menu = _ref[menuType];
      _results.push(menu.destroy());
    }
    return _results;
  }
});
