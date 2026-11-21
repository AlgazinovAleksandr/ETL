CREATE SCHEMA IF NOT EXISTS catalog;

CREATE TABLE IF NOT EXISTS catalog.products (
    product_id INTEGER PRIMARY KEY CHECK (product_id > 0),
    title TEXT NOT NULL CHECK (btrim(title) <> ''),
    category TEXT NOT NULL CHECK (btrim(category) <> ''),
    brand TEXT,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    discount_percentage NUMERIC(5, 2) NOT NULL CHECK (discount_percentage BETWEEN 0 AND 100),
    discounted_price NUMERIC(12, 2) NOT NULL CHECK (discounted_price >= 0 AND discounted_price <= price),
    rating NUMERIC(3, 2) NOT NULL CHECK (rating BETWEEN 0 AND 5),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    width NUMERIC(10, 2) NOT NULL CHECK (width >= 0),
    height NUMERIC(10, 2) NOT NULL CHECK (height >= 0),
    depth NUMERIC(10, 2) NOT NULL CHECK (depth >= 0),
    rating_percentile NUMERIC(5, 2),
    rating_segment TEXT,
    category_size INTEGER,
    CONSTRAINT products_rating_features_valid CHECK (
        category_size IS NOT NULL AND category_size >= 1
        AND rating_segment IS NOT NULL
        AND (
            (rating_segment = 'not comparable' AND rating_percentile IS NULL)
            OR (
                category_size > 1
                AND rating_segment IN ('top20%', 'top50%', 'not ranked high')
                AND rating_percentile IS NOT NULL
                AND rating_percentile BETWEEN 0 AND 100
            )
        )
    )
);
