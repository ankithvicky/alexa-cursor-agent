# Test Files Summary

This document describes all test files included for API testing.

## Files Created

### 1. CURL_EXAMPLES.md (11 KB)
**Comprehensive curl testing guide with all flows**

Contents:
- Flow 1: Health Check
- Flow 2: Single-Turn Query (3 steps)
- Flow 3: Multi-Turn Conversation (6 steps)
- Flow 4: Error Cases (4 scenarios)
- Flow 5: Batch Testing Script Template
- Flow 6: Using jq for pretty output
- Flow 7: Verbose debugging with -v flag
- Flow 8: MongoDB monitoring commands
- Flow 9: Quick copy-paste reference
- Testing checklist
- Expected timeline
- Troubleshooting guide

Best for: Learning and understanding all flows in detail

### 2. test-api.sh (6.8 KB, executable)
**Automated testing script**

Features:
- Color-coded output
- Automatic server availability check
- Runs all flows sequentially
- 35-second waits between steps
- Pretty JSON output with jq
- Progress indicators
- Detailed command output
- Error case testing

Usage:
```bash
chmod +x test-api.sh
./test-api.sh
```

Best for: Running complete test suite automatically

### 3. CURL_QUICK_REFERENCE.txt (5 KB)
**Quick copy-paste reference**

Contents:
- All flows with commands
- Expected responses
- Flow timeline
- Common variables setup
- Tips and tricks
- Typical timeline explanation

Best for: Quick reference while testing, copy-paste commands

### 4. FLOW_DIAGRAMS.txt (7 KB)
**Visual representation of API flows**

Contents:
- ASCII diagrams for each flow
- Step-by-step visualization
- Database state transitions
- Authentication flow
- Job retry state machine
- Batch test flow
- Cron job timing
- Multi-job queue example

Best for: Understanding architecture and flow sequencing

## Quick Start for Testing

### Option 1: Run Automated Script (Easiest)
```bash
# Make sure server is running: npm start
# In another terminal:
./test-api.sh
```
Takes about 140 seconds, runs all tests automatically.

### Option 2: Manual Testing (Learning)
```bash
# Read CURL_EXAMPLES.md
# Run each curl command manually from CURL_QUICK_REFERENCE.txt
# Follow the timeline between steps
```
Takes as long as you want, good for understanding each step.

### Option 3: Copy-Paste Reference (Quick)
```bash
# Use CURL_QUICK_REFERENCE.txt for exact commands
# Paste into terminal
# Wait for results
```
Takes 140+ seconds for full test, quick copy-paste flow.

## Test Coverage

### Flows Tested
- ✅ Health check endpoint
- ✅ Single-turn query (basic API flow)
- ✅ Multi-turn conversation (threadId continuity)
- ✅ Error cases (auth, validation)
- ✅ Job status transitions
- ✅ Response notification retrieval
- ✅ MongoDB data persistence

### Error Scenarios Covered
- ✅ Missing API key → 401
- ✅ Invalid API key → 401
- ✅ Empty query → 400
- ✅ Invalid threadId → 400

### Features Verified
- ✅ Fire-and-forget job creation
- ✅ Cron-based async processing
- ✅ Conversation history retrieval
- ✅ Multi-turn context inclusion
- ✅ FIFO job processing
- ✅ Response notification system

## Monitoring During Tests

### View Job Processing in Real-Time
```bash
# In another terminal while tests run:
mongosh cursor-agent
db.jobs.find().sort({createdAt: -1}).pretty()
```

### Check Conversation History
```bash
# For a specific thread:
db.conversations.find({threadId: ObjectId("YOUR_THREAD_ID")}).pretty()
```

### View Status Distribution
```bash
db.jobs.aggregate([
  {$group: {_id: "$status", count: {$sum: 1}}}
])
```

## Expected Results

### After test-api.sh Completes

**Jobs Collection**: 5 jobs created (3 from Flow 2-3, 2 from Flow 4 error tests)
- Some with status "Processed"
- Some with status "Delivered"
- Error cases may not create jobs

**Conversations Collection**: 4+ conversation entries
- 2 from Flow 2 (single-turn)
- 4+ from Flow 3 (multi-turn)

**Threads Collection**: 2 threads created
- One from Flow 2
- One from Flow 3

**Response Output**: 
- All health checks pass
- Single-turn query returns response
- Multi-turn includes previous conversation context
- Error cases return expected status codes

## Troubleshooting Test Failures

### "Connection refused" error
- Server not running: `npm start`
- Check if port 3000 is available

### "Unauthorized" error on valid key
- Check .env file has API_KEY set
- Match x-api-key header with .env value
- Default .env.example value is placeholder

### Job stuck in "InProgress"
- Wait 35+ seconds (30s cron + 5s buffer)
- Check Cursor CLI is installed: `which cursor`
- Check server logs for errors

### No response after 35 seconds
- Check MongoDB is running: `mongosh`
- Check job status: `db.jobs.find()`
- Check server logs: watch `npm start` output

### "Invalid threadId" on copy-pasted threadId
- Ensure threadId is valid MongoDB ObjectId
- Don't modify the threadId, copy exactly
- Create new conversation if unsure

## File Locations

```
cursor-agent/
├── CURL_EXAMPLES.md              ← Read this first
├── CURL_QUICK_REFERENCE.txt      ← Copy-paste commands
├── FLOW_DIAGRAMS.txt             ← Visual explanations
├── test-api.sh                   ← Run this script
├── TEST_FILES_SUMMARY.md         ← This file
└── ...
```

## Next Steps After Testing

1. Verify all tests pass
2. Check MongoDB has correct data
3. Review FLOW_DIAGRAMS.txt to understand architecture
4. Read README.md for production deployment
5. Integrate with Alexa Skill (use /chat/init and /chat/notification)
6. Configure for EC2 deployment (see scripts/startup.sh)

## Support

- **Questions about commands?** → See CURL_QUICK_REFERENCE.txt
- **Want to understand flows?** → See FLOW_DIAGRAMS.txt
- **Need detailed guide?** → See CURL_EXAMPLES.md
- **Want to automate testing?** → Run test-api.sh
- **Production deployment?** → See README.md

