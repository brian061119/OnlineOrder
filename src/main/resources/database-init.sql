DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS authorities;
DROP TABLE IF EXISTS customers;


CREATE TABLE customers
(
    id         SERIAL PRIMARY KEY   NOT NULL,
    email      TEXT UNIQUE          NOT NULL,
    enabled    BOOLEAN DEFAULT TRUE NOT NULL,
    password   TEXT                 NOT NULL,
    first_name TEXT,
    last_name  TEXT
);


CREATE TABLE carts
(
    id          SERIAL PRIMARY KEY NOT NULL,
    customer_id INTEGER UNIQUE     NOT NULL,
    total_price NUMERIC            NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
);


CREATE TABLE restaurants
(
    id        SERIAL PRIMARY KEY NOT NULL,
    name      TEXT               NOT NULL,
    address   TEXT,
    image_url TEXT,
    phone     TEXT
);


CREATE TABLE menu_items
(
    id            SERIAL PRIMARY KEY NOT NULL,
    restaurant_id INTEGER            NOT NULL,
    name          TEXT               NOT NULL,
    price         NUMERIC            NOT NULL,
    description   TEXT,
    image_url     TEXT,
    CONSTRAINT fk_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants (id) ON DELETE CASCADE
);


CREATE TABLE order_items
(
    id           SERIAL PRIMARY KEY NOT NULL,
    menu_item_id INTEGER            NOT NULL,
    cart_id      INTEGER            NOT NULL,
    price        NUMERIC            NOT NULL,
    quantity     INTEGER            NOT NULL,
    CONSTRAINT fk_cart FOREIGN KEY (cart_id) REFERENCES carts (id) ON DELETE CASCADE,
    CONSTRAINT fk_menu_item FOREIGN KEY (menu_item_id) REFERENCES menu_items (id) ON DELETE CASCADE
);


CREATE TABLE authorities
(
    id        SERIAL PRIMARY KEY NOT NULL,
    email     TEXT               NOT NULL,
    authority TEXT               NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (email) REFERENCES customers (email) ON DELETE CASCADE
);


INSERT INTO restaurants (name, address, image_url, phone)
VALUES ('Burger King', '773 N Mathilda Ave, Sunnyvale, CA 94085',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/store%2Fheader%2F10171.png',
        '(408) 736-0101'),
       ('SGD Tofu House', '3450 El Camino Real #105, Santa Clara, CA 95051',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg',
        '(408) 261-3030'),
       ('Fashion Wok', '163 S Murphy Ave, Sunnyvale, CA 94086',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg',
        '(408) 739-8866');


