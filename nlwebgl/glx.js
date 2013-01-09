// Utilities for WebGL used in Ed Angel's Interactive Graphics w/ OpenGL class.
// Module/Patterns: JavaScript Patterns by Stoyan Stefanov http://goo.gl/dbXJL
/* For js shell usage:
load("/Users/owen/src/webgl/utils/glMatrix.js")
load("/Users/owen/src/webgl/ch2/glx.js")
*/
// http://www.crockford.com/javascript/inheritance.html
// http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetActiveUniform.xml

var glx = (function() {

    // Initialize WebGL given a canvas element name
    // note: gl.canvas is original canvas element
    function initGL(canvasID, aspectRatio, contextAttribs) {
        var canvas = document.getElementById(canvasID);
        if (!canvas) {
            alert("Could not find canvas.");
        }
        aspectRatio = aspectRatio || canvas.offsetWidth/canvas.offsetHeight;
        var gl = canvas.getContext("experimental-webgl",contextAttribs);
        if (!gl) {
            alert("Could not initialise WebGL.");
        }
        resizeCanvas(gl, aspectRatio);
        gl.viewport(0, 0, canvas.width, canvas.height);
        //glx.gl = gl;
        //gl.canvasElement = canvas;
// console.log("canvas: " + (canvas === gl.canvas)); // false!  but true in console!
// gl.canvas === document.getElementById("canvas") => true!!
        return gl;
    };
    function resizeCanvas(gl, aspectRatio) { // call onresize
        var canvas = gl.canvas;
        canvas.width = canvas.offsetWidth;
        canvas.height = aspectRatio ? canvas.width/aspectRatio : canvas.offsetHeight;
        gl.viewport(0, 0, canvas.width, canvas.height);
    };
    function aspectRatio(gl) {
		var viewport = gl.getParameter( gl.VIEWPORT );
		return viewport[2]/viewport[3];
    };

    // Get a file as a string using either AJAX or DOM element
    function loadFileAJAX(name) {
        var xhr = new XMLHttpRequest(),
            okStatus = document.location.protocol === "file:" ? 0 : 200;
        xhr.open('GET', name, false);
        xhr.send(null);
        return xhr.status == okStatus ? xhr.responseText : null;
    };
    function loadFileDOM(name) {
        var src = document.getElementById(name);
        return src ? src.firstChild.nodeValue : null;
    };
    function loadFile(name) {
        return name.match(/\./) ? loadFileAJAX(name) : loadFileDOM(name);
    };
    
    // Initialize WebGL program object given its vertex/fragment shader names
    // Note the program is available via: gl.getParameter(gl.CURRENT_PROGRAM)
    function initShaders(gl, vShaderName, fShaderName, attribs, uniforms) {
        function getShader(gl, shaderName, type) {
            var shader = gl.createShader(type),
                shaderScript = loadFile(shaderName);
            if (!shaderScript) {
                alert("Could not find shader source: "+shaderName);
            }
            //gl.shaderSource(shader, shaderScript);
            gl.shaderSource(shader, shaderScript);
            gl.compileShader(shader);

            if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
                alert(gl.getShaderInfoLog(shader));
                return null;
            }
            return shader;
        }
        var vertexShader = getShader(gl, vShaderName, gl.VERTEX_SHADER),
            fragmentShader = getShader(gl, fShaderName, gl.FRAGMENT_SHADER),
            program = gl.createProgram();

        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        gl.linkProgram(program);

        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
            alert("Could not initialise shaders");
            return null;
        }
        
        gl.useProgram(program);
        setProgVars(gl, attribs, uniforms);
        
        return program;
    };
    // Very Important: get the attrib and uniform locations during initialization!
    // vertexAttribPointer: Avg: 1us. Total: 1ms.
    // getAttribLocation: Avg: 182us. Total: 182ms.
    // getUniformLocation: Avg: 186us. Total: 186ms.
    // uniform1f: Avg: 1us. Total: 1ms.
    // Note: 60fps = 1 frame every 16.6ms
    
    function setProgVars(gl, attribs, uniforms) {
        var prog = gl.getParameter(gl.CURRENT_PROGRAM);
        // attribs = attribs ? attribs : [];
        // uniforms = uniforms ? uniforms : [];
        attribs = attribs || [];
        uniforms = uniforms || [];
        attribs.forEach(function(v){
            prog[v] = gl.getAttribLocation(prog, v);
            // don't enable: may not be an attrib array, but a constant.
            //gl.enableVertexAttribArray(prog[v]);
            prog[v+"Info"] = attribInfo(gl, prog[v])
        });
        uniforms.forEach(function(v){
            prog[v] = gl.getUniformLocation(prog, v);
            prog[v+"Info"] = uniformInfo(gl, prog[v])
        });
    }
    
    // http://www.khronos.org/opengles/sdk/docs/man/xhtml/glGetActiveAttrib.xml
    // attr types can only be: GL_FLOAT, GL_FLOAT_VEC2, GL_FLOAT_VEC3, 
    // GL_FLOAT_VEC4, GL_FLOAT_MAT2, GL_FLOAT_MAT3, or GL_FLOAT_MAT4
    var GlslVariableTypesTable = { // add the uniform setting proc?
        "BYTE":           0x1400,   //    5120
        "UNSIGNED_BYTE":  0x1401,   //    5121
        "SHORT":          0x1402,   //    5122
        "UNSIGNED_SHORT": 0x1403,   //    5123
        "INT":            0x1404,   //    5124
        "UNSIGNED_INT":   0x1405,   //    5125
        "FLOAT":          0x1406,   //    5126
        "FLOAT_VEC2":     0x8B50,   //    35664
        "FLOAT_VEC3":     0x8B51,   //    35665
        "FLOAT_VEC4":     0x8B52,   //    35666
        "INT_VEC2":       0x8B53,   //    35667
        "INT_VEC3":       0x8B54,   //    35668
        "INT_VEC4":       0x8B55,   //    35669
        "BOOL":           0x8B56,   //    35670
        "BOOL_VEC2":      0x8B57,   //    35671
        "BOOL_VEC3":      0x8B58,   //    35672
        "BOOL_VEC4":      0x8B59,   //    35673
        "FLOAT_MAT2":     0x8B5A,   //    35674
        "FLOAT_MAT3":     0x8B5B,   //    35675
        "FLOAT_MAT4":     0x8B5C,   //    35676
        "SAMPLER_2D":     0x8B5E,   //    35678
        "SAMPLER_CUBE":   0x8B60    //    35680
    };
    function attribInfo(gl, attrib) {
        // size: size of attr variable;
        // type: enum (above) of attr type
        // name: name of attr
        // + typeName: name of enum (above)
        //   typeSize: number in typeName
        var program = gl.getParameter(gl.CURRENT_PROGRAM),
            info = gl.getActiveAttrib(program, attrib);
        info.typeName = okey(GlslVariableTypesTable, info.type)[0];
        //info.typeSize = Number(info.typeName.replace(/\D*/,""));
        info.typeSize = Number(info.typeName.slice(-1).replace(/\D*/,""));
        info.typeSize = info.typeSize || 1;
        return info;
    }
    function uniformInfo(gl, uniform) {
        var program = gl.getParameter(gl.CURRENT_PROGRAM),
            info = gl.getActiveUniform(program, uniform);
//glx.printf("prog: {0} info: {1} type:{2}", program, info, info.type)
        info.typeName = okey(GlslVariableTypesTable, info.type)[0];
//glx.printf("info.typeName: {0} ", info.typeName)
        info.typeSize = Number(info.typeName.slice(-1).replace(/\D*/,""));
        info.typeSize = info.typeSize || 1;
        return info;
    }
    function initBuf(gl, buffer, array, glslName, cols) { // uses current program
        //var isflat = typeof array[0] == "number"; //!Array.isArray(array[0]),
        var isflat = !Array.isArray(array[0]),
            program = gl.getParameter(gl.CURRENT_PROGRAM);

        buffer.attribName = glslName;
        buffer.elemType = (glslName)?gl.FLOAT:gl.UNSIGNED_SHORT;
        buffer.typedArray = (glslName)?Float32Array:Uint16Array;
        buffer.target = (glslName)?gl.ARRAY_BUFFER:gl.ELEMENT_ARRAY_BUFFER;
		buffer.cols = isflat ? ( (cols) ? cols : 1) : array[0].length;
		buffer.rows = isflat ? array.length/buffer.cols : array.length;

        modBuf(gl, buffer, array); // binds buffer, sends array to gpu
        
        // NOTE: place attrib location in program for this buffer.
        // REMIND: fix so that one buffer can be used by many programs.
        //      OK to require using same attr name in all programs?
        //      Maybe let glslName be either a string/name or attrib/loc
        if(glslName) { // connect program to buffer
            if(!program[glslName])
                program[glslName] = gl.getAttribLocation(program, glslName);
            gl.enableVertexAttribArray(program[glslName]);
            // webgl-debug: avoid INVALID_OPERATION in drawArrays
            // but seems harmless and may only occur w/ multi program
            // gl.vertexAttribPointer(program[glslName], 
            //     buffer.cols, buffer.elemType, false, 0, 0);
        }
        return buffer;
    }
    // does not need program
    function modBuf(gl, buffer, array) {
        var isflat = !Array.isArray(array[0]);
        // REMIND: Temp!
        buffer.array = array;
        array = new buffer.typedArray(isflat ? array : flatten(array));
        gl.bindBuffer(buffer.target, buffer);
        gl.bufferData(buffer.target, array, gl.STATIC_DRAW);
    }
    // uses current program if program null
    // buffer can be array of buffers to be set
    function setBuf(gl, buffer, program) {
        if (Array.isArray(buffer)) {
            buffer.forEach(function f(b){setBuf(gl,b,program)})
        } else {
            gl.bindBuffer(buffer.target, buffer);
            if(buffer.attribName) {
                program = program || gl.getParameter(gl.CURRENT_PROGRAM);
                gl.vertexAttribPointer(program[buffer.attribName], 
                    buffer.cols, buffer.elemType, false, 0, 0);
            }
        }
    }
    // function setUniformMatrix(gl, uniformName, matrix) {
    //     var program = gl.getParameter(gl.CURRENT_PROGRAM);
    //     gl.uniformMatrix4fv(program[uniformName], false, matrix);
    // }
    // function setUniform(gl, uniformFcn, uniformName, uniformValue) {
    //     var program = gl.getParameter(gl.CURRENT_PROGRAM);
    //     uniformFcn(program[uniformName], uniformValue);
    // }
    // pixels can be:
    //      - a matrix of Uint pixels
    //      - an image
    //      - a 2 element array: [width, height] for FBO textures (pixels -> null)
    function initTexture(gl, target, texture, pixels, mag, min, s, t) {
        var w, h;
        gl.activeTexture(target);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        if (Array.isArray(pixels)) {
            if (Array.isArray(pixels[0])){
                h = pixels.length; w = pixels[0].length;
                pixels = new Uint8Array(flatten(flatten(pixels)));
                gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
            } else {
                w = pixels[0]; h = pixels[1]; pixels = null;
            }
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, 
                w, h, 0, gl.RGB, gl.UNSIGNED_BYTE, pixels);
        } else {
            gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 
                gl.RGBA, gl.UNSIGNED_BYTE, pixels);
        }
        setTexParams(gl, mag, min, s, t);
        texture.target = target;
        return texture;
    }
    function setTexParams(gl, mag, min, s, t) {
        // http://goo.gl/NPddy MIN_FILTER is NEAREST_MIPMAP_LINEAR 
        // Reasonable to set all 4 for certainty
        if (!s) {s=min; t=min; min=mag;} // input: interp, interp, wrap, wrap
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, mag);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, min);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, s);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, t);
    }
    function setTexture(gl, target, texture, uniform){
        gl.activeTexture(target);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.uniform1i(uniform, target-gl.TEXTURE0);
    }
    
    // Get/Set don't need cache; glx.timeit(1000,function(){glx.getHTML("diffusionRate",2)}) = 5us
    function setHTML(id, value, precision) {
        var elem =  document.getElementById(id);
        if(precision !== null) {
            value = Number(value).toFixed(precision);
        }
        elem.innerHTML = value;
    }
    function getHTML(id, precision) { // return string if precision null, number otherwise
        var value = document.getElementById(id).innerHTML;
        // if(precision !== null) {
        //     value = Number(Number(value).toFixed(precision));
        // }
        return precision == null ? value : Number(Number(value).toFixed(precision));
    }
    // function getValue(id) {
    //     var elem =  document.getElementById(id);        
    // }
    function toggleButton(name, names) { // names[0] => true
        var value = document.getElementsByName(name)[0].value,
            result = (value==names[0]);
        document.getElementsByName(name)[0].value=(result)?names[1]:names[0];
        return result;
    }


    // Flatten an array of arrays into a single array (for GL buffers)
    // REMIND: convert to use slice?
    function flatten(m) {
        var result = [],
            i, j;
        for (i = 0; i < m.length; i++) {
            for (j = 0; j < m[i].length; j++) {
                result.push(m[i][j]);
            }
        }
        return result;
    };

    // Return random integer in [0,max)
    function randomInt(max) {
        return Math.floor(Math.random() * max);
    };
    // Return random integer in [from,to]
    function randomFromTo(from, to) {
        return Math.floor(Math.random() * (to - from + 1) + from);
    };
    function degToRad(degrees) {
        return degrees * Math.PI / 180;
    };
    function radToDeg(radians) {
        return radians * 180 / Math.PI;
    };
    function randomColor(min) {
        min = min || .1;
        return [min + (1-min)*Math.random(),
                min + (1-min)*Math.random(),
                min + (1-min)*Math.random()];
    };
    function clamp(val, min, max) {
        return Math.max(Math.min(val,max),min);
    }
    function timeit(n,f) {
        var t = new Date().getTime(),
            nn = n;
        while(nn--) f();
        t =  new Date().getTime() - t;
        return "Avg: "+Math.round(t*1000/n)+"us. Total: "+ t + "ms.";
        //return "Avg: "+(t*1000/n)+" µs. Total: "+ t + " ms."; // &#181;
    }

    function vop(v1, v2, f, dest) {
        dest = dest || [];
        for (var i = 0; i < v1.length; i++) {
            dest[i] = f(v1[i], v2[i], i);
        }
        return dest;
    };
    function vclone(v) {
        return v.slice(0);
    };
    // forEach, map etc don't work: v's undefined initially.
    function vrange(n, start, step) {
        start = start || 0;
        step = step || 1;
        return vmod(new Array(n), function(v,i){return start + i*step;});
        //or: repeat(n,function(i,o){o[i]=start + i*step},[])
    }
    // modify each element of an array.
    // note v.map creates new array == vmod(v,f,[]) .. i.e. vmod w/ non-null dest
    function vmod(v, f, dest) {
        dest = dest || v;
        for (var i = 0; i < v.length; i++) {
            dest[i] = f(v[i], i);
        }
        return dest;
    };
    // prefer map/filter/forEach .. or vmod 
    // note map/forEach fail for typedArrays and forEach does not return the array.
    // earlier version pushed v[i] if f true, i.e. == v.filter(f)
    function venum(v, f, dest) {
        dest = dest || [];
        for (var i = 0; i < v.length; i++) {
            f(v[i], i, dest);
        }
        return dest;
    };

    function repeat(n, o, f) {
        for (var i = 0; i < n; i++) {f(i,o)}
        return o;
    };

    
    function oenum(obj, f, result) {
        result = result || [];
        for (var key in obj) {
            if (obj.hasOwnProperty(key))
                f(key, obj[key], result);
        }
        return result;
    };
    function okeys(o) {
        //return oenum(o, function(k, v, r){r.push(k)});
        return Object.keys(o);
    }
    function ovals(o) {
        return oenum(o, function(k,v,r){r.push(v)})
    }
    function okeyvals(o) {
        function val(v){return (typeof v=="object")?v.constructor.name:v;}
        return oenum(o, function(k, v, r){r.push(k+":"+val(v))});
    }
    function okey(o,val){
        var result = oenum(o,function(k,v,r){if(v===val){r.push(k)}});
        // if (result.length = 0) 
        //     result = null;
        // else if  (result.length = 1) 
        //     result = result[0];
        return result;
    }
    // function omatch(o, o1) {
    //     return oenum(o, function(k,v,r){r.push(v===o1[k])}).indexOf(false)==-1
    // }
    function oclone(o) {
        return oenum(o, function(k,v,r){r[k]=v},{});
    }
    // YAHOO.Tools.printf: printf("Showing {0} of {1}.", 1, 2)
    function sprintf() { 
        var num = arguments.length; 
        var oStr = arguments[0];   
        for (var i = 1; i < num; i++) { 
              var pattern = "\\{" + (i-1) + "\\}"; 
              var re = new RegExp(pattern, "g"); 
              oStr = oStr.replace(re, arguments[i]); 
        } 
        return oStr; 
    }
    function printf() {
        console.log(sprintf.apply(null,arguments));
    }

    var fixedPrecision = 5;
    function ffixed(f,n) {
        var exp = Math.pow(10, n || fixedPrecision);
        return Math.round(f*exp)/exp;
    }
    function vfixed(v,dest,n) {
        return vmod(v, function(vi){return ffixed(vi,n);}, dest);
    }
    

    var matrixStack = [];
    function pushMatrix(matrix) {
        matrixStack.push(mat4.create(matrix));
    }
    function popMatrix() {
        if (matrixStack.length == 0) {
            throw "Invalid popMatrix!";
        }
        return matrixStack.pop();
    }
    
    // neighbors = [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]],
    // quad=[ [0, 0], [1, 0], [1, 1], [0, 1] ]
    function quadToTriangles(quad, dx, dy, verts, indices) {
        quad = quad.slice(0); //don't modify input quad
        if (!indices) quad.splice(-1,0,quad[0],quad[2]);
        quad.forEach(function(v,i,a){
            // note: cannot use v[0]+=dx etc, last 2 verts are dups!
            a[i]=[v[0]+dx, v[1]+dy];
            if(verts) verts.push(a[i]);
        });
        if (indices) {
            var iStart = (indices.length==0) ? 0 : indices[indices.length-1]+1;
            [0,1,2,0,2,3].forEach(function(v,i,a){indices.push(iStart+v)});
        }
        return quad;
    }
    // function quadToTriangleIndices(quad, dx, dy, iArray, qArray) {
    //     quad = [0,1,2,0,2,3];
    //     quad.forEach(function(v,i,a){
    //         // note: cannot use v[0]+=dx etc, last 2 verts are dups!
    //         a[i]=[v[0]+dx, v[1]+dy];
    //         if(array) array.push(a[i]);
    //     });
    //     return quad;
    // }
    function quadToLines(quad, dx, dy) {
        var result = [];
        quad.forEach(function(v,i,a){
            var vert = [v[0]+dx, v[1]+dy];
            result.push(vert, vert);
        });
        result.push(result.shift());
        return result;
    }
    function pushVerts(shape, verts) {
        shape.forEach(function(v){verts.push(v);});
    }
    function pushN(n, obj, verts) {
        repeat(n, verts, function(){verts.push(obj)});
        return verts;
    }

    
    // skip browser specific code if running in js shell
    if(typeof window !== "undefined") {
        // Querks-mode for browser anamation utility due to standard not yet set.
        window.requestAnimFrame = (function() {
            return window.requestAnimationFrame ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame ||
            window.oRequestAnimationFrame ||
            window.msRequestAnimationFrame ||
            function(callback, element) {
                window.setTimeout(callback, 1000 / 60);
            };
        })();
        // http://paulirish.com/2011/requestanimationframe-for-smart-animating/
        // An anamation utility taking a user defined function
        // The passed function f can access animation parameters:
        //  glx.animFrame: The current frame, starting at 1.
        //  glx.animTime: How long the animation has been running.
        // REMIND: fix fps, pass canvas to requestAnimFrame(f,c), check time arg to f.
        //      - Tried canvas passed to requestAnimFrame, no luck
        function animate(f, canvas, fps) {
            var animStart = new Date().getTime(),
                lastTime = 0;
            //animProc = f;
            glx.animFrame = 0;
            glx.animTime = 0;
            glx.animPause = false;
            function anim() {
                requestAnimFrame(anim, canvas);
                if(glx.animPause) return;
                //if( fps && ((new Date().getTime()-lastTime)/1000)<1/fps ) return;
                lastTime = glx.animTime;
                glx.animTime = new Date().getTime() - animStart;
                glx.animFrame++; // frame 1 is first
                f();
            };
            anim();
        };
        // debug
        var winNames = {};
        oenum(window, function(key){winNames[key]=key;});
        delete winNames["glx"]; // so we show up
        // glx.checkGlobals()
        function checkGlobals() {
            oenum(window, function(key) {
                if (!winNames[key]) {
                    console.log(key);
                }
            });
        }
        function NLMouseNav(gl, look, display) {
            var uiStartX, uiStartY;
            gl.canvas.addEventListener("mousedown", mouseDown, false);
            gl.canvas.addEventListener("mouseup", mouseUp, false);
            gl.canvas.addEventListener("mouseout", mouseUp, false);
            gl.canvas.addEventListener('mousewheel', mouseScroll, false);  
            function mouseDown(e) {
                uiStartX = e.offsetX;
                uiStartY = e.offsetY;
                gl.canvas.addEventListener("mousemove", mouseDrag, false);
            }
            function mouseUp(e) {
                gl.canvas.removeEventListener("mousemove", mouseDrag,  false);
            }
            function mouseScroll(e) {
                var N = vec3.normalize(look.eye,[]),
                    l = vec3.length(look.eye),
                    dr = -.01*gl.canvas.height*(e.wheelDelta/120); //120=1 wheel click
                    //dr = -.005*gl.canvas.height*e.wheelDelta; // use canvas sizes?
                    //dr = -e.wheelDelta; // use canvas sizes?
//glx.printf("wheelDelta: {0}", e.wheelDelta)
                if( (dr < 0) && (l+dr <= 1) ) {
                    look.eye=N;
                } else {
                    vec3.scale(N, dr);
                    vec3.add(look.eye,N);
                }
                if (glx.animPause) display();
                e.cancelBubble = true;
                e.returnValue = false;
                return false;
            }
            function mouseDrag(e) {
                var dx = uiStartX - e.offsetX,
                    dy = uiStartY - e.offsetY,
                    PI=Math.PI,
                    D=PI/180,
                    dax = 2*PI*(dx/gl.canvas.width),
                    day = PI*(dy/gl.canvas.height),
                    Nr = vec3.cross([0,0,1], look.eye, []),
                    theta = Math.acos(vec3.dot(look.eye,[0,0,1])/vec3.length(look.eye)),
                    mat = mat4.identity([]);
                // if ((theta+day+4*D) > PI/2) day = PI/2 - theta - 1*D;
                // if ((theta+day-4*D) < 0) day = 0 - theta + 1*D;
                if ((theta+day+D) >= PI/2) day = PI/2 - theta - 1*D;
                if ((theta+day-D) <= 0) day = 0 - theta + 1*D;

                mat4.rotate(mat, day, Nr);   
                mat4.rotateZ(mat, dax);
                mat4.multiplyVec3(mat, look.eye);

                vec3.cross(look.eye, Nr, look.up);
                vec3.normalize(look.up);

//glx.printf("look: eye: {0} at: {1} up: {2}", look.eye, look.at, look.up)
                if (glx.animPause) display();
                uiStartX = e.offsetX;
                uiStartY = e.offsetY;
            }
        }
    } else {
        var animate = null,
            NLMouseNav = null,
            checkGlobals = null;
    }

    // public interface
    return {
        checkGlobals: checkGlobals,
        loadFile: loadFile,
        initGL: initGL,
        resizeCanvas: resizeCanvas,
        //gl: null,
        aspectRatio: aspectRatio,
        initShaders: initShaders,
        setProgVars: setProgVars,
        randomInt: randomInt,
        randomFromTo: randomFromTo,
        randomColor: randomColor,
        degToRad: degToRad,
        radToDeg: radToDeg,
        clamp: clamp,
        flatten: flatten,
        timeit: timeit,
        pushMatrix: pushMatrix,
        popMatrix: popMatrix,
        quadToTriangles: quadToTriangles,
        quadToLines: quadToLines,
        pushVerts: pushVerts,
        pushN: pushN,
        initBuf: initBuf,
        setBuf: setBuf,
        modBuf: modBuf,
        // setUniformMatrix: setUniformMatrix,
        // setUniform: setUniform,
        initTexture: initTexture,
        setTexture: setTexture,
        setHTML: setHTML,
        getHTML: getHTML,
        toggleButton: toggleButton,
        vmod: vmod,
        venum: venum,
        vrange: vrange,
        vclone: vclone,
        repeat: repeat,
        oenum: oenum,
        okeys: okeys,
        ovals: ovals,
        okey: okey,
        //omatch: omatch,
        okeyvals: okeyvals,
        oclone: oclone,
        printf: printf,
        sprintf: sprintf,
        ffixed: ffixed,
        vfixed: vfixed,
        NLMouseNav: NLMouseNav,
        animate: animate,
        animPause: false,
        animFrame: 0,
        animTime: 0
    };
} ());
