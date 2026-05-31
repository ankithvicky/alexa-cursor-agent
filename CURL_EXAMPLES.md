# Curl Examples for Testing

This file contains sample curl commands for testing all flows of the Cursor CLI Wrapper API.

**Prerequisites:**
- Server running on `http://localhost:3000`
- API key set as `test-key` in `.env`
- MongoDB running and connected

---

## Flow 1: Health Check

**Purpose:** Verify the server is running

```bash
curl -X GET http://localhost:3000/health
```

**Expected Response:**
```json
{"status":"ok"}
```

---

## Flow 2: Single-Turn Query (Basic Flow)

### Step 1: Create a new job
Create a new conversation thread and submit a query.

```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is recursion in programming?",
    "sessionAttributes": {}
  }'
```

**Expected Response:**
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

**Save the threadId for next steps!**

### Step 2: Wait for processing
Wait 30+ seconds for the cron job to process.

```bash
sleep 30
```

### Step 3: Get the response
Retrieve the processed answer.

```bash
curl -X GET http://localhost:3000/chat/notification \
  -H "x-api-key: test-key"
```

**Expected Response (when ready):**
```json
{
  "hasResponse": true,
  "response": "Recursion is a programming technique where a function calls itself...",
  "sessionAttributes": {
    "threadId": "507f1f77bcf86cd799439012"
  }
}
```

**Expected Response (before ready):**
```json
{
  "hasResponse": false,
  "message": "No response yet, try asking a question",
  "sessionAttributes": {}
}
```

---

## Flow 3: Multi-Turn Conversation

### Step 1: First query (start conversation)

```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Explain what a binary tree is",
    "sessionAttributes": {}
  }'
```

**Save the threadId!**

### Step 2: Wait for processing
```bash
sleep 30
```

### Step 3: Get first response

```bash
curl -X GET http://localhost:3000/chat/notification?threadId=YOUR_THREAD_ID \
  -H "x-api-key: test-key"
```

(Replace `YOUR_THREAD_ID` with the threadId from Step 1)

### Step 4: Second query (continue conversation)
Use the same threadId to continue the conversation.

```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Can you give me a code example of a binary tree?",
    "sessionAttributes": {
      "threadId": "YOUR_THREAD_ID"
    }
  }'
```

(Replace `YOUR_THREAD_ID` with the threadId from previous responses)

### Step 5: Wait for processing
```bash
sleep 30
```

### Step 6: Get second response

```bash
curl -X GET http://localhost:3000/chat/notification?threadId=YOUR_THREAD_ID \
  -H "x-api-key: test-key"
```

Note: The previous conversation is automatically included in the Cursor CLI context.

---

## Flow 4: Error Cases

### Missing API Key

```bash
curl -X GET http://localhost:3000/chat/notification
```

**Expected Response (401):**
```json
{"error":"Unauthorized"}
```

### Invalid API Key

```bash
curl -X GET http://localhost:3000/chat/notification \
  -H "x-api-key: wrong-key"
```

**Expected Response (401):**
```json
{"error":"Unauthorized"}
```

### Empty Query

```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "",
    "sessionAttributes": {}
  }'
```

**Expected Response (400):**
```json
{"error":"Query is required"}
```

### Invalid ThreadId

```bash
curl -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Hello",
    "sessionAttributes": {
      "threadId": "invalid-id"
    }
  }'
```

**Expected Response (400):**
```json
{"error":"Invalid threadId"}
```

---

## Flow 5: Batch Testing Script

Create a shell script to run all tests sequentially:

**File: `test-api.sh`**

```bash
#!/bin/bash

API_KEY="test-key"
BASE_URL="http://localhost:3000"

echo "=========================================="
echo "Test 1: Health Check"
echo "=========================================="
curl -X GET $BASE_URL/health
echo ""
echo ""

echo "=========================================="
echo "Test 2: Single-Turn Query"
echo "=========================================="
echo "Step 2a: Create job..."
RESPONSE=$(curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is a hash map?",
    "sessionAttributes": {}
  }')

echo $RESPONSE | jq '.'
THREAD_ID=$(echo $RESPONSE | jq -r '.sessionAttributes.threadId')
echo "Thread ID: $THREAD_ID"
echo ""

echo "Step 2b: Waiting 35 seconds for processing..."
sleep 35
echo ""

echo "Step 2c: Get response..."
curl -s -X GET "$BASE_URL/chat/notification" \
  -H "x-api-key: $API_KEY" | jq '.'
echo ""
echo ""

echo "=========================================="
echo "Test 3: Multi-Turn Conversation"
echo "=========================================="
echo "Step 3a: First query..."
RESPONSE=$(curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is a linked list?",
    "sessionAttributes": {}
  }')

echo $RESPONSE | jq '.'
THREAD_ID=$(echo $RESPONSE | jq -r '.sessionAttributes.threadId')
echo "Thread ID: $THREAD_ID"
echo ""

echo "Step 3b: Waiting 35 seconds..."
sleep 35
echo ""

echo "Step 3c: Get first response..."
curl -s -X GET "$BASE_URL/chat/notification?threadId=$THREAD_ID" \
  -H "x-api-key: $API_KEY" | jq '.'
echo ""

echo "Step 3d: Second query (continue conversation)..."
RESPONSE=$(curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"How do you reverse a linked list?\",
    \"sessionAttributes\": {
      \"threadId\": \"$THREAD_ID\"
    }
  }")

echo $RESPONSE | jq '.'
echo ""

echo "Step 3e: Waiting 35 seconds..."
sleep 35
echo ""

echo "Step 3f: Get second response..."
curl -s -X GET "$BASE_URL/chat/notification?threadId=$THREAD_ID" \
  -H "x-api-key: $API_KEY" | jq '.'
echo ""
echo ""

echo "=========================================="
echo "Test 4: Error Cases"
echo "=========================================="
echo "Test 4a: Missing API Key"
curl -s -X GET $BASE_URL/chat/notification | jq '.'
echo ""

echo "Test 4b: Invalid API Key"
curl -s -X GET $BASE_URL/chat/notification \
  -H "x-api-key: wrong-key" | jq '.'
echo ""

echo "Test 4c: Empty Query"
curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "", "sessionAttributes": {}}' | jq '.'
echo ""

echo "=========================================="
echo "All tests completed!"
echo "=========================================="
```

