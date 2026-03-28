# File: test_logic.py
# Programmer: Nicholas Vuletich
# Date: 3-28-26

import pytest
from logic.logic import (
    waste_calculator,
    projections,
    calculate_trends,
    analyze_spending,
    classify_items
)

#----------BASIC _LOGIC_TESTS----------

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


def test_trends_positive():
    trend = calculate_trends(120, 100)
    assert round(trend, 2) == 20.0


def test_trends_negative():
    trend = calculate_trends(50, 100)
    assert round(trend, 2) == -50.0


#----------PIPELINE_TEST----------

def test_analyze_spending_structure():
    items = [
        {"name": "Coffee", "price": 5},
        {"name": "Groceries", "price": 50}
    ]

    result = analyze_spending(items, 120, 100)

    assert "total" in result
    assert "waste" in result
    assert "projections" in result
    assert "trend" in result
    assert "insight" in result


#----------CLASSIFIER_TEST_(NO API)----------

def test_classifier_fallback():
    from logic import logic

    logic.USE_GEMINI = False

    items = [{"name": "RandomThing", "price": 10}]
    result = classify_items(items)

    assert result[0]["essential"] == False

def test_full_pipeline_values():
    items = [
        {"name": "Coffee", "price": 5},
        {"name": "Chicken", "price": 10}
    ]

    result = analyze_spending(items, 100, 100)

    assert result["total"] == 15
    assert result["trend"] == 0