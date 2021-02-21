import vertSrc from './vert.glsl';
import fragSrc from './frag.glsl';

import * as Stats from "stats.js"
let stats = new Stats();
stats.showPanel(0); // 0: fps, 1: ms, 2: mb, 3+: custom
stats.dom.style.left = "auto";
stats.dom.style.right = "0";
stats.dom.style.top = "50px";
document.body.appendChild(stats.dom);


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
const normalAttributeLocation = gl.getAttribLocation(program, "a_normal");
const dataAttributeLocation = gl.getAttribLocation(program, "a_data");
const timeUniformLocation= gl.getUniformLocation(program, "u_time");
const stretchValUniformLoc = gl.getUniformLocation(program, "u_windAmp");

const maxPoints = 1000;

const lineBuffer = gl.createBuffer();
const lineData = new Float32Array(maxPoints * 10);
{
    gl.bindBuffer(gl.ARRAY_BUFFER, lineBuffer);

    // Px, Py
    // Nx, Ny
    // val
    // Px, Py
    // Nx, Ny
    // val
    for (let i = 0; i < maxPoints; i++) {
        const val = Math.sin(i*0.01);

        lineData[i*10+0] = i/(maxPoints-1); //px
        lineData[i*10+1] = 0; // py
        lineData[i*10+2] = 0; // nx
        lineData[i*10+3] = 1; // ny
        
        lineData[i*10+4] = val;

        lineData[i*10+5] = i/(maxPoints-1); //x
        lineData[i*10+6] = 0;
        lineData[i*10+7] = 0;
        lineData[i*10+8] = -1;

        lineData[i*10+9] = val;
    }


    // Px, Py
    // Nx, Ny
    // Px, Py
    // Nx, Ny

    gl.bufferData(gl.ARRAY_BUFFER, lineData, gl.DYNAMIC_DRAW);
}

let ptIdx = 0;
let stretchVal = 0;
const websocket = new WebSocket('ws://localhost:5000');
websocket.binaryType = 'arraybuffer';
websocket.addEventListener('message', (message) => {
    const dv = new DataView(message.data);
    stretchVal = dv.getUint32(0, true);

    lineData[ptIdx*10+4] = stretchVal/1024;
    lineData[ptIdx*10+9] = stretchVal/1024;
    ptIdx = (ptIdx + 1)%maxPoints;
});

// const dataBuffer = gl.createBuffer();
// {
//     gl.bindBuffer(gl.ARRAY_BUFFER, lineBuffer);

//     const data = new Float32Array(maxPoints*2);
//     for (let i = 0; i < maxPoints; i++) {
//         const val = Math.sin(i * 0.1);
//         // Duplicate the val so that it gets sent to each vertex
//         data[i*2+0] = val;
//         data[i*2+1] = val;
//     }

//     gl.bufferData(gl.ARRAY_BUFFER, data, gl.DYNAMIC_DRAW);
// }

const indexBuffer = gl.createBuffer();
{
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    const data = new Uint16Array((maxPoints - 1)*6);
    for (let i = 0; i < maxPoints; i++) {
        data[i*6+0] = 0 + 2*i; 
        data[i*6+1] = 1 + 2*i;
        data[i*6+2] = 2 + 2*i;

        data[i*6+3] = 2 + 2*i;
        data[i*6+4] = 1 + 2*i;
        data[i*6+5] = 3 + 2*i;
    }
    gl.bufferData(
        gl.ELEMENT_ARRAY_BUFFER,
        data,
        gl.STATIC_DRAW
    );
}

// Pos attrib
// normal attrib
// Data attrib,

