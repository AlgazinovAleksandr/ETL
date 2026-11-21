-- Старые строки остаются на месте до успешной замены снимка
ALTER TABLE catalog.products
    ADD COLUMN IF NOT EXISTS rating_percentile NUMERIC(5, 2),
    ADD COLUMN IF NOT EXISTS rating_segment TEXT,
    ADD COLUMN IF NOT EXISTS category_size INTEGER;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'catalog.products'::regclass
          AND conname = 'products_rating_features_valid'
    ) THEN
        ALTER TABLE catalog.products
            ADD CONSTRAINT products_rating_features_valid CHECK (
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
            ) NOT VALID;
    END IF;
END;
$$;

-- Load проверяет ограничение для всего нового снимка перед commit
