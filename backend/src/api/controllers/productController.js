const Product = require('../models/ProductModel');

// @desc    Fetch all products
// @route   GET /api/products
const getProducts = async (req, res) => {
  try {
    const products = await Product.find({});
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Create a product
// @route   POST /api/products
// @access  Private/Admin
const createProduct = async (req, res) => {
    const { name, price, description, imageUrl, stock } = req.body;
    try {
        const product = new Product({
            name,
            price,
            description,
            imageUrl,
            stock,
        });
        const createdProduct = await product.save();
        res.status(201).json(createdProduct);
    } catch (error) {
         res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = { getProducts, createProduct };