const vao = gl.createVertexArray();
{
    gl.bindVertexArray(vao);

    gl.enableVertexAttribArray(positionAttributeLocation);
    gl.enableVertexAttribArray(normalAttributeLocation);
    gl.enableVertexAttribArray(dataAttributeLocation);

    gl.bindBuffer(gl.ARRAY_BUFFER, lineBuffer);
    {
        const size = 2;          // 2 components per iteration
        const type = gl.FLOAT;   // the data is 32bit floats
        const normalize = false; // don't normalize the data
        const stride = 5 * 4;    // 0 = move forward size * sizeof(type) each iteration to get the next position
        const offset = 0;        // start at the beginning of the buffer
        gl.vertexAttribPointer(
            positionAttributeLocation, size, type, normalize, stride, offset);
        // Automatically binds whatever gl.ARRAY_BUFFER is (lineBuffer in this case) to the positionAttributeLocation
    }

    gl.bindBuffer(gl.ARRAY_BUFFER, lineBuffer);
    {
        const size = 2;          // 2 components per iteration
        const type = gl.FLOAT;   // the data is 32bit floats
        const normalize = false; // don't normalize the data
        const stride = 5 * 4;    // 0 = move forward size * sizeof(type) each iteration to get the next position
        const offset = 2 * 4;        // start at the beginning of the buffer
        gl.vertexAttribPointer(
            normalAttributeLocation, size, type, normalize, stride, offset);
        // Automatically binds whatever gl.ARRAY_BUFFER is (lineBuffer in this case) to the normalAttributeLocation
    }

    // lineData[i*10+0] = i/(maxPoints-1); //px
    // lineData[i*10+1] = 0; // py
    // lineData[i*10+2] = 0; // nx
    // lineData[i*10+3] = 1; // ny
    
    // lineData[i*10+4] = val;

    // lineData[i*10+5] = i/(maxPoints-1); //x
    // lineData[i*10+6] = 0;
    // lineData[i*10+7] = 0;
    // lineData[i*10+8] = -1;

    // lineData[i*10+9] = val;

    gl.bindBuffer(gl.ARRAY_BUFFER, lineBuffer);
    {
        const size = 1;          // 2 components per iteration
        const type = gl.FLOAT;   // the data is 32bit floats
        const normalize = false; // don't normalize the data
        const stride = 5 * 4;    // 0 = move forward size * sizeof(type) each iteration to get the next position
        const offset = 4 * 4;        // start at the beginning of the buffer
        gl.vertexAttribPointer(
            dataAttributeLocation, size, type, normalize, stride, offset);
        // Automatically binds whatever gl.ARRAY_BUFFER is (lineBuffer in this case) to the normalAttributeLocation
    }

    // gl.bindBuffer(gl.ARRAY_BUFFER, dataBuffer);
    // {
    //     const size = 1;          // 2 components per iteration
    //     const type = gl.FLOAT;   // the data is 32bit floats
    //     const normalize = false; // don't normalize the data
    //     const stride = 0;    // 0 = move forward size * sizeof(type) each iteration to get the next position
    //     const offset = 0;        // start at the beginning of the buffer
    //     gl.vertexAttribPointer(
    //         dataAttributeLocation, size, type, normalize, stride, offset);
    //     // Automatically binds whatever gl.ARRAY_BUFFER is (lineBuffer in this case) to the positionAttributeLocation
    // }

}


function drawNow(time: number) {
    stats.begin();

    resize(canvas);
    
    gl.bufferData(gl.ARRAY_BUFFER, lineData, gl.DYNAMIC_DRAW);

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
    
    //texture:
    gl.useProgram(program);
    {
        gl.uniform1f(timeUniformLocation, time);
        // gl.uniform1f(stretchValUniformLoc, stretchVal/1024);
        
        gl.bindVertexArray(vao);
        {
            // const primitiveType = gl.TRIANGLES;
            // const offset = 0;
            // const count = 3*2; // How often to execute the vertex shader
            // gl.drawArrays(primitiveType, offset, count);
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
            const primitiveType = gl.TRIANGLES;
            const offset = 0;
            const count = (maxPoints - 1)*6;
            const indexType = gl.UNSIGNED_SHORT;
            gl.drawElements(primitiveType, count, indexType, offset);
        }

        // console.log(stretchVal);
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