import os
from pymongo import MongoClient

def get_connection(db, collection=None, query=None, fetch_one=False, update=None, insert=None, delete=False):
    client = MongoClient(os.getenv("MONGO_URI"))
    database = client[db]

    if collection is None:
        return database

    col = database[collection]

    if insert:
        col.insert_one(insert)
        client.close()
        return None

    if delete and query:
        col.delete_one(query)
        client.close()
        return None

    if update and query:
        col.update_one(query, {"$set": update})
        client.close()
        return None

    if query:
        return col.find_one(query) if fetch_one else list(col.find(query))

    return col