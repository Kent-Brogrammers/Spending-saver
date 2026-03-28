# File: logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

import os
import json
from dotenv import load_dotenv
from google import genai

classification_cache = {}

#----------Configuration----------
load_dotenv(".env_keys")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=GEMINI_API_KEY)

USE_GEMINI = True
DEBUG_GEMINI = False


#----------Test data----------
items = [
    {"name": "Chips" ,"price": 5.99},
    {"name": "Pizza(10in)" ,"price": 11.99},
    {"name": "Chicken" ,"price": 11.43}
]



#----------Waste Claculator----------
def waste_calculator(items):
    waste = 0
    total = 0
    for item in items:
        total += item["price"]
        if item["essential"] is False:
            waste += item["price"]
        
    return total, waste

#----------Projections----------

def projections(waste):
    daily = waste
    weekly = daily * 7
    monthly = weekly * 4
    yearly = weekly * 52

    return {
        "daily": daily,
        "weekly": weekly,
        "monthly": monthly,
        "yearly": yearly
    }

#----------Trends----------

def calculate_trends(this_week, last_week):
    if last_week == 0:
        return 0
    
    return ((this_week-last_week)/last_week) * 100
    

#----------Insight generation----------

def generate_insight(total, waste, proj, trend):
    yearly = proj["yearly"]

    if trend > 0:
        trend_text = f"{trend:.1f}% more than last week"
    else:
        trend_text = f"{abs(trend):.1f}% less than last week"

    insight = f"""
You spent ${total:.2f} total, with ${waste:.2f} on non-essential items.

At this rate, that's ${yearly:.2f} per year.

That is equal to:
{yearly / 1500:.1f} vacations
{yearly / 1200:.1f} laptops

Your spending is {trend_text}.
"""
    return insight.strip()

#----------Gemini Classifier----------

def classify_items(items):
    names = [item.get("name", "") for item in items]

    cached_result_map = {}
    uncached_names = []

    for name in names:
        key = name.lower()
        if key in classification_cache:
            cached_result_map[key] = classification_cache[key]
        else:
            uncached_names.append(name)

    prompt = f"""
Classify each item as essential or non-essential.

Items:
{uncached_names}

Return STRICT JSON in this format:
[
  {{"name": "<item>", "essential": true/false}}
]

Use the SAME item names provided.

No explanation. No markdown. No extra text.
"""

    if not USE_GEMINI:
        result_map = {name.lower(): False for name in names}

    else:
        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt
            )
            text = response.text.strip()


            if DEBUG_GEMINI:
                print("Gemini raw response:", text)

            if not text:
                raise ValueError("Empty response from Gemini")

            try:
                data = json.loads(text)
            except:
                print("Bad JSON:", text)
                raise

            result_map = {
                d["name"].lower(): d["essential"]
                for d in data
            }

            result_map.update(cached_result_map)

        except Exception as e:
            print("Gemini Error:", e)
            result_map = {name.lower(): False for name in names}

    classified_items = []

    for item in items:
        name = item.get("name", "")
        price = item.get("price", 0)

        essential = result_map.get(name.lower(), False)

        
        classification_cache[name.lower()] = essential

        classified_items.append({
            "name": name,
            "price": price,
            "essential": essential
        })

    return classified_items   

#----------Analyze spending----------

def analyze_spending(items, this_week, last_week):
    classified = classify_items(items)
    total, waste = waste_calculator(classified)
    proj =  projections(waste)
    trend = calculate_trends(this_week, last_week)
    insight = generate_insight(total, waste, proj, trend)

    return {
        "total": round(total, 2), 
        "waste": round(waste, 2),
        "projections": proj,
        "trend": round(trend, 2),
        "insight": insight
    }

#----------Testing----------

if __name__ == "__main__":
    stats = analyze_spending(items, 120, 98)

    print("\n=== Spending Analysis ===")
    print(f"Total: ${stats['total']}")
    print(f"Waste: ${stats['waste']}")
    print(f"Trend: {stats['trend']}%")
    print(stats["projections"])
    print("\nInsight:\n")
    print(stats["insight"])

    # Backend output
    print("\n=== Backend Payload ===")
    print(json.dumps(stats, indent=2))
    
