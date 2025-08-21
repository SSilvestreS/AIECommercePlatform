-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Create database if not exists
-- Note: This will be created automatically by POSTGRES_DB environment variable

-- Create custom types
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_method AS ENUM ('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cryptocurrency', 'cash_on_delivery');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled');
CREATE TYPE fraud_risk_level AS ENUM ('low', 'medium', 'high');
CREATE TYPE sentiment_label AS ENUM ('positive', 'negative', 'neutral');

-- Create tables with ML-friendly structure
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    address VARCHAR(200),
    postal_code VARCHAR(10),
    preferred_categories TEXT[],
    preferred_brands TEXT[],
    average_order_value DECIMAL(10,2),
    total_orders INTEGER DEFAULT 0,
    last_order_date TIMESTAMP,
    last_login_date TIMESTAMP,
    login_count INTEGER DEFAULT 0,
    churn_probability DECIMAL(5,4),
    lifetime_value DECIMAL(10,2),
    customer_segment VARCHAR(50),
    browsing_history TEXT[],
    search_history TEXT[],
    wishlist_items TEXT[],
    cart_abandonments TEXT[],
    preference_embedding REAL[],
    behavior_embedding REAL[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(100),
    created_by VARCHAR(100) DEFAULT 'system',
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    stock_quantity INTEGER NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    brand VARCHAR(50),
    category VARCHAR(100),
    tags TEXT[],
    images TEXT[],
    attributes JSONB,
    average_rating DECIMAL(3,2),
    total_reviews INTEGER DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    popularity_score DECIMAL(5,4),
    price_history REAL[],
    sales_history INTEGER[],
    last_price_change TIMESTAMP,
    last_stock_update TIMESTAMP,
    name_embedding REAL[],
    description_embedding REAL[],
    category_embedding REAL[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(100),
    created_by VARCHAR(100) DEFAULT 'system',
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id),
    user_id UUID NOT NULL REFERENCES users(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    title VARCHAR(200),
    images TEXT[],
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_helpful BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    sentiment_score REAL,
    sentiment_label sentiment_label,
    confidence DECIMAL(5,4),
    extracted_keywords TEXT[],
    detected_topics TEXT[],
    aspect_sentiments JSONB,
    comment_embedding REAL[],
    title_embedding REAL[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(100),
    created_by VARCHAR(100) DEFAULT 'system',
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    payment_method payment_method NOT NULL,
    payment_status payment_status NOT NULL DEFAULT 'pending',
    payment_date TIMESTAMP,
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    shipping_address VARCHAR(200) NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_country VARCHAR(100) NOT NULL,
    shipping_postal_code VARCHAR(10) NOT NULL,
    tracking_number VARCHAR(20),
    fraud_risk_score REAL,
    fraud_risk_level fraud_risk_level,
    fraud_risk_factors TEXT[],
    is_fraudulent BOOLEAN DEFAULT FALSE,
    fraud_detection_notes TEXT,
    time_from_last_order INTERVAL,
    items_in_cart INTEGER,
    average_item_price DECIMAL(10,2),
    is_first_time_customer BOOLEAN DEFAULT FALSE,
    device_type VARCHAR(50),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(100),
    created_by VARCHAR(100) DEFAULT 'system',
    updated_by VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id),
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for ML performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_preference_embedding ON users USING gin(preference_embedding);
CREATE INDEX IF NOT EXISTS idx_users_behavior_embedding ON users USING gin(behavior_embedding);

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);
CREATE INDEX IF NOT EXISTS idx_products_name_embedding ON products USING gin(name_embedding);
CREATE INDEX IF NOT EXISTS idx_products_description_embedding ON products USING gin(description_embedding);

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_sentiment_score ON reviews(sentiment_score);
CREATE INDEX IF NOT EXISTS idx_reviews_comment_embedding ON reviews USING gin(comment_embedding);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_fraud_risk_score ON orders(fraud_risk_score);

-- Create ML-specific tables
CREATE TABLE IF NOT EXISTS ml_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name VARCHAR(100) NOT NULL,
    model_type VARCHAR(50) NOT NULL,
    version VARCHAR(20) NOT NULL,
    model_data BYTEA,
    model_path VARCHAR(500),
    accuracy REAL,
    training_date TIMESTAMP,
    features TEXT[],
    hyperparameters JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ml_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_id UUID REFERENCES ml_models(id),
    input_data JSONB,
    prediction_result JSONB,
    confidence REAL,
    prediction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ml_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_name VARCHAR(100) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value REAL NOT NULL,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data for testing
INSERT INTO users (email, username, first_name, last_name, country, city) VALUES
('john.doe@example.com', 'johndoe', 'John', 'Doe', 'United States', 'New York'),
('jane.smith@example.com', 'janesmith', 'Jane', 'Smith', 'Canada', 'Toronto'),
('mike.johnson@example.com', 'mikejohnson', 'Mike', 'Johnson', 'United Kingdom', 'London')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, description, price, category, brand, stock_quantity, sku) VALUES
('iPhone 15 Pro', 'Latest iPhone with advanced features', 999.99, 'Electronics', 'Apple', 50, 'IPHONE15PRO001'),
('MacBook Air M2', 'Lightweight laptop with M2 chip', 1199.99, 'Electronics', 'Apple', 30, 'MACBOOKAIRM2001'),
('Samsung Galaxy S24', 'Android flagship smartphone', 899.99, 'Electronics', 'Samsung', 45, 'GALAXYS24001')
ON CONFLICT (sku) DO NOTHING;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
