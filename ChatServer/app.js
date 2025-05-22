
const express = require("express");
const chatRoutes = require("./routes/chat");
const db = require("./db/index");

const app = express();
app.use(express.json());

const http = require('http');
const { Server } = require('socket.io');

const server = http.createServer(app);
const io = new Server(server);

app.use(express.json());

const connectedUsers = new Map(); // username -> socket

// 🔹 Socket.IO messaging
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  socket.on('register', (username) => {
    console.log(`User registered: ${username}`);
    connectedUsers.set(username, socket);
    socket.emit('register');
  });

  socket.on('send-message', ({ sender, receiver, text }) => {
    if (!sender || !receiver || !text) return;

    const getUserId = db.prepare('SELECT id FROM users WHERE username = ?');
    const senderRow = getUserId.get(sender);
    const receiverRow = getUserId.get(receiver);
    if (!senderRow || !receiverRow) return;

    // Store message in DB
    const insert = db.prepare('INSERT INTO messages (senderId, receiverId, text) VALUES (?, ?, ?)');
    insert.run(senderRow.id, receiverRow.id, text);

    // Emit to receiver if online
    const receiverSocket = connectedUsers.get(receiver);
    if (receiverSocket) {
      receiverSocket.emit('receive-message', { from: sender, text });
    }
  });

  socket.on('disconnect', () => {
    for (const [username, s] of connectedUsers.entries()) {
      if (s === socket) {
        connectedUsers.delete(username);
        break;
      }
    }
    console.log('User disconnected:', socket.id);
  });
});

server.listen(3000, () => {
  console.log('Server listening on http://localhost:3000');
});