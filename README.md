# Cursor CLI Wrapper for Alexa

An Express.js API that wraps Cursor CLI for Alexa Skill integration, with async job processing and conversation history management.

## Features

- Async job processing with cron-based polling
- Conversation history management with MongoDB
- Automatic retry logic for failed jobs
- API key authentication
- EC2 auto-deployment script

## Project Structure

```
cursor-agent/
├── src/
│   ├── models/
│   │   ├── Job.js          # Job schema with status tracking
│   │   ├── Thread.js       # Thread schema for conversation state
│   │   └── Conversation.js # Message history storage
│   ├── routes/
│   │   └── chat.js         # API route handlers
│   ├── controllers/
│   │   └── chatController.js  # Business logic for endpoints
│   ├── workers/
│   │   └── jobWorker.js    # Job processing logic
│   ├── utils/
│   │   ├── cursorCli.js    # Cursor CLI wrapper functions
│   │   └── middleware.js   # Auth middleware
│   ├── config/
│   │   └── database.js     # MongoDB connection
│   └── server.js           # Express app entry point
├── scripts/
│   └── startup.sh          # EC2 initialization script
├── .env.example            # Environment variable template
├── .gitignore
├── package.json
└── README.md
```

## Quick Start

### Prerequisites

- Node.js 20.x or higher
- MongoDB 4.0 or higher
- Cursor CLI installed and API key configured

### Installation

1. Clone the repository:
```bash
git clone YOUR_REPO_URL cursor-agent
cd cursor-agent
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file from template:
```bash
cp .env.example .env
```

4. Edit `.env` with your configuration:
```bash
MONGODB_URI=mongodb://localhost:27017/cursor-agent
API_KEY=your-secret-api-key
CURSOR_CLI_PATH=/usr/local/bin/cursor
CURSOR_API_KEY=your-cursor-api-key
PORT=3000
```

5. Start MongoDB locally:
```bash
mongod --dbpath ./data
```

6. Start the server:
```bash
npm start
```

Server will be available at `http://localhost:3000`

## API Endpoints

### POST /chat/init

Create a new job for a user query.

**Request:**
```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "What is recursion?", "sessionAttributes": {}}'
```

**Response:**
```json
{
  "jobId": "507f1f77bcf86cd799439011",
  "threadId": "507f1f77bcf86cd799439012",
  "message": "Your request is being processed",
  "sessionAttributes": {
    "threadId": "507f1f77bcf86cd799439012"
  }
}
```

### GET /chat/notification

Retrieve a processed response.

**Request:**
```bash
curl -X GET "http://localhost:3000/chat/notification" \
  -H "x-api-key: your-api-key"
```

With optional threadId filter:
```bash
curl -X GET "http://localhost:3000/chat/notification?threadId=507f1f77bcf86cd799439012" \
  -H "x-api-key: your-api-key"
```

**Response (with answer):**
```json
{
  "hasResponse": true,
  "response": "Recursion is a programming technique where a function calls itself...",
  "sessionAttributes": {
    "threadId": "507f1f77bcf86cd799439012"
  }
}
```

**Response (no answer yet):**
```json
{
  "hasResponse": false,
  "message": "No response yet, try asking a question",
  "sessionAttributes": {}
}
```

### GET /health

Health check endpoint.

```bash
curl http://localhost:3000/health
```

## Job Processing

Jobs are processed asynchronously using:
- **Cron scheduling**: Every 30 seconds
- **Fire-and-forget**: Immediately triggered on new chat/init requests
- **Sequential processing**: One job at a time to prevent resource exhaustion
- **Retry logic**: Jobs stuck in InProgress for >5 minutes reset to Pending (max 3 retries)

### Job Status Flow

```
Pending → InProgress → Processed → Delivered
                    ↓
                  Failed (max 3 retries exceeded)
```

## Conversation Management

Multi-turn conversations are supported through threadId:
1. First request: POST /chat/init without threadId (new thread created)
2. Subsequent requests: Include threadId in sessionAttributes to continue conversation
3. History automatically fetched and embedded in Cursor CLI context

## Environment Variables

See `.env.example` for all available options:

| Variable | Description | Example |
|----------|-------------|---------|
| MONGODB_URI | MongoDB connection string | mongodb://localhost:27017/cursor-agent |
| API_KEY | Secret key for API authentication | your-secret-key |
| CURSOR_CLI_PATH | Path to Cursor CLI executable | /usr/local/bin/cursor |
| CURSOR_API_KEY | Cursor API authentication key | your-cursor-key |
| RESPONSE_INSTRUCTIONS | System prompt embedded in queries | "Provide concise responses..." |
| PORT | Server port | 3000 |
| NODE_ENV | Environment | development or production |

## EC2 Deployment

The `scripts/startup.sh` script fully provisions a fresh Ubuntu 22.04 instance.

**Before running:**
1. Update the following in the script:
   - `YOUR_REPO_URL` - Your git repository URL
   - `.env` values - MongoDB URI, API keys, etc.

**Run on EC2 instance:**
```bash
chmod +x scripts/startup.sh
./scripts/startup.sh
```

This will:
- Install Node.js 20.x, nginx, and Cursor CLI
- Clone and install the application
- Configure nginx to proxy port 80 → 3000
- Start the application with PM2
- Enable automatic restart on reboot

## Testing

### Local Testing

1. Start MongoDB and the server (see Quick Start)
2. Create a request:
```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "What is recursion?", "sessionAttributes": {}}'
```

3. Wait 30 seconds for cron to process
4. Check for response:
```bash
curl -X GET "http://localhost:3000/chat/notification" \
  -H "x-api-key: test-key"
```

5. Verify MongoDB collections:
```bash
# Connect to MongoDB
mongosh cursor-agent

# Check jobs
db.jobs.find()

# Check conversations
db.conversations.find()

# Check threads
db.threads.find()
```

### Multi-turn Conversation Testing

1. Get threadId from first /chat/init response
2. Use that threadId in next /chat/init request:
```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "Can you give an example?", "sessionAttributes": {"threadId": "507f1f77bcf86cd799439012"}}'
```

3. Previous conversation will be included in Cursor CLI context

## Troubleshooting

### Cursor CLI not found
- Ensure `CURSOR_CLI_PATH` in `.env` points to the correct executable
- Run `which cursor` to find the installed location
- Verify Cursor CLI is installed: `cursor --version`

### MongoDB connection errors
- Verify MongoDB is running: `mongosh`
- Check `MONGODB_URI` in `.env`
- For MongoDB Atlas, ensure IP whitelist allows your connection

### Jobs stuck in InProgress
- Check server logs: `npm start` (shows detailed logs)
- Jobs automatically reset to Pending after 5 minutes
- Max 3 retries before marking as Failed

### High memory usage
- Reduce cron frequency (currently 30 seconds) in `src/server.js`
- Implement job queue limits
- Monitor Cursor CLI process performance

## Architecture Notes

### Why Fire-and-Forget + Cron?
- **Immediate trigger**: Users don't wait for next cron cycle
- **Redundancy**: Cron catches jobs if fire-and-forget fails
- **Simple**: No complex queue library needed
- **Singleton flag**: Prevents concurrent job processing

### Why Manual Conversation History?
- Cursor CLI doesn't support native thread persistence
- History is reconstructed from MongoDB for each request
- Allows flexibility in context window management

### Why One Job at a Time?
- Prevents resource exhaustion on EC2 spot instances
- Cursor CLI can be memory-intensive
- Ensures predictable performance

## License

MIT
