import crypto from 'crypto';

class Block {
  constructor(timestamp, data, previousHash = '') {
    this.timestamp = timestamp;
    this.data = data;
    this.previousHash = previousHash;
    this.hash = this.calculateHash();
  }

  calculateHash() {
    return crypto.createHash('sha256')
      .update(this.timestamp + JSON.stringify(this.data) + this.previousHash)
      .digest('hex');
  }
}

class Blockchain {
  constructor() {
    this.chain = [this.createGenesisBlock()];
  }

  createGenesisBlock() {
    return new Block(new Date().toISOString(), { message: 'Genesis Block' }, '0');
  }

  getLatestBlock() {
    return this.chain[this.chain.length - 1];
  }

  addBlock(data) {
    const newBlock = new Block(
      new Date().toISOString(),
      data,
      this.getLatestBlock().hash
    );
    this.chain.push(newBlock);
    return newBlock;
  }

  getChain() {
    return this.chain;
  }

  getBlockByHash(hash) {
    return this.chain.find(block => block.hash === hash);
  }

  getBlocksByProductId(productId) {
    return this.chain.filter(block => 
      block.data && block.data.productId === productId
    );
  }
}

const blockchain = new Blockchain();

export default blockchain;