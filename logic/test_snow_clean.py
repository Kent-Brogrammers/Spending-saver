# test_snowflake_clean.py

import os
from dotenv import load_dotenv
import snowflake.connector

load_dotenv()

conn = snowflake.connector.connect(
    user=os.getenv("SW_USER"),
    password=os.getenv("SW_PASS"),
    account=os.getenv("SW_ACCOUNT"),
    warehouse=os.getenv("SW_WAREHOUSE"),
    database=os.getenv("SW_DB"),
    schema=os.getenv("SW_SCHEMA"),
)

cursor = conn.cursor()

prompt = f"""
Classify each item as essential or non-essential.
...
Return ONLY JSON:
[
  {{"name": "<item>", "essential": true/false}}
]
"""

query = f"""
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large',
    '{prompt}'
);
"""

cursor.execute(query)
row = cursor.fetchone()

print("ROW:", row)

cursor.close()
conn.close()