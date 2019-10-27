
# https://stackoverflow.com/questions/34815650/python-multithread-and-postgresql
# https://www.toptal.com/python/beginners-guide-to-concurrency-and-parallelism-in-python

import psycopg2 
import random
from concurrent.futures import ThreadPoolExecutor, as_completed
from psycopg2.pool import ThreadedConnectionPool

def write_sim_to_db(all_ids2):
    if all_ids1[i] != all_ids2:
        conn = tcp.getconn()
        c = conn.cursor()
        c.execute("""SELECT count(*) FROM similarity WHERE prod_id1 = %s AND prod_id2 = %s""", (all_ids1[i], all_ids2,))
        count = c.fetchone()
        if count[0] == 0:
            sim_sum = random.random()
            c.execute("""INSERT INTO similarity(prod_id1, prod_id2, sim_sum) 
                    VALUES(%s, %s, %s)""", (all_ids1[i], all_ids2, sim_sum,))
            conn.commit()
        tcp.putconn(conn)

DSN = "postgresql://user:pass@localhost/db"
tcp = ThreadedConnectionPool(1, 10, DSN)

all_ids1 = list(n for n in range(1000))
all_ids2_list = list(n for n in range(1000))

for i in range(len(all_ids1)):
    with ThreadPoolExecutor(max_workers=2) as pool:
        results = [pool.submit(write_sim_to_db, i) for i in all_ids2_list]
