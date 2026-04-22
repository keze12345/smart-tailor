from app import app
from models.database import db
from models.user import User
from models.dress_post import DressPost

with app.app_context():
    # Create sample tailor
    tailor = User.query.filter_by(email='tailor@smarttailor.com').first()
    if not tailor:
        tailor = User(
            name='Master Tailor Emmanuel',
            email='tailor@smarttailor.com',
            phone='+237670000001',
            role='tailor',
            skills='Ankara,Kaftan,Wedding,Traditional,Formal',
            years_experience=12,
            location='Buea, Cameroon',
            contact_info='+237670000001 (WhatsApp)',
            is_public=True,
            dress_preferences='Ankara,Kaftan,Wedding',
        )
        db.session.add(tailor)
        db.session.commit()
        print('Tailor created: ID', tailor.id)

    tailor2 = User.query.filter_by(email='tailor2@smarttailor.com').first()
    if not tailor2:
        tailor2 = User(
            name='Madam Grace Fashions',
            email='tailor2@smarttailor.com',
            phone='+237680000002',
            role='tailor',
            skills='Wedding,Evening,Casual,Corporate',
            years_experience=8,
            location='Douala, Cameroon',
            contact_info='+237680000002 (WhatsApp)',
            is_public=True,
            dress_preferences='Wedding,Evening',
        )
        db.session.add(tailor2)
        db.session.commit()
        print('Tailor 2 created: ID', tailor2.id)

    dresses = [
        {'title': 'Classic Ankara Gown', 'category': 'Ankara', 'description': 'Elegant full-length Ankara gown with puff sleeves and a fitted waist. Perfect for celebrations and cultural events.'},
        {'title': 'Modern Kaftan Dress', 'category': 'Kaftan', 'description': 'Flowing kaftan in rich fabric with gold embroidery detailing. Comfortable yet stunning for any occasion.'},
        {'title': 'Bridal Wedding Gown', 'category': 'Wedding', 'description': 'Stunning white bridal gown with lace overlay and cathedral train. Every bride deserves to feel magical.'},
        {'title': 'Corporate Power Suit', 'category': 'Corporate', 'description': 'Sharp tailored two-piece suit in deep navy. Commands respect in any boardroom or professional setting.'},
        {'title': 'Traditional Attire', 'category': 'Traditional', 'description': 'Authentic traditional regalia with intricate beadwork and hand-woven fabric. Celebrate your heritage in style.'},
        {'title': 'Evening Cocktail Dress', 'category': 'Evening', 'description': 'Sleek cocktail dress with asymmetric hem and sequin details. Turn heads at any evening event.'},
        {'title': 'Casual Summer Dress', 'category': 'Casual', 'description': 'Light and breezy casual dress perfect for warm days. Simple elegance for everyday wear.'},
        {'title': 'Ankara Jumpsuit', 'category': 'Ankara', 'description': 'Trendy wide-leg jumpsuit in vibrant Ankara print. The perfect blend of African culture and modern fashion.'},
        {'title': 'Formal Ball Gown', 'category': 'Formal', 'description': 'Sweeping ball gown with structured bodice and full skirt. Make a statement at any formal event.'},
        {'title': 'Kaftan Wedding Guest', 'category': 'Kaftan', 'description': 'Luxurious kaftan in champagne silk with beaded neckline. The ideal choice for wedding guests.'},
        {'title': 'Kids Party Dress', 'category': 'Kids', 'description': 'Adorable layered tutu dress for little ones. Let your child shine at every party and celebration.'},
        {'title': 'Sports Tracksuit', 'category': 'Sportswear', 'description': 'Stylish matching tracksuit in breathable fabric. Stay comfortable and fashionable during workouts.'},
    ]

    for d in dresses:
        existing = DressPost.query.filter_by(title=d['title']).first()
        if not existing:
            post = DressPost(
                uploader_id=tailor.id,
                title=d['title'],
                description=d['description'],
                category=d['category'],
                is_public=True,
            )
            db.session.add(post)
            db.session.commit()

            from models.favorite import TailorDressLink
            link = TailorDressLink(tailor_id=tailor.id, post_id=post.id)
            db.session.add(link)
            if d['category'] in ['Wedding', 'Evening', 'Casual', 'Corporate']:
                link2 = TailorDressLink(tailor_id=tailor2.id, post_id=post.id)
                db.session.add(link2)
            db.session.commit()
            print('Created post:', d['title'])

    print('Seeding complete!')