INSERT INTO menu_items (description, image_url, name, price, restaurant_id)
VALUES ('Made with white meat chicken, our Chicken Fries are coated in a light crispy breading seasoned with savory spices and herbs.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=300,format=auto,quality=50/https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg',
        'Chicken Fries - 9 Pc', 4.89, 1),
       ('Our Whopper Sandwich is a 1/4 lb* of savory flame-grilled beef topped with juicy tomatoes, fresh lettuce, creamy mayonnaise, ketchup, crunchy pickles, and sliced white onions on a soft sesame seed bun.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=300,format=auto,quality=50/https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg',
        'Whopper Meal', 10.59, 1),
       ('Our Impossible™ Whopper Sandwich features a savory flame-grilled patty made from plants topped with juicy tomatoes, fresh lettuce, creamy mayonnaise, ketchup, crunchy pickles, and sliced white onions on a soft sesame seed bun',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/5c306a5f-fdd2-41d2-a660-9762aaa8eee8-retina-large.jpg',
        'Impossible™ Whopper', 7.99, 1),
       ('Say hello to our HERSHEY’S® Sundae Pie. One part crunchy chocolate crust and one part chocolate crème filling, garnished with a delicious topping and real HERSHEY’S® Chocolate Chips',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/80b1670d-e9c0-4886-a5b7-1ad48edd24ca-retina-large.jpg',
        'HERSHEYS® Sundae Pie', 3.09, 1),
       ('Our Whopper Sandwich is a 1/4 lb* of savory flame-grilled beef topped with juicy tomatoes, fresh lettuce, creamy mayonnaise, ketchup, crunchy pickles, and sliced white onions on a soft sesame seed bun.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/9b3d7985-e457-43b3-938d-5184f48c2687-retina-large-jpeg',
        'Whopper', 6.39, 1),
       ('Our Double Whopper Sandwich is a pairing of two 1/4 lb* savory flame-grilled beef patties topped with juicy tomatoes, fresh lettuce, creamy mayonnaise, ketchup, crunchy pickles, and sliced white onions on a soft sesame seed bun',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/45addf4a-e8a8-47cb-a705-cce1d10ce86d-retina-large.jpg',
        'Double Whopper Meal', 11.69, 1),
       ('Our Double Whopper Sandwich is a pairing of two 1/4 lb* savory flame-grilled beef patties topped with juicy tomatoes, fresh lettuce, creamy mayonnaise, ketchup, crunchy pickles, and sliced white onions on a soft sesame seed bun',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/31dd68c2-06ec-42ad-bcd4-da7bd3425437-retina-large-jpeg',
        'Spicy Crispy Chicken Sandwich', 6.09, 1),
       ('Our Original Chicken Sandwich is lightly breaded and topped with a simple combination of shredded lettuce and creamy mayonnaise on a sesame seed bun',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/3e437f54-fa4e-4e9d-bf80-8a1e5b120f32-retina-large-jpeg',
        'Original Chicken Sandwich', 6.09, 1),
       ('Our Bacon King Sandwich features two 1/4 lb* savory flame-grilled beef patties, topped a with hearty portion of thick-cut smoked bacon, melted American cheese and topped with ketchup and creamy mayonnaise all on a soft sesame seed bun.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/adb96c32-3c5b-4375-ba92-b30767d2513d-retina-large.jpg',
        'Bacon King Sandwich Meal', 12.19, 1),
       ('Cool down with our creamy hand spun OREO® Shake.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/c3ad483f-bad7-44f1-96af-4c3dcfc63c6d-retina-large.jpg',
        'Classic OREO® Shake', 3.99, 1),
       ('Tofu boiled with your choice of meat and mushrooms. Served with your choice of side and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg',
        'Original Soft Tofu', 17.06, 2),
       ('Tofu boiled with beef, shrimp, and clams. Served with your choice of side and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/37ad1974-1395-4e5c-86ff-fdf120cf8c58-retina-large-jpeg',
        'Combination Soft Tofu', 17.06, 2),
       ('Tofu boiled with mussels, shrimp, and clam. Served with your choice of side and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/96bc8289-1950-4b4f-823d-12f33349a5fe-retina-large-jpeg',
        'Seafood Soft Tofu', 17.06, 2),
       ('Squid, clam, imitation crab, and grilled onions fried in batter.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg',
        'Seafood Pancake', 20.27, 2),
       ('Tofu boiled with kimchi and your choice of meat. Served with your choice of side and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/0c062cff-1868-40e1-946d-29d3e46f1541-retina-large-jpeg',
        'Kimchi Soft Tofu', 17.06, 2),
       ('Beef short ribs served with rice and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/6340c369-2485-4d60-afcf-ca9068448d84-retina-large.jpg',
        'Beef Short Ribs', 29.36, 2),
       ('Tofu boiled with dumplings, rice cake, and beef. Served with your choice of side and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg',
        'Dumpling Soft Tofu', 17.06, 2),
       ('Tofu boiled with assorted mushrooms. Served with your choice of side and an assortment of kimchi dishes',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg',
        'Assorted Mushroom Tofu', 17.06, 2),
       ('Rice, BBQ beef, and vegetables served in stoneware with an assortment of kimchi dishes',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/9844dd4e-3c74-4942-8f90-2b3f4be25049-retina-large-jpeg',
        'BBQ Beef & Vegetables in Stoneware', 20.27, 2),
       ('Tofu boiled with ham and cheese. Served with your choice of side and an assortment of kimchi dishes.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/9c6b2a1c-1e2c-4d80-a111-2bebbcadd64c-retina-large.jpg',
        'Ham & Cheese Soft Tofu', 17.06, 2),
       ('Medium spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/5b34852e-d253-461c-8be8-1bb0bc5e39be-retina-large.jpg',
        'Stir Fried Pork with Pepper', 13.99, 3),
       ('',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/bf70f262-0c55-41e1-89bc-84c061ae485f-retina-large.jpg',
        'Eggplant with Minced Pork, Garlic, Cilantro', 14.99, 3),
       ('Mild spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/cb870c77-ace1-49ec-aa2f-9e18de102242-retina-large.jpg',
        'Stir Fried Cauliflower with Pork', 14.99, 3),
       ('Mild spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg',
        'Poached Fish Fillets in Sour Soup', 17.99, 3),
       ('Very spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/7f05859d-5e83-476d-a45a-73a3eb8a94e0-retina-large.jpg',
        'Stir Fried Beef with Pepper', 16.99, 3),
       ('Medium spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/8b2ca9fc-2c1d-4bf2-96ff-d0bd3c415e8d-retina-large.jpg',
        'Stir Fried Shredded Tripe with Wugang Tofu', 19.99, 3),
       ('Very spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/89ad8679-346e-41d8-b98f-3501fff4b277-retina-large.jpg',
        'Poached Sliced Beef in Hot Chili Oil', 17.99, 3),
       ('With chopped broccoli, peas, carrots, bok choy, egg.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg',
        'Fried Rice', 9.5, 3),
       ('Very spicy.',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/2fe1b87f-d41f-4fa4-8cae-5f2ee5bb97e4-retina-large.jpg',
        'Smashed Green Pepper, Chinese Eggplant & Preserved Egg', 11.99, 3),
       ('',
        'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/https://cdn.doordash.com/media/photos/a307e73d-dd12-4841-be14-6f5825a64c59-retina-large.jpg',
        'Stir Fried A-Choy with Minced Garlic', 10.99, 3);


