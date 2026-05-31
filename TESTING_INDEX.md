# Testing Index - All Test Files at a Glance

## What to Read First

Start here based on your needs:

### 🚀 "Just Run It" (Fastest)
```bash
./test-api.sh
```
**File**: `test-api.sh` (executable)  
**Time**: ~140 seconds  
**What happens**: Runs all tests automatically with colored output

---

### 📚 "I Want to Learn" (Comprehensive)
**File**: `CURL_EXAMPLES.md`  
**Time**: 15-30 minutes reading  
**Contains**:
- Detailed explanation of each flow
- Expected responses for each command
- Step-by-step examples
- Error case handling
- MongoDB monitoring commands
- Complete testing checklist
- Troubleshooting guide

**Read this if you**: Want to understand every detail before testing

---

### ⚡ "Give Me the Commands" (Quick Reference)
**File**: `CURL_QUICK_REFERENCE.txt`  
**Time**: 2 minutes to scan  
**Contains**:
- Copy-paste ready curl commands
- Expected responses
- Flow summaries
- Tips and common variables
- Timeline explanation

**Read this if you**: Know curl and just need the exact commands

---

### 📊 "Show Me the Diagrams" (Visual)
**File**: `FLOW_DIAGRAMS.txt`  
**Time**: 10-15 minutes to review  
**Contains**:
- ASCII diagrams for each flow
- Step-by-step visualizations
- Database state transitions
- Job retry state machine
- Cron job timing diagrams
- Multi-job queue examples

**Read this if you**: Learn better visually

---

### 📋 "What Files Do I Have?" (Overview)
**File**: `TEST_FILES_SUMMARY.md`  
**Time**: 5 minutes  
**Contains**:
- Description of all test files
- How to use each file
- Test coverage details
- Troubleshooting section
- Expected results

**Read this if you**: Want an overview of testing resources

---

## Quick Decision Tree

```
Do you want to...

  ├─ Run automated tests?
  │  └─> ./test-api.sh
  │
  ├─ Learn the API flows?
  │  └─> CURL_EXAMPLES.md
  │
  ├─ Quick copy-paste commands?
  │  └─> CURL_QUICK_REFERENCE.txt
  │
  ├─ Understand architecture visually?
  │  └─> FLOW_DIAGRAMS.txt
  │
  └─ Find out about test files?
     └─> TEST_FILES_SUMMARY.md
```

---

## All Test Files

| File | Size | Purpose | Time | Format |
|------|------|---------|------|--------|
| `test-api.sh` | 6.8K | Automated testing | 140s | Executable |
| `CURL_EXAMPLES.md` | 11K | Comprehensive guide | 15-30m | Markdown |
| `CURL_QUICK_REFERENCE.txt` | 8K | Quick reference | 2m | Text |
| `FLOW_DIAGRAMS.txt` | 22K | Visual diagrams | 10-15m | ASCII art |
| `TEST_FILES_SUMMARY.md` | 5.6K | Test overview | 5m | Markdown |
| `TESTING_INDEX.md` | This file | Navigation | 3m | Markdown |

---

## Flows Covered in All Files

### Flow 1: Health Check
- ✅ `test-api.sh` (automated)
- ✅ `CURL_EXAMPLES.md` (step 1)
- ✅ `CURL_QUICK_REFERENCE.txt` (section 1)
- ✅ `FLOW_DIAGRAMS.txt` (diagram 1)

### Flow 2: Single-Turn Query
- ✅ `test-api.sh` (automated)
- ✅ `CURL_EXAMPLES.md` (section 2)
- ✅ `CURL_QUICK_REFERENCE.txt` (section 2)
- ✅ `FLOW_DIAGRAMS.txt` (diagram 2)

### Flow 3: Multi-Turn Conversation
- ✅ `test-api.sh` (automated)
- ✅ `CURL_EXAMPLES.md` (section 3)
- ✅ `CURL_QUICK_REFERENCE.txt` (section 3-4)
- ✅ `FLOW_DIAGRAMS.txt` (diagram 3)

### Flow 4: Error Cases
- ✅ `test-api.sh` (automated)
- ✅ `CURL_EXAMPLES.md` (section 4)
- ✅ `CURL_QUICK_REFERENCE.txt` (section 5)
- ✅ `FLOW_DIAGRAMS.txt` (diagram 5)

### Flow 5: Batch Testing
- ✅ `test-api.sh` (is the script)
- ✅ `CURL_EXAMPLES.md` (section 5)
- ✅ `FLOW_DIAGRAMS.txt` (diagram 7)

### Flow 6+: Advanced Topics
- ✅ `CURL_EXAMPLES.md` (sections 6-9)
- ✅ `CURL_QUICK_REFERENCE.txt` (sections 7-10)
- ✅ `FLOW_DIAGRAMS.txt` (diagrams 4, 6, 8)

---

## How to Use Each File

### test-api.sh
**When**: You want automation  
**How**:
```bash
# Make sure server is running
npm start &

# In another terminal
./test-api.sh
```
**Output**: Colored output with progress, ~140 seconds

---

### CURL_EXAMPLES.md
**When**: You want to learn  
**How**:
1. Read the markdown file
2. Copy commands from examples
3. Modify as needed
4. Run in your terminal
5. Compare output to "Expected Response"

**Output**: Detailed understanding of each flow

---

### CURL_QUICK_REFERENCE.txt
**When**: You need commands fast  
**How**:
1. Open file
2. Find the flow you want
3. Copy the curl command
4. Paste in terminal
5. Modify API_KEY/threadId as needed

**Output**: Instant command execution

---

