from flask import Blueprint, request, jsonify
from models.database import db
from models.customer import Customer

customers_bp = Blueprint("customers", __name__)

@customers_bp.route("/", methods=["GET"])
def get_customers():
    customers = Customer.query.all()
    return jsonify([c.to_dict() for c in customers])

@customers_bp.route("/", methods=["POST"])
def add_customer():
    data = request.get_json()
    customer = Customer(
        name=data["name"],
        phone=data["phone"],
        email=data.get("email", "")
    )
    db.session.add(customer)
    db.session.commit()
    return jsonify(customer.to_dict()), 201

@customers_bp.route("/<int:id>", methods=["GET"])
def get_customer(id):
    customer = Customer.query.get_or_404(id)
    return jsonify(customer.to_dict())

@customers_bp.route("/<int:id>", methods=["DELETE"])
def delete_customer(id):
    customer = Customer.query.get_or_404(id)
    db.session.delete(customer)
    db.session.commit()
    return jsonify({"message": "Customer deleted"})
