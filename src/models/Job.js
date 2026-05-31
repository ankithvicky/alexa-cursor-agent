const mongoose = require('mongoose');

const jobSchema = new mongoose.Schema(
  {
    status: {
      type: String,
      enum: ['Pending', 'InProgress', 'Failed', 'Processed', 'Delivered'],
      default: 'Pending'
    },
    threadId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Thread',
      required: true
    },
    query: {
      type: String,
      required: true
    },
    response: String,
    retryCount: {
      type: Number,
      default: 0
    },
    error: String,
    startedAt: Date,
    processedAt: Date,
    queuedDurationMs: Number,
    processingDurationMs: Number
  },
  {
    timestamps: true
  }
);

jobSchema.index({ status: 1, createdAt: 1 });
jobSchema.index({ threadId: 1 });

module.exports = mongoose.model('Job', jobSchema);
