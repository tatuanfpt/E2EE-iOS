const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const initDatabase = require('./initDatabase');

const db = initDatabase();
const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.json());

const connectedUsers = new Map(); // username -> socket

// 🔹 Create or log in a user
app.post('/users', (req, res) => {
  const { username } = req.body;
  if (!username) return res.status(400).json({ error: 'Username required' });

  const find = db.prepare('SELECT * FROM users WHERE username = ?');
  let user = find.get(username);

  if (!user) {
    const insert = db.prepare('INSERT INTO users (username) VALUES (?)');
    const info = insert.run(username);
    user = { id: info.lastInsertRowid, username };
  }

  res.json(user);
});

// 🔹 Fetch messages between two users
app.get('/messages/:userA/:userB', (req, res) => {
  const { userA, userB } = req.params;

  const getUserId = db.prepare('SELECT id FROM users WHERE username = ?');
  const a = getUserId.get(userA);
  const b = getUserId.get(userB);

  if (!a || !b) return res.status(404).json({ error: 'User not found' });

  const query = db.prepare(`
    SELECT * FROM messages
    WHERE (senderId = ? AND receiverId = ?)
       OR (senderId = ? AND receiverId = ?)
    ORDER BY createdAt
  `);

  const messages = query.all(a.id, b.id, b.id, a.id);
  res.json(messages);
});

// 🔹 Socket.IO messaging
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  socket.on('register', (username) => {
    console.log(`User registered: ${username}`);
    connectedUsers.set(username, socket);
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