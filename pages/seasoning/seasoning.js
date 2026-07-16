const { TABOO_OPTIONS, DEFAULT_SAUCES } = require('../../utils/sauces');
const store = require('../../utils/store');

Page({
  data: {
    tabooOptions: [],
    defaultSauces: [],
    customSauces: [],
    addDialog: { visible: false, name: '', ingredients: '' },
  },

  tabooItems: [],
  customSauceList: [],

  onShow() {
    this.tabooItems = store.loadTabooItems();
    this.customSauceList = store.loadCustomSauces();
    this.refresh();
  },

  refresh() {
    const taboo = this.tabooItems;
    const decorate = (sauce) => ({
      ...sauce,
      hasTaboo: sauce.ingredients.some((ing) => taboo.indexOf(ing) !== -1),
      ingredientRows: sauce.ingredients.map((name) => ({
        name,
        isTaboo: taboo.indexOf(name) !== -1,
      })),
    });

    this.setData({
      tabooOptions: TABOO_OPTIONS.map((name) => ({
        name,
        selected: taboo.indexOf(name) !== -1,
      })),
      defaultSauces: DEFAULT_SAUCES.map(decorate),
      customSauces: this.customSauceList.map(decorate),
    });
  },

  onToggleTaboo(e) {
    const name = e.currentTarget.dataset.name;
    const index = this.tabooItems.indexOf(name);
    if (index === -1) {
      this.tabooItems.push(name);
    } else {
      this.tabooItems.splice(index, 1);
    }
    store.saveTabooItems(this.tabooItems);
    this.refresh();
  },

  onOpenAdd() {
    this.setData({ addDialog: { visible: true, name: '', ingredients: '' } });
  },

  onAddNameInput(e) {
    this.setData({ 'addDialog.name': e.detail.value });
  },

  onAddIngredientsInput(e) {
    this.setData({ 'addDialog.ingredients': e.detail.value });
  },

  onAddCancel() {
    this.setData({ 'addDialog.visible': false });
  },

  onAddSave() {
    const name = this.data.addDialog.name.trim();
    const ingredients = this.data.addDialog.ingredients
      .split(/[，,]/)
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    if (!name || ingredients.length === 0) {
      wx.showToast({ title: '请填写名称和食材', icon: 'none' });
      return;
    }
    this.customSauceList.push({
      id: `custom_${Date.now()}`,
      name,
      tag: '自定义',
      description: '',
      ingredients,
      isCustom: true,
    });
    store.saveCustomSauces(this.customSauceList);
    this.setData({ 'addDialog.visible': false });
    this.refresh();
  },

  onRemoveSauce(e) {
    const id = e.currentTarget.dataset.id;
    this.customSauceList = this.customSauceList.filter((s) => s.id !== id);
    store.saveCustomSauces(this.customSauceList);
    this.refresh();
  },
});
