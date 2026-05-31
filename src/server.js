require('dotenv').config();

const express = require('express');
const cors = require('cors');
const cron = require('node-cron');
const connectDB = require('./config/database');
const chatRoutes = require('./routes/chat');
const { processJobs, checkStuckJobs } = require('./workers/jobWorker');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/chat', chatRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Connect to database and start server
async function startServer() {
  try {
    console.log("Connecting to database...");
    await connectDB();
    console.log("Database connected successfully");
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });

    // Set up cron job to process jobs every 30 seconds
    cron.schedule('*/30 * * * * *', async () => {
      await checkStuckJobs();
      await processJobs();
    });

    console.log('Cron job scheduled: Every 30 seconds');
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
