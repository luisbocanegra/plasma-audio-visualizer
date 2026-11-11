
function mergeConfigs(sourceConfig, newConfig) {
  for (var key in sourceConfig) {
    if (Array.isArray(sourceConfig[key])) {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = sourceConfig[key].slice();
      }
    } else if (typeof sourceConfig[key] === "object" && sourceConfig[key] !== null) {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = {};
      }
      mergeConfigs(sourceConfig[key], newConfig[key]);
    } else {
      if (!newConfig.hasOwnProperty(key)) {
        newConfig[key] = sourceConfig[key];
      }
    }
  }
  return newConfig;
}

function getRandomColor(h, s, l, a) {
  h = h ?? Math.random();
  s = s ?? Math.random();
  l = l ?? Math.random();
  a = a ?? 1.0;
  return Qt.hsla(h, s, l, a);
}

function scaleSaturation(color, saturation) {
  return Qt.hsla(color.hslHue, saturation, color.hslLightness, color.a);
}

function scaleLightness(color, lightness) {
  return Qt.hsla(color.hslHue, color.hslSaturation, lightness, color.a);
}

function adjustColor(color, saturationEnabled, saturation, lightnessEnabled, lightness, alpha) {
  if (saturationEnabled) {
    color = scaleSaturation(color, saturation);
  }
  if (lightnessEnabled) {
    color = scaleLightness(color, lightness);
  }
  if (alpha !== 1.0) {
    color = Qt.hsla(color.hslHue, color.hslSaturation, color.hslLightness, alpha);
  }
  return color;
}


function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16),
    }
    : null;
}

function rgbToQtColor(rgb) {
  return Qt.rgba(rgb.r / 255, rgb.g / 255, rgb.b / 255, 1);
}

function hexToQtColor(hex) {
  let rgb = hexToRgb(hex);
  return rgbToQtColor(rgb);
}

function buildCanvasGradient(ctx, smooth, gradientStops, orientation, height, width, circleMode = false) {
  let gradient;
  // FIXME: maybe guard against this earlier
  if (!ctx || height < 1 || width < 1 || !gradientStops || !gradientStops.length) {
    return gradient;
  }
  if (circleMode) {
    const centerX = width / 2;
    const centerY = height / 2;
    const radius = Math.min(width, height) / 2;
    gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);
  } else if (orientation === 0) {
    gradient = ctx.createLinearGradient(0, 0, width, 0);
  } else {
    gradient = ctx.createLinearGradient(0, height, 0, 0);
  }
  for (let i = 0; i < gradientStops.length; i++) {
    const stop = gradientStops[i];
    let color = stop.color ?? stop;
    let position;
    if (smooth) {
      position = stop.position ?? (gradientStops.length > 1 ? (i / (gradientStops.length - 1)) : 0);
    } else {
      position = stop.position ?? (i / gradientStops.length);
    }
    gradient.addColorStop(position, color);
    if (!smooth && i > 0 && i < gradientStops.length) {
      let prevStop = gradientStops[i - 1];
      let prevColor = prevStop.color ?? prevStop;
      gradient.addColorStop(Math.max(position - 0.0001, 0), prevColor);
    }
  }
  return gradient;
}

function getColors(barColorsCfg, barCount, themeColor) {
  const saturationEnabled = barColorsCfg.saturationEnabled;
  const saturation = barColorsCfg.saturation;
  const lightnessEnabled = barColorsCfg.lightnessEnabled;
  const lightness = barColorsCfg.lightness;
  const alpha = barColorsCfg.alpha;
  const colorSourceType = barColorsCfg.sourceType;
  const reverseList = barColorsCfg.reverseList;
  const hueStart = barColorsCfg.hueStart;
  const hueEnd = barColorsCfg.hueEnd;

  let colors = [];
  let color = null;
  if (colorSourceType === Enum.ColorSourceType.Custom) {
    color = hexToQtColor(barColorsCfg.custom);
  } else if (colorSourceType === Enum.ColorSourceType.SystemTheme) {
    color = themeColor;
  }
  if (color) {
    colors.push(adjustColor(color, saturationEnabled, saturation, lightnessEnabled, lightness, alpha));
  }
  if (colorSourceType === Enum.ColorSourceType.List) {
    colors = barColorsCfg.list.map(c => adjustColor(hexToQtColor(c), saturationEnabled, saturation, lightnessEnabled, lightness, alpha));
  }
  if (colorSourceType === Enum.ColorSourceType.Random) {
    for (let i = 0; i < barCount; i++) {
      colors.push(adjustColor(getRandomColor(null, 0.8, 0.7, null), saturationEnabled, saturation, lightnessEnabled, lightness, alpha));
    }
  }
  if (colorSourceType === Enum.ColorSourceType.Hue) {
    const start = hueStart / 360;
    const end = hueEnd / 360;
    for (let i = 0; i < barCount; i++) {
      let c = Qt.hsla(start + ((i / barCount) * (end - start)), 0.8, 0.7, 1.0);
      colors.push(adjustColor(c, saturationEnabled, saturation, lightnessEnabled, lightness, alpha));
    }
  }
  if (reverseList) {
    let reversed = [];
    for (let i = colors.length - 1; i >= 0; i--) {
      reversed.push(colors[i]);
    }
    colors = reversed;
  }
  return colors;
}

// https://stackoverflow.com/questions/28507619/how-to-create-delay-function-in-qml
function delay(interval, callback, parentItem) {
  let timer = Qt.createQmlObject("import QtQuick; Timer {}", parentItem);
  timer.interval = interval;
  timer.repeat = false;
  timer.triggered.connect(callback);
  timer.triggered.connect(function release() {
    timer.triggered.disconnect(callback);
    timer.triggered.disconnect(release);
    timer.destroy();
  });
  timer.start();
}

function makeEven(n) {
  return n - (n % 2);
}

function swapChannels(arr) {
  const mid = arr.length / 2;
  for (let i = 0; i < mid; i++) {
    const temp = arr[i];
    arr[i] = arr[mid + i];
    arr[mid + i] = temp;
  }
  return arr;
}
