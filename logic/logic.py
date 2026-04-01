# File: logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

import os
import json
from dotenv import load_dotenv
from google import genai

classification_cache = {}

#----------Configuration----------
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

client = genai.Client(api_key=GEMINI_API_KEY)

USE_GEMINI = bool(GEMINI_API_KEY)
DEBUG_GEMINI = True


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
        return price / 30

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

        if item["essential"] is False:
            waste += daily_value

    waste_percentage = round((waste / total) * 100, 2) if total > 0 else 0
        
    return total, waste, waste_percentage

#----------Projections----------

def projections(waste):
    daily = waste
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

#----------Gemini Classifier----------

def classify_items(items, preferences_text=""):
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

User preferences:
{preferences_text}

Items:
{uncached_names}

Return STRICT JSON:
[
  {{"name": "<item>", "essential": true/false}}
]

No explanation.
"""

    if not USE_GEMINI:
        result_map = {name.lower(): False for name in names}

    elif not uncached_names:
        result_map = cached_result_map.copy()

    else:
        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt
            )
            text = response.text.strip()

            
            if text.startswith("```"):
                text = text.split("```")[1]
                text = text.replace("json", "", 1).strip()  
                text = text.rsplit("```", 1)[0].strip()


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
            result_map = cached_result_map.copy()

    classified_items = []

    for item in items:
        name = item.get("name", "")
        price = item.get("price", 0)
        freq = item.get("frequency", "one-time")

        essential = result_map.get(name.lower(), False)

        
        classification_cache[name.lower()] = essential

        classified_items.append({
            "name": name,
            "price": price,
            "frequency": freq,
            "essential": essential
        })

    return classified_items   

#----------Analyze spending----------

def analyze_spending(items, this_week, last_week, preferences_text=""):
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
    proj =  projections(waste)
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

