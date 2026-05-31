#!/bin/bash

API_KEY="test-key"
BASE_URL="http://localhost:3000"
RESET='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo -e "${BLUE}=========================================="
echo "API Testing Script"
echo "==========================================${RESET}"
echo ""

# Check if server is running
echo -e "${YELLOW}Checking if server is running...${RESET}"
if ! curl -s $BASE_URL/health > /dev/null 2>&1; then
  echo -e "${RED}✗ Server is not running on $BASE_URL${RESET}"
  echo "Start the server with: npm start"
  exit 1
fi
echo -e "${GREEN}✓ Server is running${RESET}"
echo ""

# Test 1: Health Check
echo -e "${BLUE}=========================================="
echo "Test 1: Health Check"
echo "==========================================${RESET}"
echo "Command: curl -X GET $BASE_URL/health"
echo ""
curl -s -X GET $BASE_URL/health | jq '.' || curl -s -X GET $BASE_URL/health
echo ""
echo ""

# Test 2: Single-Turn Query
echo -e "${BLUE}=========================================="
echo "Test 2: Single-Turn Query (Basic Flow)"
echo "==========================================${RESET}"

echo -e "${YELLOW}Step 2a: Create a new job${RESET}"
echo "Command: curl -X POST $BASE_URL/chat/init -H \"x-api-key: $API_KEY\" -H \"Content-Type: application/json\" -d '{\"query\": \"What is a hash map?\", \"sessionAttributes\": {}}'"
echo ""
RESPONSE=$(curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is a hash map?",
    "sessionAttributes": {}
  }')

echo $RESPONSE | jq '.' || echo $RESPONSE
THREAD_ID=$(echo $RESPONSE | jq -r '.threadId' 2>/dev/null)
echo -e "${GREEN}Thread ID: $THREAD_ID${RESET}"
echo ""

echo -e "${YELLOW}Step 2b: Waiting 35 seconds for Cursor CLI to process...${RESET}"
for i in {1..7}; do
  echo -n "."
  sleep 5
done
echo ""
echo ""

echo -e "${YELLOW}Step 2c: Retrieve the response${RESET}"
echo "Command: curl -X GET \"$BASE_URL/chat/notification\" -H \"x-api-key: $API_KEY\""
echo ""
curl -s -X GET "$BASE_URL/chat/notification" \
  -H "x-api-key: $API_KEY" | jq '.' || curl -s -X GET "$BASE_URL/chat/notification" -H "x-api-key: $API_KEY"
echo ""
echo ""

# Test 3: Multi-Turn Conversation
echo -e "${BLUE}=========================================="
echo "Test 3: Multi-Turn Conversation"
echo "==========================================${RESET}"

echo -e "${YELLOW}Step 3a: First query (start new conversation)${RESET}"
echo "Command: curl -X POST $BASE_URL/chat/init -H \"x-api-key: $API_KEY\" -H \"Content-Type: application/json\" -d '{\"query\": \"What is a linked list?\", \"sessionAttributes\": {}}'"
echo ""
RESPONSE=$(curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is a linked list?",
    "sessionAttributes": {}
  }')

echo $RESPONSE | jq '.' || echo $RESPONSE
THREAD_ID=$(echo $RESPONSE | jq -r '.threadId' 2>/dev/null)
echo -e "${GREEN}Thread ID: $THREAD_ID${RESET}"
echo ""

echo -e "${YELLOW}Step 3b: Waiting 35 seconds for processing...${RESET}"
for i in {1..7}; do
  echo -n "."
  sleep 5
done
echo ""
echo ""

echo -e "${YELLOW}Step 3c: Get first response${RESET}"
echo "Command: curl -X GET \"$BASE_URL/chat/notification?threadId=$THREAD_ID\" -H \"x-api-key: $API_KEY\""
echo ""
curl -s -X GET "$BASE_URL/chat/notification?threadId=$THREAD_ID" \
  -H "x-api-key: $API_KEY" | jq '.' || curl -s -X GET "$BASE_URL/chat/notification?threadId=$THREAD_ID" -H "x-api-key: $API_KEY"
