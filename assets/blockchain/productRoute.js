import express from 'express';
import blockchain from 'simpleChain.js'; // .js extension required

const router = express.Router();

// Register a new product
router.post('/register', async (req, res) => {
  try {

    const { productId, name, producerName, location, harvestDate } = req.body;
    
    // Validate input
    if (!productId || !name || !producerName) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    let productData = {}
    
    if (blockchain.getBlocksByProductId(productId).length === 0) {
      productData = {
        type: 'PRODUCT_REGISTRATION',
        productId,
        name,
        producerName,
        location,
        harvestDate,
        status: 'harvested',
        timestamp: new Date().toISOString()
      };
    } else {
      return res.status(404).json({ error: 'Product already exists' });
    }
    const newBlock = blockchain.addBlock(productData);
    
    
    
    res.status(201).json({
      success: true,
      data: {
        productId: productId,
        blockHash: newBlock.hash
      },
      message: 'Product registered successfully'
    });
  } catch (error) {
    console.error('Error in /register:', error);
    res.status(400).json({
      success: false,
      message: error.message,
      error: error
    });
  }
});

// Record a product handoff
router.post('/handoff', (req, res) => {
  try {
    const { productId, senderId, receiverId, location, notes } = req.body;
    
    // Validate input
    if (!productId || !senderId || !receiverId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Create handoff data
    const handoffData = {
      type: 'PRODUCT_HANDOFF',
      productId,
      senderId,
      receiverId,
      location,
      notes,
      timestamp: new Date().toISOString()
    };
    
    // Add to blockchain
    const newBlock = blockchain.addBlock(handoffData);
    
    res.status(201).json({
      message: 'Handoff recorded successfully',
      blockHash: newBlock.hash
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get product history
router.get('/:productId/history', (req, res) => {
  try {
    const { productId } = req.params;
    
    // Get all blocks for this product
    const productBlocks = blockchain.getBlocksByProductId(productId);
    
    if (productBlocks.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json(productBlocks);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


export default router; 