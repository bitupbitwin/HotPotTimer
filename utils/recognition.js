/**
 * 本地可运行的识别占位层：从图片路径与用户补充文字中按
 * 名称/分类/别名关键词匹配已收录食材。
 * 后续接入真实视觉 API 时，只需替换 recognize 的内部实现。
 * 对应 Flutter 版 FoodRecognitionService。
 */

function splitFoodNames(value) {
  return String(value || '')
    .split(/[,，、\s\n]+/)
    .map((name) => name.trim())
    .filter((name) => name.length > 0);
}

function itemKeys(item) {
  return [item.name, item.category, ...(item.aliases || [])]
    .map((key) => String(key).toLowerCase())
    .filter((key) => key.length > 0);
}

function matchesCatalog(name, catalog) {
  const lowerName = name.toLowerCase();
  return catalog.some((item) =>
    itemKeys(item).some((key) => key === lowerName || key.indexOf(lowerName) !== -1)
  );
}

/**
 * @param {string} imagePath 选图临时路径（真实 API 接入前仅参与关键词匹配）
 * @param {Array} catalog 全部食材（预设 + 自定义）
 * @param {string[]} userHints 用户补充的食材名
 * @returns {{ matchedItems: Array, unmatchedNames: string[] }}
 */
function recognize(imagePath, catalog, userHints) {
  const hints = userHints || [];
  const sourceText = [imagePath || '', ...hints].join(' ').toLowerCase();

  const matchedItems = catalog.filter((item) =>
    itemKeys(item).some((key) => sourceText.indexOf(key) !== -1)
  );

  const seen = {};
  const unmatchedNames = hints
    .reduce((acc, hint) => acc.concat(splitFoodNames(hint)), [])
    .filter((name) => !matchesCatalog(name, catalog))
    .filter((name) => (seen[name] ? false : (seen[name] = true)));

  return { matchedItems, unmatchedNames };
}

module.exports = { recognize, splitFoodNames, matchesCatalog };
