# 🎮 In-Game Shop - Full-Stack E-commerce Application

A full-stack e-commerce application for an **in-game item shop**, featuring a **mobile frontend built with Flutter** and a **backend system developed with Node.js, Express, and MongoDB**. The application integrates a payment system via **PromptPay QR Code** using the **Omise payment gateway**.

This project was created to demonstrate a comprehensive understanding of full-stack application development, from design and development to API integration and payment system management.

---

## 📸 Application Screenshots

> _Recommendation: Add beautiful screenshots or GIFs of your application here to give viewers an immediate overview of the project._

- Login Screen  
- Home Screen  
- Cart Screen  
- Payment Screen  

---

## ✨ Key Features

### 🔐 Authentication System:
- User registration and login functionality.
- Utilizes JSON Web Tokens (JWT) for securing API access.
- Securely stores tokens on the client-side using `flutter_secure_storage`.

### 🛍️ Shopping System:
- Displays a list of all products fetched from the backend.
- Detailed product view for each item.
- Shopping cart system (add/remove items) with state managed by `Provider`.

### 🛒 Ordering System:
- Creates orders from items in the shopping cart and saves them to the database.
- Links each order to the corresponding user.

### 💳 Payment System:
- Integrates with the Omise Payment Gateway.
- Generates dynamic PromptPay QR Codes based on the order's total amount.
- The backend converts SVG files from Omise into PNG images using `sharp` to resolve compatibility issues on iOS.

### 🔄 Webhook System (Real-time Update):
- Implements a webhook endpoint to receive payment confirmation from Omise.
- Automatically updates the order status in the database to `paid` upon successful payment.

---

## 🛠️ Technology Stack

### Frontend (Mobile Application)
- **Framework:** Flutter (v3.x.x)  
- **Language:** Dart  
- **State Management:** Provider  
- **HTTP Client:** `http`  
- **Secure Storage:** `flutter_secure_storage`  
- **UI/UX:** Material Design + Responsive Layout

### Backend (Server-Side)
- **Runtime Environment:** Node.js  
- **Framework:** Express.js  
- **Database:** MongoDB (with Mongoose ODM)  
- **Authentication:** JWT & `bcrypt.js`  
- **Image Processing:** `sharp`  
- **API Client:** `axios` (for backend-to-Omise communication)

### Payment Gateway
- **Omise Thailand:** For enabling PromptPay payments

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed  
- Node.js installed  
- MongoDB Community Server installed and running locally, or use MongoDB Atlas

---

### 1. Backend Setup

```
# 1. Navigate to the backend directory
cd backend

# 2. Install all dependencies
npm install

# 3. Create a .env file in the root of the backend directory and add the following variables
# (replace with your own data)
MONGO_URI=mongodb://localhost:27017/ingameshop
JWT_SECRET=your_jwt_secret_key
OMISE_PUBLIC_KEY=pkey_test_xxxxxxxxxxxxxx
OMISE_SECRET_KEY=skey_test_xxxxxxxxxxxxxx

# 4. Run the backend server (will run on http://localhost:5000)
npm run dev
```

### 2. Frontend Setup

```
# 1. Navigate to the frontend app directory
cd frontend/app

# 2. Install all dependencies
flutter pub get

# 3. Run the application on an emulator or a physical device
flutter run
```

##💡 Future Improvements
Order History: A screen for users to view their past orders.

Admin Panel: A web-based dashboard for administrators to manage products, view all orders, and manage users.

Push Notifications: Notify users upon successful payment or when their order status changes.

Product Search & Filtering: Implement functionality to search for products by name and filter by category or price.



