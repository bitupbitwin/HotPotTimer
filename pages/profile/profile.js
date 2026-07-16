const store = require('../../utils/store');

const FEEDBACK_EMAIL = 'jingyuzhang053@gmail.com';
const VERSION = '1.0.0';

Page({
  data: {
    tabooItems: [],
    version: VERSION,
    email: FEEDBACK_EMAIL,
    howToDialog: false,
    feedbackDialog: false,
  },

  onShow() {
    this.setData({ tabooItems: store.loadTabooItems() });
  },

  goSeasoning() {
    wx.switchTab({ url: '/pages/seasoning/seasoning' });
  },

  openHowTo() {
    this.setData({ howToDialog: true });
  },

  closeHowTo() {
    this.setData({ howToDialog: false });
  },

  openFeedback() {
    this.setData({ feedbackDialog: true });
  },

  closeFeedback() {
    this.setData({ feedbackDialog: false });
  },

  copyEmail() {
    wx.setClipboardData({
      data: FEEDBACK_EMAIL,
      success: () => {
        wx.showToast({ title: '邮箱已复制', icon: 'none' });
      },
    });
  },

  goPrivacy() {
    wx.navigateTo({ url: '/pages/privacy/privacy' });
  },
});
