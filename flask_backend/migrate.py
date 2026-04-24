from app import app
from models.database import db

with app.app_context():
    with db.engine.connect() as conn:
        try:
            conn.execute(db.text("ALTER TABLE dress_posts ADD COLUMN price FLOAT DEFAULT 0"))
            print("Added price column")
        except Exception as e:
            print(f"price: {e}")
        try:
            conn.execute(db.text("ALTER TABLE dress_posts ADD COLUMN estimated_days INTEGER DEFAULT 7"))
            print("Added estimated_days column")
        except Exception as e:
            print(f"estimated_days: {e}")
        conn.commit()
    print("Migration done!")
