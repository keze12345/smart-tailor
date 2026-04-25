from models.database import db
from datetime import datetime

class Review(db.Model):
    __tablename__ = 'reviews'
    id = db.Column(db.Integer, primary_key=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    tailor_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False)
    rating = db.Column(db.Integer, nullable=False)  # 1-5
    comment = db.Column(db.String(500), default='')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    customer = db.relationship('User', foreign_keys=[customer_id])
    tailor = db.relationship('User', foreign_keys=[tailor_id])

    def to_dict(self):
        return {
            'id': self.id,
            'customer_id': self.customer_id,
            'tailor_id': self.tailor_id,
            'order_id': self.order_id,
            'rating': self.rating,
            'comment': self.comment,
            'customer_name': self.customer.name if self.customer else '',
            'customer_avatar': self.customer.avatar_url if self.customer else '',
            'created_at': str(self.created_at),
        }
