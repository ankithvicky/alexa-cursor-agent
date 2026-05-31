const express = require('express');
const router = express.Router();
const { authenticateApiKey } = require('../utils/middleware');
const chatController = require('../controllers/chatController');

router.use(authenticateApiKey);

router.post('/init', chatController.initChat);
router.get('/notification', chatController.getNotification);

module.exports = router;
