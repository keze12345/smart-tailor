import sqlite3
conn = sqlite3.connect('instance/tailoring.db')
tables = conn.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
print('Tables:', tables)
for table in tables:
    rows = conn.execute(f"SELECT * FROM {table[0]}").fetchall()
    print(f"\n{table[0]}:", rows)
conn.close()