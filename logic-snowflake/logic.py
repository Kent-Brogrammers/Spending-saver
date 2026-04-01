# File: logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

import os
import json
from dotenv import load_dotenv
import snowflake.connector


classification_cache = {}

#----------Configuration----------
load_dotenv()
AI_PROVIDER = "snowflake"
DEBUG = False

#----------Helper function----------

def to_daily(price, frequency):
    if frequency == "daily":
        return price
    elif frequency == "weekly":
        return price / 7
    elif frequency == "monthly":
        return price / 30
    elif frequency == "yearly":
        return price / 365
    else: # for one time purchases 
        return 0

#----------Waste Claculator----------
def waste_calculator(items):
    waste = 0.0
    total = 0.0

    for item in items:
        price = float(item.get("price", 0))
        freq = item.get("frequency", "one-time")

        valid_freqs = {"daily", "weekly", "monthly", "yearly", "one-time"}
        if freq not in valid_freqs:
            freq = "one-time"

        daily_value = to_daily(price, freq)

        total += daily_value

        if not item.get("essential", False):
            waste += daily_value

    waste_percentage = round((waste / total) * 100, 2) if total > 0 else 0
        
    return total, waste, waste_percentage

#----------Projections----------

def projections(total):
    daily = total
    weekly = daily * 7
    monthly = weekly * 4
    yearly = weekly * 52

    return {
        "daily": round(daily, 2),
        "weekly": round(weekly, 2),
        "monthly": round(monthly, 2),
        "yearly": round(yearly, 2)
    }

#----------Trends----------
# calculates the change in spending compared to last week
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

That could be:
{yearly / 1500:.1f} vacations
{yearly / 1200:.1f} laptops

Your spending is {trend_text}.
"""
    return insight.strip()

#----------Classifier----------

def classify_items(items, preferences_text=""):
    preference_keywords = preferences_text.lower().replace(",", "").split()
    names = [item.get("name", "") for item in items]
    

    cached_result_map = {}
    uncached_names = []

    for item in items:
        name = item.get("name", "")
        key = name.lower()

        if "essential" in item:
            cached_result_map[key] = item["essential"]
            continue

        if key in classification_cache:
            cached_result_map[key] = classification_cache[key]
        else:
            uncached_names.append(name)

    
    if not uncached_names:
        result_map = cached_result_map.copy()
    else:
        try:
            result_map = classify_with_snowflake(uncached_names, preferences_text)
            result_map.update(cached_result_map)
        except Exception as e:
            print("Snowflake Error:", e)
            result_map = cached_result_map.copy()

    classified_items = []

    for item in items:
        name = item.get("name", "")
        price = item.get("price", 0)
        freq = item.get("frequency", "one-time")

        name_lower = name.lower()

        if "essential" in item:
            essential = item["essential"]

        else:
            essential = result_map.get(name_lower, False)

            for keyword in preference_keywords:
                if keyword in name_lower:
                    essential = True

        classification_cache[name_lower] = essential

        classified_items.append({
            "name": name,
            "price": price,
            "frequency": freq,
            "essential": essential
        })

    return classified_items


#----------Snowflake Classify----------

def classify_with_snowflake(names, preferences_text=""):

    prompt = f"""
You are a strict JSON generator.

Do NOT explain anything.
Do NOT include text.
Do NOT say hello.

ONLY return valid JSON.

Task:
Classify each item as essential or non-essential.

User preferences:
{preferences_text}

Items:
{",".join(names)}

Return EXACTLY this format:
[
  {{"name": "item name", "essential": true}}
]

Rules:
- Essential = necessary for survival, health, work, or responsibilities
- Non-essential = luxury, entertainment, convenience
- ALWAYS prioritize user preferences
- If the user says something is essential, it MUST be essential
- Only mark additional items essential if they are strongly related to preferences

Output JSON ONLY.
"""

    
    safe_prompt = prompt.replace("'", "''")

    conn = snowflake.connector.connect(
    user=os.getenv("SW_USER"),
    password=os.getenv("SW_PASS"),
    account=os.getenv("SW_ACCOUNT"),
    warehouse=os.getenv("SW_WAREHOUSE"),
    database=os.getenv("SW_DB"),
    schema=os.getenv("SW_SCHEMA"),
)

    cursor = conn.cursor()

    if DEBUG == True:
        print("\n=== PROMPT SENT TO SNOWFLAKE ===")
        print(prompt)
        print("================================\n")

    try:
        query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'mistral-large',
            '{safe_prompt}'
        );
        """
        if DEBUG == True:
            print("\n=== SAFE PROMPT (SQL) ===")
            print(safe_prompt)
            print("=========================\n")

        cursor.execute(query)
        row = cursor.fetchone()

        if not row:
            raise ValueError("No row returned from Snowflake")

        result = row[0]

        if not result:
            raise ValueError("Empty response from Snowflake")

        if DEBUG == True:
            print("Snowflake raw response:", result)

        text = str(result).strip()

        
        if "```" in text:
            text = text.split("```")[1]
            text = text.replace("json", "", 1).strip()
            text = text.rsplit("```", 1)[0].strip()

        data = json.loads(text)

        if DEBUG == True:
            print("\n=== PARSED AI OUTPUT ===")
            for d in data:
                print(d)
            print("========================\n")

            result_map = {
                d.get("name", "").lower(): d.get("essential", False)
                for d in data
            }

            print("\n=== FINAL RESULT MAP ===")
            print(result_map)
            print("========================\n")

            return result_map

        return {
            d.get("name", "").lower(): d.get("essential", False)
            for d in data
        }

    except Exception as e:
        print("Snowflake Error:", e)
        return {name.lower(): False for name in names}

    finally:
        cursor.close()
        conn.close()

#----------Analyze spending----------

def analyze_spending(items, this_week, last_week, preferences_text=""):

    if DEBUG == True:
        print("\n=== ITEMS RECEIVED ===")
        for item in items:
            print(item)
        print("=====================\n")

    if not items:
        return {
            "total": 0,
            "waste": 0,
            "projections": projections(0),
            "trend": 0,
            "insight": "No spending data available."
        }
    classified = classify_items(items, preferences_text)
    total, waste, waste_percentage = waste_calculator(classified)
    proj =  projections(total)
    trend = calculate_trends(this_week, last_week)
    insight = generate_insight(total, waste, proj, trend)

    return {
        "total": round(total, 2), 
        "waste": round(waste, 2),
        "projections": proj,
        "trend": round(trend, 2),
        "waste_percentage": waste_percentage,
        "insight": insight
    }

#----------Process Request----------

def process_request(data):
    items = data.get("items", [])
    this_week = float(data.get("this_week", 0))
    last_week = float(data.get("last_week", 0))
    preferences_text = data.get("preferences_text", "")

    return analyze_spending(items, this_week, last_week, preferences_text)

