# AI Spending Analyzer

An AI-powered financial analysis application that helps users understand and reduce unnecessary spending by revealing hidden long-term costs.

---

## Overview

Most people don't realize how small daily purchases accumulate over time.

This project analyzes user spending data and uses AI to classify purchases as essential vs non-essential, then calculates:

  * Daily waste
  * Weekly / Monthly / Yearly projections
  * Personalized financial insights

Example output:
````JSON
{
  "total": 192.09,
  "waste": 36.95,
  "projections": {
    "daily": 36.95,
    "weekly": 258.63,
    "monthly": 1034.52,
    "yearly": 13448.77
  },
  "trend": 47.73,
  "waste_percentage": 19.23,
  "insight": "You spent $192.09 total, with $36.95 on non-essential items.\n\nAt this rate, that's $13448.77 per year.\n\nThat could be:\n9.0 vacations\n11.2 laptops\n\nYour spending is 47.7% more than last week."
}
````
*Meaning: You could be wasting over $10,000/year without realizing it.*

---

## Key Features
 * AI-powered classification of spending (essential vs non-essential)
 * Financial projections (daily → yearly impact)
 * Trend analysis (week-over-week behavior)
 * Secure authentication (JWT + hashed passwords)
 * Real-time backend analysis
 * Personalized insights based on user preferences

---

## MongoDB + Gemini AI Integration

This project uses MongoDB as the database and Google Gemini as the AI inference layer.

## What we did:
* Stored structured user spending data in MongoDB Atlas
* Queried data using pymongo
* Used Google Gemini to classify spending and generate personalized insights
* Integrated AI directly into our backend pipeline

## Why this matters:
````Data lives in MongoDB, AI lives in Gemini — connected through our Flask backend```

This allows:
* Flexible, schema-optional document storage
* Fast reads/writes for real-time spending analysis
* Powerful LLM reasoning without infrastructure overhead

---

## Architecture
```text
Swift Frontend
      ↓
Flask Backend (API Layer)
      ↓
MongoDB Atlas (Database)
      ↓
Google Gemini (AI Classification + Insights)
      ↓
Backend Logic (Analysis + Projections)
      ↓
Frontend Visualization
```

---

## Backend Intelligence

The core intelligence layer processes data through:
```text
Input → Gemini Classification → Rule Overrides → Normalization → Projections → Insight Generation
```
Key logic includes:
* Frequency normalization (daily, weekly, monthly, yearly)
* AI classification with deterministic overrides
* Waste calculation and percentage analysis
* Long-term financial projections

Example (from logic system):
```python
essential = result_map.get(name_lower, False)

for keyword in preference_keywords:
    if keyword in name_lower:
        essential = True
```
Combines AI reasoning + guaranteed correctness

---

## Tech Stack
### Backend
* Python (Flask)
* MongoDB Atlas (Database)
* Google Gemini (AI / LLM inference)
* JWT Authentication
* bcrypt (password hashing)

### Frontend
* Swift (iOS)

### AI
* Google Gemini

---

## API Endpoints
### Auth
* POST /login/create_account
* POST /login/login

### Data
* POST /inputs/insertFood
* DELETE /inputs/deleteFood
* POST /inputs/insertPref
* DELETE /inputs/removePref

### Analysis
* POST /inputs/analyze

---

## How It Works
1. User inputs spending data via frontend
2. Data is stored in MongoDB Atlas
3. Backend retrieves user data
4. Google Gemini classifies items and generates insights
5. Backend processes results into:
    * waste
    * projections
    * insights
6. Results are returned to the frontend

---

## Why This Project Stands Out
* Uses AI beyond a chatbot — embedded into real logic
* Combines document-based storage with LLM reasoning
* Produces actionable financial insights
* Demonstrates real backend system design
* Clean separation between data layer (MongoDB) and AI layer (Gemini)

---

## Team

Built during a hackathon project focused on AI + data systems.

### Members:
    - Nicholas Vuletich
    - Christopher Vuletich
    - Connor Banning

---

## Future Improvements
* Visualization dashboards (graphs, charts)
* Enhanced iOS UI/UX
* More advanced personalization
* Predictive spending models
````