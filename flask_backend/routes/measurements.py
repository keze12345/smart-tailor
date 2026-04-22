from flask import Blueprint, request, jsonify
from models.database import db
from models.measurement import Measurement

measurements_bp = Blueprint("measurements", __name__)

@measurements_bp.route("/", methods=["POST"])
def add_measurement():
    data = request.get_json()
    m = Measurement(
        user_id=data.get("user_id", None),
        customer_id=data.get("customer_id", None),
        chest=data.get("chest", 0),
        waist=data.get("waist", 0),
        hips=data.get("hips", 0),
        shoulder=data.get("shoulder", 0),
        sleeve=data.get("sleeve", 0),
        inseam=data.get("inseam", 0),
        notes=data.get("notes", ""),
        label=data.get("label", "Body Scan"),
    )
    db.session.add(m)
    db.session.commit()
    return jsonify(m.to_dict()), 201

@measurements_bp.route("/<int:customer_id>", methods=["GET"])
def get_measurements(customer_id):
    ms = Measurement.query.filter_by(customer_id=customer_id).order_by(Measurement.created_at.desc()).all()
    return jsonify([m.to_dict() for m in ms])

@measurements_bp.route("/user/<int:user_id>", methods=["GET"])
def get_user_measurements(user_id):
    ms = Measurement.query.filter_by(user_id=user_id).order_by(Measurement.created_at.desc()).all()
    return jsonify([m.to_dict() for m in ms])

@measurements_bp.route("/<int:id>/edit", methods=["PUT"])
def edit_measurement(id):
    m = Measurement.query.get_or_404(id)
    data = request.get_json()
    for field in ["chest","waist","hips","shoulder","sleeve","inseam","notes","label"]:
        if field in data:
            setattr(m, field, data[field])
    db.session.commit()
    return jsonify(m.to_dict())

@measurements_bp.route("/<int:id>", methods=["DELETE"])
def delete_measurement(id):
    m = Measurement.query.get_or_404(id)
    db.session.delete(m)
    db.session.commit()
    return jsonify({"message": "Deleted"})