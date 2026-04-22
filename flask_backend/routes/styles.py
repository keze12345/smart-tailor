from flask import Blueprint, request, jsonify

styles_bp = Blueprint("styles", __name__)

@styles_bp.route("/recommend", methods=["POST"])
def recommend_style():
    data = request.get_json()
    chest = data.get("chest", 0)
    waist = data.get("waist", 0)
    hips = data.get("hips", 0)

    if chest > 100 or waist > 90:
        fit = "loose fit recommended"
    elif chest < 80 and waist < 70:
        fit = "slim fit recommended"
    else:
        fit = "regular fit recommended"

    return jsonify({
        "fit": fit,
        "message": f"Based on your measurements, {fit}."
    })