echo ""

echo -e "${YELLOW}Step 3d: Second query (continue same conversation)${RESET}"
echo "Command: curl -X POST $BASE_URL/chat/init -H \"x-api-key: $API_KEY\" -H \"Content-Type: application/json\" -d '{\"query\": \"How do you reverse a linked list?\", \"sessionAttributes\": {\"threadId\": \"$THREAD_ID\"}}'"
echo ""
RESPONSE=$(curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"How do you reverse a linked list?\",
    \"sessionAttributes\": {
      \"threadId\": \"$THREAD_ID\"
    }
  }")

echo $RESPONSE | jq '.' || echo $RESPONSE
echo ""

echo -e "${YELLOW}Step 3e: Waiting 35 seconds for processing...${RESET}"
for i in {1..7}; do
  echo -n "."
  sleep 5
done
echo ""
echo ""

echo -e "${YELLOW}Step 3f: Get second response (with conversation history)${RESET}"
echo "Command: curl -X GET \"$BASE_URL/chat/notification?threadId=$THREAD_ID\" -H \"x-api-key: $API_KEY\""
echo ""
curl -s -X GET "$BASE_URL/chat/notification?threadId=$THREAD_ID" \
  -H "x-api-key: $API_KEY" | jq '.' || curl -s -X GET "$BASE_URL/chat/notification?threadId=$THREAD_ID" -H "x-api-key: $API_KEY"
echo ""
echo ""

# Test 4: Error Cases
echo -e "${BLUE}=========================================="
echo "Test 4: Error Cases"
echo "==========================================${RESET}"

echo -e "${YELLOW}Test 4a: Missing API Key (expect 401)${RESET}"
echo "Command: curl -X GET $BASE_URL/chat/notification"
echo ""
curl -s -X GET $BASE_URL/chat/notification | jq '.' || curl -s -X GET $BASE_URL/chat/notification
echo ""

echo -e "${YELLOW}Test 4b: Invalid API Key (expect 401)${RESET}"
echo "Command: curl -X GET $BASE_URL/chat/notification -H \"x-api-key: wrong-key\""
echo ""
curl -s -X GET $BASE_URL/chat/notification \
  -H "x-api-key: wrong-key" | jq '.' || curl -s -X GET $BASE_URL/chat/notification -H "x-api-key: wrong-key"
echo ""

echo -e "${YELLOW}Test 4c: Empty Query (expect 400)${RESET}"
echo "Command: curl -X POST $BASE_URL/chat/init -H \"x-api-key: $API_KEY\" -H \"Content-Type: application/json\" -d '{\"query\": \"\", \"sessionAttributes\": {}}'"
echo ""
curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "", "sessionAttributes": {}}' | jq '.' || curl -s -X POST $BASE_URL/chat/init -H "x-api-key: $API_KEY" -H "Content-Type: application/json" -d '{"query": "", "sessionAttributes": {}}'
echo ""

echo -e "${YELLOW}Test 4d: Invalid ThreadId (expect 400)${RESET}"
echo "Command: curl -X POST $BASE_URL/chat/init -H \"x-api-key: $API_KEY\" -H \"Content-Type: application/json\" -d '{\"query\": \"Hello\", \"sessionAttributes\": {\"threadId\": \"invalid-id\"}}'"
echo ""
curl -s -X POST $BASE_URL/chat/init \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "Hello", "sessionAttributes": {"threadId": "invalid-id"}}' | jq '.' || curl -s -X POST $BASE_URL/chat/init -H "x-api-key: $API_KEY" -H "Content-Type: application/json" -d '{"query": "Hello", "sessionAttributes": {"threadId": "invalid-id"}}'
echo ""
echo ""

echo -e "${BLUE}=========================================="
echo "Testing Complete!"
echo "==========================================${RESET}"
echo ""
echo "To view MongoDB data:"
echo "  mongosh cursor-agent"
echo "  db.jobs.find().pretty()"
echo "  db.conversations.find().pretty()"
echo "  db.threads.find().pretty()"
echo ""
echo "For more information, see CURL_EXAMPLES.md"
