# Sustainable Food Systems Platform

**Accelerating the transition to regenerative food systems through AI, blockchain, and cloud technologies.**

![SDG Alignment](https://img.shields.io/badge/SDGs-2,3,12,13,15-brightgreen)
![Tech Stack](https://img.shields.io/badge/Tech-Flutter,Firebase,TensorFlow,Blockchain,Gemini-blue)

## Table of Contents
- [Sustainable Food Systems Platform](#sustainable-food-systems-platform)
  - [Table of Contents](#table-of-contents)
  - [📌 Introduction](#-introduction)
  - [🎯 Problem Statement](#-problem-statement)
  - [🌍 Alignment with UN SDGs](#-alignment-with-un-sdgs)
  - [✨ Key Features](#-key-features)
    - [🌱 AI-Powered Crop Advisory](#-ai-powered-crop-advisory)
    - [🔗 Blockchain-Verified Supply Chain](#-blockchain-verified-supply-chain)
    - [� Personalized Nutrition Planning](#-personalized-nutrition-planning)
    - [♻️ Predictive Food Waste Reduction](#️-predictive-food-waste-reduction)
    - [🌦️ Climate-Smart Farming Library](#️-climate-smart-farming-library)
  - [📱 App Demo](#-app-demo)
  - [🔧 Installation \& Setup](#-installation--setup)
    - [Prerequisites](#prerequisites)
    - [Steps](#steps)
  - [🤝 Contributing](#-contributing)
  - [📜 License](#-license)
  - [📞 Contact](#-contact)

## 📌 Introduction
Our platform bridges the gap between fragmented food system solutions by integrating AI-driven agriculture, transparent supply chains, personalized nutrition, and food waste reduction. By optimizing for both human and environmental health, we empower farmers, consumers, and businesses to adopt sustainable practices seamlessly.

## 🎯 Problem Statement
The global food system drives interconnected crises—hunger, malnutrition, climate change, biodiversity loss, and food waste. Current solutions are siloed, leading to inefficiencies. Our unified digital platform leverages AI, blockchain, and cloud technologies to:
- Enhance sustainable farming
- Ensure supply chain transparency
- Reduce food waste
- Promote climate-resilient agriculture
- Improve nutrition accessibility

## 🌍 Alignment with UN SDGs
Our solution directly contributes to:
- **SDG 2 (Zero Hunger)** – Boosts small-scale farmer productivity & promotes resilient agriculture.
- **SDG 3 (Good Health & Well-Being)** – Enables personalized nutrition to combat diet-related diseases.
- **SDG 12 (Responsible Consumption & Production)** – Cuts food waste via predictive redistribution.
- **SDG 13 (Climate Action)** – Strengthens climate resilience in farming.
- **SDG 15 (Life on Land)** – Restores soil health & biodiversity through regenerative practices.

## ✨ Key Features

### 🌱 AI-Powered Crop Advisory
- Predicts crop yields & detects diseases via image analysis
- Provides tailored farming recommendations using TensorFlow & Cloud Vision API
- Integrates traditional knowledge with AI insights

### 🔗 Blockchain-Verified Supply Chain
- Tracks food from farm to fork using blockchain
- QR code scanning for authenticity & sustainability verification
- Builds consumer trust in sustainable products

### � Personalized Nutrition Planning
- Recommends sustainable, locally available foods
- Generates meal plans using Gemini AI
- Tailors suggestions based on dietary needs

### ♻️ Predictive Food Waste Reduction
- Forecasts surplus food before waste occurs
- Connects donors with recipients via Firebase & Google Maps
- Optimizes food redistribution networks

### 🌦️ Climate-Smart Farming Library
- Delivers region-specific adaptation strategies
- Uses geolocation and weather data
- Suggests sustainable farming methods

## 📱 App Demo
![App Showcase](demo.gif)


## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Firebase account
- Google Cloud account (for AI services)
- Node.js (for blockchain development)
- Python (v3.9 or higher)


### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/jocelyngan2005/agriroute.git
   cd agriroute
2. **Set Up Python Backend**
   ```bash
   #Navigate to backend directory
   cd assets
   cd backend

   #Create and activate virtual environment
   python -m venv venv
   venv\Scripts\activate

   #Install Python dependencies
   pip intall -r requirements.txt
3. **Configure Firebase**
   - Set up Firestore & Authentication in Firebase Console
   - Add your google-services,jason to /android/app
4. **Set up AI services**
   - Enable Cloud Vision API and Gemini API in Google Cloud Console
5. **Run the system**
   ```bash
   cd assets
   cd backend
   python server.py
6. **Run the application**
   ```bash
   flutter run
## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:
- Report bugs by opening an issue
- Suggest features through the issue tracker
- Submit code improvements via pull requests

## 📜 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact
For questions or partnership opportunities:
- Project Lead: Jocelyn Gan
- GitHub: @jocelyngan2005