-- Additional restaurants (id 4-22)
INSERT INTO restaurants (name, address, image_url, phone)
VALUES ('Chipotle Mexican Grill', '1080 Blossom Hill Rd, San Jose, CA 95123', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(408) 265-5900'),
       ('In-N-Out Burger', '500 E Charleston Rd, Palo Alto, CA 94306', 'https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg', '(800) 786-1000'),
       ('Philz Coffee', '101 Forest Ave, Palo Alto, CA 94301', 'https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg', '(650) 321-2161'),
       ('Sushi Tomi', '4030 El Camino Real, Palo Alto, CA 94306', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(650) 493-9793'),
       ('Ramen Nagi', '541 Bryant St, Palo Alto, CA 94301', 'https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg', '(650) 391-2136'),
       ('Taqueria La Bamba', '2058 Old Middlefield Way, Mountain View, CA 94043', 'https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg', '(650) 965-2755'),
       ('Curry Up Now', '321 Castro St, Mountain View, CA 94041', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(650) 449-9940'),
       ('The Halal Guys', '2551 Winchester Blvd, Campbell, CA 95008', 'https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg', '(408) 963-9500'),
       ('Shake Shack', '855 El Camino Real, Palo Alto, CA 94301', 'https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg', '(650) 656-6540'),
       ('Panda Express', '2410 Charleston Rd, Mountain View, CA 94043', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(650) 969-6688'),
       ('Sweetgreen', '185 University Ave, Palo Alto, CA 94301', 'https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg', '(650) 383-8090'),
       ('Pho Ha Noi', '2050 W El Camino Real, Mountain View, CA 94040', 'https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg', '(650) 386-6555'),
       ('Din Tai Fung', '2855 Stevens Creek Blvd, Santa Clara, CA 95050', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(408) 248-1688'),
       ('Ike''s Love & Sandwiches', '2755 El Camino Real, Santa Clara, CA 95051', 'https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg', '(408) 244-4537'),
       ('Boiling Point', '1088 E El Camino Real, Sunnyvale, CA 94087', 'https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg', '(408) 720-8896'),
       ('Gott''s Roadside', '855 El Camino Real Suite 76, Palo Alto, CA 94301', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(650) 326-1462'),
       ('Mendocino Farms', '500 University Ave, Palo Alto, CA 94301', 'https://cdn.doordash.com/media/store%2Fheader%2F1579.jpg', '(650) 600-3400'),
       ('Poke House', '156 Castro St, Mountain View, CA 94041', 'https://cdn.doordash.com/media/store%2Fheader%2F273997.jpg', '(650) 968-7653'),
       ('Falafel Stop', '1325 Sunnyvale Saratoga Rd, Sunnyvale, CA 94087', 'https://cdn.doordash.com/media/store%2Fheader%2F10171.png', '(408) 736-0806');


-- Additional menu items for restaurants 4-22
INSERT INTO menu_items (description, image_url, name, price, restaurant_id)
VALUES
    -- 4 Chipotle Mexican Grill
    ('Your choice of protein wrapped in a warm flour tortilla with rice, beans, salsa, and cheese.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Chicken Burrito', 11.25, 4),
    ('Marinated and grilled steak served in a bowl over cilantro-lime rice with black beans.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Steak Burrito Bowl', 13.45, 4),
    ('Braised and shredded beef with hand-mashed guacamole on soft corn tortillas.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Barbacoa Tacos', 12.95, 4),
    ('Seasoned adobo-marinated peppers and onions with fajita veggies and queso blanco.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Veggie Quesadilla', 9.75, 4),
    ('Freshly made daily with ripe Hass avocados, lime, cilantro, and red onion.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Large Chips & Guacamole', 5.85, 4),
    ('Crispy corn tortilla chips with warm queso blanco made from aged Monterey Jack.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Chips & Queso Blanco', 5.25, 4),
    -- 5 In-N-Out Burger
    ('Two 100% American beef patties, hand-leafed lettuce, tomato, and spread on a toasted bun.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Double-Double', 5.65, 5),
    ('One beef patty with American cheese, lettuce, tomato, and our signature spread.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Cheeseburger', 3.95, 5),
    ('Fresh whole potatoes, hand-cut in-store and cooked in 100% sunflower oil.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'French Fries', 2.35, 5),
    ('Our fries smothered in melted cheese and spread, grilled onions on top.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Animal Style Fries', 4.60, 5),
    ('Made with real ice cream, hand-spun to order in chocolate, vanilla, or strawberry.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Chocolate Shake', 3.05, 5),
    ('Two patties and two slices of cheese wrapped in hand-leafed lettuce instead of a bun.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Protein Style Burger', 5.65, 5),
    -- 6 Philz Coffee
    ('Our signature blend with notes of chocolate and berry, brewed one cup at a time.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Tesora Pour Over', 4.75, 6),
    ('Mint-infused medium roast served over ice with cream and sugar.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Mint Mojito Iced Coffee', 5.95, 6),
    ('Steeped 12 hours for a smooth, low-acid finish. Served black over ice.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Cold Brew', 5.25, 6),
    ('Rich chocolate blended with espresso and steamed whole milk.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Mocha Tesora', 6.15, 6),
    ('Buttery, flaky, and baked fresh each morning by a local Bay Area bakery.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Almond Croissant', 4.50, 6),
    ('Rolled oats with almond butter, banana, and a drizzle of local honey.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Overnight Oats', 6.75, 6),
    -- 7 Sushi Tomi
    ('Eight pieces of chef-selected nigiri with a California roll.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Sushi Combo', 26.50, 7),
    ('Fresh bluefin tuna sliced thin over seasoned sushi rice, two pieces.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Maguro Nigiri', 8.50, 7),
    ('Torched salmon belly with ponzu and scallion, two pieces.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Aburi Salmon', 9.25, 7),
    ('Shrimp and seasonal vegetables in a light, crisp tempura batter.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Tempura Moriawase', 16.75, 7),
    ('Spicy tuna, cucumber, and avocado topped with tobiko.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Spicy Tuna Roll', 11.50, 7),
    ('Silken tofu, wakame, and scallion in a dashi-based broth.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Miso Soup', 3.75, 7),
    -- 8 Ramen Nagi
    ('Original tonkotsu broth with chashu pork, scallion, and black fungus.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Butao King Ramen', 17.95, 8),
    ('Tonkotsu broth layered with a house chili blend. Adjustable spice level.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Red King Ramen', 18.50, 8),
    ('Squid ink and garlic give this broth its deep color and umami.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Black King Ramen', 18.50, 8),
    ('Parmesan and basil folded into tonkotsu for a rich, unexpected finish.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Green King Ramen', 18.95, 8),
    ('Pan-fried pork dumplings with a crisp bottom, five pieces.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Gyoza', 8.25, 8),
    ('Marinated soft-boiled egg with a jammy yolk. Add to any bowl.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Ajitama Egg', 2.50, 8),
    -- 9 Taqueria La Bamba
    ('Grilled marinated steak, rice, beans, cheese, and pico in a flour tortilla.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Carne Asada Super Burrito', 13.50, 9),
    ('Slow-braised pork with onion and cilantro on double corn tortillas, three pieces.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Carnitas Tacos', 11.25, 9),
    ('Crispy tortilla chips layered with beans, cheese, guacamole, and sour cream.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Nachos Supreme', 12.75, 9),
    ('Marinated chicken grilled with peppers and onions, served with tortillas.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Pollo Asado Plate', 15.95, 9),
    ('Beer-battered white fish with cabbage slaw and chipotle crema, two pieces.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Baja Fish Tacos', 12.50, 9),
    ('Traditional Mexican rice water with cinnamon, served over ice.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Horchata', 4.25, 9),
    -- 10 Curry Up Now
    ('Tikka masala chicken wrapped burrito-style with basmati rice and chutney.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Chicken Tikka Masala Burrito', 14.95, 10),
    ('Crispy fries topped with curried chickpeas, chutney, and house sauce.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Deconstructed Samosa', 11.50, 10),
    ('Spiced lamb keema over basmati rice with raita and pickled onion.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Lamb Keema Bowl', 16.75, 10),
    ('Paneer cubes seared with bell pepper and onion in a tomato-cream sauce.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Paneer Tikka Bowl', 14.25, 10),
    ('Griddled naan brushed with garlic butter and fresh cilantro.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Garlic Naan', 4.50, 10),
    ('Yogurt blended with mango pulp and a touch of cardamom.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Mango Lassi', 5.50, 10),
    -- 11 The Halal Guys
    ('Grilled chicken over seasoned rice with lettuce, tomato, and white sauce.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Chicken Platter', 13.99, 11),
    ('Thinly sliced seasoned beef gyro over rice with pita on the side.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Gyro Platter', 14.99, 11),
    ('Half chicken and half gyro over rice, our most popular order.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Combo Platter', 15.49, 11),
    ('Crispy chickpea fritters in warm pita with lettuce, tomato, and tahini.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Falafel Sandwich', 10.99, 11),
    ('Six golden falafel balls served with tahini for dipping.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Falafel Side', 5.49, 11),
    ('Cool, creamy, and tangy. The sauce that started it all.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Extra White Sauce', 1.25, 11),
    -- 12 Shake Shack
    ('Cheeseburger topped with lettuce, tomato, and ShackSauce on a potato bun.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'ShackBurger', 8.29, 12),
    ('Crispy portobello mushroom filled with melted muenster and cheddar.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Shroom Burger', 9.49, 12),
    ('All-natural chicken breast, crisp lettuce, pickles, and buttermilk herb mayo.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Chicken Shack', 9.19, 12),
    ('Crinkle-cut fries topped with our signature cheese sauce.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Cheese Fries', 5.79, 12),
    ('Vanilla frozen custard blended with fudge and shortbread cookies.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Shack Attack Concrete', 7.29, 12),
    ('Hand-spun vanilla custard shake made fresh to order.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Vanilla Shake', 6.49, 12),
    -- 13 Panda Express
    ('Crispy chicken wok-tossed in a sweet and spicy Sichuan-inspired sauce.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Orange Chicken', 9.20, 13),
    ('Beef and broccoli in a savory ginger soy sauce. Premium entree.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Broccoli Beef', 9.20, 13),
    ('Chicken, peanuts, and vegetables in a Sichuan sauce with a mild kick.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Kung Pao Chicken', 9.20, 13),
    ('Marinated grilled teriyaki chicken thigh sliced and served over rice.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Grilled Teriyaki Chicken', 9.70, 13),
    ('Steamed rice wok-tossed with soy sauce, eggs, peas, carrots, and green onion.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Fried Rice', 5.20, 13),
    ('Wheat noodles tossed with cabbage, celery, and onion.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Chow Mein', 5.20, 13),
    -- 14 Sweetgreen
    ('Roasted chicken, avocado, tomato, and spicy sunflower seeds over greens.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Harvest Bowl', 15.45, 14),
    ('Blackened chicken, avocado, tortilla chips, and lime cilantro jalapeno vinaigrette.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Chicken Pesto Parm', 16.25, 14),
    ('Warm wild rice, sweet potato, roasted almonds, and balsamic vinaigrette.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Guacamole Greens', 15.95, 14),
    ('Shredded kale, quinoa, chickpeas, and lemon tahini dressing.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Kale Caesar', 14.75, 14),
    ('Cold-pressed apple, ginger, lemon, and mint.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Green Juice', 7.50, 14),
    ('Warm focaccia baked daily and brushed with rosemary olive oil.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Focaccia Side', 3.95, 14),
    -- 15 Pho Ha Noi
    ('Rare steak in a 12-hour beef bone broth with rice noodles and herbs.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Pho Tai', 15.50, 15),
    ('Beef brisket, flank, and meatball in our house pho broth.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Pho Dac Biet', 17.25, 15),
    ('Grilled lemongrass pork over vermicelli with pickled carrot and fish sauce.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Bun Thit Nuong', 16.50, 15),
    ('Grilled pork and pate on a crisp baguette with cilantro and jalapeno.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Banh Mi Thit Nuong', 10.25, 15),
    ('Shrimp and pork wrapped in rice paper with peanut dipping sauce, two rolls.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Goi Cuon', 8.50, 15),
    ('Strong drip coffee over condensed milk and ice.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Ca Phe Sua Da', 5.75, 15),
    -- 16 Din Tai Fung
    ('Ten delicate pork soup dumplings, steamed to order.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Pork Xiao Long Bao', 16.50, 16),
    ('Steamed dumplings filled with kurobuta pork and black truffle.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Truffle & Pork XLB', 24.00, 16),
    ('Shrimp and pork wontons tossed in house-made spicy sauce.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Spicy Wontons', 13.50, 16),
    ('Wok-tossed with egg, scallion, and chopped shrimp.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Shrimp Fried Rice', 15.75, 16),
    ('Blanched greens with minced garlic and a touch of sesame oil.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Garlic String Beans', 11.25, 16),
    ('Steamed buns filled with sweet red bean paste, three pieces.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Red Bean Buns', 9.50, 16),
    -- 17 Ike's Love & Sandwiches
    ('Halal chicken, honey mustard, and dutch crunch bread with Ike''s dirty sauce.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Menage a Trois', 14.99, 17),
    ('Fried chicken, bacon, cheddar, and barbecue sauce on a French roll.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Barry Bonds', 15.49, 17),
    ('Vegan meatballs, marinara, and vegan mozzarella on garlic bread.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Vegan Meatball', 14.25, 17),
    ('Turkey, avocado, provolone, and pesto on dutch crunch.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Sexy Vegan Bacon', 14.75, 17),
    ('Crispy waffle fries with a side of Ike''s dirty sauce.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Waffle Fries', 5.50, 17),
    ('A rotating selection of craft sodas from small California bottlers.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Craft Soda', 3.75, 17),
    -- 18 Boiling Point
    ('Kimchi, pork, tofu, and enoki mushrooms in a bubbling stone pot.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Kimchi Pork Hot Pot', 17.95, 18),
    ('Milk-based broth with sliced beef, corn, and napa cabbage.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'House Special Milk Hot Pot', 18.95, 18),
    ('Clam, shrimp, fish fillet, and squid in a light seafood broth.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Seafood Hot Pot', 19.95, 18),
    ('Napa cabbage, tofu, mushrooms, and glass noodles in vegetarian broth.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Vegetarian Hot Pot', 15.95, 18),
    ('Crispy fried chicken bites tossed with basil and five-spice salt.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Popcorn Chicken', 8.50, 18),
    ('Brewed black tea with chewy tapioca pearls and non-dairy creamer.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Boba Milk Tea', 6.25, 18),
    -- 19 Gott's Roadside
    ('Wisconsin cheddar, secret sauce, lettuce, tomato, and pickle on an egg bun.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Cheeseburger', 12.99, 19),
    ('Beer-battered Pacific cod with tartar sauce and shredded cabbage, three tacos.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Baja Fish Tacos', 16.99, 19),
    ('Grass-fed patty with avocado, sprouts, and herb mayo on a whole wheat bun.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'California Burger', 14.49, 19),
    ('Hand-cut Kennebec potatoes fried in rice bran oil, served with garlic aioli.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Garlic Fries', 7.49, 19),
    ('Rotating seasonal greens with local produce and citrus vinaigrette.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Seasonal Salad', 11.99, 19),
    ('Hand-spun with Straus organic ice cream and real Ghirardelli chocolate.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Organic Milkshake', 8.29, 19),
    -- 20 Mendocino Farms
    ('Shredded chicken, herb aioli, and pickled onion on ciabatta.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Kurobuta Pork Belly Banh Mi', 15.75, 20),
    ('Roasted turkey, brie, arugula, and cranberry mostarda on rustic white.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Not So Fried Chicken', 15.25, 20),
    ('Vegan chorizo, avocado, and cashew crema in a warm wrap.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Vegan Banh Mi', 14.50, 20),
    ('Chopped romaine, corn, black beans, cotija, and chipotle vinaigrette.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Modern Caesar', 13.95, 20),
    ('Slow-simmered tomato bisque with a grilled cheese soldier.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Tomato Soup', 8.50, 20),
    ('Kettle-cooked chips seasoned with sea salt and cracked pepper.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Kettle Chips', 3.25, 20),
    -- 21 Poke House
    ('Ahi tuna, edamame, cucumber, and masago over sushi rice with shoyu sauce.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Classic Ahi Bowl', 15.95, 21),
    ('Salmon, avocado, sweet onion, and spicy mayo over brown rice.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Spicy Salmon Bowl', 16.50, 21),
    ('Marinated tofu, seaweed salad, mango, and ponzu over mixed greens.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Veggie Poke Bowl', 13.95, 21),
    ('Build your own with three scoops of protein and unlimited toppings.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Large Custom Bowl', 18.95, 21),
    ('Crispy nori sheets dusted with sea salt and sesame.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Seaweed Snack', 4.25, 21),
    ('Chilled green tea brewed daily, unsweetened.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Iced Green Tea', 3.50, 21),
    -- 22 Falafel Stop
    ('Six falafel balls in fresh pita with Israeli salad, hummus, and tahini.', 'https://cdn.doordash.com/media/photos/1acf9c6b-189d-4583-a151-7ef522c283d9-retina-large.jpg', 'Falafel Pita', 11.50, 22),
    ('Marinated chicken shawarma carved to order with garlic sauce.', 'https://cdn.doordash.com/media/photos/f878a689-618b-4c70-a00f-e7b1f320adc9-retina-large.jpg', 'Chicken Shawarma Plate', 17.95, 22),
    ('Creamy hummus topped with whole chickpeas, olive oil, and paprika.', 'https://cdn.doordash.com/media/photos/ec06c431-9426-4971-a129-920440e1c9ce-retina-large.jpg', 'Hummus Plate', 9.95, 22),
    ('Grilled beef and lamb kebab over rice with grilled tomato and onion.', 'https://cdn.doordash.com/media/photos/f439436f-c5ab-47af-bac4-7b73ab60a24b-retina-large.jpg', 'Kebab Plate', 19.50, 22),
    ('Fried eggplant, hard-boiled egg, potato, and amba in pita.', 'https://cdn.doordash.com/media/photos/0a94b7e9-903d-49b7-937a-7940c8b56ad5-retina-large-jpeg', 'Sabich Sandwich', 12.75, 22),
    ('Layers of shredded phyllo, walnut, and honey syrup.', 'https://cdn.doordash.com/media/photos/b7055ca9-3caf-4d9d-9c99-04be1e36dbbf-retina-large-jpeg', 'Baklava', 4.50, 22);
