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
const dataView = new DataView(messageBuffer);

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
        console.log (results[i]);
    }
    for (let i = 0; i < results.length; i++) {
        if (results[i].vendorId === '16C0') {
            const port = new SerialPort(results[i].path, 
                { baudRate: 115200 },
                (error) => {
                    if (error) {   
                        console.log("Error", error);
                    }
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
                        dataView.setUint8(readIdx, data.readUInt8(j));
                        
                        if (readIdx >= 3) {
                            const sentInt = dataView.getUint32(0, true);
                            // console.log('Got Int:', sentInt);
                            // console.log(floatReader.getFloat32(0, true));
                            for (let connIdx = 0; connIdx < connections.length; connIdx++) {
                                if (sentInt > 0) {
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
        else{
            console.log(results[i].vendorId);
        }
    }
});