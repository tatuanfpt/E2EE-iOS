const express = require("express");
const router = express.Router();
const db = require("../db/index");

// GET /users
router.get("/users", (req, res) => {
    try {
      const stmt = db.prepare("SELECT id, username FROM users");
      const users = stmt.all();
      res.json({ users });
      console.log('GET user: ', users);
    } catch (err) {
      console.error("Error fetching users:", err);
      res.status(500).json({ error: "Internal Server Error" });
    }
  });

// GET /users/chatted-with/:userId
router.get("/users/chatted-with/:userId", (req, res) => {
    const userId = req.params.userId;
  
    try {
      const stmt = db.prepare(`
        SELECT u.id, u.username
  FROM (
    SELECT DISTINCT
      CASE
        WHEN sender_id = @userId THEN receiver_id
        ELSE sender_id
      END AS chatted_user_id
    FROM messages
    WHERE sender_id = @userId OR receiver_id = @userId
  ) AS chat_users
  JOIN users u ON u.id = chat_users.chatted_user_id;
      `);
  
      const rows = stmt.all({ userId });
      const users = rows.map(row => row.chatted_user_id);
  
      res.json({ users });
    } catch (err) {
      console.error("Error fetching chat users:", err);
      res.status(500).json({ error: "Internal server error" });
    }
  });
  
  // 🔹 Create or log in a user
  router.post('/users', (req, res) => {
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
  router.get('/messages/:userA/:userB', (req, res) => {
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

module.exports = router;