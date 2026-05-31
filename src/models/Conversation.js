const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema(
  {
    threadId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Thread',
      required: true
    },
    message: {
      type: String,
      required: true
    },
    actor: {
      type: String,
      enum: ['user', 'assistant'],
      required: true
    }
  },
  {
    timestamps: true
  }
);

conversationSchema.index({ threadId: 1, createdAt: 1 });

module.exports = mongoose.model('Conversation', conversationSchema);
