# File: test_logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

from logic.logic import waste_calculator, projections, calculate_trends

def test_waste_calculator():
    items = [
        {"name": "A", "price": 10, "essential": False},
        {"name": "B", "price": 5, "essential": True}
    ]

    total, waste = waste_calculator(items)

    assert total == 15
    assert waste == 10


def test_projections():
    proj = projections(10)

    assert proj["daily"] == 10
    assert proj["weekly"] == 70
    assert proj["monthly"] == 280
    assert proj["yearly"] == 3640


def test_trends():
    trend = calculate_trends(120, 100)

    assert round(trend, 2) == 20.0

def test_classification_fallback():
    from logic.logic import classify_items, USE_GEMINI

    USE_GEMINI = False

    items = [{"name": "Random", "price": 10}]
    result = classify_items(items)

    assert result[0]["essential"] == False