from flask import Flask, request, jsonify
import oracledb

app = Flask(__name__)

# ----------------------------
# Database Configuration
# ----------------------------
db_config = {
    "user": "system",
    "password": "root",  # Update with your database password
    "dsn": "localhost/XEPDB1"  # Update DSN as per your database configuration
}


# ----------------------------
# Utility: Get DB Connection
# ----------------------------
def get_db_connection():
    return oracledb.connect(**db_config)


# ----------------------------
# Routes
# ----------------------------
@app.route("/")
def index():
    return "Welcome to the Online Auction System API!"


# ----------------------------
# 1. User APIs
# ----------------------------
@app.route("/users", methods=["POST"])
def create_user():
    data = request.json
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Users (user_id, name, email, password, role) "
            "VALUES (SEQ_USERS.NEXTVAL, :1, :2, :3, :4)",
            (data["name"], data["email"], data["password"], data["role"])
        )
        conn.commit()
        return jsonify({"message": "User created successfully!"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


@app.route("/users", methods=["GET"])
def get_users():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT user_id, name, email, role FROM Users")
        users = [
            {"user_id": row[0], "name": row[1], "email": row[2], "role": row[3]}
            for row in cursor.fetchall()
        ]
        return jsonify(users)
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


# ----------------------------
# 2. Item APIs
# ----------------------------
@app.route("/items", methods=["POST"])
def create_item():
    data = request.json
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            """INSERT INTO Items (item_id, seller_id, name, description, starting_price, auction_end_time)
               VALUES (SEQ_ITEMS.NEXTVAL, :1, :2, :3, :4, TO_DATE(:5, 'YYYY-MM-DD HH24:MI:SS'))""",
            (data["seller_id"], data["name"], data["description"], data["starting_price"], data["auction_end_time"])
        )
        conn.commit()
        return jsonify({"message": "Item created successfully!"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


@app.route("/items", methods=["GET"])
def get_items():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT item_id, name, description, starting_price, auction_end_time FROM Items")
        items = [
            {
                "item_id": row[0],
                "name": row[1],
                "description": row[2],
                "starting_price": row[3],
                "auction_end_time": row[4].strftime("%Y-%m-%d %H:%M:%S")
            }
            for row in cursor.fetchall()
        ]
        return jsonify(items)
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


# ----------------------------
# 3. Auction APIs
# ----------------------------
@app.route("/auctions", methods=["GET"])
def get_auctions():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT auction_id, item_id, status, highest_bid FROM Auctions")
        auctions = [
            {
                "auction_id": row[0],
                "item_id": row[1],
                "status": row[2],
                "highest_bid": row[3]
            }
            for row in cursor.fetchall()
        ]
        return jsonify(auctions)
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


# ----------------------------
# 4. Bid APIs
# ----------------------------
@app.route("/bids", methods=["POST"])
def add_bid():
    data = request.json
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Call PL/SQL Procedure to Add Bid
        cursor.callproc("Add_Bid", [data["auction_id"], data["buyer_id"], data["bid_amount"]])

        conn.commit()
        return jsonify({"message": "Bid placed successfully!"}), 201
    except oracledb.DatabaseError as e:
        error_obj = e.args[0]
        return jsonify({"error": error_obj.message}), 400
    finally:
        conn.close()


# ----------------------------
# 5. Winner APIs
# ----------------------------
@app.route("/winners", methods=["GET"])
def get_winners():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            """SELECT w.winner_id, w.auction_id, w.winner_user_id, w.winning_bid, u.name 
               FROM Winners w 
               JOIN Users u ON w.winner_user_id = u.user_id"""
        )
        winners = [
            {
                "winner_id": row[0],
                "auction_id": row[1],
                "winner_user_id": row[2],
                "winning_bid": row[3],
                "winner_name": row[4]
            }
            for row in cursor.fetchall()
        ]
        return jsonify(winners)
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    finally:
        conn.close()


# ----------------------------
# Run the Flask App
# ----------------------------
if __name__ == "__main__":
    app.run(debug=True)
