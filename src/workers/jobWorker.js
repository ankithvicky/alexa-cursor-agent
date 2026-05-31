const Job = require('../models/Job');
const Conversation = require('../models/Conversation');
const { askCursor } = require('../utils/cursorCli');

let isWorkerRunning = false;

async function checkStuckJobs() {
  try {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const stuckJobs = await Job.find({
      status: 'InProgress',
      startedAt: { $lt: fiveMinutesAgo }
    });

    for (const job of stuckJobs) {
      if (job.retryCount < 3) {
        await Job.updateOne(
          { _id: job._id },
          {
            status: 'Pending',
            $inc: { retryCount: 1 },
            startedAt: null
          }
        );
        console.log(`Reset job ${job._id} to Pending (retry ${job.retryCount + 1}/3)`);
      } else {
        await Job.updateOne(
          { _id: job._id },
          {
            status: 'Failed',
            error: 'Job timeout exceeded maximum retries'
          }
        );
        console.log(`Marked job ${job._id} as Failed (max retries exceeded)`);
      }
    }
  } catch (error) {
    console.error('Error in checkStuckJobs:', error);
  }
}

async function processJobs() {
  if (isWorkerRunning) {
    return;
  }

  isWorkerRunning = true;

  try {
    // Find one Pending job (oldest first)
    const job = await Job.findOne({ status: 'Pending' }).sort({ createdAt: 1 });

    if (!job) {
      return;
    }

    // Update job to InProgress
    job.status = 'InProgress';
    job.startedAt = new Date();
    await job.save();

    console.log(`Processing job ${job._id}`);

    // Build context from conversation history
    const conversations = await Conversation.find({ threadId: job.threadId })
      .sort({ createdAt: 1 });

    let context = '';
    if (conversations.length > 0) {
      context = 'Previous conversation:\n';
      for (const conv of conversations) {
        const actor = conv.actor === 'user' ? 'User' : 'Assistant';
        context += `${actor}: ${conv.message}\n`;
      }
    }

    // Execute Cursor CLI
    try {
      const response = await askCursor(context, job.query);

      const processedAt = new Date();
      job.status = 'Processed';
      job.response = response;
      job.processedAt = processedAt;
      job.queuedDurationMs = job.startedAt - job.createdAt;
      job.processingDurationMs = processedAt - job.startedAt;
      await job.save();

      await Conversation.create({
        threadId: job.threadId,
        message: response,
        actor: 'assistant'
      });

      console.log(`Job ${job._id} processed successfully`);
    } catch (error) {
      job.status = 'Failed';
      job.error = error.message;
      await job.save();

      console.error(`Job ${job._id} failed:`, error.message);
    }
  } catch (error) {
    console.error('Error in processJobs:', error);
  } finally {
    isWorkerRunning = false;
  }
}

module.exports = { processJobs, checkStuckJobs };
