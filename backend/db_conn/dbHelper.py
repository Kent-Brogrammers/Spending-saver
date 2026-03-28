import os
import snowflake.connector


def get_connection(db, query=None, fetch_one=False, params=None):
    conn = snowflake.connector.connect(
        user=os.getenv("SW_USER"),
        password=os.getenv("SW_PASS"),
        account=os.getenv("SW_ACCOUNT"),
        warehouse=os.getenv("SW_WAREHOUSE"),
        database=db,
        schema=os.getenv("SW_SCHEMA")
    )

    if query:
        cur = conn.cursor()
        if params:
            cur.execut(query, params)
        else:
            cur.execute(query)
        result = cur.fetchone() if fetch_one else cur.fetchall()
        cur.close()
        conn.close()
        return result
    return conn