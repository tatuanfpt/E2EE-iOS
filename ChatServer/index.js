const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Replace with your iOS app's origin in production
    methods: ["GET", "POST"]
  }
});

io.on("connection", socket => {
  console.log("✅ New client connected:", socket.id);

  socket.on("message", data => {
    console.log("📨 Message from", socket.id, ":", data);
    socket.broadcast.emit("message", data); // Send to all except sender
    socket.emit("message", "Response message");
  });

  socket.on("disconnect", () => {
    console.log("❌ Client disconnected:", socket.id);
  });
});

server.listen(3000, () => {
  console.log("🚀 WebSocket server is running on http://localhost:3000");
});