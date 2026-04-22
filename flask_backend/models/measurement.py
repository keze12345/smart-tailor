from models.database import db
from datetime import datetime

class Measurement(db.Model):
    __tablename__ = 'measurements'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('customers.id'), nullable=True)
    chest = db.Column(db.Float, default=0)
    waist = db.Column(db.Float, default=0)
    hips = db.Column(db.Float, default=0)
    shoulder = db.Column(db.Float, default=0)
    sleeve = db.Column(db.Float, default=0)
    inseam = db.Column(db.Float, default=0)
    notes = db.Column(db.String(300), default='')
    label = db.Column(db.String(100), default='Body Scan')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'customer_id': self.customer_id,
            'chest': self.chest,
            'waist': self.waist,
            'hips': self.hips,
            'shoulder': self.shoulder,
            'sleeve': self.sleeve,
            'inseam': self.inseam,
            'notes': self.notes,
            'label': self.label,
            'created_at': str(self.created_at),
        }