const express = require('express');
const WebSocket = require('ws');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const PORT = 7777
const cors = require('cors');

// MongoDB connection
mongoose.connect('mongodb+srv://aniket8439:aniket123@cluster0.9fm3bp3.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0', { useNewUrlParser: true, useUnifiedTopology: true });
const db = mongoose.connection;

db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', function() {
  console.log('Connected to MongoDB');
});

// Define user schema
const userSchema = new mongoose.Schema({
  username: String,
  password: String,
});

const User = mongoose.model('User', userSchema);

// Create Express app
const app = express();
app.use(express.json());
app.use(cors())

// WebSocket server
const wss = new WebSocket.Server({ noServer: true });

// Array to store connected clients
const clients = [];

// Function to broadcast messages to all connected clients
function broadcast(message) {
  clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

// Event handler for new WebSocket connections
wss.on('connection', function connection(ws) {
  console.log('Client connected');
  
  // Add new client to the array
  clients.push(ws);

  // Event handler for incoming messages from clients
  ws.on('message', function incoming(message) {
    console.log('Received: %s', message);
    // Broadcast the received message to all connected clients
    broadcast(message);
  });

  // Event handler for client disconnections
  ws.on('close', function close() {
    console.log('Client disconnected');
    // Remove disconnected client from the array
    const index = clients.indexOf(ws);
    if (index !== -1) {
      clients.splice(index, 1);
    }
  });
});

// User authentication endpoints

// User signup
app.post('/signup', async (req, res) => {
  try {
    const { username, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ username, password: hashedPassword });
    await newUser.save();
    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// User login
app.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }
    const token = jwt.sign({ username }, 'secretkey');
    res.status(200).json({ token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Middleware to authenticate user requests
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  jwt.verify(token, 'secretkey', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    req.user = user;
    next();
  });
}
app.get('/test',(req,res)=>{
    res.send("hi there");
})

// Protected route example
app.get('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'Protected route accessed successfully', user: req.user });
});

// Start the Express server
const server = app.listen(PORT, () => {
  console.log('Server is running on port',PORT);
});

// Upgrade HTTP server to support WebSocket
server.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, ws => {
    wss.emit('connection', ws, request);
  });
});