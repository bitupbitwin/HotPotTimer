/** 计时状态机与时间格式化，对应 Flutter 版 SelectedHotpotItem 的推导逻辑 */

// 熟透后允许的"完美窗口"，超过后进入严重超时
const READY_WINDOW_SECONDS = 60;

const STATE = {
  IDLE: 'idle', // 未下锅：外圈黑色
  COUNTING: 'counting', // 煮熟中：外圈黄色闪烁
  READY: 'ready', // 完美熟透：外圈绿色呼吸
  OVERCOOKED: 'overcooked', // 严重超时：外圈红色高频闪烁
};

/**
 * 由下锅时间推导当前状态与剩余/超时秒数（外部受控模式，
 * 与 Flutter 版一致：状态永远由时间计算，杀进程恢复后依然准确）。
 */
function computeTiming(targetSeconds, startedAt, now) {
  if (!startedAt) {
    return { state: STATE.IDLE, elapsed: 0, remaining: 0, overtime: 0 };
  }
  const nowMs = now || Date.now();
  let elapsed = Math.floor((nowMs - startedAt) / 1000);
  if (elapsed < 0) elapsed = 0;

  const remaining = Math.max(0, targetSeconds - elapsed);
  const overtime = Math.max(0, elapsed - targetSeconds);

  let state = STATE.COUNTING;
  if (elapsed >= targetSeconds + READY_WINDOW_SECONDS) {
    state = STATE.OVERCOOKED;
  } else if (elapsed >= targetSeconds) {
    state = STATE.READY;
  }
  return { state, elapsed, remaining, overtime };
}

function formatSeconds(seconds) {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  if (m > 0) {
    return `${m}:${String(s).padStart(2, '0')}`;
  }
  return `${s}s`;
}

module.exports = { STATE, READY_WINDOW_SECONDS, computeTiming, formatSeconds };
