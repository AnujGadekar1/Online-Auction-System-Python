-- Online Auction System in PL/SQL

-- 1. Create Tables

CREATE TABLE Users (
    user_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100),
    password VARCHAR2(100),
    role VARCHAR2(20) CHECK (role IN ('buyer', 'seller'))
);

CREATE TABLE Items (
    item_id NUMBER PRIMARY KEY,
    seller_id NUMBER REFERENCES Users(user_id),
    name VARCHAR2(100),
    description VARCHAR2(500),
    starting_price NUMBER,
    created_at DATE DEFAULT SYSDATE,
    auction_end_time DATE
);

CREATE TABLE Auctions (
    auction_id NUMBER PRIMARY KEY,
    item_id NUMBER REFERENCES Items(item_id),
    status VARCHAR2(20) CHECK (status IN ('ongoing', 'completed', 'canceled')),
    highest_bid NUMBER DEFAULT 0
);

CREATE TABLE Bids (
    bid_id NUMBER PRIMARY KEY,
    auction_id NUMBER REFERENCES Auctions(auction_id),
    buyer_id NUMBER REFERENCES Users(user_id),
    bid_amount NUMBER,
    bid_time DATE DEFAULT SYSDATE
);

CREATE TABLE Winners (
    winner_id NUMBER PRIMARY KEY,
    auction_id NUMBER REFERENCES Auctions(auction_id),
    winner_user_id NUMBER REFERENCES Users(user_id),
    winning_bid NUMBER
);

-- 2. Sequences for Primary Keys
CREATE SEQUENCE SEQ_USERS START WITH 1;
CREATE SEQUENCE SEQ_ITEMS START WITH 1;
CREATE SEQUENCE SEQ_AUCTIONS START WITH 1;
CREATE SEQUENCE SEQ_BIDS START WITH 1;
CREATE SEQUENCE SEQ_WINNERS START WITH 1;

-- 3. Stored Procedure to Add a Bid
CREATE OR REPLACE PROCEDURE Add_Bid (
    p_auction_id IN NUMBER,
    p_buyer_id IN NUMBER,
    p_bid_amount IN NUMBER
) AS
    v_highest_bid NUMBER;
    v_status VARCHAR2(20);
BEGIN
    -- Fetch current highest bid and auction status
    SELECT highest_bid, status
    INTO v_highest_bid, v_status
    FROM Auctions
    WHERE auction_id = p_auction_id;

    -- Validate auction status
    IF v_status != 'ongoing' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Auction is not ongoing.');
    END IF;

    -- Validate bid amount
    IF p_bid_amount <= v_highest_bid THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bid amount must be higher than the current highest bid.');
    END IF;

    -- Insert the bid
    INSERT INTO Bids (bid_id, auction_id, buyer_id, bid_amount, bid_time)
    VALUES (SEQ_BIDS.NEXTVAL, p_auction_id, p_buyer_id, p_bid_amount, SYSDATE);

    -- Update highest bid in Auctions
    UPDATE Auctions
    SET highest_bid = p_bid_amount
    WHERE auction_id = p_auction_id;

    DBMS_OUTPUT.PUT_LINE('Bid successfully placed!');
END;
/

-- 4. Stored Procedure to Close an Auction
CREATE OR REPLACE PROCEDURE Close_Auction (
    p_auction_id IN NUMBER
) AS
    v_winner_user_id NUMBER;
    v_winning_bid NUMBER;
BEGIN
    -- Find the highest bidder
    SELECT buyer_id, MAX(bid_amount)
    INTO v_winner_user_id, v_winning_bid
    FROM Bids
    WHERE auction_id = p_auction_id
    GROUP BY buyer_id;

    -- Insert winner record
    INSERT INTO Winners (winner_id, auction_id, winner_user_id, winning_bid)
    VALUES (SEQ_WINNERS.NEXTVAL, p_auction_id, v_winner_user_id, v_winning_bid);

    -- Update auction status
    UPDATE Auctions
    SET status = 'completed'
    WHERE auction_id = p_auction_id;

    DBMS_OUTPUT.PUT_LINE('Auction closed and winner declared!');
END;
/

-- 5. Trigger to Start an Auction Automatically
CREATE OR REPLACE TRIGGER Start_Auction_Trigger
AFTER INSERT ON Items
FOR EACH ROW
BEGIN
    INSERT INTO Auctions (auction_id, item_id, status)
    VALUES (SEQ_AUCTIONS.NEXTVAL, :NEW.item_id, 'ongoing');
END;
/

