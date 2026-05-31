const Job = require('../models/Job');
const Thread = require('../models/Thread');
const Conversation = require('../models/Conversation');
const { processJobs } = require('../workers/jobWorker');

exports.initChat = async (req, res) => {
  try {
    const { query, sessionAttributes = {} } = req.body;

    if (!query) {
      return res.status(400).json({ error: 'Query is required' });
    }

    // Extract or create threadId
    let threadId = sessionAttributes.threadId;
    let thread;

    if (threadId) {
      thread = await Thread.findById(threadId);
      if (!thread) {
        return res.status(400).json({ error: 'Invalid threadId' });
      }
      threadId = thread._id;
    } else {
      thread = new Thread({ status: 'active' });
      await thread.save();
      threadId = thread._id;
    }

    // Update thread status to active
    await Thread.updateOne({ _id: threadId }, { status: 'active' });

    // Create conversation document for user query
    await Conversation.create({
      threadId,
      message: query,
      actor: 'user'
    });

    // Create job
    const job = new Job({
      status: 'Pending',
      threadId,
      query
    });
    await job.save();

    console.log(`Created job ${job._id} for thread ${threadId}`);

    // Fire-and-forget: trigger job processing
    setImmediate(() => {
      processJobs().catch(err => console.error('Fire-and-forget processing error:', err));
    });

    // Return immediate response
    res.json({
      jobId: job._id.toString(),
      threadId: threadId.toString(),
      message: 'Your request is being processed',
      sessionAttributes: {
        threadId: threadId.toString()
      }
    });
  } catch (error) {
    console.error('Error in initChat:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getNotification = async (req, res) => {
  try {
    const { threadId } = req.query;

    // Build query for processed jobs
    const query = { status: 'Processed' };
    if (threadId) {
      query.threadId = threadId;
    }

    // Find one processed job (oldest first)
    const job = await Job.findOne(query).sort({ createdAt: 1 });

    if (!job) {
      return res.json({
        hasResponse: false,
        message: 'No response yet, try asking a question',
        sessionAttributes: threadId ? { threadId } : {}
      });
    }

    // Update job to Delivered
    await Job.updateOne({ _id: job._id }, { status: 'Delivered' });

    console.log(`Delivered response for job ${job._id}`);

    res.json({
      hasResponse: true,
      response: job.response,
      queuedDurationMs: job.queuedDurationMs ?? null,
      processingDurationMs: job.processingDurationMs ?? null,
      sessionAttributes: {
        threadId: job.threadId.toString()
      }
    });
  } catch (error) {
    console.error('Error in getNotification:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
