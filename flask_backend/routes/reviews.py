from flask import Blueprint, request, jsonify
from models.database import db
from models.review import Review

reviews_bp = Blueprint("reviews", __name__)

@reviews_bp.route("/", methods=["POST"])
def create_review():
    data = request.get_json()
    # Check if already reviewed this order
    existing = Review.query.filter_by(
        order_id=data['order_id'],
        customer_id=data['customer_id']).first()
    if existing:
        # Update existing review
        existing.rating = data['rating']
        existing.comment = data.get('comment', '')
        db.session.commit()
        return jsonify(existing.to_dict()), 200
    review = Review(
        customer_id=data['customer_id'],
        tailor_id=data['tailor_id'],
        order_id=data['order_id'],
        rating=data['rating'],
        comment=data.get('comment', ''),
    )
    db.session.add(review)
    db.session.commit()
    return jsonify(review.to_dict()), 201

@reviews_bp.route("/tailor/<int:tailor_id>", methods=["GET"])
def get_tailor_reviews(tailor_id):
    reviews = Review.query.filter_by(tailor_id=tailor_id)\
        .order_by(Review.created_at.desc()).all()
    total = len(reviews)
    avg = round(sum(r.rating for r in reviews) / total, 1) if total > 0 else 0
    return jsonify({
        'reviews': [r.to_dict() for r in reviews],
        'average': avg,
        'total': total,
    })

@reviews_bp.route("/order/<int:order_id>", methods=["GET"])
def get_order_review(order_id):
    review = Review.query.filter_by(order_id=order_id).first()
    if not review:
        return jsonify(None), 200
    return jsonify(review.to_dict())
