(function() {
  var ABM, array, name, u, _base, _ref,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.ABM = ABM = {};

  ABM.util = {
    error: function(string) {
      throw new Error(string);
    },
    MaxINT: Math.pow(2, 53),
    MinINT: -Math.pow(2, 53),
    MaxINT32: 0 | 0x7fffffff,
    MinINT32: 0 | 0x80000000,
    isObject: function(object) {
      return !!(object && (typeof object === "object"));
    },
    isArray: function(object) {
      return !!(object && object.concat && object.unshift && !object.callee);
    },
    isFunction: function(object) {
      return !!(object && object.constructor && object.call && object.apply);
    },
    isString: function(object) {
      return !!(object === '' || (object && object.charCodeAt && object.substr));
    },
    isNumber: function(object) {
      return !!(typeof object === "number");
    },
    isBoolean: function(object) {
      return !!(typeof object === "boolean");
    },
    randomSeed: function(seed) {
      if (seed == null) {
        seed = 123456;
      }
      return Math.random = function() {
        var x;
        x = Math.sin(seed++) * 10000;
        return x - Math.floor(x);
      };
    },
    randomInt: function(minmax, max) {
      if (minmax == null) {
        minmax = 2;
      }
      if (max == null) {
        max = null;
      }
      return Math.floor(this.randomFloat(minmax, max));
    },
    randomFloat: function(minmax, max) {
      var min;
      if (minmax == null) {
        minmax = 1;
      }
      if (max == null) {
        max = null;
      }
      if (max === null) {
        max = minmax;
        min = 0;
      } else {
        min = minmax;
      }
      return min + Math.random() * (max - min);
    },
    randomNormal: function(mean, standardDeviation) {
      var normal, u1, u2;
      if (mean == null) {
        mean = 0.0;
      }
      if (standardDeviation == null) {
        standardDeviation = 1.0;
      }
      u1 = 1.0 - Math.random();
      u2 = Math.random();
      normal = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
      return normal * standardDeviation + mean;
    },
    randomCentered: function(r) {
      return this.randomFloat(-r / 2, r / 2);
    },
    onceEvery: function(number) {
      if (number == null) {
        number = 100;
      }
      return this.randomInt(number) === 1;
    },
    log10: function(number) {
      return Math.log(number) / Math.LN10;
    },
    log2: function(number) {
      return this.logN(number, 2);
    },
    logN: function(number, base) {
      return Math.log(number) / Math.log(base);
    },
    mod: function(number, moduloOf) {
      return ((number % moduloOf) + moduloOf) % moduloOf;
    },
    wrap: function(number, min, max) {
      return min + this.mod(number - min, max - min);
    },
    clamp: function(number, min, max) {
      return Math.max(Math.min(number, max), min);
    },
    sign: function(number) {
      if (number < 0) {
        return -1;
      } else {
        return 1;
      }
    },
    isLittleEndian: function() {
      var d32;
      d32 = new Uint32Array([0x01020304]);
      return (new Uint8ClampedArray(d32.buffer))[0] === 4;
    },
    degreesToRadians: function(degrees) {
      return degrees * Math.PI / 180;
    },
    radiansToDegrees: function(radians) {
      return radians * 180 / Math.PI;
    },
    substractRadians: function(radians1, radians2) {
      var PI, angle;
      angle = radians1 - radians2;
      PI = Math.PI;
      if (angle <= -PI) {
        angle += 2 * PI;
      }
      if (angle > PI) {
        angle -= 2 * PI;
      }
      return angle;
    },
    ownKeys: function(object) {
      var key, value;
      return ABM.Array.from((function() {
        var _results;
        _results = [];
        for (key in object) {
          if (!__hasProp.call(object, key)) continue;
          value = object[key];
          _results.push(key);
        }
        return _results;
      })());
    },
    ownVariableKeys: function(object) {
      var key, value;
      return ABM.Array.from((function() {
        var _results;
        _results = [];
        for (key in object) {
          if (!__hasProp.call(object, key)) continue;
          value = object[key];
          if (!this.isFunction(value)) {
            _results.push(key);
          }
        }
        return _results;
      }).call(this));
    },
    ownValues: function(object) {
      var key, value;
      return ABM.Array.from((function() {
        var _results;
        _results = [];
        for (key in object) {
          if (!__hasProp.call(object, key)) continue;
          value = object[key];
          _results.push(value);
        }
        return _results;
      })());
    },
    merge: function(first, second) {
      var hash, key, value;
      hash = {};
      for (key in first) {
        if (!__hasProp.call(first, key)) continue;
        value = first[key];
        hash[key] = value;
      }
      for (key in second) {
        if (!__hasProp.call(second, key)) continue;
        value = second[key];
        hash[key] = value;
      }
      return hash;
    },
    angle: function(point1, point2, patches) {
      if (patches.isTorus) {
        return this.angleTorus(point1, point2, patches);
      } else {
        return this.angleEuclidian(point1, point2);
      }
    },
    angleEuclidian: function(point1, point2) {
      return Math.atan2(point2.y - point1.y, point2.x - point1.x);
    },
    angleTorus: function(point1, point2, patches) {
      var closest;
      closest = this.closestTorusPoint(point1, point2, patches.width, patches.height);
      return this.angleEuclidian(point1, closest);
    },
    inCone: function(heading, cone, radius, point1, point2, patches) {
      if (patches.isTorus) {
        return this.inConeTorus(heading, cone, radius, point1, point2, patches);
      } else {
        return this.inConeEuclidian(heading, cone, radius, point1, point2);
      }
    },
    inConeEuclidian: function(heading, cone, radius, point1, point2) {
      var angle;
      if (radius < this.distanceEuclidian(point1, point2)) {
        return false;
      }
      angle = this.angleEuclidian(point1, point2);
      return cone / 2 >= Math.abs(this.substractRadians(heading, angle));
    },
    inConeTorus: function(heading, cone, radius, point1, point2, patches) {
      var point, _i, _len, _ref;
      _ref = this.torus4Points(point1, point2, patches.width, patches.height);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        if (this.inConeEuclidian(heading, cone, radius, point1, point)) {
          return true;
        }
      }
      return false;
    },
    distance: function(point1, point2, patches) {
      if (patches.isTorus) {
        return this.distanceTorus(point1, point2, patches);
      } else {
        return this.distanceEuclidian(point1, point2);
      }
    },
    distanceEuclidian: function(point1, point2) {
      var distanceX, distanceY;
      distanceX = point1.x - point2.x;
      distanceY = point1.y - point2.y;
      return Math.sqrt(distanceX * distanceX + distanceY * distanceY);
    },
    distanceTorus: function(point1, point2, patches) {
      var minX, minY, xDistance, yDistance;
      xDistance = Math.abs(point2.x - point1.x);
      yDistance = Math.abs(point2.y - point1.y);
      minX = Math.min(xDistance, patches.width - xDistance);
      minY = Math.min(yDistance, patches.height - yDistance);
      return Math.sqrt(minX * minX + minY * minY);
    },
    torus4Points: function(point1, point2, width, height) {
      var xReflected, yReflected, _ref;
      _ref = this.torusReflect(point1, point2, width, height), xReflected = _ref[0], yReflected = _ref[1];
      return [
        point2, {
          x: xReflected,
          y: point2.y
        }, {
          x: point2.x,
          y: yReflected
        }, {
          x: xReflected,
          y: yReflected
        }
      ];
    },
    closestTorusPoint: function(point1, point2, width, height) {
      var x, xReflected, y, yReflected, _ref;
      _ref = this.torusReflect(point1, point2, width, height), xReflected = _ref[0], yReflected = _ref[1];
      if (Math.abs(xReflected - point1.x) < Math.abs(point2.x - point1.x)) {
        x = xReflected;
      } else {
        x = point2.x;
      }
      if (Math.abs(yReflected - point1.y) < Math.abs(point2.y - point1.y)) {
        y = yReflected;
      } else {
        y = point2.y;
      }
      return {
        x: x,
        y: y
      };
    },
    torusReflect: function(point1, point2, width, height) {
      var xReflected, yReflected;
      if (point2.x < point1.x) {
        xReflected = point2.x + width;
      } else {
        xReflected = point2.x - width;
      }
      if (point2.y < point1.y) {
        yReflected = point2.y + height;
      } else {
        yReflected = point2.y - height;
      }
      return [xReflected, yReflected];
    },
    fileIndex: {},
    importImage: function(name, call) {
      var image;
      if (call == null) {
        call = function() {};
      }
      image = this.fileIndex[name];
      if (image != null) {
        if (image.isDone) {
          call(image);
        }
      } else {
        image = new Image();
        image.isDone = false;
        image.crossOrigin = "Anonymous";
        image.onload = function() {
          call(image);
          return image.isDone = true;
        };
        image.src = name;
        this.fileIndex[name] = image;
      }
      return image;
    },
    xhrLoadFile: function(name, method, type, call) {
      var xhr;
      if (method == null) {
        method = "GET";
      }
      if (type == null) {
        type = "text";
      }
      if (call == null) {
        call = function() {};
      }
      xhr = this.fileIndex[name];
      if (xhr != null) {
        if (xhr.isDone) {
          call(xhr.response);
        }
      } else {
        xhr = new XMLHttpRequest();
        xhr.isDone = false;
        xhr.open(method, name);
        xhr.responseType = type;
        xhr.onload = function() {
          call(xhr.response);
          return xhr.isDone = true;
        };
        this.fileIndex[name] = xhr;
        xhr.send();
      }
      return xhr;
    },
    filesLoaded: function(files) {
      var array, object;
      if (files == null) {
        files = this.fileIndex;
      }
      array = (function() {
        var _i, _len, _ref, _results;
        _ref = this.ownValues(files);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          _results.push(object.isDone);
        }
        return _results;
      }).call(this);
      return array.reduce((function(valueA, valueB) {
        return valueA && valueB;
      }), true);
    },
    waitOnFiles: function(call, files) {
      if (files == null) {
        files = this.fileIndex;
      }
      return this.waitOn(((function(_this) {
        return function() {
          return _this.filesLoaded(files);
        };
      })(this)), call);
    },
    waitOn: function(done, call) {
      if (done()) {
        return call();
      } else {
        return setTimeout(((function(_this) {
          return function() {
            return _this.waitOn(done, call);
          };
        })(this)), 1000);
      }
    },
    cloneImage: function(image) {
      var newImage;
      newImage = new Image();
      newImage.src = image.src;
      return newImage;
    },
    imageToData: function(image, call, arrayType) {
      if (call == null) {
        call = this.pixelByte(0);
      }
      if (arrayType == null) {
        arrayType = Uint8ClampedArray;
      }
      return this.imageRowsToData(image, image.height, call, arrayType);
    },
    imageRowsToData: function(image, rowsPerSlice, call, arrayType) {
      var context, data, dataStart, i, idata, rows, rowsDone, _i, _ref;
      if (call == null) {
        call = this.pixelByte(0);
      }
      if (arrayType == null) {
        arrayType = Uint8ClampedArray;
      }
      rowsDone = 0;
      data = new arrayType(image.width * image.height);
      while (rowsDone < image.height) {
        rows = Math.min(image.height - rowsDone, rowsPerSlice);
        context = this.imageSliceToContext(image, 0, rowsDone, image.width, rows);
        idata = this.contextToImageData(context).data;
        dataStart = rowsDone * image.width;
        for (i = _i = 0, _ref = idata.length / 4; _i < _ref; i = _i += 1) {
          data[dataStart + i] = call(idata, 4 * i);
        }
        rowsDone += rows;
      }
      return data;
    },
    imageSliceToContext: function(image, sx, sy, sw, sh, context) {
      if (context != null) {
        context.canvas.width = sw;
        context.canvas.height = sh;
      } else {
        context = this.createContext(sw, sh);
      }
      context.drawImage(image, sx, sy, sw, sh, 0, 0, sw, sh);
      return context;
    },
    pixelByte: function(n) {
      return function(byte, i) {
        return byte[i + n];
      };
    },
    createCanvas: function(width, height) {
      var canvas;
      canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      return canvas;
    },
    createContext: function(width, height, contextType) {
      var canvas, _ref;
      if (contextType == null) {
        contextType = "2d";
      }
      canvas = this.createCanvas(width, height);
      if (contextType === "2d") {
        return canvas.getContext("2d");
      } else {
        return (_ref = canvas.getContext("webgl")) != null ? _ref : canvas.getContext("experimental-webgl");
      }
    },
    createLayer: function(div, width, height, z, context) {
      var element;
      if (context == null) {
        context = "2d";
      }
      if (context === "img") {
        element = context = new Image();
        context.width = width;
        context.height = height;
      } else {
        element = (context = this.createContext(width, height, context)).canvas;
      }
      this.insertLayer(div, element, width, height, z);
      return context;
    },
    insertLayer: function(div, element, w, h, z) {
      element.setAttribute('style', "position:absolute;top:0;left:0;width:" + w + ";height:" + h + ";z-index:" + z);
      return div.appendChild(element);
    },
    setContextSmoothing: function(context, smoothing) {
      context.imageSmoothingEnabled = smoothing;
      context.mozImageSmoothingEnabled = smoothing;
      context.oImageSmoothingEnabled = smoothing;
      return context.webkitImageSmoothingEnabled = smoothing;
    },
    setIdentity: function(context) {
      context.save();
      return context.setTransform(1, 0, 0, 1, 0, 0);
    },
    clearContext: function(context) {
      if (context.save != null) {
        this.setIdentity(context);
        context.clearRect(0, 0, context.canvas.width, context.canvas.height);
        return context.restore();
      } else {
        context.clearColor(0, 0, 0, 0);
        return context.clear(context.COLOR_BUFFER_BIT | context.DEPTH_BUFFER_BIT);
      }
    },
    fillContext: function(context, color) {
      if (context.fillStyle != null) {
        this.setIdentity(context);
        context.fillStyle = color.rgbString();
        context.fillRect(0, 0, context.canvas.width, context.canvas.height);
        return context.restore();
      } else {
        context.clearColor.apply(context, __slice.call(color).concat([1]));
        return context.clear(context.COLOR_BUFFER_BIT | context.DEPTH_BUFFER_BIT);
      }
    },
    contextDrawText: function(context, string, x, y, color, setIdentity) {
      if (color == null) {
        color = u.color.black;
      }
      if (setIdentity == null) {
        setIdentity = true;
      }
      if (setIdentity) {
        this.setIdentity(context);
      }
      context.fillStyle = color.rgbString();
      context.fillText(string, x, y);
      if (setIdentity) {
        return context.restore();
      }
    },
    contextTextParams: function(context, font, align, baseline) {
      if (align == null) {
        align = "center";
      }
      if (baseline == null) {
        baseline = "middle";
      }
      context.font = font;
      context.textAlign = align;
      return context.textBaseline = baseline;
    },
    elementTextParams: function(element, font, align, baseline) {
      if (align == null) {
        align = "center";
      }
      if (baseline == null) {
        baseline = "middle";
      }
      if (element.canvas != null) {
        element = element.canvas;
      }
      element.style.font = font;
      element.style.textAlign = align;
      return element.style.textBaseline = baseline;
    },
    contextToDataUrl: function(context) {
      return context.canvas.toDataURL("image/png");
    },
    contextToDataUrlImage: function(context, call) {
      var image;
      image = new Image();
      if (call != null) {
        image.onload = function() {
          return call(image);
        };
      }
      image.src = context.canvas.toDataURL("image/png");
      return image;
    },
    contextToImageData: function(context) {
      return context.getImageData(0, 0, context.canvas.width, context.canvas.height);
    },
    drawCenteredImage: function(context, image, radians, x, y, dx, dy) {
      context.translate(x, y);
      context.rotate(radians);
      return context.drawImage(image, -dx / 2, -dy / 2);
    },
    copyContext: function(context) {
      var newContext;
      newContext = this.createContext(context.canvas.width, context.canvas.height);
      newContext.drawImage(context.canvas, 0, 0);
      return newContext;
    },
    resizeContext: function(context, width, height, scale) {
      var newContext;
      if (scale == null) {
        scale = false;
      }
      newContext = this.copyContext(context);
      context.canvas.width = width;
      context.canvas.height = height;
      return context.drawImage(newContext.canvas, 0, 0);
    },
    linearInterpolate: function(low, high, scale) {
      return low + (high - low) * scale;
    },
    identityFunction: function(object) {
      return object;
    },
    propertyFunction: function(property) {
      return function(object) {
        return object[property];
      };
    },
    propertySortFunction: function(property) {
      return function(objectA, objectB) {
        if (objectA[property] < objectB[property]) {
          return -1;
        } else if (objectA[property] > objectB[property]) {
          return 1;
        } else {
          return 0;
        }
      };
    },
    typedToJS: function(typedArray) {
      var i, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = typedArray.length; _i < _len; _i++) {
        i = typedArray[_i];
        _results.push(i);
      }
      return _results;
    }
  };

  u = ABM.util;

  ABM.Util = (function() {
    function Util() {}

    return Util;

  })();

  ABM.util.array = {
    from: function(array, arrayType) {
      return ABM.Array.from(array, arrayType);
    },
    toString: function(array) {
      var object;
      return "[" + ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = array.length; _i < _len; _i++) {
          object = array[_i];
          _results.push(object.toString());
        }
        return _results;
      })()).join(", ") + "]";
    },
    toFixed: function(array, precision) {
      var newArray, number, _i, _len;
      if (precision == null) {
        precision = 2;
      }
      newArray = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        number = array[_i];
        newArray.push(number.toFixed(precision));
      }
      return newArray;
    },
    any: function(array) {
      return !this.empty(array);
    },
    empty: function(array) {
      return array.length === 0;
    },
    clear: function(array) {
      array.length = 0;
      return array;
    },
    clone: function(array, begin, end) {
      var method;
      if (begin == null) {
        begin = null;
      }
      if (end == null) {
        end = null;
      }
      if (array.slice != null) {
        method = "slice";
      } else {
        method = "subarray";
      }
      if (begin != null) {
        return array[method](begin, end);
      } else {
        return array[method](0);
      }
    },
    first: function(array) {
      return array[0];
    },
    last: function(array) {
      if (this.empty(array)) {
        return void 0;
      } else {
        return array[array.length - 1];
      }
    },
    select: function(array, condition) {
      var newArray, object, _i, _len;
      newArray = new ABM.Array;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        if (condition(object)) {
          newArray.push(object);
        }
      }
      return newArray;
    },
    reject: function(array, condition) {
      var newArray, object, _i, _len;
      newArray = new ABM.Array;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        if (!condition(object)) {
          newArray.push(object);
        }
      }
      return newArray;
    },
    sample: function(array, options) {
      var newArray, object, rejects;
      if ((options == null) || u.isNumber(options)) {
        options = {
          size: options
        };
      }
      if (this.empty(array) && (options.size == null)) {
        return null;
      }
      options.size = Math.floor(options.size);
      if (options.condition != null) {
        return this.sample(this.select(array, options.condition), {
          size: options.size
        });
      } else if (options.size) {
        if (options.uniqueArray == null) {
          options.uniqueArray = array.clone().uniq();
        }
        if (options.size > options.uniqueArray.length) {
          options.size = options.uniqueArray.length;
        }
        if (options.size * 1.8 > options.uniqueArray.length) {
          rejects = this.sample(array, u.merge(options, {
            size: options.uniqueArray.length - options.size
          }));
          return this.shuffle(this.removeItems(options.uniqueArray, rejects));
        } else {
          newArray = new ABM.Array;
          object = true;
          while (newArray.length < options.size && (object != null)) {
            object = array[u.randomInt(array.length)];
            if (object && __indexOf.call(newArray, object) < 0) {
              newArray.push(object);
            }
          }
          return newArray;
        }
      } else {
        return array[u.randomInt(array.length)];
      }
    },
    contains: function(array, object) {
      return array.indexOf(object) >= 0;
    },
    remove: function(array, object) {
      var index;
      while (true) {
        index = array.indexOf(object);
        if (index === -1) {
          break;
        }
        array.splice(index, 1);
      }
      return array;
    },
    removeItems: function(array, objects) {
      var object, _i, _len;
      for (_i = 0, _len = objects.length; _i < _len; _i++) {
        object = objects[_i];
        this.remove(array, object);
      }
      return array;
    },
    shuffle: function(array) {
      array.sort(function() {
        return 0.5 - Math.random();
      });
      return array;
    },
    min: function(array, call, valueToo) {
      var minObject, minValue, object, value, _i, _len;
      if (call == null) {
        call = u.identityFunction;
      }
      if (valueToo == null) {
        valueToo = false;
      }
      if (this.empty(array)) {
        u.error("min: empty array");
      }
      if (u.isString(call)) {
        call = u.propertyFunction(call);
      }
      minValue = Infinity;
      minObject = null;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        value = call(object);
        if (value < minValue) {
          minValue = value;
          minObject = object;
        }
      }
      if (valueToo) {
        return [minObject, minValue];
      } else {
        return minObject;
      }
    },
    max: function(array, call, valueToo) {
      var maxObject, maxValue, object, value, _i, _len;
      if (call == null) {
        call = u.identityFunction;
      }
      if (valueToo == null) {
        valueToo = false;
      }
      if (this.empty(array)) {
        u.error("max: empty array");
      }
      if (u.isString(call)) {
        call = u.propertyFunction(call);
      }
      maxValue = -Infinity;
      maxObject = null;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        value = call(object);
        if (value > maxValue) {
          maxValue = value;
          maxObject = object;
        }
      }
      if (valueToo) {
        return [maxObject, maxValue];
      } else {
        return maxObject;
      }
    },
    sum: function(array, call) {
      var object, value, _i, _len;
      if (call == null) {
        call = u.identityFunction;
      }
      if (u.isString(call)) {
        call = u.propertyFunction(call);
      }
      value = 0;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        value += call(object);
      }
      return value;
    },
    average: function(array, call) {
      if (call == null) {
        call = u.identityFunction;
      }
      return this.sum(array, call) / array.length;
    },
    median: function(array) {
      var middle;
      if (array.sort != null) {
        array = this.clone(array);
      } else {
        array = u.typedToJS(array);
      }
      middle = (array.length - 1) / 2;
      this.sort(array);
      return (array[Math.floor(middle)] + array[Math.ceil(middle)]) / 2;
    },
    histogram: function(array, binSize, call) {
      var histogram, integer, object, value, _i, _j, _len, _len1;
      if (binSize == null) {
        binSize = 1;
      }
      if (call == null) {
        call = u.identityFunction;
      }
      if (u.isString(call)) {
        call = u.propertyFunction(call);
      }
      histogram = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        integer = Math.floor(call(object) / binSize);
        histogram[integer] || (histogram[integer] = 0);
        histogram[integer] += 1;
      }
      for (integer = _j = 0, _len1 = histogram.length; _j < _len1; integer = ++_j) {
        value = histogram[integer];
        if (value == null) {
          histogram[integer] = 0;
        }
      }
      return histogram;
    },
    sort: function(array, call) {
      if (call == null) {
        call = null;
      }
      if (u.isString(call)) {
        call = u.propertySortFunction(call);
      }
      array._sort(call);
      return array;
    },
    uniq: function(array) {
      var hash, i;
      hash = {};
      i = 0;
      while (i < array.length) {
        if (hash[array[i]] === true) {
          array.splice(i, 1);
          i -= 1;
        } else {
          hash[array[i]] = true;
        }
        i += 1;
      }
      return array;
    },
    flatten: function(array) {
      return array.reduce(function(arrayA, arrayB) {
        if (!u.isArray(arrayA)) {
          arrayA = new ABM.Array(arrayA);
        }
        return arrayA.concat(arrayB);
      });
    },
    concat: function(array, addArray) {
      var element, newArray, _i, _len;
      newArray = array.clone();
      if (u.isArray(addArray)) {
        for (_i = 0, _len = addArray.length; _i < _len; _i++) {
          element = addArray[_i];
          newArray.push(element);
        }
      } else {
        newArray.push(addArray);
      }
      return newArray;
    },
    normalize: function(array, low, high) {
      var max, min, newArray, number, scale, _i, _len;
      if (low == null) {
        low = 0;
      }
      if (high == null) {
        high = 1;
      }
      min = this.min(array);
      max = this.max(array);
      scale = 1 / (max - min);
      newArray = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        number = array[_i];
        newArray.push(u.linearInterpolate(low, high, scale * (number - min)));
      }
      return newArray;
    },
    normalizeInt: function(array, low, high) {
      var i;
      return (function() {
        var _i, _len, _ref, _results;
        _ref = this.normalize(array, low, high);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push(Math.round(i));
        }
        return _results;
      }).call(this);
    },
    ask: function(array, call) {
      var object, _i, _len;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        call(object);
      }
      return array;
    },
    "with": function(array, functionString) {
      var object;
      if (u.isString(functionString)) {
        eval("f=function(object){return " + functionString + ";}");
      }
      return this.from((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = array.length; _i < _len; _i++) {
          object = array[_i];
          if (functionString(object)) {
            _results.push(object);
          }
        }
        return _results;
      })());
    },
    getProperty: function(array, property) {
      var newArray, object, _i, _len;
      newArray = new ABM.Array;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        newArray.push(object[property]);
      }
      return newArray;
    },
    setProperty: function(array, property, value) {
      var object, _i, _len;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        object[property] = value;
      }
      return array;
    },
    other: function(array, given) {
      var newArray, object, _i, _len;
      newArray = new ABM.Array;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        object = array[_i];
        if (object !== given) {
          newArray.push(object);
        }
      }
      return newArray;
    }
  };

  ABM.util.array.extender = {
    methods: function() {
      var key, value, _ref, _results;
      _ref = ABM.util.array;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        if (typeof value === 'function') {
          _results.push(key);
        }
      }
      return _results;
    },
    extendArray: function(className) {
      var method, methods, _i, _len, _results;
      methods = this.methods();
      _results = [];
      for (_i = 0, _len = methods.length; _i < _len; _i++) {
        method = methods[_i];
        _results.push(eval("" + className + ".prototype." + method + " = function() {\n  var options, _ref, _ret;\n  options = 1 <= arguments.length ? __slice.call(arguments, 0) : [];\n  _ret = (_ref = u.array)." + method + ".apply(_ref, [this].concat(__slice.call(options)));\n  if (ABM.util.isArray(_ret)) {\n    return this.constructor.from(_ret);\n  } else {\n    return _ret;\n  }\n};"));
      }
      return _results;
    }
  };

  ABM.Util.Array = (function() {
    function Array() {}

    return Array;

  })();

  (_base = Array.prototype).indexOf || (_base.indexOf = function(given) {
    var i, object, _i, _len;
    for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
      object = this[i];
      if (object === given) {
        return i;
      }
    }
    return -1;
  });

  Array.prototype._sort = Array.prototype.sort;

  ABM.Array = (function(_super) {
    __extends(Array, _super);

    Array.from = function(array, arrayType) {
      var _ref;
      if (arrayType == null) {
        arrayType = ABM.Array;
      }
      array.__proto__ = (_ref = arrayType.prototype) != null ? _ref : arrayType.constructor.prototype;
      return array;
    };

    function Array() {
      var options;
      options = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.constructor.from(options);
    }

    return Array;

  })(Array);

  ABM.util.array.extender.extendArray('ABM.Array');

  ABM.util.shapes = {
    polygon: function(context, array) {
      var i, position, _i, _len;
      for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
        position = array[i];
        if (i === 0) {
          context.moveTo(position[0], position[1]);
        } else {
          context.lineTo(position[0], position[1]);
        }
      }
      return null;
    },
    centered_circle: function(context, x, y, size) {
      return context.arc(x, y, size / 2, 0, 2 * Math.PI);
    },
    counter_centered_circle: function(context, x, y, size) {
      return context.arc(x, y, size / 2, 0, 2 * Math.PI, true);
    },
    centered_image: function(context, x, y, size, image) {
      context.scale(1, -1);
      context.drawImage(image, x - size / 2, y - size / 2, size, size);
      return context.scale(1, -1);
    },
    centered_square: function(context, x, y, size) {
      return context.fillRect(x - size / 2, y - size / 2, size, size);
    },
    fillSlot: function(slot, image) {
      slot.context.save();
      slot.context.scale(1, -1);
      slot.context.drawImage(image, slot.x, -(slot.y + slot.spriteSize), slot.spriteSize, slot.spriteSize);
      return slot.context.restore();
    },
    spriteSheets: new ABM.Array,
    "default": {
      rotate: true,
      draw: function(context) {
        return u.shapes.polygon(context, [[.5, 0], [-.5, -.5], [-.25, 0], [-.5, .5]]);
      }
    },
    triangle: {
      rotate: true,
      draw: function(context) {
        return u.shapes.polygon(context, [[.5, 0], [-.5, -.4], [-.5, .4]]);
      }
    },
    arrow: {
      rotate: true,
      draw: function(context) {
        return u.shapes.polygon(context, [[.5, 0], [0, .5], [0, .2], [-.5, .2], [-.5, -.2], [0, -.2], [0, -.5]]);
      }
    },
    bug: {
      rotate: true,
      draw: function(context) {
        context.strokeStyle = context.fillStyle;
        context.lineWidth = .05;
        u.shapes.polygon(context, [[.4, .225], [.2, 0], [.4, -.225]]);
        context.stroke();
        context.beginPath();
        u.shapes.centered_circle(context, .12, 0, .26);
        u.shapes.centered_circle(context, -.05, 0, .26);
        return u.shapes.centered_circle(context, -.27, 0, .4);
      }
    },
    pyramid: {
      rotate: false,
      draw: function(context) {
        return u.shapes.polygon(context, [[0, .5], [-.433, -.25], [.433, -.25]]);
      }
    },
    circle: {
      shortcut: function(context, x, y, size) {
        context.beginPath();
        u.shapes.centered_circle(context, x, y, size);
        context.closePath();
        return context.fill();
      },
      rotate: false,
      draw: function(context) {
        return u.shapes.centered_circle(context, 0, 0, 1);
      }
    },
    square: {
      shortcut: function(context, x, y, size) {
        return u.shapes.centered_square(context, x, y, size);
      },
      rotate: false,
      draw: function(context) {
        return u.shapes.centered_square(context, 0, 0, 1);
      }
    },
    pentagon: {
      rotate: false,
      draw: function(context) {
        return u.shapes.polygon(context, [[0, .45], [-.45, .1], [-.3, -.45], [.3, -.45], [.45, .1]]);
      }
    },
    ring: {
      rotate: false,
      draw: function(context) {
        u.shapes.centered_circle(context, 0, 0, 1);
        context.closePath();
        return u.shapes.counter_centered_circle(context, 0, 0, .6);
      }
    },
    filledRing: {
      rotate: false,
      draw: function(context) {
        var tempStyle;
        u.shapes.centered_circle(context, 0, 0, 1);
        tempStyle = context.fillStyle;
        context.fillStyle = context.strokeStyle;
        context.fill();
        context.fillStyle = tempStyle;
        context.beginPath();
        return u.shapes.centered_circle(context, 0, 0, 0.8);
      }
    },
    person: {
      rotate: false,
      draw: function(context) {
        u.shapes.polygon(context, [[.15, .2], [.3, 0], [.125, -.1], [.125, .05], [.1, -.15], [.25, -.5], [.05, -.5], [0, -.25], [-.05, -.5], [-.25, -.5], [-.1, -.15], [-.125, .05], [-.125, -.1], [-.3, 0], [-.15, .2]]);
        context.closePath();
        return u.shapes.centered_circle(context, 0, .35, .30);
      }
    },
    names: function() {
      var array, name, value;
      array = new ABM.Array;
      for (name in this) {
        if (!__hasProp.call(this, name)) continue;
        value = this[name];
        if ((value.rotate != null) && (value.draw != null)) {
          array.push(name);
        }
      }
      return array;
    },
    add: function(name, rotate, draw, shortcut) {
      var shape;
      if (u.isFunction(draw)) {
        shape = {
          rotate: rotate,
          draw: draw
        };
      } else {
        shape = {
          rotate: rotate,
          image: draw,
          draw: function(context) {
            return this.centered_image(context, .5, .5, 1, this.image);
          }
        };
      }
      this[name] = shape;
      if (shortcut != null) {
        return shape.shortcut = shortcut;
      } else if ((shape.image != null) && !shape.rotate) {
        return shape.shortcut = function(context, x, y, size) {
          return this.centered_image(context, x, y, size, this.image);
        };
      }
    },
    draw: function(context, shape, x, y, size, rad, color, strokeColor) {
      if (shape.shortcut != null) {
        if (shape.image == null) {
          context.fillStyle = color.rgbString();
        }
        shape.shortcut(context, x, y, size);
      } else {
        context.save();
        context.translate(x, y);
        if (size !== 1) {
          context.scale(size, size);
        }
        if (rad !== 0) {
          context.rotate(rad);
        }
        if (shape.image != null) {
          shape.draw(context);
        } else {
          context.fillStyle = color.rgbString();
          if (strokeColor) {
            context.strokeStyle = strokeColor.rgbString();
            context.lineWidth = 0.05;
          }
          context.save();
          context.beginPath();
          shape.draw(context);
          context.closePath();
          context.restore();
          context.fill();
          if (strokeColor) {
            context.stroke();
          }
        }
        context.restore();
      }
      return shape;
    },
    drawSprite: function(context, slot, x, y, size, radians) {
      if (radians === 0) {
        context.drawImage(slot.context.canvas, slot.x, slot.y, slot.spriteSize, slot.spriteSize, x - size / 2, y - size / 2, size, size);
      } else {
        context.save();
        context.translate(x, y);
        context.rotate(radians);
        context.drawImage(slot.context.canvas, slot.x, slot.y, slot.spriteSize, slot.spriteSize, -size / 2, -size / 2, size, size);
        context.restore();
      }
      return slot;
    },
    shapeToSprite: function(name, color, size, strokeColor) {
      var context, foundSlot, index, shape, slot, slotSize, spriteSize, strokePadding, x, y;
      spriteSize = Math.ceil(size);
      strokePadding = 4;
      slotSize = spriteSize + strokePadding;
      shape = this[name];
      if (shape.image != null) {
        index = name;
      } else {
        index = "" + name + "-" + (color.rgbString());
      }
      context = this.spriteSheets[slotSize];
      if (context == null) {
        this.spriteSheets[slotSize] = context = u.createContext(slotSize * 10, slotSize);
        context.nextX = 0;
        context.nextY = 0;
        context.index = {};
      }
      if ((foundSlot = context.index[index]) != null) {
        return foundSlot;
      }
      if (slotSize * context.nextX === context.canvas.width) {
        u.resizeContext(context, context.canvas.width, context.canvas.height + slotSize);
        context.nextX = 0;
        context.nextY++;
      }
      x = slotSize * context.nextX + strokePadding / 2;
      y = slotSize * context.nextY + strokePadding / 2;
      slot = {
        context: context,
        x: x,
        y: y,
        size: size,
        spriteSize: spriteSize,
        name: name,
        color: color,
        strokeColor: strokeColor,
        index: index
      };
      context.index[index] = slot;
      if (shape.image != null) {
        if (shape.image.height !== 0) {
          this.fillSlot(slot, shape.image);
        } else {
          shape.image.onload = function() {
            return this.fillSlot(slot, shape.image);
          };
        }
      } else {
        context.save();
        context.translate((context.nextX + 0.5) * slotSize, (context.nextY + 0.5) * slotSize);
        context.scale(spriteSize, spriteSize);
        context.fillStyle = color.rgbString();
        if (strokeColor) {
          context.strokeStyle = strokeColor.rgbString();
          context.lineWidth = 0.05;
        }
        context.save();
        context.beginPath();
        shape.draw(context);
        context.closePath();
        context.restore();
        context.fill();
        if (strokeColor) {
          context.stroke();
        }
        context.restore();
      }
      context.nextX++;
      return slot;
    }
  };

  ABM.Util.Shapes = (function() {
    function Shapes() {}

    return Shapes;

  })();

  ABM.Color = (function(_super) {
    __extends(Color, _super);

    Color.COLORS = {
      aliceblue: [240, 248, 255],
      antiquewhite: [250, 235, 215],
      aqua: [0, 255, 255],
      aquamarine: [127, 255, 212],
      azure: [240, 255, 255],
      beige: [245, 245, 220],
      bisque: [255, 228, 196],
      black: [0, 0, 0],
      blanchedalmond: [255, 235, 205],
      blue: [0, 0, 255],
      blueviolet: [138, 43, 226],
      brown: [165, 42, 42],
      burlywood: [222, 184, 135],
      cadetblue: [95, 158, 160],
      chartreuse: [127, 255, 0],
      chocolate: [210, 105, 30],
      coral: [255, 127, 80],
      cornflowerblue: [100, 149, 237],
      cornsilk: [255, 248, 220],
      crimson: [220, 20, 60],
      cyan: [0, 255, 255],
      darkblue: [0, 0, 139],
      darkcyan: [0, 139, 139],
      darkgoldenrod: [184, 134, 11],
      darkgray: [169, 169, 169],
      darkgreen: [0, 100, 0],
      darkkhaki: [189, 183, 107],
      darkmagenta: [139, 0, 139],
      darkolivegreen: [85, 107, 47],
      darkorange: [255, 140, 0],
      darkorchid: [153, 50, 204],
      darkred: [139, 0, 0],
      darksalmon: [233, 150, 122],
      darkseagreen: [143, 188, 143],
      darkslateblue: [72, 61, 139],
      darkslategray: [47, 79, 79],
      darkturquoise: [0, 206, 209],
      darkviolet: [148, 0, 211],
      deeppink: [255, 20, 147],
      deepskyblue: [0, 191, 255],
      dimgray: [105, 105, 105],
      dodgerblue: [30, 144, 255],
      firebrick: [178, 34, 34],
      floralwhite: [255, 250, 240],
      forestgreen: [34, 139, 34],
      fuchsia: [255, 0, 255],
      gainsboro: [220, 220, 220],
      ghostwhite: [248, 248, 255],
      gold: [255, 215, 0],
      goldenrod: [218, 165, 32],
      gray: [128, 128, 128],
      green: [0, 128, 0],
      greenyellow: [173, 255, 47],
      honeydew: [240, 255, 240],
      hotpink: [255, 105, 180],
      indianred: [205, 92, 92],
      indigo: [75, 0, 130],
      ivory: [255, 255, 240],
      khaki: [240, 230, 140],
      lavender: [230, 230, 250],
      lavenderblush: [255, 240, 245],
      lawngreen: [124, 252, 0],
      lemonchiffon: [255, 250, 205],
      lightblue: [173, 216, 230],
      lightcoral: [240, 128, 128],
      lightcyan: [224, 255, 255],
      lightgoldenrodyellow: [250, 250, 210],
      lightgray: [211, 211, 211],
      lightgreen: [144, 238, 144],
      lightpink: [255, 182, 193],
      lightsalmon: [255, 160, 122],
      lightseagreen: [32, 178, 170],
      lightskyblue: [135, 206, 250],
      lightslategray: [119, 136, 153],
      lightsteelblue: [176, 196, 222],
      lightyellow: [255, 255, 224],
      lime: [0, 255, 0],
      limegreen: [50, 205, 50],
      linen: [250, 240, 230],
      magenta: [255, 0, 255],
      maroon: [128, 0, 0],
      mediumaquamarine: [102, 205, 170],
      mediumblue: [0, 0, 205],
      mediumorchid: [186, 85, 211],
      mediumpurple: [147, 112, 219],
      mediumseagreen: [60, 179, 113],
      mediumslateblue: [123, 104, 238],
      mediumspringgreen: [0, 250, 154],
      mediumturquoise: [72, 209, 204],
      mediumvioletred: [199, 21, 133],
      midnightblue: [25, 25, 112],
      mintcream: [245, 255, 250],
      mistyrose: [255, 228, 225],
      moccasin: [255, 228, 181],
      navajowhite: [255, 222, 173],
      navy: [0, 0, 128],
      oldlace: [253, 245, 230],
      olive: [128, 128, 0],
      olivedrab: [107, 142, 35],
      orange: [255, 165, 0],
      orangered: [255, 69, 0],
      orchid: [218, 112, 214],
      palegoldenrod: [238, 232, 170],
      palegreen: [152, 251, 152],
      paleturquoise: [175, 238, 238],
      palevioletred: [219, 112, 147],
      papayawhip: [255, 239, 213],
      peachpuff: [255, 218, 185],
      peru: [205, 133, 63],
      pink: [255, 192, 203],
      plum: [221, 160, 221],
      powderblue: [176, 224, 230],
      purple: [128, 0, 128],
      red: [255, 0, 0],
      rosybrown: [188, 143, 143],
      royalblue: [65, 105, 225],
      saddlebrown: [139, 69, 19],
      salmon: [250, 128, 114],
      sandybrown: [244, 164, 96],
      seagreen: [46, 139, 87],
      seashell: [255, 245, 238],
      sienna: [160, 82, 45],
      silver: [192, 192, 192],
      skyblue: [135, 206, 235],
      slateblue: [106, 90, 205],
      slategray: [112, 128, 144],
      snow: [255, 250, 250],
      springgreen: [0, 255, 127],
      steelblue: [70, 130, 180],
      tan: [210, 180, 140],
      teal: [0, 128, 128],
      thistle: [216, 191, 216],
      tomato: [255, 99, 71],
      turquoise: [64, 224, 208],
      violet: [238, 130, 238],
      wheat: [245, 222, 179],
      white: [255, 255, 255],
      whitesmoke: [245, 245, 245],
      yellow: [255, 255, 0],
      yellowgreen: [154, 205, 50]
    };

    Color._color_list = [];

    Color._color_cache = {};

    Color.from = function(array, arrayType) {
      var arrayString, _ref;
      if (arrayType == null) {
        arrayType = ABM.Array;
      }
      arrayString = array.toString();
      if (!this._color_cache[arrayString]) {
        array.__proto__ = (_ref = ABM.Color.prototype) != null ? _ref : ABM.Color.constructor.prototype;
        this._color_cache[arrayString] = array;
        this._color_list.push(arrayString);
        if (this._color_list.length > 200) {
          delete this._color_cache[this._color_list.shift()];
        }
      }
      return this._color_cache[arrayString];
    };

    Color.fromName = function(colorIn) {
      colorIn = colorIn.toLowerCase().replace(/(\s|-)/, "");
      return this[colorIn];
    };

    Color.fromHex = function(colorIn) {
      colorIn = colorIn.toLowerCase();
      if (/^#?([0-9]|[a-f])+$/.test(colorIn)) {
        if (colorIn[0] === '#') {
          colorIn = colorIn.subStr(1, 6);
        }
        if (colorIn.length === 3) {
          colorIn = colorIn[0] + colorIn[0] + colorIn[1] + colorIn[1] + colorIn[2] + colorIn[2];
        }
        if (colorIn.length === 6) {
          return this.from([parseInt(colorIn.slice(0, 2), 16), parseInt(colorIn.slice(2, 4), 16), parseInt(colorIn.slice(4, 6), 16)]);
        }
      }
    };

    Color.random = function(options) {
      var color, i, max, min, random, _i, _j;
      if (options == null) {
        options = {};
      }
      if (u.isString(options)) {
        if (options === "map") {
          options = {
            map: [0, 63, 127, 191, 255]
          };
        } else {
          options = {
            type: options
          };
        }
      }
      if (options.type === "bright") {
        return this.random({
          map: [0, 127, 255]
        });
      }
      if (options.map) {
        color = [u.array.sample(options.map), u.array.sample(options.map), u.array.sample(options.map)];
      } else {
        color = [];
        if (options.type === "gray") {
          min = options.min || 64;
          max = options.max || 192;
          random = u.randomInt(min, max);
          for (i = _i = 0; _i <= 2; i = ++_i) {
            color[i] = random;
          }
        } else {
          min = options.min || 0;
          max = options.max || 256;
          for (i = _j = 0; _j <= 2; i = ++_j) {
            color[i] = u.randomInt(min, max);
          }
        }
      }
      return new Color(color);
    };

    function Color(colorIn) {
      var color;
      color = colorIn;
      if (!u.isArray(color)) {
        color = this.constructor.fromName(colorIn) || this.constructor.fromHex(colorIn);
        if (!u.isArray(color)) {
          u.error("unless you're using basic colors, specify an rgb array [nr, nr, nr]");
        }
      }
      return this.constructor.from(color);
    }

    Color.prototype.fraction = function(fraction) {
      var color, value, _i, _len;
      color = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        value = this[_i];
        color.push(u.clamp(Math.round(value * fraction), 0, 255));
      }
      return new Color(color);
    };

    Color.prototype.brighten = function(fraction) {
      var color, value, _i, _len;
      color = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        value = this[_i];
        color.push(u.clamp(Math.round(value + fraction * 255), 0, 255));
      }
      return new Color(color);
    };

    Color.prototype.rgbString = function() {
      if (this._rgbString == null) {
        if ((this[3] != null) && this[3] > 1) {
          u.error("alpha > 1");
        }
        if (this[3] != null) {
          this._rgbString = "rgba(" + this[0] + "," + this[1] + "," + this[2] + "," + this[3] + ")";
        } else {
          this._rgbString = "rgb(" + this[0] + "," + this[1] + "," + this[2] + ")";
        }
      }
      return this._rgbString;
    };

    Color.prototype.equals = function(color2) {
      return this.toString() === color2.toString();
    };

    return Color;

  })(ABM.Array);

  _ref = ABM.Color.COLORS;
  for (name in _ref) {
    array = _ref[name];
    ABM.Color[name] = ABM.Color.from(array);
  }

  ABM.util.color = ABM.Color;

  ABM.Set = (function(_super) {
    __extends(Set, _super);

    function Set() {
      return Set.__super__.constructor.apply(this, arguments);
    }

    Set.from = function(array, setType) {
      var _ref1;
      if (this.model != null) {
        setType || (setType = this.model.Set);
      } else {
        setType || (setType = ABM.Set);
      }
      array.__proto__ = (_ref1 = setType.prototype) != null ? _ref1 : setType.constructor.prototype;
      return array;
    };

    Set.prototype.from = function(array, setType) {
      if (setType == null) {
        setType = this;
      }
      return this.model.Set.from(array, setType);
    };

    Set.prototype.setDefault = function(name, value) {
      this.agentClass.prototype[name] = value;
      return this;
    };

    Set.prototype.exclude = function(breeds) {
      var o;
      breeds = breeds.split(" ");
      return this.from((function() {
        var _i, _len, _ref1, _results;
        _results = [];
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          o = this[_i];
          if (_ref1 = o.breed.name, __indexOf.call(breeds, _ref1) < 0) {
            _results.push(o);
          }
        }
        return _results;
      }).call(this));
    };

    Set.prototype.draw = function(context) {
      var object, _i, _len;
      u.clearContext(context);
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        object = this[_i];
        if (!object.hidden) {
          object.draw(context);
        }
      }
      return null;
    };

    Set.prototype.show = function() {
      var object, _i, _len;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        object = this[_i];
        object.hidden = false;
      }
      return this.draw(this.model.contexts[this.name]);
    };

    Set.prototype.hide = function() {
      var object, _i, _len;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        object = this[_i];
        object.hidden = true;
      }
      return this.draw(this.model.contexts[this.name]);
    };

    Set.prototype.inRadius = function(point, options) {
      var entity, inner, _i, _len;
      inner = new this.model.Set;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        entity = this[_i];
        if (entity.distance(point) <= options.radius) {
          inner.push(entity);
        }
      }
      return inner;
    };

    Set.prototype.inCone = function(point, options) {
      var entity, inner, _i, _len;
      inner = new this.model.Set;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        entity = this[_i];
        if (u.inCone(options.heading, options.cone, options.radius, point, entity.position, this.model.patches)) {
          inner.push(entity);
        }
      }
      return inner;
    };

    return Set;

  })(ABM.Array);

  ABM.BreedSet = (function(_super) {
    __extends(BreedSet, _super);

    function BreedSet(agentClass, name, mainSet) {
      BreedSet.__super__.constructor.call(this, 0);
      this.agentClass = agentClass;
      this.name = name;
      this.mainSet = mainSet;
      if (this.mainSet == null) {
        this.breeds = [];
        this.ID = 0;
      }
      this.agentClass.prototype.breed = this;
    }

    BreedSet.prototype.create = function() {};

    BreedSet.prototype._push = BreedSet.prototype.push;

    BreedSet.prototype.push = function() {
      var item, object, _i, _len;
      object = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (object.length > 1) {
        for (_i = 0, _len = object.length; _i < _len; _i++) {
          item = object[_i];
          this.push(item);
        }
      } else {
        object = object[0];
        this._push(object);
        if (this.mainSet != null) {
          this.mainSet.push(object);
        } else {
          if (object.id != null) {
            if ((object.breed != null) && object.breed.name === !this.name) {
              object.id = this.ID++;
            }
          } else {
            object.id = this.ID++;
          }
        }
      }
      return object;
    };

    BreedSet.prototype.remove = function(object) {
      if (this.mainSet != null) {
        this.mainSet.remove(object);
      }
      u.array.remove(this, object);
      return this;
    };

    BreedSet.prototype.pop = function() {
      var object;
      object = this.last();
      this.remove(object);
      return object;
    };

    BreedSet.prototype.reBreed = function(agent) {
      var key, proto, value;
      agent.breed.remove(agent);
      this.push(agent);
      proto = agent.__proto__ = this.agentClass.prototype;
      for (key in agent) {
        if (!__hasProp.call(agent, key)) continue;
        value = agent[key];
        if (proto[key] != null) {
          delete agent[key];
        }
      }
      return agent;
    };

    return BreedSet;

  })(ABM.Set);

  ABM.Agent = (function() {
    Agent.prototype.id = null;

    Agent.prototype.breed = null;

    Agent.prototype.position = null;

    Agent.prototype.patch = null;

    Agent.prototype.size = 1;

    Agent.prototype.color = null;

    Agent.prototype.strokeColor = null;

    Agent.prototype.shape = "default";

    Agent.prototype.hidden = false;

    Agent.prototype.label = null;

    Agent.prototype.labelColor = u.color.black;

    Agent.prototype.labelOffset = {
      x: 0,
      y: 0
    };

    Agent.prototype.penDown = false;

    Agent.prototype.penSize = 1;

    Agent.prototype.heading = null;

    Agent.prototype.sprite = null;

    Agent.prototype.links = null;

    function Agent() {
      this.position = {
        x: 0,
        y: 0
      };
      if (this.color == null) {
        this.color = ABM.Color.random();
      }
      if (this.heading == null) {
        this.heading = u.randomFloat(Math.PI * 2);
      }
      this.links = new ABM.Array;
      this.moveTo(this.position);
    }

    Agent.prototype.toString = function() {
      return ("{id: " + this.id + ", position: {x: " + (this.position.x.toFixed(2)) + ",") + (" y: " + (this.position.y.toFixed(2)) + "}, c: " + this.color + ",") + (" h: " + (this.heading.toFixed(2)) + "/" + (Math.round(u.radiansToDegrees(this.heading))) + "}");
    };

    Agent.prototype.moveTo = function(point) {
      var drawing, oldPatch, x0, y0, _ref1;
      if (this.penDown) {
        _ref1 = [this.position.x, this.position.y], x0 = _ref1[0], y0 = _ref1[1];
      }
      this.position = this.model.patches.coordinate(point);
      oldPatch = this.patch;
      this.patch = this.model.patches.patch(this.position);
      if (oldPatch) {
        oldPatch.agents.remove(this);
      }
      if (this.patch) {
        this.patch.agents.push(this);
      }
      if (this.penDown) {
        drawing = this.model.drawing;
        drawing.strokeStyle = this.color.rgbString();
        drawing.lineWidth = this.model.patches.fromBits(this.penSize);
        drawing.beginPath();
        drawing.moveTo(x0, y0);
        drawing.lineTo(this.position.x, this.position.y);
        return drawing.stroke();
      }
    };

    Agent.prototype.moveOff = function() {
      if (this.patch) {
        this.patch.agents.remove(this);
      }
      return this.patch = this.position = null;
    };

    Agent.prototype.forward = function(distance, options) {
      var x, y;
      if (distance == null) {
        distance = 1;
      }
      if (options == null) {
        options = {};
      }
      x = this.position.x + distance * Math.cos(this.heading);
      y = this.position.y + distance * Math.sin(this.heading);
      if (options.snap) {
        return this.moveTo({
          x: Math.round(x),
          y: Math.round(y)
        });
      } else {
        return this.moveTo({
          x: x,
          y: y
        });
      }
    };

    Agent.prototype.rotate = function(options) {
      if (u.isNumber(options)) {
        return this.heading = u.wrap(this.heading + options, 0, Math.PI * 2);
      } else if (options.right) {
        return this.rotate(options.right * -1);
      } else {
        return this.rotate(options.left);
      }
    };

    Agent.prototype.face = function(point) {
      return this.heading = u.angle(this.position, point, this.model.patches);
    };

    Agent.prototype.distance = function(point) {
      return u.distance(this.position, point, this.model.patches);
    };

    Agent.prototype.neighbors = function(options) {
      var neighbors, square;
      if (options == null) {
        options = 1;
      }
      if (u.isNumber(options)) {
        options = {
          range: options
        };
      }
      if (!options.meToo) {
        options = u.merge(options, {
          meToo: true,
          not: this
        });
      }
      if (!this.patch) {
        return new this.model.Set;
      } else {
        if (options.radius) {
          square = this.patch.neighborAgents(options.radius);
          if (options.cone) {
            if (options.heading == null) {
              options.heading = this.heading;
            }
            neighbors = square.inCone(this.position, options);
          } else {
            neighbors = square.inRadius(this.position, options);
          }
        } else {
          neighbors = this.patch.neighborAgents(options);
        }
        return neighbors;
      }
    };

    Agent.prototype.die = function() {
      var link, _i, _ref1;
      this.breed.remove(this);
      _ref1 = this.links;
      for (_i = _ref1.length - 1; _i >= 0; _i += -1) {
        link = _ref1[_i];
        link.die();
      }
      this.moveOff();
      return null;
    };

    Agent.prototype.hatch = function(number, breed, init) {
      if (number == null) {
        number = 1;
      }
      if (breed == null) {
        breed = this.model.agents;
      }
      if (init == null) {
        init = function() {};
      }
      return breed.create(number, (function(_this) {
        return function(agent) {
          var key, value;
          agent.moveTo(_this.position);
          for (key in _this) {
            if (!__hasProp.call(_this, key)) continue;
            value = _this[key];
            if (key !== "id") {
              agent[key] = value;
            }
          }
          init(agent);
          return agent;
        };
      })(this));
    };

    Agent.prototype.otherEnd = function(link) {
      if (link.from === this) {
        return link.to;
      } else {
        return link.from;
      }
    };

    Agent.prototype.outLinks = function() {
      var link, _i, _len, _ref1, _results;
      _ref1 = this.links;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        link = _ref1[_i];
        if (link.from === this) {
          _results.push(link);
        }
      }
      return _results;
    };

    Agent.prototype.inLinks = function() {
      var link, _i, _len, _ref1, _results;
      _ref1 = this.links;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        link = _ref1[_i];
        if (link.to === this) {
          _results.push(link);
        }
      }
      return _results;
    };

    Agent.prototype.linkNeighbors = function() {
      var link, _i, _len, _ref1;
      array = new ABM.Array;
      _ref1 = this.links;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        link = _ref1[_i];
        array.push(this.otherEnd(link));
      }
      return array.uniq();
    };

    Agent.prototype.inLinkNeighbors = function() {
      var link, _i, _len, _ref1;
      array = new ABM.Array;
      _ref1 = this.inLinks();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        link = _ref1[_i];
        array.push(link.from);
      }
      return array.uniq();
    };

    Agent.prototype.outLinkNeighbors = function() {
      var link, _i, _len, _ref1;
      array = new ABM.Array;
      _ref1 = this.outLinks();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        link = _ref1[_i];
        array.push(link.to);
      }
      return array.uniq();
    };

    Agent.prototype.draw = function(context) {
      var radians, shape, x, y, _ref1;
      if (this.patch === null) {
        return;
      }
      shape = u.shapes[this.shape];
      if (shape.rotate) {
        radians = this.heading;
      } else {
        radians = 0;
      }
      if ((this.sprite != null) || this.breed.useSprites) {
        if (this.sprite == null) {
          this.setSprite();
        }
        u.shapes.drawSprite(context, this.sprite, this.position.x, this.position.y, this.size, radians);
      } else {
        u.shapes.draw(context, shape, this.position.x, this.position.y, this.size, radians, this.color, this.strokeColor);
      }
      if (this.label != null) {
        _ref1 = this.model.patches.patchXYtoPixelXY(this.position.x, this.position.y), x = _ref1[0], y = _ref1[1];
        return u.contextDrawText(context, this.label, x + this.labelOffset.x, y + this.labelOffset.y, this.labelColor);
      }
    };

    Agent.prototype.setSprite = function(sprite) {
      if (sprite != null) {
        this.sprite = sprite;
        this.color = sprite.color;
        this.strokeColor = sprite.strokeColor;
        this.shape = sprite.shape;
        return this.size = sprite.size;
      } else {
        if (this.color == null) {
          this.color = ABM.Color.random();
        }
        return this.sprite = u.shapes.shapeToSprite(this.shape, this.color, this.model.patches.toBits(this.size), this.strokeColor);
      }
    };

    Agent.prototype.stamp = function() {
      return this.draw(this.model.drawing);
    };

    return Agent;

  })();

  ABM.Agents = (function(_super) {
    __extends(Agents, _super);

    function Agents() {
      Agents.__super__.constructor.apply(this, arguments);
      this.useSprites = false;
    }

    Agents.prototype.setUseSprites = function(useSprites) {
      this.useSprites = useSprites != null ? useSprites : true;
    };

    Agents.prototype["in"] = function(agents) {
      var agent, _i, _len;
      array = [];
      for (_i = 0, _len = agents.length; _i < _len; _i++) {
        agent = agents[_i];
        if (agent.breed === this) {
          array.push(agent);
        }
      }
      return this.from(array);
    };

    Agents.prototype.create = function(num, initialize) {
      var i, object, _i;
      if (initialize == null) {
        initialize = function() {};
      }
      for (i = _i = 1; _i <= num; i = _i += 1) {
        object = new this.agentClass;
        this.push(object);
        initialize(object);
      }
      return this;
    };

    Agents.prototype.clear = function() {
      while (this.any()) {
        this.last().die();
      }
      return null;
    };

    Agents.prototype.neighboring = function(agent, rangeOptions) {
      array = agent.neighbors(rangeOptions);
      return this["in"](array);
    };

    Agents.prototype.formCircle = function(radius, startAngle, direction) {
      var agent, dTheta, i, _i, _len;
      if (startAngle == null) {
        startAngle = Math.PI / 2;
      }
      if (direction == null) {
        direction = -1;
      }
      dTheta = 2 * Math.PI / this.length;
      for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
        agent = this[i];
        agent.moveTo({
          x: 0,
          y: 0
        });
        agent.heading = startAngle + direction * dTheta * i;
        agent.forward(radius);
      }
      return null;
    };

    return Agents;

  })(ABM.BreedSet);

  ABM.Animator = (function() {
    function Animator(rate, multiStep) {
      this.rate = rate != null ? rate : 30;
      this.multiStep = multiStep != null ? multiStep : this.model.isHeadless;
      this.animateDraws = __bind(this.animateDraws, this);
      this.animateSteps = __bind(this.animateSteps, this);
      this.reset();
    }

    Animator.prototype.setRate = function(rate, multiStep) {
      this.rate = rate;
      this.multiStep = multiStep != null ? multiStep : this.model.isHeadless;
      return this.resetTimes();
    };

    Animator.prototype.start = function() {
      if (!this.stopped) {
        return;
      }
      this.resetTimes();
      this.stopped = false;
      return this.animate();
    };

    Animator.prototype.stop = function() {
      this.stopped = true;
      if (this.animatorHandle != null) {
        cancelAnimationFrame(this.animatorHandle);
      }
      if (this.timeoutHandle != null) {
        clearTimeout(this.timeoutHandle);
      }
      if (this.intervalHandle != null) {
        clearInterval(this.intervalHandle);
      }
      return this.animatorHandle = this.timerHandle = this.intervalHandle = null;
    };

    Animator.prototype.resetTimes = function() {
      this.startMS = this.now();
      this.startTick = this.ticks;
      return this.startDraw = this.draws;
    };

    Animator.prototype.reset = function() {
      this.stop();
      return this.ticks = this.draws = 0;
    };

    Animator.prototype.step = function() {
      this.ticks++;
      return this.model.step();
    };

    Animator.prototype.draw = function() {
      this.draws++;
      return this.model.draw();
    };

    Animator.prototype.once = function() {
      this.step();
      if (!this.model.isHeadless) {
        return this.draw();
      }
    };

    Animator.prototype.now = function() {
      return (typeof performance !== "undefined" && performance !== null ? performance : Date).now();
    };

    Animator.prototype.ms = function() {
      return this.now() - this.startMS;
    };

    Animator.prototype.ticksPerSec = function() {
      var elapsed;
      elapsed = this.ticks - this.startTick;
      if (elapsed === 0) {
        return 0;
      } else {
        return Math.round(elapsed * 1000 / this.ms());
      }
    };

    Animator.prototype.drawsPerSec = function() {
      var elapsed;
      elapsed = this.draws - this.startDraw;
      if (elapsed === 0) {
        return 0;
      } else {
        return Math.round(elapsed * 1000 / this.ms());
      }
    };

    Animator.prototype.toString = function() {
      return ("ticks: " + this.ticks + ", draws: " + this.draws + ", rate: " + this.rate + " ") + ("tps/dps: " + (this.ticksPerSec()) + "/" + (this.drawsPerSec()));
    };

    Animator.prototype.animateSteps = function() {
      this.step();
      if (!this.stopped) {
        return this.timeoutHandle = setTimeout(this.animateSteps, 10);
      }
    };

    Animator.prototype.animateDraws = function() {
      if (this.model.isHeadless) {
        if (this.ticksPerSec() < this.rate) {
          this.step();
        }
      } else if (this.drawsPerSec() < this.rate) {
        if (!this.multiStep) {
          this.step();
        }
        this.draw();
      }
      if (!this.stopped) {
        return this.animatorHandle = requestAnimationFrame(this.animateDraws);
      }
    };

    Animator.prototype.animate = function() {
      if (this.multiStep) {
        this.animateSteps();
      }
      if (!(this.model.isHeadless && this.multiStep)) {
        return this.animateDraws();
      }
    };

    return Animator;

  })();

  ABM.Link = (function() {
    Link.prototype.id = null;

    Link.prototype.breed = null;

    Link.prototype.from = null;

    Link.prototype.to = null;

    Link.prototype.color = u.color.lightgray;

    Link.prototype.thickness = 2;

    Link.prototype.hidden = false;

    Link.prototype.label = null;

    Link.prototype.labelColor = u.color.black;

    Link.prototype.labelOffset = {
      x: 0,
      y: 0
    };

    function Link(from, to) {
      this.from = from;
      this.to = to;
      this.from.links.push(this);
      this.to.links.push(this);
    }

    Link.prototype.die = function() {
      this.breed.remove(this);
      this.from.links.remove(this);
      this.to.links.remove(this);
      return null;
    };

    Link.prototype.bothEnds = function() {
      return new ABM.Array(this.from, this.to);
    };

    Link.prototype.length = function() {
      return this.from.distance(this.to.position);
    };

    Link.prototype.otherEnd = function(agent) {
      if (this.from === agent) {
        return this.to;
      } else {
        return this.from;
      }
    };

    Link.prototype.draw = function(context) {
      var point, x, x0, y, y0, _ref1;
      context.save();
      context.strokeStyle = this.color.rgbString();
      context.lineWidth = this.model.patches.fromBits(this.thickness);
      context.beginPath();
      if (!this.model.patches.isTorus) {
        context.moveTo(this.from.position.x, this.from.position.y);
        context.lineTo(this.to.position.x, this.to.position.y);
      } else {
        point = u.closestTorusPoint(this.from.position, this.to.position, this.model.patches.width, this.model.patches.height);
        context.moveTo(this.from.position.x, this.from.position.y);
        context.lineTo(point.x, point.y);
        if (point.x !== this.to.position.x || point.y !== this.to.position.y) {
          point = u.closestTorusPoint(this.to.position, this.from.position, this.model.patches.width, this.model.patches.height);
          context.moveTo(this.to.position.x, this.to.position.y);
          context.lineTo(point.x, point.y);
        }
      }
      context.closePath();
      context.stroke();
      context.restore();
      if (this.label != null) {
        x0 = u.linearInterpolate(this.from.position.x, this.to.position.x, .5);
        y0 = u.linearInterpolate(this.from.position.y, this.to.position.y, .5);
        _ref1 = this.model.patches.patchXYtoPixelXY(x0, y0), x = _ref1[0], y = _ref1[1];
        return u.contextDrawText(context, this.label, x + this.labelOffset[0], y + this.labelOffset[1], this.labelColor);
      }
    };

    return Link;

  })();

  ABM.Links = (function(_super) {
    __extends(Links, _super);

    function Links() {
      Links.__super__.constructor.apply(this, arguments);
    }

    Links.prototype.create = function(from, toAgentOrAgents, initialize) {
      var object, to, toAgents, _i, _len;
      if (initialize == null) {
        initialize = function() {};
      }
      if (u.isArray(toAgentOrAgents)) {
        toAgents = toAgentOrAgents;
      } else {
        toAgents = [toAgentOrAgents];
      }
      for (_i = 0, _len = toAgents.length; _i < _len; _i++) {
        to = toAgents[_i];
        object = new this.agentClass(from, to);
        this.push(object);
        initialize(object);
      }
      return this;
    };

    Links.prototype.clear = function() {
      while (this.any()) {
        this.last().die();
      }
      return null;
    };

    Links.prototype.nodesWithDups = function() {
      var link, set, _i, _len;
      set = new this.model.Set;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        link = this[_i];
        set.push(link.from, link.to);
      }
      return set;
    };

    Links.prototype.nodes = function() {
      return this.nodesWithDups().uniq();
    };

    return Links;

  })(ABM.BreedSet);

  ABM.Model = (function() {
    Model.prototype.contextsInit = {
      patches: {
        z: 10,
        context: "2d"
      },
      drawing: {
        z: 20,
        context: "2d"
      },
      links: {
        z: 30,
        context: "2d"
      },
      agents: {
        z: 40,
        context: "2d"
      },
      spotlight: {
        z: 50,
        context: "2d"
      }
    };

    function Model(options) {
      var context, div, isHeadless, key, value, _ref1;
      div = options.div;
      isHeadless = options.isHeadless = options.isHeadless || (div == null);
      this.setWorld(options);
      this.contexts = {};
      if (!isHeadless) {
        (this.div = document.getElementById(div)).setAttribute('style', "position:relative; width:" + this.world.pxWidth + "px; height:" + this.world.pxHeight + "px");
        _ref1 = this.contextsInit;
        for (key in _ref1) {
          if (!__hasProp.call(_ref1, key)) continue;
          value = _ref1[key];
          this.contexts[key] = context = u.createLayer(this.div, this.world.pxWidth, this.world.pxHeight, value.z, value.context);
          if (context.canvas != null) {
            this.setContextTransform(context);
          }
          if (context.canvas != null) {
            context.canvas.style.pointerEvents = 'none';
          }
          u.elementTextParams(context, "10px sans-serif", "center", "middle");
        }
        this.drawing = this.contexts.drawing;
        this.drawing.clear = (function(_this) {
          return function() {
            return u.clearContext(_this.drawing);
          };
        })(this);
        this.contexts.spotlight.globalCompositeOperation = "xor";
      }
      this.Patches = this.extendWithModel(this.Patches);
      this.Patch = this.extendWithModel(this.Patch);
      this.Agents = this.extendWithModel(this.Agents);
      this.Agent = this.extendWithModel(this.Agent);
      this.Links = this.extendWithModel(this.Links);
      this.Link = this.extendWithModel(this.Link);
      this.Set = this.extendWithModel(this.Set);
      this.Animator = this.extendWithModel(this.Animator);
      this.animator = new this.Animator;
      this.refreshLinks = this.refreshAgents = this.refreshPatches = true;
      this.patches = new this.Patches(this.Patch, "patches");
      this.agents = new this.Agents(this.Agent, "agents");
      this.links = new this.Links(this.Link, "links");
      this.modelReady = false;
      this.globalNames = null;
      this.globalNames = u.ownKeys(this);
      this.globalNames.set = false;
      this.startup();
      u.waitOnFiles((function(_this) {
        return function() {
          _this.modelReady = true;
          _this.setup();
          if (!_this.globalNames.set) {
            return _this.globals();
          }
        };
      })(this));
    }

    Model.prototype.setWorld = function(options) {
      var defaults, halfDiameter, key, shift, value, worldDefaults, _base1, _base2;
      defaults = {
        isHeadless: false,
        Agents: ABM.Agents,
        Agent: ABM.Agent,
        Links: ABM.Links,
        Link: ABM.Link,
        Patches: ABM.Patches,
        Patch: ABM.Patch,
        Set: ABM.Set,
        Animator: ABM.Animator
      };
      worldDefaults = {
        patchSize: 13,
        mapSize: 32,
        isTorus: false,
        min: null,
        max: null
      };
      options = u.merge(defaults, options);
      options = u.merge(worldDefaults, options);
      this.world = {};
      for (key in options) {
        if (!__hasProp.call(options, key)) continue;
        value = options[key];
        if (typeof worldDefaults[key] !== 'undefined') {
          this.world[key] = value;
        } else {
          this[key] = value;
        }
      }
      halfDiameter = this.world.mapSize / 2;
      shift = 0;
      this.world.mapSize = null;
      if (Math.floor(halfDiameter) !== halfDiameter) {
        halfDiameter = Math.floor(halfDiameter);
      } else {
        shift = 1;
      }
      if ((_base1 = this.world).min == null) {
        _base1.min = {
          x: -1 * halfDiameter + shift,
          y: -1 * halfDiameter + shift
        };
      }
      if ((_base2 = this.world).max == null) {
        _base2.max = {
          x: halfDiameter,
          y: halfDiameter
        };
      }
      this.world.width = this.world.max.x - this.world.min.x + 1;
      this.world.height = this.world.max.y - this.world.min.y + 1;
      this.world.pxWidth = this.world.width * this.world.patchSize;
      this.world.pxHeight = this.world.height * this.world.patchSize;
      this.world.minCoordinate = {
        x: this.world.min.x - .5,
        y: this.world.min.y - .5
      };
      return this.world.maxCoordinate = {
        x: this.world.max.x + .5,
        y: this.world.max.y + .5
      };
    };

    Model.prototype.setContextTransform = function(context) {
      context.canvas.width = this.world.pxWidth;
      context.canvas.height = this.world.pxHeight;
      context.save();
      context.scale(this.world.patchSize, -this.world.patchSize);
      return context.translate(-this.world.minCoordinate.x, -this.world.maxCoordinate.y);
    };

    Model.prototype.globals = function(globalNames) {
      if (globalNames != null) {
        this.globalNames = globalNames;
        return this.globalNames.set = true;
      } else {
        return this.globalNames = u.ownKeys(this).removeItems(this.globalNames);
      }
    };

    Model.prototype.extendWithModel = function(original) {
      var extendedClass, model;
      model = this;
      extendedClass = (function(_super) {
        __extends(extendedClass, _super);

        extendedClass.model = model;

        extendedClass.prototype.model = model;

        function extendedClass() {
          extendedClass.__super__.constructor.apply(this, arguments);
        }

        return extendedClass;

      })(original);
      return extendedClass;
    };

    Model.prototype.setFastPatches = function() {
      return this.patches.usePixels();
    };

    Model.prototype.setMonochromePatches = function() {
      return this.patches.monochrome = true;
    };

    Model.prototype.startup = function() {};

    Model.prototype.setup = function() {};

    Model.prototype.step = function() {};

    Model.prototype.start = function() {
      u.waitOn(((function(_this) {
        return function() {
          return _this.modelReady;
        };
      })(this)), ((function(_this) {
        return function() {
          return _this.animator.start();
        };
      })(this)));
      this.isRunning = true;
      return this;
    };

    Model.prototype.stop = function() {
      this.animator.stop();
      this.isRunning = false;
      return this;
    };

    Model.prototype.toggle = function() {
      if (this.isRunning) {
        return this.stop();
      } else {
        return this.start();
      }
    };

    Model.prototype.once = function() {
      if (!this.animator.stopped) {
        this.stop();
      }
      this.animator.once();
      return this;
    };

    Model.prototype.reset = function() {
      this.animator.reset();
      this.isRunning = false;
      this.resetContexts();
      this.patches = new this.Patches(this.Patch, "patches");
      this.agents = new this.Agents(this.Agent, "agents");
      this.links = new this.Links(this.Link, "links");
      u.shapes.spriteSheets.length = 0;
      return this.setup();
    };

    Model.prototype.restart = function() {
      this.reset();
      return this.start();
    };

    Model.prototype.destroy = function() {
      this.stop();
      this.agents = this.patches = this.links = null;
      return this.resetContexts();
    };

    Model.prototype.resetContexts = function() {
      var key, value, _ref1, _results;
      _ref1 = this.contexts;
      _results = [];
      for (key in _ref1) {
        value = _ref1[key];
        if (value.canvas != null) {
          value.restore();
          _results.push(this.setContextTransform(value));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Model.prototype.draw = function(force) {
      if (force == null) {
        force = this.animator.stopped;
      }
      if (force || this.refreshPatches || this.animator.draws === 1) {
        this.patches.draw(this.contexts.patches);
      }
      if (force || this.refreshLinks || this.animator.draws === 1) {
        this.links.draw(this.contexts.links);
      }
      if (force || this.refreshAgents || this.animator.draws === 1) {
        this.agents.draw(this.contexts.agents);
      }
      if (this.spotlightAgent != null) {
        return this.drawSpotlight(this.spotlightAgent.position, this.contexts.spotlight);
      }
    };

    Model.prototype.setSpotlight = function(spotlightAgent) {
      this.spotlightAgent = spotlightAgent;
      console.log(this.spotlightAgent);
      if (this.spotlightAgent == null) {
        return u.clearContext(this.contexts.spotlight);
      }
    };

    Model.prototype.drawSpotlight = function(position, context) {
      u.clearContext(context);
      u.fillContext(context, u.color.from([0, 0, 0, 0.6]));
      context.beginPath();
      context.arc(position.x, position.y, 3, 0, 2 * Math.PI, false);
      return context.fill();
    };

    Model.prototype.createBreeds = function(list, type, agentClass, breedSet) {
      var breed, breedClass, breeds, className, resetType, string, _i, _len;
      breeds = [];
      breeds.classes = {};
      breeds.sets = {};
      resetType = false;
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        string = list[_i];
        if (string === type) {
          this[type] = new breedSet(agentClass, string);
        } else {
          className = string.charAt(0).toUpperCase() + string.substr(1);
          breedClass = this[className] = (function(_super) {
            __extends(_Class, _super);

            function _Class() {
              return _Class.__super__.constructor.apply(this, arguments);
            }

            return _Class;

          })(agentClass);
          breed = this[string] = new breedSet(breedClass, string, agentClass.prototype.breed);
          breeds.push(breed);
          breeds.sets[string] = breed;
          breeds.classes["" + string + "Class"] = breedClass;
        }
      }
      return this[type].breeds = breeds;
    };

    Model.prototype.patchBreeds = function(list) {
      return this.createBreeds(list, 'patches', this.Patch, this.Patches);
    };

    Model.prototype.agentBreeds = function(list) {
      return this.createBreeds(list, 'agents', this.Agent, this.Agents);
    };

    Model.prototype.linkBreeds = function(list) {
      return this.createBreeds(list, 'links', this.Link, this.Links);
    };

    return Model;

  })();

  ABM.Patch = (function() {
    Patch.prototype.id = null;

    Patch.prototype.breed = null;

    Patch.prototype.position = null;

    Patch.prototype.color = u.color.black;

    Patch.prototype.hidden = false;

    Patch.prototype.label = null;

    Patch.prototype.labelColor = u.color.black;

    Patch.prototype.labelOffset = {
      x: 0,
      y: 0
    };

    Patch.prototype.agents = null;

    function Patch(position) {
      this.position = position;
      this.neighborsCache = {};
      this.agents = new ABM.Array;
    }

    Patch.prototype.toString = function() {
      return ("{id: " + this.id + " position: {x: " + this.position.x + ", y: " + this.position.y + "}") + (", c: " + (this.color.join(", ")) + "}");
    };

    Patch.prototype.empty = function() {
      return this.agents.empty();
    };

    Patch.prototype.isOnEdge = function() {
      return this.position.x === this.breed.min.x || this.position.x === this.breed.max.x || this.position.y === this.breed.min.y || this.position.y === this.breed.max.y;
    };

    Patch.prototype.sprout = function(number, breed, init) {
      if (number == null) {
        number = 1;
      }
      if (breed == null) {
        breed = this.model.agents;
      }
      if (init == null) {
        init = function() {};
      }
      return breed.create(number, (function(_this) {
        return function(agent) {
          agent.moveTo(_this.position);
          init(agent);
          return agent;
        };
      })(this));
    };

    Patch.prototype.distance = function(point) {
      return u.distance(this.position, point, this.model.patches);
    };

    Patch.prototype.neighbors = function(options) {
      var cacheKey, neighbors, square;
      if (options == null) {
        options = 1;
      }
      if (u.isNumber(options)) {
        options = {
          range: options
        };
      }
      if ((options.cache == null) || options.cache) {
        cacheKey = JSON.stringify(options);
        neighbors = this.neighborsCache[cacheKey];
      }
      if (neighbors == null) {
        if (options.radius) {
          square = this.neighbors({
            range: options.radius,
            meToo: options.meToo
          }, {
            cache: options.cache
          });
          if (options.cone) {
            neighbors = square.inCone(this.position, options);
            if (!options.cache) {
              cacheKey = null;
            }
          } else {
            neighbors = square.inRadius(this.position, options);
          }
        } else if (options.diamond) {
          neighbors = this.diamondNeighbors(options.diamond, options.meToo);
        } else {
          neighbors = this.breed.patchRectangle(this, options.range, options.range, options.meToo);
        }
        if (cacheKey != null) {
          this.neighborsCache[cacheKey] = neighbors;
        }
      }
      return neighbors;
    };

    Patch.prototype.neighborAgents = function(options) {
      var agent, neighbors, notAgent, patch, _i, _j, _len, _len1, _ref1, _ref2;
      neighbors = new this.model.Set;
      notAgent = options.not;
      delete options.not;
      _ref1 = this.neighbors(options);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        patch = _ref1[_i];
        _ref2 = patch.agents;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          agent = _ref2[_j];
          if (agent !== notAgent) {
            neighbors.push(agent);
          }
        }
      }
      return neighbors;
    };

    Patch.prototype.diamondNeighbors = function(range, meToo) {
      var column, counter, diamond, distanceColumn, distanceRow, neighbor, neighbors, row, span, _i, _len;
      neighbors = this.breed.patchRectangleNullPadded(this, range, range, true);
      diamond = new this.model.Set;
      counter = 0;
      row = 0;
      column = -1;
      span = range * 2 + 1;
      for (_i = 0, _len = neighbors.length; _i < _len; _i++) {
        neighbor = neighbors[_i];
        row = counter % span;
        if (row === 0) {
          column += 1;
        }
        distanceColumn = Math.abs(column - range);
        distanceRow = Math.abs(row - range);
        if (distanceRow + distanceColumn <= range && (meToo || distanceRow + distanceColumn !== 0)) {
          diamond.push(neighbor);
        }
        counter += 1;
      }
      diamond.remove(null);
      return diamond;
    };

    Patch.prototype.draw = function(context) {
      var position;
      context.fillStyle = this.color.rgbString();
      context.fillRect(this.position.x - .5, this.position.y - .5, 1, 1);
      if (this.label != null) {
        position = this.breed.patchXYtoPixelXY(this.position);
        return u.contextDrawText(context, this.label, position.x + this.labelOffset.x, position.y + this.labelOffset.y, this.labelColor);
      }
    };

    return Patch;

  })();

  ABM.Patches = (function(_super) {
    __extends(Patches, _super);

    Patches.prototype.model = null;

    Patches.prototype.patchSize = null;

    Patches.prototype.isTorus = null;

    Patches.prototype.min = null;

    Patches.prototype.max = null;

    Patches.prototype.width = null;

    Patches.prototype.height = null;

    Patches.prototype.pxWidth = null;

    Patches.prototype.pxHeight = null;

    Patches.prototype.minCoordinate = null;

    Patches.prototype.maxCoordinate = null;

    function Patches() {
      var key, value, _ref1;
      Patches.__super__.constructor.apply(this, arguments);
      this.monochrome = false;
      _ref1 = this.model.world;
      for (key in _ref1) {
        if (!__hasProp.call(_ref1, key)) continue;
        value = _ref1[key];
        this[key] = value;
      }
    }

    Patches.prototype.create = function(position) {
      var x, y, _i, _j, _ref1, _ref2, _ref3, _ref4;
      if (position != null) {
        this.push(new this.agentClass(position));
      } else {
        for (y = _i = _ref1 = this.max.y, _ref2 = this.min.y; _i >= _ref2; y = _i += -1) {
          for (x = _j = _ref3 = this.min.x, _ref4 = this.max.x; _j <= _ref4; x = _j += 1) {
            this.create({
              x: x,
              y: y
            });
          }
        }
      }
      if (this.pixelsSet == null) {
        if (!this.model.isHeadless) {
          this.setPixels();
        }
        this.pixelsSet = true;
      }
      return this;
    };

    Patches.prototype.patch = function(point) {
      var coordinate, rounded;
      if (this.isCoordinate(point, this.min, this.max)) {
        coordinate = point;
      } else {
        coordinate = this.coordinate(point, this.min, this.max);
      }
      rounded = {
        x: Math.round(coordinate.x),
        y: Math.round(coordinate.y)
      };
      return this[this.patchIndex(rounded)];
    };

    Patches.prototype.coordinate = function(point, minPoint, maxPoint) {
      if (minPoint == null) {
        minPoint = this.minCoordinate;
      }
      if (maxPoint == null) {
        maxPoint = this.maxCoordinate;
      }
      if (this.isTorus) {
        return this.wrap(point, minPoint, maxPoint);
      } else {
        return this.clamp(point, minPoint, maxPoint);
      }
    };

    Patches.prototype.clamp = function(point, minPoint, maxPoint) {
      if (minPoint == null) {
        minPoint = this.minCoordinate;
      }
      if (maxPoint == null) {
        maxPoint = this.maxCoordinate;
      }
      return {
        x: u.clamp(point.x, minPoint.x, maxPoint.x),
        y: u.clamp(point.y, minPoint.y, maxPoint.y)
      };
    };

    Patches.prototype.wrap = function(point, minPoint, maxPoint) {
      if (minPoint == null) {
        minPoint = this.minCoordinate;
      }
      if (maxPoint == null) {
        maxPoint = this.maxCoordinate;
      }
      return {
        x: u.wrap(point.x, minPoint.x, maxPoint.x),
        y: u.wrap(point.y, minPoint.y, maxPoint.y)
      };
    };

    Patches.prototype.isCoordinate = function(point, minPoint, maxPoint) {
      var _ref1, _ref2;
      if (minPoint == null) {
        minPoint = this.minCoordinate;
      }
      if (maxPoint == null) {
        maxPoint = this.maxCoordinate;
      }
      return (minPoint.x <= (_ref1 = point.x) && _ref1 <= maxPoint.x) && (minPoint.y <= (_ref2 = point.y) && _ref2 <= maxPoint.y);
    };

    Patches.prototype.isOnWorld = function(point) {
      return this.isTorus || this.isCoordinate(point);
    };

    Patches.prototype.patchIndex = function(point) {
      return point.x - this.min.x + this.width * (this.max.y - point.y);
    };

    Patches.prototype.randomPoint = function() {
      return {
        x: u.randomFloat(this.minCoordinate.x, this.maxCoordinate.x),
        y: u.randomFloat(this.minCoordinate.y, this.maxCoordinate.y)
      };
    };

    Patches.prototype.toBits = function(patch) {
      return patch * this.patchSize;
    };

    Patches.prototype.fromBits = function(bit) {
      return bit / this.patchSize;
    };

    Patches.prototype.patchRectangle = function(patch, dx, dy, meToo) {
      var rectangle;
      if (meToo == null) {
        meToo = false;
      }
      rectangle = this.patchRectangleNullPadded(patch, dx, dy, meToo);
      return rectangle.remove(null);
    };

    Patches.prototype.patchRectangleNullPadded = function(patch, dx, dy, meToo) {
      var nextPatch, rectangle, x, y, _i, _j, _ref1, _ref2, _ref3, _ref4;
      if (meToo == null) {
        meToo = false;
      }
      rectangle = new this.model.Set;
      for (y = _i = _ref1 = patch.position.y - dy, _ref2 = patch.position.y + dy; _i <= _ref2; y = _i += 1) {
        for (x = _j = _ref3 = patch.position.x - dx, _ref4 = patch.position.x + dx; _j <= _ref4; x = _j += 1) {
          nextPatch = null;
          if (this.isTorus) {
            if (x < this.min.x) {
              x += this.width;
            }
            if (x > this.max.x) {
              x -= this.width;
            }
            if (y < this.min.y) {
              y += this.height;
            }
            if (y > this.max.y) {
              y -= this.height;
            }
            nextPatch = this.patch({
              x: x,
              y: y
            });
          } else if (x >= this.min.x && x <= this.max.x && y >= this.min.y && y <= this.max.y) {
            nextPatch = this.patch({
              x: x,
              y: y
            });
          }
          if (meToo || patch !== nextPatch) {
            rectangle.push(nextPatch);
          }
        }
      }
      if (this.isTorus && (dx * 2 + 1 > this.width || dy * 2 + 1 > this.height)) {
        rectangle.uniq();
      }
      return rectangle;
    };

    Patches.prototype.importDrawing = function(imageSrc, f) {
      return u.importImage(imageSrc, (function(_this) {
        return function(image) {
          _this.installDrawing(image);
          if (f != null) {
            return f();
          }
        };
      })(this));
    };

    Patches.prototype.installDrawing = function(image, context) {
      if (context == null) {
        context = this.model.contexts.drawing;
      }
      u.setIdentity(context);
      context.drawImage(image, 0, 0, context.canvas.width, context.canvas.height);
      return context.restore();
    };

    Patches.prototype.pixelByteIndex = function(patch) {
      return 4 * patch.id;
    };

    Patches.prototype.pixelWordIndex = function(patch) {
      return patch.id;
    };

    Patches.prototype.pixelXYtoPatchXY = function(x, y) {
      return [this.minCoordinate.x + (x / this.patchSize), this.maxCoordinate.y - (y / this.patchSize)];
    };

    Patches.prototype.patchXYtoPixelXY = function(x, y) {
      return [(x - this.minCoordinate.x) * this.patchSize, (this.maxCoordinate.y - y) * this.patchSize];
    };

    Patches.prototype.drawScaledPixels = function(context) {
      if (this.patchSize !== 1) {
        u.setIdentity(context);
      }
      if (this.pixelsData32 != null) {
        this.drawScaledPixels32(context);
      } else {
        this.drawScaledPixels8(context);
      }
      if (this.patchSize !== 1) {
        return context.restore();
      }
    };

    Patches.prototype.drawScaledPixels8 = function(context) {
      var color, data, i, j, patch, transparency, _i, _j, _len;
      data = this.pixelsData;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        patch = this[_i];
        i = this.pixelByteIndex(patch);
        color = patch.color;
        if (color.length === 4) {
          transparency = color[3];
        } else {
          transparency = 255;
        }
        for (j = _j = 0; _j <= 2; j = ++_j) {
          data[i + j] = color[j];
        }
        data[i + 3] = transparency;
      }
      this.pixelsContext.putImageData(this.pixelsImageData, 0, 0);
      if (this.patchSize === 1) {
        return;
      }
      return context.drawImage(this.pixelsContext.canvas, 0, 0, context.canvas.width, context.canvas.height);
    };

    Patches.prototype.drawScaledPixels32 = function(context) {
      var color, data, i, patch, transparency, _i, _len;
      data = this.pixelsData32;
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        patch = this[_i];
        i = this.pixelWordIndex(patch);
        color = patch.color;
        if (color.length === 4) {
          transparency = color[3];
        } else {
          transparency = 255;
        }
        if (this.pixelsAreLittleEndian) {
          data[i] = (transparency << 24) | (color[2] << 16) | (color[1] << 8) | color[0];
        } else {
          data[i] = (color[0] << 24) | (color[1] << 16) | (color[2] << 8) | transparency;
        }
      }
      this.pixelsContext.putImageData(this.pixelsImageData, 0, 0);
      if (this.patchSize === 1) {
        return;
      }
      return context.drawImage(this.pixelsContext.canvas, 0, 0, context.canvas.width, context.canvas.height);
    };

    Patches.prototype.diffuse = function(variable, rate, color) {
      var dv, dv8, neighbor, nn, patch, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref1;
      if (this[0]._diffuseNext == null) {
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          patch = this[_i];
          patch._diffuseNext = 0;
        }
      }
      for (_j = 0, _len1 = this.length; _j < _len1; _j++) {
        patch = this[_j];
        dv = patch[variable] * rate;
        dv8 = dv / 8;
        nn = patch.neighbors().length;
        patch._diffuseNext += patch[variable] - dv + (8 - nn) * dv8;
        _ref1 = patch.neighbors();
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          neighbor = _ref1[_k];
          neighbor._diffuseNext += dv8;
        }
      }
      for (_l = 0, _len3 = this.length; _l < _len3; _l++) {
        patch = this[_l];
        patch[variable] = patch._diffuseNext;
        patch._diffuseNext = 0;
        if (color) {
          patch.color = color.fraction(patch[variable]);
        }
      }
      return null;
    };

    Patches.prototype.usePixels = function(drawWithPixels) {
      var context;
      this.drawWithPixels = drawWithPixels != null ? drawWithPixels : true;
      context = this.model.contexts.patches;
      return u.setContextSmoothing(context, !this.drawWithPixels);
    };

    Patches.prototype.setPixels = function() {
      if (this.patchSize === 1) {
        this.usePixels();
        this.pixelsContext = this.model.contexts.patches;
      } else {
        this.pixelsContext = u.createContext(this.width, this.height);
      }
      this.pixelsImageData = this.pixelsContext.getImageData(0, 0, this.width, this.height);
      this.pixelsData = this.pixelsImageData.data;
      if (this.pixelsData instanceof Uint8Array) {
        this.pixelsData32 = new Uint32Array(this.pixelsData.buffer);
        return this.pixelsAreLittleEndian = u.isLittleEndian();
      }
    };

    Patches.prototype.draw = function(context) {
      if (this.monochrome) {
        return u.fillContext(context, this.agentClass.prototype.color);
      } else if (this.drawWithPixels) {
        return this.drawScaledPixels(context);
      } else {
        return Patches.__super__.draw.call(this, context);
      }
    };

    return Patches;

  })(ABM.BreedSet);

}).call(this);
