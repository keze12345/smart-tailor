from flask import Blueprint, request, jsonify
from models.database import db
from models.tailor_customer import TailorCustomer, TailorMeasurement

tailor_customers_bp = Blueprint("tailor_customers", __name__)

@tailor_customers_bp.route("/<int:tailor_id>", methods=["GET"])
def get_tailor_customers(tailor_id):
    customers = TailorCustomer.query.filter_by(tailor_id=tailor_id).all()
    return jsonify([c.to_dict() for c in customers])

@tailor_customers_bp.route("/", methods=["POST"])
def add_tailor_customer():
    data = request.get_json()
    c = TailorCustomer(
        tailor_id=data["tailor_id"],
        name=data["name"],
        phone=data.get("phone", ""),
        email=data.get("email", ""),
        notes=data.get("notes", ""),
    )
    db.session.add(c)
    db.session.commit()
    return jsonify(c.to_dict()), 201

@tailor_customers_bp.route("/<int:id>", methods=["PUT"])
def update_tailor_customer(id):
    c = TailorCustomer.query.get_or_404(id)
    data = request.get_json()
    for field in ["name", "phone", "email", "notes"]:
        if field in data:
            setattr(c, field, data[field])
    db.session.commit()
    return jsonify(c.to_dict())

@tailor_customers_bp.route("/<int:id>", methods=["DELETE"])
def delete_tailor_customer(id):
    c = TailorCustomer.query.get_or_404(id)
    TailorMeasurement.query.filter_by(tailor_customer_id=c.id).delete()
    db.session.delete(c)
    db.session.commit()
    return jsonify({"message": "Deleted"})

@tailor_customers_bp.route("/<int:customer_id>/measurements", methods=["GET"])
def get_tailor_customer_measurements(customer_id):
    ms = TailorMeasurement.query.filter_by(tailor_customer_id=customer_id).all()
    return jsonify([m.to_dict() for m in ms])

@tailor_customers_bp.route("/<int:customer_id>/measurements", methods=["POST"])
def add_tailor_customer_measurement(customer_id):
    data = request.get_json()
    m = TailorMeasurement(
        tailor_customer_id=customer_id,
        chest=data.get("chest", 0),
        waist=data.get("waist", 0),
        hips=data.get("hips", 0),
        shoulder=data.get("shoulder", 0),
        sleeve=data.get("sleeve", 0),
        inseam=data.get("inseam", 0),
        label=data.get("label", "Manual Entry"),
        notes=data.get("notes", ""),
    )
    db.session.add(m)
    db.session.commit()
    return jsonify(m.to_dict()), 201

@tailor_customers_bp.route("/measurements/<int:id>", methods=["PUT"])
def update_tailor_measurement(id):
    m = TailorMeasurement.query.get_or_404(id)
    data = request.get_json()
    for field in ["chest","waist","hips","shoulder","sleeve","inseam","label","notes"]:
        if field in data:
            setattr(m, field, data[field])
    db.session.commit()
    return jsonify(m.to_dict())

@tailor_customers_bp.route("/measurements/<int:id>", methods=["DELETE"])
def delete_tailor_measurement(id):
    m = TailorMeasurement.query.get_or_404(id)
    db.session.delete(m)
    db.session.commit()
    return jsonify({"message": "Deleted"})