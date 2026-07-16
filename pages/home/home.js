const { CATEGORIES, DEFAULT_ITEMS } = require('../../utils/items');
const store = require('../../utils/store');
const feedback = require('../../utils/feedback');
const recognition = require('../../utils/recognition');
const { STATE, computeTiming, formatSeconds } = require('../../utils/util');

Page({
  data: {
    categories: CATEGORIES,
    selectedCategory: CATEGORIES[0],
    selectedCount: 0,
    menuItems: [],
    selectedCards: [],
    // 弹窗状态
    hintDialog: { visible: false, value: '' },
    confirmDialog: { visible: false, items: [] },
    customDialog: { visible: false, name: '', seconds: '60' },
    managerDialog: { visible: false, items: [] },
  },

  // ------- 非渲染态（挂在 this 上，避免频繁 setData）-------
  customItems: [],
  selectedItems: {}, // id -> { item, quantity, startedAt }
  lastStates: {}, // 上一秒各食材状态，用于检测跃迁触发提示音/震动
  customSeed: 0,
  ticker: null,
  pickedImagePath: '',
  missingQueue: [], // 识别后未收录、待补录的食材名队列

  onLoad() {
    this.customItems = store.loadCustomItems();
    // 取现有 custom_N 的最大 N，删除后重启不会复用旧 id 导致冲突
    this.customSeed = this.customItems.reduce((maxSeed, item) => {
      const match = /^custom_(\d+)$/.exec(item.id);
      const n = match ? parseInt(match[1], 10) : 0;
      return n > maxSeed ? n : maxSeed;
    }, 0);

    const selected = store.loadSelectedItems();
    this.selectedItems = {};
    selected.forEach((entry) => {
      if (entry && entry.item && entry.item.id) {
        this.selectedItems[entry.item.id] = entry;
      }
    });
    if (selected.length > 0) {
      this.setData({ selectedCategory: '已点' });
    }
    this.refresh();
  },

  onShow() {
    this.startTicker();
    this.refresh();
  },

  onHide() {
    this.stopTicker();
  },

  onUnload() {
    this.stopTicker();
  },

  startTicker() {
    this.stopTicker();
    this.ticker = setInterval(() => {
      const hasRunning = Object.keys(this.selectedItems).some(
        (id) => this.selectedItems[id].startedAt
      );
      if (hasRunning) {
        this.checkStateTransitions();
        this.refresh();
      }
    }, 1000);
  },

  stopTicker() {
    if (this.ticker) {
      clearInterval(this.ticker);
      this.ticker = null;
    }
  },

  // ------- 数据派生 -------

  catalog() {
    return [...DEFAULT_ITEMS, ...this.customItems];
  },

  visibleItems() {
    const category = this.data.selectedCategory;
    if (category === '全部') return this.catalog();
    if (category === '推荐') return DEFAULT_ITEMS.slice(0, 10);
    return this.catalog().filter((item) => item.category === category);
  },

  sortRank(entry, timing) {
    // 超时 > 将熟 > 计时中 > 未开始（与 Flutter 版 _selectedSortRank 一致）
    if (!entry.startedAt) return entry.item.targetSeconds + 100000;
    switch (timing.state) {
      case STATE.OVERCOOKED:
        return -100000 - timing.overtime;
      case STATE.READY:
        return -50000 - timing.overtime;
      case STATE.COUNTING:
        return timing.remaining;
      default:
        return entry.item.targetSeconds + 100000;
    }
  },

  refresh() {
    const now = Date.now();
    const categories = this.customItems.length
      ? [...CATEGORIES, '自定义']
      : CATEGORIES;
    const selectedCount = Object.keys(this.selectedItems).length;

    let patch = { categories, selectedCount };

    if (this.data.selectedCategory === '已点') {
      const entries = Object.keys(this.selectedItems).map((id) => {
        const entry = this.selectedItems[id];
        const timing = computeTiming(entry.item.targetSeconds, entry.startedAt, now);
        return { entry, timing };
      });
      entries.sort((a, b) => {
        const rankDiff = this.sortRank(a.entry, a.timing) - this.sortRank(b.entry, b.timing);
        if (rankDiff !== 0) return rankDiff;
        return a.entry.item.targetSeconds - b.entry.item.targetSeconds;
      });
      patch.selectedCards = entries.map(({ entry, timing }) => {
        const item = entry.item;
        let timeText = '';
        let label = '';
        if (timing.state === STATE.COUNTING) {
          timeText = formatSeconds(timing.remaining);
        } else if (timing.state === STATE.READY) {
          timeText = formatSeconds(timing.overtime);
          label = '可吃!';
        } else if (timing.state === STATE.OVERCOOKED) {
          timeText = formatSeconds(timing.overtime);
          label = '太老了!';
        }
        return {
          id: item.id,
          name: item.name,
          emoji: item.emoji || '',
          imagePath: item.imagePath || '',
          quantity: entry.quantity,
          state: timing.state,
          timeText,
          label,
          targetText: formatSeconds(item.targetSeconds),
        };
      });
    } else {
      patch.menuItems = this.visibleItems().map((item) => {
        const entry = this.selectedItems[item.id];
        return {
          id: item.id,
          name: item.name,
          emoji: item.emoji || '',
          imagePath: item.imagePath || '',
          selected: !!entry,
          quantity: entry ? entry.quantity : 0,
        };
      });
    }

    this.setData(patch);
  },

  /**
   * 检测每个已点食材的状态跃迁，触发对应提示音与震动。
   * 状态由时间推导，提醒必须在这里驱动（与 Flutter 版一致）。
   */
  checkStateTransitions() {
    const now = Date.now();
    Object.keys(this.selectedItems).forEach((id) => {
      const entry = this.selectedItems[id];
      const timing = computeTiming(entry.item.targetSeconds, entry.startedAt, now);
      const current = timing.state;
      const previous = this.lastStates[id];
      if (previous && current !== previous) {
        if (current === STATE.READY) {
          feedback.perfectAlarm();
        } else if (current === STATE.OVERCOOKED) {
          feedback.urgentAlarm();
        }
      } else if (
        current === STATE.OVERCOOKED &&
        timing.overtime > 60 &&
        timing.overtime % 15 === 0
      ) {
        // 持续超时，周期性催促
        feedback.urgentAlarm();
      }
      this.lastStates[id] = current;
    });
    Object.keys(this.lastStates).forEach((id) => {
      if (!this.selectedItems[id]) delete this.lastStates[id];
    });
  },

  persistSelected() {
    store.saveSelectedItems(
      Object.keys(this.selectedItems).map((id) => this.selectedItems[id])
    );
  },

  // ------- 交互 -------

  onSelectCategory(e) {
    this.setData({ selectedCategory: e.currentTarget.dataset.category }, () =>
      this.refresh()
    );
  },

  findItem(id) {
    return this.catalog().find((item) => item.id === id);
  },

  onToggleItem(e) {
    const id = e.currentTarget.dataset.id;
    if (this.selectedItems[id]) {
      delete this.selectedItems[id];
    } else {
      const item = this.findItem(id);
      if (!item) return;
      this.selectedItems[id] = { item, quantity: 1, startedAt: null };
    }
    this.persistSelected();
    this.refresh();
  },

  addItems(items) {
    items.forEach((item) => {
      const entry = this.selectedItems[item.id];
      // 已存在时仅叠加数量，保留 startedAt，避免清掉正在走的计时
      this.selectedItems[item.id] = entry
        ? { ...entry, quantity: entry.quantity + 1 }
        : { item, quantity: 1, startedAt: null };
    });
    this.persistSelected();
    this.refresh();
  },

  onRemoveSelected(e) {
    const id = e.currentTarget.dataset.id;
    delete this.selectedItems[id];
    this.persistSelected();
    this.refresh();
  },

  onTimerTap(e) {
    const id = e.currentTarget.dataset.id;
    const entry = this.selectedItems[id];
    if (!entry) return;

    const starting = !entry.startedAt;
    if (starting) {
      feedback.tapFeedback();
    } else {
      feedback.stop();
    }
    this.selectedItems[id] = {
      ...entry,
      startedAt: starting ? Date.now() : null,
    };
    this.lastStates[id] = starting ? STATE.COUNTING : STATE.IDLE;
    this.persistSelected();
    this.refresh();
  },

  onClearAll() {
    if (!this.data.selectedCount) return;
    wx.showModal({
      title: '清空已点',
      content: '将移除所有已点食材并停止计时，确定吗？',
      confirmText: '清空',
      confirmColor: '#FFCC00',
      success: (res) => {
        if (!res.confirm) return;
        feedback.stop();
        this.selectedItems = {};
        this.lastStates = {};
        this.persistSelected();
        this.refresh();
      },
    });
  },

  // ------- 照片识别 -------

  onPickImage() {
    wx.chooseMedia({
      count: 1,
      mediaType: ['image'],
      sourceType: ['album'],
      success: (res) => {
        this.pickedImagePath = res.tempFiles[0].tempFilePath;
        this.setData({ hintDialog: { visible: true, value: '' } });
      },
    });
  },

  onHintInput(e) {
    this.setData({ 'hintDialog.value': e.detail.value });
  },

  onHintCancel() {
    this.setData({ hintDialog: { visible: false, value: '' } });
  },

  onHintConfirm() {
    const hintText = this.data.hintDialog.value;
    this.setData({ hintDialog: { visible: false, value: '' } });

    const userNames = recognition.splitFoodNames(hintText);
    const result = recognition.recognize(this.pickedImagePath, this.catalog(), userNames);

    this.missingQueue = [];
    if (result.matchedItems.length === 0 && userNames.length === 0) {
      this.missingQueue.push('未识别食材');
    }
    this.missingQueue.push(...result.unmatchedNames);

    this.setData({
      confirmDialog: {
        visible: true,
        items: result.matchedItems.map((item) => ({
          id: item.id,
          name: item.name,
          checked: true,
          subtitle: `${item.category} · 推荐 ${formatSeconds(item.targetSeconds)}`,
        })),
      },
    });
  },

  onConfirmToggle(e) {
    const index = e.currentTarget.dataset.index;
    this.setData({
      [`confirmDialog.items[${index}].checked`]:
        !this.data.confirmDialog.items[index].checked,
    });
  },

  onConfirmCancel() {
    this.missingQueue = [];
    this.setData({ confirmDialog: { visible: false, items: [] } });
  },

  onConfirmOk() {
    const checked = this.data.confirmDialog.items.filter((row) => row.checked);
    const items = checked
      .map((row) => this.findItem(row.id))
      .filter((item) => !!item);
    const matchedTotal = this.data.confirmDialog.items.length;
    this.setData({ confirmDialog: { visible: false, items: [] } });

    this.addItems(items);

    if (this.missingQueue.length > 0) {
      this.processMissingQueue();
    } else {
      wx.showToast({
        title: `已加入 ${matchedTotal} 个识别到的食材`,
        icon: 'none',
      });
    }
  },

  /** 逐个弹出"未收录食材"补录框 */
  processMissingQueue() {
    if (this.missingQueue.length === 0) return;
    const name = this.missingQueue.shift();
    this.setData({
      customDialog: {
        visible: true,
        name: name === '未识别食材' ? '' : name,
        seconds: '60',
      },
    });
  },

  // ------- 自定义食材 -------

  onOpenManager() {
    this.setData({
      managerDialog: {
        visible: true,
        items: this.customItems.map((item) => ({
          id: item.id,
          name: item.name,
          targetText: formatSeconds(item.targetSeconds),
        })),
      },
    });
  },

  onManagerClose() {
    this.setData({ 'managerDialog.visible': false });
  },

  onManagerAdd() {
    this.setData({
      'managerDialog.visible': false,
      customDialog: { visible: true, name: '', seconds: '60' },
    });
  },

  onManagerDelete(e) {
    const id = e.currentTarget.dataset.id;
    const removed = this.customItems.find((item) => item.id === id);
    this.customItems = this.customItems.filter((item) => item.id !== id);
    if (removed) delete this.selectedItems[id];
    store.saveCustomItems(this.customItems);
    this.persistSelected();
    if (this.data.selectedCategory === '自定义' && this.customItems.length === 0) {
      this.setData({ selectedCategory: '全部' });
    }
    this.setData({
      'managerDialog.items': this.customItems.map((item) => ({
        id: item.id,
        name: item.name,
        targetText: formatSeconds(item.targetSeconds),
      })),
    });
    this.refresh();
  },

  onCustomNameInput(e) {
    this.setData({ 'customDialog.name': e.detail.value });
  },

  onCustomSecondsInput(e) {
    this.setData({ 'customDialog.seconds': e.detail.value });
  },

  onCustomCancel() {
    this.setData({ 'customDialog.visible': false });
    this.processMissingQueue();
  },

  onCustomSave() {
    const name = this.data.customDialog.name.trim();
    const seconds = parseInt(this.data.customDialog.seconds, 10);
    if (!name || !seconds || seconds <= 0) {
      wx.showToast({ title: '请填写名字和秒数', icon: 'none' });
      return;
    }
    this.customSeed += 1;
    const item = {
      id: `custom_${this.customSeed}`,
      name,
      category: '自定义',
      targetSeconds: seconds,
      aliases: [],
      emoji: '',
      imagePath: '',
    };
    // 同名覆盖旧配置
    this.customItems = this.customItems.filter((it) => it.name !== name);
    this.customItems.push(item);
    store.saveCustomItems(this.customItems);

    this.setData({ 'customDialog.visible': false });
    this.addItems([item]);
    this.processMissingQueue();
  },
});
