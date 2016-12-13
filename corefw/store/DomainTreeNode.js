// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.store.DomainTreeNode', {
  extend: 'Ext.data.TreeStore',
  requires: ['Corefw.model.DomainTreeNode'],
  model: 'Corefw.model.DomainTreeNode',
  autoLoad: false,
  clearOnLoad: true,
  constructor: function(config) {
    this.currentSearchPath = null;
    this.domainName = null;
    this.sendRequest = true;
    this.callParent(arguments);
  },
  proxy: {
    type: 'rest',
    appendId: false,
    actionMethods: {
      read: 'POST'
    },
    url: 'api/pivot/domainTree',
    reader: {
      type: 'json'
    }
  },
  listeners: {
    beforeload: function(me, operation, eOpts) {
      var isCallForFocus, node, nodeId, p, path, search_s;
      console.time('Tree load finished');
      nodeId = void 0;
      isCallForFocus = operation.params.isCallForFocus;
      path = operation.params.path;
      this.currentSearchPath = path;
      if (operation === null) {
        return false;
      }
      node = operation.node;
      search_s = Ext.String.trim(this.ownerTree.down('combo').rawValue);
      if (search_s.length > 2) {
        this.sendRequest = true;
      } else {
        search_s = '';
      }
      if (node && node.data) {
        console.log('load children for node:' + node.data.text);
        nodeId = node.data.path;
      }
      if (node.isRoot()) {
        nodeId = null;
        me.ownerTree.setLoading('Loading');
      }
      p = {
        getNodesMD: function() {
          return 'All';
        },
        getDepth: function() {
          return '5';
        },
        getProminence: function() {
          return 'Med';
        },
        getFilterBy: function() {
          return 'NAME';
        }
      };
      operation.params = {
        domainName: this.domainName,
        uipath: this.uipath,
        parentPathString: nodeId,
        searchString: '',
        searchMeasureDimension: p.getNodesMD(),
        searchDepth: p.getDepth().toString(),
        searchProminence: p.getProminence(),
        searchFilterBy: p.getFilterBy(),
        isCallForFocus: isCallForFocus,
        path: path
      };
      return true;
    },
    load: function(th, node, records, successful, eOpts) {
      var breakFlag, curLength, currentChildNodes, currentRoot, f_val, i, loc, me, path, root, substring, tc, v;
      console.timeEnd('Tree load finished');
      me = th;
      tc = void 0;
      if (successful) {
        f_val = Ext.String.trim(me.ownerTree.down('combo').rawValue);
        if (f_val.length > 2) {
          this.applySnapshot(f_val);
          tc = this.getLeafCount(me.getRootNode());
          Ext.Array.each(me.getRootNode().childNodes, (function(item, index) {
            if (index === 0) {
              this.expandNode(item, true);
              return false;
            }
          }), me.ownerTree);
          if (th.currentSearchPath) {
            path = th.currentSearchPath;
            root = th.getRootNode();
            currentRoot = root.childNodes[1];
            breakFlag = false;
            v = me.ownerTree;
            while (!breakFlag) {
              if (currentRoot) {
                v.expandNode(currentRoot, false);
                currentChildNodes = currentRoot.childNodes;
                i = 0;
                while (i < currentChildNodes.length) {
                  if (currentChildNodes[i].get('leaf')) {
                    i++;
                    continue;
                  }
                  if (path.indexOf(currentChildNodes[i].get('path')) !== -1) {
                    i++;
                    continue;
                  }
                  if (path === currentChildNodes[i].get('path')) {
                    v.expandNode(currentChildNodes[i], false);
                    breakFlag = true;
                    break;
                  } else {
                    loc = path.indexOf(currentChildNodes[i].get('path'));
                    curLength = currentChildNodes[i].get('path').length;
                    substring = path.substring(loc + curLength);
                    if (substring.charAt(0) === '/') {
                      v.expandNode(currentChildNodes[i], false);
                    } else {
                      i++;
                      continue;
                    }
                  }
                  currentRoot = currentChildNodes[i];
                  break;
                  i++;
                }
              }
              if (breakFlag) {
                break;
              }
            }
          }
        } else {
          this.sendRequest = false;
          delete this.snapshot;
          Ext.Array.each(me.getRootNode().childNodes, (function(item, index) {
            this.expandNode(item, false);
          }), me.ownerTree);
        }
      } else {
        Corefw.Msg.alert('Error', 'Tree data load error.');
      }
      me.ownerTree.setLoading(false);
    }
  },
  getLeafCount: function(Mynode) {
    var recurFunc, tc;
    tc = 0;
    recurFunc = function(Node) {
      if (Node.hasChildNodes()) {
        tc += Node.childNodes.length;
        Node.eachChild(recurFunc);
      } else {
        return 0;
      }
    };
    if (Mynode.hasChildNodes()) {
      tc += Mynode.childNodes.length;
      Mynode.eachChild(recurFunc);
    }
    return tc;
  },
  applyFilters: function(filters) {
    var decoded, flattened, fn, i, item, items, length, me, node, resultNodes, root, visibleNodes;
    me = this;
    decoded = me.decodeFilters(filters);
    i = 0;
    length = decoded.length;
    node = void 0;
    visibleNodes = [];
    resultNodes = [];
    root = me.getRootNode();
    flattened = me.tree.flatten();
    items = void 0;
    item = void 0;
    fn = void 0;

    /**
    		 * @property {Ext.util.MixedCollection} snapshot
    		 * A pristine (unfiltered) collection of the records in this store. This is used to reinstate
    		 * records when a filter is removed or changed
     */
    me.snapshot = me.snapshot || me.getRootNode().copy(null, true);
    i = 0;
    while (i < length) {
      me.filters.replace(decoded[i]);
      i++;
    }
    items = me.filters.items;
    length = items.length;
    i = 0;
    while (i < length) {
      item = items[i];
      fn = item.filterFn || function(item) {
        return item.get(item.property) === item.value;
      };
      visibleNodes = Ext.Array.merge(visibleNodes, Ext.Array.filter(flattened, fn));
      i++;
    }
    length = visibleNodes.length;
    i = 0;
    while (i < length) {
      node = visibleNodes[i];
      node.bubble(function(n) {
        if (n.parentNode) {
          resultNodes.push(n.parentNode);
        } else {
          return false;
        }
      });
      i++;
    }
    visibleNodes = Ext.Array.merge(visibleNodes, resultNodes);
    resultNodes = [];
    root.cascadeBy(function(n) {
      if (!Ext.Array.contains(visibleNodes, n)) {
        resultNodes.push(n);
      }
    });
    length = resultNodes.length;
    i = 0;
    while (i < length) {
      resultNodes[i].remove();
      i++;
    }
  },
  filter: function(filters, value) {
    this.applyFilters(filters);
  },
  applySnapshot: function(f_val) {
    var me;
    me = this;
    delete me.snapshot;
    delete me.searchS;
    me.searchS = f_val;
    me.snapshot = me.getRootNode().copy(null, true);
  },
  clearFilter: function(suppressEvent) {
    var me;
    me = this;
    me.filters.clear();
    if (me.isFiltered()) {
      me.setRootNode(me.snapshot);
      delete me.snapshot;
    }
  },
  isFiltered: function() {
    var snapshot;
    snapshot = this.snapshot;
    return !!snapshot && snapshot !== this.getRootNode();
  }
});