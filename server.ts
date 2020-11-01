import * as WebSocket from 'ws';
import * as SerialPort from 'serialport';
// import * as ByteLength from '@serialport/parser-byte-length';

const ByteLength = SerialPort.parsers.ByteLength;

enum State {
    WaitingForStart,
    Reading
}

let state = State.WaitingForStart;
let readIdx = 0;
const messageBuffer = new ArrayBuffer(4);
// const readBuffer = new Uint8Array(messageBuffer);
const floatView = new DataView(messageBuffer);

// const serialPort = new SerialPort()


const wss = new WebSocket.Server({
    port: 5000
});

const connections: WebSocket[] = [];
wss.on('connection', (ws) => {
    connections.push(ws);
    ws.on('close', () => {
        const idx = connections.indexOf(ws);
        if (idx >= 0) {
            connections.splice(idx, 1);
        }
    })
});


SerialPort.list().then((results) => {
    for (let i = 0; i < results.length; i++) {
        if (results[i].vendorId === '2341') {
            const port = new SerialPort(results[i].path, 
                { baudRate: 57600 },
                (error) => {
                    console.log("Error", error);
                });
            console.log("Start");
            port.on('data', (data) => {
                // console.log(state);
                for (let j = 0; j < data.length; j++) {
                    if (state === State.WaitingForStart) {
                        if (data.readUInt8(j) === 128) {
                            state = State.Reading;
                            readIdx = 0;
                        }
                    } else if (state === State.Reading) {
                        floatView.setUint8(readIdx, data.readUInt8(j));
                        
                        if (readIdx >= 3) {
                            const float = floatView.getFloat32(0, true);
                            // console.log(floatReader.getFloat32(0, true));
                            for (let connIdx = 0; connIdx < connections.length; connIdx++) {
                                if (float > 0) {
                                    connections[connIdx].send(messageBuffer.slice(0));
                                }
                            }
                            state = State.WaitingForStart;
                        }

                        readIdx++;
                    }
                }
            });
        }
    }
});