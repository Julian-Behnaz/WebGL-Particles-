import vertSrc from './vert.glsl';
import fragSrc from './frag.glsl';

import * as Stats from "stats.js"
let stats = new Stats();
stats.showPanel(0); // 0: fps, 1: ms, 2: mb, 3+: custom
stats.dom.style.left = "auto";
stats.dom.style.right = "0";
stats.dom.style.top = "50px";
document.body.appendChild(stats.dom);

let currWindAmp = 0;
const websocket = new WebSocket('ws://localhost:5000');
websocket.binaryType = 'arraybuffer';
websocket.addEventListener('message', (message) => {
    const dv = new DataView(message.data);
    currWindAmp = dv.getFloat32(0, true);
});


const canvas = document.querySelector("#main") as HTMLCanvasElement;

const gl = canvas.getContext("webgl2");
if(!gl){
    // No webgl support in this browser session
    // TODO: explain.
}

enum ShaderType {
    Vertex = gl.VERTEX_SHADER,
    Fragment = gl.FRAGMENT_SHADER
}

const vertexShader = createShader(gl, ShaderType.Vertex, vertSrc);
const fragmentShader = createShader(gl, ShaderType.Fragment, fragSrc);
const program = createProgram(gl, vertexShader, fragmentShader);

const positionAttributeLocation = gl.getAttribLocation(program, "a_position");
const timeUniformLocation= gl.getUniformLocation(program, "u_time");
const windAmpUniformLoc = gl.getUniformLocation(program, "u_windAmp");
const dimsUniformLocation = gl.getUniformLocation(program, "u_dims");
const smoothData= gl.getUniformLocation(program,"u_smooth");

const positionBuffer = gl.createBuffer();
{
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    
    // // WebGL Context:
    // {
    //     ARRAY_BUFFER = positionBuffer
    // }
    
/* 
 (-1,1)------------(1,1)
       |          / |
       |         /  |
       |  (0,0)     |
       |/           |
 (-1,-1)-----------(1,-1)

*/

    // three 2d points
    const positions = [ //xy...
        /* pos */-1, 1,
        /* pos */-1, -1,
        /* pos */1, 1,
        /* pos */1, 1,
        /* pos */-1, -1,
        /* pos */1, -1,
      ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
}

const vao = gl.createVertexArray();
{
    gl.bindVertexArray(vao);

    gl.enableVertexAttribArray(positionAttributeLocation);

    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    {
        const size = 2;          // 2 components per iteration
        const type = gl.FLOAT;   // the data is 32bit floats
        const normalize = false; // don't normalize the data
        const stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position
        const offset = 0;        // start at the beginning of the buffer
        gl.vertexAttribPointer(
            positionAttributeLocation, size, type, normalize, stride, offset);
        // Automatically binds whatever gl.ARRAY_BUFFER is (positionBuffer in this case) to the positionAttributeLocation
    }
}

let windAdd = 0.0;
function drawNow(time: number) {
    stats.begin();

    resize(canvas);
    

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    
    //texture:
    gl.useProgram(program);
    {
        gl.uniform1f(timeUniformLocation, time);
        gl.uniform1f(windAmpUniformLoc, currWindAmp);
        gl.uniform2f(dimsUniformLocation, gl.canvas.width, gl.canvas.height);
        gl.uniform1f(smoothData, windAdd);
        windAdd+= currWindAmp;
        gl.bindVertexArray(vao);
        {
            const primitiveType = gl.TRIANGLES;
            const offset = 0;
            const count = 3*2; // How often to execute the vertex shader
            gl.drawArrays(primitiveType, offset, count);
        }

        console.log(currWindAmp);
    }

    stats.end();

    window.requestAnimationFrame(drawNow);
}

window.requestAnimationFrame(drawNow);

function createShader(
        gl: WebGL2RenderingContext,
        type: ShaderType,
        source: string): WebGLShader | null {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    const success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (success) {
      return shader;
    }
   
    console.error(`Shader compile failed ${ShaderType[type]}:`,gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    return null;
}

function createProgram(
    gl: WebGL2RenderingContext,
    vertexShader: WebGLShader,
    fragmentShader: WebGLShader): WebGLProgram | null {
    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    const success = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (success) {
      return program;
    }
   
    console.error("Program compile failed:", gl.getProgramInfoLog(program));
    gl.deleteProgram(program);
    return null;
  }

  /* from https://webgl2fundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html */
function resize(canvas: HTMLCanvasElement) {
    var cssToRealPixels = window.devicePixelRatio || 1;
  
    // Lookup the size the browser is displaying the canvas in CSS pixels
    // and compute a size needed to make our drawingbuffer match it in
    // device pixels.
    var displayWidth  = Math.floor(canvas.clientWidth  * cssToRealPixels);
    var displayHeight = Math.floor(canvas.clientHeight * cssToRealPixels);
  
    // Check if the canvas is not the same size.
    if (canvas.width  !== displayWidth ||
        canvas.height !== displayHeight) {
  
      // Make the canvas the same size
      canvas.width  = displayWidth;
      canvas.height = displayHeight;
    }
}