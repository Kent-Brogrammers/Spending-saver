# AI Spending Analyzer

An AI-powered financial analysis application that helps users understand and reduce unnecessary spending by revealing hidden long-term costs.
---
## Overview

Most people don’t realize how small daily purchases accumulate over time.

This project analyzes user spending data and uses AI to classify purchases as essential vs non-essential, then calculates:

  * Daily waste
  * Weekly / Monthly / Yearly projections
  * Personalized financial insights

Example output:
```JSON
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
```
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
## Snowflake + AI Integration (Hackathon Track)

This project uses Snowflake as both the database and AI inference layer, fully aligning with the Snowflake AI track.

## What we did:
* Stored structured user spending data in Snowflake
* Queried data using Snowflake SQL
* Used Snowflake Cortex (SNOWFLAKE.CORTEX.COMPLETE) to classify spending
* Integrated AI directly into our backend pipeline
## Why this matters:

Instead of calling external AI APIs, we intentionally designed the system so that:

```Data + AI live in the same platform (Snowflake)```

This allows:
* Reduced external dependencies
* Better scalability with user data
* Tighter integration between structured data and AI

We initially experimented with other LLM providers, but chose Snowflake Cortex to align with a data-centric AI architecture.
---
## Architecture
```text
Swift Frontend
      ↓
Flask Backend (API Layer)
      ↓
Snowflake (Database + Cortex AI)
      ↓
Backend Logic (Analysis + Insights)
      ↓
Frontend Visualization
```
---
## Backend Intelligence

The core intelligence layer processes data through:
```text
Input → AI Classification → Rule Overrides → Normalization → Projections → Insight Generation
```
Key logic includes:
* Frequency normalization (daily, weekly, monthly, yearly)
* AI classification with deterministic overrides
* Waste calculation and percentage analysis
* Long-term financial projections

Example (from logic system ):
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
* Snowflake (Database)
* Snowflake Cortex (AI / LLM inference)
* JWT Authentication
* bcrypt (password hashing)
### Frontend
* Swift (iOS)
### AI
* Snowflake Cortex (mistral-large model)
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
2. Data is stored in Snowflake
3. Backend retrieves user data
4. Snowflake Cortex classifies items
5. Backend processes results into:
    * waste
    * projections
    * insights
6. Results are returned to the frontend
---
## Why This Project Stands Out
* Uses AI beyond a chatbot — embedded into real logic
* Combines structured data + LLMs
* Produces actionable financial insights
* Demonstrates real backend system design
* Fully leverages Snowflake’s data + AI ecosystem
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