**Run the test script:**

```bash
chmod +x test-api.sh
./test-api.sh
```

---

## Flow 6: Using jq for Pretty Output

All examples above use `jq` for JSON formatting. If you don't have jq installed:

```bash
# On macOS
brew install jq

# On Ubuntu
sudo apt-get install jq
```

Or run curl without `jq`:

```bash
curl -X GET http://localhost:3000/chat/notification \
  -H "x-api-key: test-key"
```

---

## Flow 7: Verbose Debugging

If you need to see request/response details:

```bash
curl -v -X POST http://localhost:3000/chat/init \
  -H "x-api-key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Test query",
    "sessionAttributes": {}
  }'
```

The `-v` flag shows:
- Request headers
- Response status code
- Response headers
- Response body

---

## Flow 8: Monitor MongoDB During Testing

In a separate terminal, watch the database changes:

```bash
# Connect to MongoDB
mongosh cursor-agent

# In MongoDB shell
# View all jobs
db.jobs.find().pretty()

# View jobs by status
db.jobs.aggregate([{ $group: { _id: "$status", count: { $sum: 1 } } }])

# View conversations for a specific thread
db.conversations.find({ threadId: ObjectId("YOUR_THREAD_ID") }).pretty()

# Watch jobs in real-time (polls every 1 second)
while true; do
  echo "=== $(date) ==="
  db.jobs.aggregate([{ $group: { _id: "$status", count: { $sum: 1 } } }])
  sleep 1
done
```

---

## Flow 9: Quick Copy-Paste Reference

### Test 1: Health Check
```bash
curl -X GET http://localhost:3000/health
```

### Test 2: Create Job
```bash
curl -X POST http://localhost:3000/chat/init -H "x-api-key: test-key" -H "Content-Type: application/json" -d '{"query": "What is recursion?", "sessionAttributes": {}}'
```

### Test 3: Get Response
```bash
curl -X GET "http://localhost:3000/chat/notification?threadId=YOUR_THREAD_ID" -H "x-api-key: test-key"
```

### Test 4: Multi-turn (with threadId)
```bash
curl -X POST http://localhost:3000/chat/init -H "x-api-key: test-key" -H "Content-Type: application/json" -d '{"query": "Follow-up question", "sessionAttributes": {"threadId": "YOUR_THREAD_ID"}}'
```

---

## Testing Checklist

Use this checklist to verify all functionality:

- [ ] Health check returns `{"status":"ok"}`
- [ ] POST /chat/init with new query returns jobId and threadId
- [ ] Wait 30+ seconds for processing
- [ ] GET /chat/notification returns `hasResponse: true` with response text
- [ ] Multi-turn: Use threadId from previous conversation
- [ ] Previous conversation appears in new response context
- [ ] API key validation works (401 on missing key)
- [ ] Invalid threadId returns 400 error
- [ ] Empty query returns 400 error
- [ ] MongoDB collections have entries (jobs, conversations, threads)

---

## Expected Flow Timeline

1. **T+0s**: POST /chat/init returns immediately
2. **T+0-30s**: Job is in "InProgress" status
3. **T+30s**: Cron job processes the job
4. **T+30-60s**: Job status changes to "Processed"
5. **T+30+**: GET /chat/notification returns the response
6. **After retrieval**: Job status changes to "Delivered"

---

## Troubleshooting

### Job never completes
- Check if Cursor CLI is installed: `which cursor`
- Check `.env` values are correct
- Check server logs: `npm start` should show processing logs
- Verify MongoDB connection in logs

### API Key error
- Ensure API_KEY in `.env` matches the x-api-key header
- Default in `.env.example` is placeholder - must be changed

### No response from /chat/notification
- Make sure 30+ seconds have passed since POST /chat/init
- Check MongoDB: `db.jobs.find()` to see job status
- Try again after waiting another 30 seconds

### Invalid threadId error
- Ensure threadId is a valid MongoDB ObjectId (24 hex characters)
- Copy exactly from previous response, don't edit it
- Create a new conversation if unsure

