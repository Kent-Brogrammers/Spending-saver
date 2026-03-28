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
        
    return waste, total

#----------Projections----------

#----------Trends----------

#----------Insight generation----------


#----------Testing----------

if __name__ == "__main__":
    waste, total = waste_calculator(items)
    print(waste)
    print(total)
    