-- 6. Trigger to End Auctions Automatically
CREATE OR REPLACE TRIGGER End_Auction_Trigger
AFTER INSERT OR UPDATE ON Auctions
FOR EACH ROW
WHEN (NEW.auction_end_time < SYSDATE AND NEW.status = 'ongoing')
BEGIN
    Close_Auction(:NEW.auction_id);
END;
/

-- 7. Function to Fetch Auction Details
CREATE OR REPLACE FUNCTION Get_Auction_Details (
    p_auction_id IN NUMBER
) RETURN VARCHAR2 AS
    v_details VARCHAR2(500);
BEGIN
    SELECT 'Auction ID: ' || auction_id || ', Item: ' || item_id || ', Highest Bid: ' || highest_bid
    INTO v_details
    FROM Auctions
    WHERE auction_id = p_auction_id;

    RETURN v_details;
END;
/

-- Sample Usage:
 BEGIN
   Add_Bid(1, 2, 500);
 END;

 Test Data:
 INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'John Doe', 'john@example.com', 'password123', 'buyer');

INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'John Doe', 'john@example.com', 'password123', 'buyer');
INSERT INTO Items VALUES (SEQ_ITEMS.NEXTVAL, 1, 'Smartphone', 'Latest model smartphone', 5000, SYSDATE, SYSDATE + 7);

BEGIN
    Add_Bid(1, 1, 6000);  -- Auction ID = 1, Buyer ID = 1, Bid Amount = 6000
END;
/


SELECT * FROM Bids;
SELECT * FROM Auctions;

SELECT * FROM Winners;

SELECT Get_Auction_Details(1) FROM DUAL;


INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'John Doe', 'john@example.com', 'password123', 'buyer');
INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'Jane Smith', 'jane@example.com', 'password456', 'buyer');
INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'Alice Johnson', 'alice@example.com', 'password789', 'seller');
INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'Bob Brown', 'bob@example.com', 'password321', 'seller');
INSERT INTO Users VALUES (SEQ_USERS.NEXTVAL, 'Charlie White', 'charlie@example.com', 'password654', 'buyer');

INSERT INTO Items VALUES (SEQ_ITEMS.NEXTVAL, 3, 'Gaming Laptop', 'High-performance gaming laptop', 1000, SYSDATE, SYSDATE + 7);
INSERT INTO Items VALUES (SEQ_ITEMS.NEXTVAL, 3, 'Smartphone', 'Latest model smartphone', 800, SYSDATE, SYSDATE + 5);
INSERT INTO Items VALUES (SEQ_ITEMS.NEXTVAL, 4, 'Wireless Headphones', 'Noise-canceling headphones', 200, SYSDATE, SYSDATE + 10);
INSERT INTO Items VALUES (SEQ_ITEMS.NEXTVAL, 4, 'Tablet', '10-inch display tablet', 300, SYSDATE, SYSDATE + 8);
INSERT INTO Items VALUES (SEQ_ITEMS.NEXTVAL, 3, 'Smartwatch', 'Feature-packed smartwatch', 150, SYSDATE, SYSDATE + 6);  

INSERT INTO Auctions VALUES (SEQ_AUCTIONS.NEXTVAL, 2, 'ongoing', 800);
INSERT INTO Auctions VALUES (SEQ_AUCTIONS.NEXTVAL, 3, 'ongoing', 200);
INSERT INTO Auctions VALUES (SEQ_AUCTIONS.NEXTVAL, 4, 'ongoing', 300);
INSERT INTO Auctions VALUES (SEQ_AUCTIONS.NEXTVAL, 5, 'ongoing', 150);

INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 1, 1, 1100, SYSDATE);
INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 1, 2, 1200, SYSDATE);
INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 2, 1, 850, SYSDATE);
INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 2, 5, 900, SYSDATE);
INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 3, 2, 250, SYSDATE);
INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 4, 5, 350, SYSDATE);
INSERT INTO Bids VALUES (SEQ_BIDS.NEXTVAL, 5, 1, 180, SYSDATE);

INSERT INTO Winners VALUES (SEQ_WINNERS.NEXTVAL, 1, 2, 1200);
INSERT INTO Winners VALUES (SEQ_WINNERS.NEXTVAL, 2, 5, 900);
INSERT INTO Winners VALUES (SEQ_WINNERS.NEXTVAL, 3, 2, 250);
INSERT INTO Winners VALUES (SEQ_WINNERS.NEXTVAL, 4, 5, 350);
INSERT INTO Winners VALUES (SEQ_WINNERS.NEXTVAL, 5, 1, 180);

SELECT * FROM Users;
SELECT * FROM Winners;
SELECT * FROM Bids;
SELECT * FROM Auctions;
SELECT * FROM Items;









