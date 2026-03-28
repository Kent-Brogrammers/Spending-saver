# File: logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

#----------Test data----------
items = [
    {"name": "Chips" ,"price": 5.99, "essential": False},
    {"name": "Pizza(10in)" ,"price": 11.99, "essential": False},
    {"name": "Chicken" ,"price": 11.43, "essential": True}
]


#----------Gemini Classifier----------


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
    insight = f"""
    You spent ${total:.2f} total, with ${waste:.2f} on non-essential items.
    At this rate, that's ${yearly:.2f} per year.

    That is equal to:
    ~{yearly / 1500:.1f} Vacations
    ~{yearly / 1200:.1f} Laptops

    Your spending is {trend:.1f}% compared to last week.
    """
    return insight.strip()


#----------Testing----------

if __name__ == "__main__":
    total, waste = waste_calculator(items)
    proj =  projections(waste)
    trend = calculate_trends(120, 353)
    insight = generate_insight(total, waste, proj, trend)
    print("Waste: ",waste)
    print("Total: ", total)
    print(proj)
    print(trend)
    print("\n", insight)
    
