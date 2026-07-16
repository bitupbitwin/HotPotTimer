/**
 * 震动 + 声效统一反馈服务，对应 Flutter 版 FeedbackService。
 * 小程序端用 wx.vibrateShort/vibrateLong 替代 vibration 插件，
 * 用 InnerAudioContext 播放 assets/sounds 下的提示音。
 */

const audio = wx.createInnerAudioContext({ useWebAudioImplement: false });
audio.autoplay = false;

let pendingVibrations = [];

function play(src) {
  try {
    audio.stop();
    audio.src = src;
    audio.play();
  } catch (e) {
    // 静默失败：无声也不影响计时
  }
}

function vibrate(type) {
  try {
    wx.vibrateShort({ type });
  } catch (e) {}
}

function clearPendingVibrations() {
  pendingVibrations.forEach((timer) => clearTimeout(timer));
  pendingVibrations = [];
}

/** 按 pattern（毫秒间隔）触发多次短震动，模拟 Vibration.vibrate(pattern) */
function vibratePattern(type, delays) {
  clearPendingVibrations();
  vibrate(type);
  let acc = 0;
  delays.forEach((delay) => {
    acc += delay;
    pendingVibrations.push(setTimeout(() => vibrate(type), acc));
  });
}

module.exports = {
  /** 下锅时轻触反馈 + 上升音效 */
  tapFeedback() {
    vibrate('light');
    play('/assets/sounds/start.wav');
  },

  /** 煮熟瞬间：叮咚提示音 + 间歇震动 */
  perfectAlarm() {
    vibratePattern('medium', [500]);
    play('/assets/sounds/ready.wav');
  },

  /** 超时报警：急促三连音 + 连续震动 */
  urgentAlarm() {
    vibratePattern('heavy', [300, 300]);
    play('/assets/sounds/overcooked.wav');
  },

  stop() {
    clearPendingVibrations();
    try {
      audio.stop();
    } catch (e) {}
  },
};
