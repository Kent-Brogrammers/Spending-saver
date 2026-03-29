# File: test_logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

import json
from logic import process_request
import random

def generate_random_test_data():
    items_pool = [
        "Starbucks Latte", "Groceries", "Uber Ride", "Netflix Subscription",
        "Chicken Breast", "Gym Membership", "DoorDash Order", "Gas",
        "Protein Powder", "Concert Ticket", "Water Bottle", "New Shoes",
        "Amazon Purchase", "Chipotle", "Parking Fee", "Movie Ticket",
        "Haircut", "Laundry", "Energy Drink", "Supplements"
    ]

    frequencies = ["daily", "weekly", "monthly", "yearly", "one-time"]

    items = []

    for name in random.sample(items_pool, k=random.randint(8, 15)):
        item = {
            "name": name,
            "price": round(random.uniform(2, 150), 2),
            "frequency": random.choice(frequencies)
        }

        if random.random() < 0.3:
            item["essential"] = random.choice([True, False])

        items.append(item)


    last_week = round(random.uniform(100, 600), 2)

    this_week = round(last_week * random.uniform(0.5, 1.8), 2)

    preferences = [
        "I care about fitness and convenience. Gym and Uber are essential for me.",
        "I value saving money and only essentials.",
        "Food and transportation are essential for me.",
        "I prioritize health, groceries, and fitness."
    ]

    return {
        "items": items,
        "this_week": this_week,
        "last_week": last_week,
        "preferences_text": random.choice(preferences)
    }

if __name__ == "__main__":
    request_data = generate_random_test_data()

    print("\n=== RANDOM TEST INPUT ===")
    print(json.dumps(request_data, indent=2))

    result = process_request(request_data)

    print("\n=== FINAL SYSTEM TEST / LOGIC OUTPUT ===")
    print(json.dumps(result, indent=2))