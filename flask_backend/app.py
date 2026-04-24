from flask import Flask
from flask_cors import CORS
from models.database import db, init_db

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///tailoring.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
CORS(app)
db.init_app(app)

from routes.customers import customers_bp
from routes.measurements import measurements_bp
from routes.styles import styles_bp
from routes.users import users_bp
from routes.posts import posts_bp
from routes.tailor_customers import tailor_customers_bp
from routes.orders import orders_bp

app.register_blueprint(customers_bp, url_prefix="/api/customers")
app.register_blueprint(measurements_bp, url_prefix="/api/measurements")
app.register_blueprint(styles_bp, url_prefix="/api/styles")
app.register_blueprint(users_bp, url_prefix="/api/users")
app.register_blueprint(posts_bp, url_prefix="/api/posts")
app.register_blueprint(tailor_customers_bp, url_prefix="/api/tailor-customers")
app.register_blueprint(orders_bp, url_prefix="/api/orders")

with app.app_context():
    init_db()
    with db.engine.connect() as conn:
        migrations = [
            "ALTER TABLE dress_posts ADD COLUMN price FLOAT DEFAULT 0",
            "ALTER TABLE dress_posts ADD COLUMN estimated_days INTEGER DEFAULT 7",
            "ALTER TABLE orders ADD COLUMN budget FLOAT DEFAULT 0",
            "ALTER TABLE orders ADD COLUMN location VARCHAR(200) DEFAULT ''",
            "ALTER TABLE orders ADD COLUMN color_preference VARCHAR(200) DEFAULT ''",
            "ALTER TABLE orders ADD COLUMN style_preference VARCHAR(300) DEFAULT ''",
            "ALTER TABLE orders ADD COLUMN note VARCHAR(500) DEFAULT ''",
            "ALTER TABLE orders ADD COLUMN chest FLOAT DEFAULT 0",
            "ALTER TABLE orders ADD COLUMN waist FLOAT DEFAULT 0",
            "ALTER TABLE orders ADD COLUMN hips FLOAT DEFAULT 0",
            "ALTER TABLE orders ADD COLUMN shoulder FLOAT DEFAULT 0",
            "ALTER TABLE orders ADD COLUMN sleeve FLOAT DEFAULT 0",
            "ALTER TABLE orders ADD COLUMN inseam FLOAT DEFAULT 0",
        ]
        for sql in migrations:
            try:
                conn.execute(db.text(sql))
                conn.commit()
            except Exception:
                pass

@app.route("/")
def home():
    return {"message": "Smart Tailor API v2"}

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
