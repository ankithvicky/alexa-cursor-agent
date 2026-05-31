# Quick Start Guide

## Setup (5 minutes)

### 1. Create .env file
```bash
cp .env.example .env
```

Edit `.env` and set your values:
- `MONGODB_URI`: Your MongoDB connection string
- `API_KEY`: Your secret API key (use this in x-api-key header)
- `CURSOR_CLI_PATH`: Path to cursor executable (typically `/usr/local/bin/cursor`)
- `CURSOR_API_KEY`: Your Cursor API key
- `PORT`: Server port (default 3000)

### 2. Install Cursor CLI (if not already done)
```bash
curl https://cursor.com/install -fsS | bash
```

### 3. Setup MongoDB
**Option A: Local MongoDB**
```bash
mongod --dbpath ./data
```

**Option B: MongoDB Atlas (Cloud)**
Use Atlas connection string in MONGODB_URI

## Run Locally

```bash
npm start
```

Server starts on http://localhost:3000

## Test the API

### Test 1: Health Check
```bash
curl http://localhost:3000/health
```

### Test 2: Create a Job
```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "What is recursion?", "sessionAttributes": {}}'
```

Save the `threadId` from response.

### Test 3: Wait for Processing
Wait 30 seconds (cron cycle time)

### Test 4: Get Response
```bash
curl -X GET "http://localhost:3000/chat/notification?threadId=YOUR_THREAD_ID" \
  -H "x-api-key: your-api-key"
```

### Test 5: Multi-turn Conversation
Use the threadId from test 2:
```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "Can you give an example?", "sessionAttributes": {"threadId": "YOUR_THREAD_ID"}}'
```

Wait 30 seconds, then check notification endpoint again.

## Monitor Jobs

### Check MongoDB Collections
```bash
# Connect to MongoDB
mongosh your-database-name

# View jobs
db.jobs.find().pretty()

# View conversations
db.conversations.find().pretty()

# View threads
db.threads.find().pretty()

# Check job status distribution
db.jobs.aggregate([
  { $group: { _id: "$status", count: { $sum: 1 } } }
])
```

## Deploy to EC2

### 1. Update startup.sh
Edit `scripts/startup.sh`:
- Replace `YOUR_REPO_URL` with your git repository URL
- Update `.env` values with production credentials

### 2. Launch EC2 Instance
- OS: Ubuntu 22.04 LTS
- Instance type: t3.small or larger
- Security group: Allow ports 80, 443, 22

### 3. Run Setup Script
```bash
chmod +x scripts/startup.sh
./scripts/startup.sh
```

Application will start automatically on port 80.

### 4. Verify Deployment
```bash
# Check if running
curl http://your-instance-ip/health

# Check logs
pm2 logs cursor-agent

# View running processes
pm2 list
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| MongoDB connection error | Verify MONGODB_URI is correct, MongoDB is running |
| Cursor CLI not found | Install with: `curl https://cursor.com/install -fsS \| bash` |
| API returns 401 | Check x-api-key header matches API_KEY in .env |
| Jobs stuck in InProgress | Check server logs, restart with `npm start` |
| High memory usage | Reduce cron frequency in src/server.js (currently 30 seconds) |
| No response after 30+ seconds | Check Cursor CLI is working manually: `cursor agent -p "test"` |

## Next Steps

1. Test locally thoroughly (see Test sections above)
2. Integrate with Alexa Skill (use /chat/init and /chat/notification)
3. Configure Alexa Skill to:
   - Call POST /chat/init on user query
   - Poll GET /chat/notification every 5-10 seconds
   - Pass threadId in sessionAttributes for continuity
4. Deploy to EC2 with production configuration
5. Monitor logs and job status regularly

## Key Endpoints Reference

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | /health | Health check | None |
| POST | /chat/init | Create new job | x-api-key |
| GET | /chat/notification | Get response | x-api-key |

## Important Notes

- **API Key**: Change from `.env.example` value
- **MongoDB**: Use Atlas or managed instance (not on spot instance)
- **Timeout**: Cursor CLI has 4-minute timeout per request
- **Rate Limits**: No built-in rate limiting (add if needed)
- **Logging**: Check console/pm2 logs for debugging
- **Conversation Continuity**: Pass threadId to continue previous conversation
