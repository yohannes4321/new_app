import mongoose from "mongoose";
import { MongoMemoryServer } from "mongodb-memory-server";
import net from "node:net";

let mongo : MongoMemoryServer;
let patchedListen = false;

export const connect = async () => {
    if (!patchedListen) {
        const originalListen = net.Server.prototype.listen;
        net.Server.prototype.listen = function (...args: any[]) {
            if (args.length === 1 && typeof args[0] === "number") {
                return originalListen.call(this, args[0], "127.0.0.1");
            }
            if (args.length === 2 && typeof args[0] === "number" && typeof args[1] === "function") {
                return originalListen.call(this, args[0], "127.0.0.1", args[1]);
            }
            return originalListen.apply(this, args as any);
        };
        patchedListen = true;
    }
    mongo = await MongoMemoryServer.create({
        instance: {
            ip: "127.0.0.1",
            port: 37017,
        },
    });
    const uri = mongo.getUri();

    await mongoose.connect(uri);
}

export const close = async () => {
    if (mongo) {
        await mongoose.connection.dropDatabase();
        await mongoose.connection.close();
        await mongo.stop();
    }
}

export const clear = async () => {
    if (mongo) {
        const collections = mongoose.connection.collections;
        for (const key in collections) {
            const collection = collections[key];
            await collection.deleteMany({});
        }
    }
}
