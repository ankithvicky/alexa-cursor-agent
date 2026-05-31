const mongoose = require('mongoose');

const threadSchema = new mongoose.Schema(
  {
    status: {
      type: String,
      enum: ['active', 'inactive'],
      default: 'active'
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Thread', threadSchema);
