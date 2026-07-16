/**
 * 本地持久化：自定义食材 / 已点食材 / 忌口 / 自定义蘸料。
 * 全部使用微信本地缓存（wx.setStorageSync），不上传任何数据。
 */

const KEY_CUSTOM_ITEMS = 'hotpot_custom_items_v1';
const KEY_SELECTED_ITEMS = 'hotpot_selected_items_v1';
const KEY_TABOO = 'hotpot_taboo_v1';
const KEY_CUSTOM_SAUCES = 'hotpot_custom_sauces_v1';

function load(key, fallback) {
  try {
    const value = wx.getStorageSync(key);
    return value === '' || value == null ? fallback : value;
  } catch (e) {
    return fallback;
  }
}

function save(key, value) {
  try {
    wx.setStorageSync(key, value);
  } catch (e) {
    // 存储失败不阻断主流程
  }
}

module.exports = {
  loadCustomItems() {
    return load(KEY_CUSTOM_ITEMS, []);
  },
  saveCustomItems(items) {
    save(KEY_CUSTOM_ITEMS, items);
  },

  /** 已点食材：[{ item, quantity, startedAt(ms|null) }] */
  loadSelectedItems() {
    return load(KEY_SELECTED_ITEMS, []);
  },
  saveSelectedItems(items) {
    save(KEY_SELECTED_ITEMS, items);
  },

  loadTabooItems() {
    return load(KEY_TABOO, []);
  },
  saveTabooItems(items) {
    save(KEY_TABOO, items);
  },

  loadCustomSauces() {
    return load(KEY_CUSTOM_SAUCES, []);
  },
  saveCustomSauces(sauces) {
    save(KEY_CUSTOM_SAUCES, sauces);
  },
};
