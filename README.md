# Online Auction System API

This project is a **Flask-based API** for an **Online Auction System**, built to interact with an Oracle Database that uses PL/SQL for core operations. The system enables users to manage auctions, place bids, and declare winners.

---

## Features

1. **User Management**
   - Create and retrieve user details.

2. **Item Management**
   - Add items for auction.
   - View available items.

3. **Auction Management**
   - Automatically start auctions when items are created.
   - Close auctions and declare winners.
   - View auction details.

4. **Bid Management**
   - Place bids for ongoing auctions.
   - Automatically validate bid amounts and auction status.

5. **Winner Management**
   - View details of auction winners.

---

## Technologies Used

### Backend
- **Flask**: Web framework for the API.
- **Oracle Database**: Backend database to store and manage auction data.
- **PL/SQL**: Stored procedures, triggers, and functions for core auction operations.

### Tools
- **oracledb**: Python package to connect to Oracle Database.

---

## Database Schema
The database includes the following tables:

1. **Users**: Stores user information.
2. **Items**: Stores items available for auction.
3. **Auctions**: Manages auction statuses and highest bids.
4. **Bids**: Tracks all bids placed during auctions.
5. **Winners**: Stores winner details for completed auctions.

---

## Prerequisites

1. **Oracle Database**
   - Install and configure Oracle Database Express Edition (XE).
   - Import the provided PL/SQL scripts to set up the database schema, triggers, and stored procedures.

2. **Python**
   - Python 3.8 or later.
   - Install dependencies:
     ```bash
     pip install flask oracledb
     ```

---

## Installation

1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd <repository_folder>
   ```

2. Run the Flask application:
   ```bash
   python app.py
   ```

3. Access the API at:
   - Base URL: `http://127.0.0.1:5000`

---

## API Endpoints

### 1. User APIs
#### Create User
- **POST** `/users`
- Request Body:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "buyer"
  }
  ```

#### Get All Users
- **GET** `/users`

### 2. Item APIs
#### Create Item
- **POST** `/items`
- Request Body:
  ```json
  {
    "seller_id": 1,
    "name": "Smartphone",
    "description": "Latest model smartphone",
    "starting_price": 500,
    "auction_end_time": "2025-01-15 23:59:59"
  }
  ```

#### Get All Items
- **GET** `/items`

### 3. Auction APIs
#### Get All Auctions
- **GET** `/auctions`

### 4. Bid APIs
#### Place a Bid
- **POST** `/bids`
- Request Body:
  ```json
  {
    "auction_id": 1,
    "buyer_id": 2,
    "bid_amount": 600
  }
  ```

### 5. Winner APIs
#### Get All Winners
- **GET** `/winners`

---

## Example Usage

### Adding a User
```bash
curl -X POST http://127.0.0.1:5000/users \
-H "Content-Type: application/json" \
-d '{
  "name": "Alice",
  "email": "alice@example.com",
  "password": "securepassword",
  "role": "seller"
}'
```

### Adding an Item
```bash
curl -X POST http://127.0.0.1:5000/items \
-H "Content-Type: application/json" \
-d '{
  "seller_id": 1,
  "name": "Gaming Laptop",
  "description": "High-performance gaming laptop",
  "starting_price": 1000,
  "auction_end_time": "2025-01-20 18:00:00"
}'
```

### Placing a Bid
```bash
curl -X POST http://127.0.0.1:5000/bids \
-H "Content-Type: application/json" \
-d '{
  "auction_id": 1,
  "buyer_id": 2,
  "bid_amount": 1200
}'
```

---

## Notes

1. Ensure the database is up and running before starting the Flask application.
2. Always validate the JSON body before sending API requests.
3. Auction and bidding statuses are managed automatically by triggers and stored procedures in the database.

---

## Future Enhancements
- Add authentication and authorization.
- Implement pagination for large datasets.
- Enhance error handling with custom exceptions.
- Add real-time updates for auctions using WebSockets.

---

## License
This project is licensed under the MIT License.