### FLOW_DIAGRAMS.txt
**When**: You want visual understanding  
**How**:
1. Read the ASCII diagrams
2. Follow the arrows
3. Read the accompanying explanation
4. Look at the example command
5. Understand the flow

**Output**: Visual/conceptual understanding

---

### TEST_FILES_SUMMARY.md
**When**: You need overview  
**How**:
1. Scan the file descriptions
2. Check the "Which file to use" section
3. Review test coverage
4. Look at troubleshooting for issues

**Output**: Knowledge of what tests exist

---

## Testing Progression

### Level 1: Verify It Works
```bash
# Just run the automated test
./test-api.sh
```
Expected: All tests pass in ~140 seconds

### Level 2: Understand the API
```bash
# Read the comprehensive guide
cat CURL_EXAMPLES.md

# Pick a flow and run it manually
# Follow the steps in the guide
```
Expected: Full understanding of API behavior

### Level 3: Visualize the Architecture
```bash
# Study the diagrams
cat FLOW_DIAGRAMS.txt

# Read FLOW_DIAGRAMS.txt section on:
# - Database state transitions
# - Job retry state machine
# - Cron job timing
```
Expected: Understanding of async job processing

### Level 4: Production Preparation
```bash
# Review deployment readiness
cat README.md
cat QUICK_START.md
cat scripts/startup.sh
```
Expected: Ready to deploy to EC2

---

## File Relationships

```
TESTING_INDEX.md (you are here)
    │
    ├─ test-api.sh ──────────────> Runs all flows automatically
    │
    ├─ CURL_EXAMPLES.md ─────────> Detailed walk-through
    │                               └─ Use for learning
    │
    ├─ CURL_QUICK_REFERENCE.txt ──> Command reference
    │                               └─ Use for quick copy-paste
    │
    ├─ FLOW_DIAGRAMS.txt ────────> Visual explanations
    │                               └─ Use for understanding architecture
    │
    └─ TEST_FILES_SUMMARY.md ────> Metadata about test files
                                    └─ Use for navigation
```

---

## Common Scenarios

### Scenario 1: "I have 2 minutes"
1. Run: `./test-api.sh`
2. Watch colored output
3. Verify all tests pass
4. Done!

### Scenario 2: "I want to understand the API"
1. Read: `CURL_EXAMPLES.md`
2. Read: `FLOW_DIAGRAMS.txt`
3. Run: `./test-api.sh`
4. Study: Database state in MongoDB
5. Done!

### Scenario 3: "I need specific curl commands"
1. Search: `CURL_QUICK_REFERENCE.txt` for your flow
2. Copy the command
3. Modify API_KEY/threadId
4. Run
5. Done!

### Scenario 4: "I'm debugging a failure"
1. Read: `TEST_FILES_SUMMARY.md` troubleshooting section
2. Check: Server logs with `npm start`
3. Check: MongoDB with `mongosh`
4. Review: `FLOW_DIAGRAMS.txt` for state transitions
5. Try again
6. Done!

### Scenario 5: "I'm integrating with Alexa"
1. Read: `CURL_EXAMPLES.md` for API format
2. Copy: Request/response examples
3. Map: To Alexa Skill backend
4. Test: `CURL_QUICK_REFERENCE.txt` commands
5. Deploy: See `README.md`
6. Done!

---

## Checklists

### Pre-Testing
- [ ] Server running: `npm start`
- [ ] MongoDB running: `mongosh`
- [ ] .env configured with API_KEY=test-key
- [ ] curl installed (check: `curl --version`)
- [ ] jq installed (optional, check: `jq --version`)

### Running Tests
- [ ] Read the appropriate file for your level
- [ ] Set up shell variables (optional)
- [ ] Run health check first
- [ ] Wait appropriate time between steps
- [ ] Check responses match expected values

### Post-Testing
- [ ] Verify MongoDB has data
- [ ] Review job status distribution
- [ ] Check conversation history
- [ ] Test error cases work correctly
- [ ] Review test output for issues

---

## Troubleshooting Quick Links

| Problem | Solution |
|---------|----------|
| "Connection refused" | Server not running, run `npm start` |
| "Unauthorized" (401) | API key mismatch, check .env file |
| Job stuck in "InProgress" | Wait 35+ seconds for cron, check Cursor CLI |
| No response after 35s | MongoDB down, check with `mongosh` |
| "Invalid threadId" | Copy exact threadId, don't modify |
| Need more help | See `TEST_FILES_SUMMARY.md` troubleshooting |

---

## Next Steps

1. **Quick Test**: Run `./test-api.sh` (2 minutes)
2. **Understand**: Read `FLOW_DIAGRAMS.txt` (15 minutes)
3. **Learn Details**: Read `CURL_EXAMPLES.md` (30 minutes)
4. **Reference**: Use `CURL_QUICK_REFERENCE.txt` for commands
5. **Deploy**: Follow `README.md` for production

---

## Questions?

- **How do I run tests?** → See "All Test Files" table above
- **What commands do I use?** → See `CURL_QUICK_REFERENCE.txt`
- **How does it work?** → See `FLOW_DIAGRAMS.txt`
- **What files exist?** → See `TEST_FILES_SUMMARY.md`
- **Detailed walkthrough?** → See `CURL_EXAMPLES.md`

---

**Start here**: Pick your level and dive in!

- 🚀 **Fast**: `./test-api.sh`
- 📚 **Comprehensive**: `CURL_EXAMPLES.md`
- ⚡ **Reference**: `CURL_QUICK_REFERENCE.txt`
- 📊 **Visual**: `FLOW_DIAGRAMS.txt`
