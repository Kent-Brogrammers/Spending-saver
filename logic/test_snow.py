# File: test_logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

import json
from snowflake_ai import process_request

#----------Test data----------
request_data = {
    "items": [
        {"name": "Starbucks Latte", "price": 6.25, "frequency": "daily"},
        {"name": "Groceries", "price": 85.00, "frequency": "weekly"},
        {"name": "Uber Ride", "price": 18.50, "frequency": "one-time"},
        {"name": "Netflix Subscription", "price": 15.99, "frequency": "monthly"},
        {"name": "Chicken Breast", "price": 12.40, "frequency": "weekly"},
        {"name": "Gym Membership", "price": 30.00, "frequency": "monthly"},
        {"name": "DoorDash Order", "price": 22.75, "frequency": "one-time"},
        {"name": "Gas", "price": 40.00, "frequency": "weekly"},
        {"name": "Protein Powder", "price": 35.99, "frequency": "monthly"},
        {"name": "Concert Ticket", "price": 120.00, "frequency": "one-time"},
        {"name": "Water Bottle", "price": 2.00, "frequency": "daily"},
        {"name": "New Shoes", "price": 85.00, "frequency": "yearly"}
    ],
    "this_week": 443.18,
    "last_week": 300.00,
    "preferences_text": "I care about fitness and convenience. Gym and Uber are essential for me."
}

#----------Testing----------

if __name__ == "__main__":
    result = process_request(request_data)
    
    print("\n=== FINAL SYSTEM TEST ===")
    print(json.dumps(result, indent=2))
    