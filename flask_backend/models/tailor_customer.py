from models.database import db
from datetime import datetime

class TailorCustomer(db.Model):
    __tablename__ = 'tailor_customers'
    id = db.Column(db.Integer, primary_key=True)
    tailor_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    name = db.Column(db.String(120), nullable=False)
    phone = db.Column(db.String(30), default='')
    email = db.Column(db.String(200), default='')
    notes = db.Column(db.String(500), default='')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    measurements = db.relationship('TailorMeasurement', backref='tailor_customer', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'tailor_id': self.tailor_id,
            'name': self.name,
            'phone': self.phone,
            'email': self.email,
            'notes': self.notes,
            'created_at': str(self.created_at),
        }

class TailorMeasurement(db.Model):
    __tablename__ = 'tailor_measurements'
    id = db.Column(db.Integer, primary_key=True)
    tailor_customer_id = db.Column(db.Integer, db.ForeignKey('tailor_customers.id'), nullable=False)
    chest = db.Column(db.Float, default=0)
    waist = db.Column(db.Float, default=0)
    hips = db.Column(db.Float, default=0)
    shoulder = db.Column(db.Float, default=0)
    sleeve = db.Column(db.Float, default=0)
    inseam = db.Column(db.Float, default=0)
    label = db.Column(db.String(100), default='Manual Entry')
    notes = db.Column(db.String(300), default='')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'tailor_customer_id': self.tailor_customer_id,
            'chest': self.chest,
            'waist': self.waist,
            'hips': self.hips,
            'shoulder': self.shoulder,
            'sleeve': self.sleeve,
            'inseam': self.inseam,
            'label': self.label,
            'notes': self.notes,
            'created_at': str(self.created_at),
        }