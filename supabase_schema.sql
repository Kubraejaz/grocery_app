-- ==============================================================================
-- GROCERY APP - SUPABASE DATABASE & ROLE CONFIGURATION
-- ==============================================================================

-- 1. PROFILES TABLE (Stores user_type: 1 = Admin, 2 = Customer / User)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  user_type INT DEFAULT 2, -- 1: Admin, 2: User
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Helper function to check if current user is admin without RLS recursion
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND user_type = 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read profiles (prevents infinite recursion code: 42P17)
DROP POLICY IF EXISTS "Allow users to read profile" ON public.profiles;
CREATE POLICY "Allow users to read profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;
CREATE POLICY "Allow users to update their own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- 2. AUTOMATIC PROFILE CREATION TRIGGER ON SIGNUP
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, user_type)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'user_type')::INT, 2)
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. ENSURE PRODUCTS TABLE HAS ALL NECESSARY COLUMNS
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  price NUMERIC NOT NULL,
  discount_price NUMERIC,
  image_url TEXT DEFAULT '',
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  stock INT DEFAULT 0,
  unit TEXT DEFAULT 'piece',
  rating NUMERIC DEFAULT 0.0,
  review_count INT DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ROW LEVEL SECURITY (RLS) FOR PRODUCTS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Anyone authenticated can view active products
DROP POLICY IF EXISTS "Public read active products" ON public.products;
CREATE POLICY "Public read active products"
  ON public.products FOR SELECT
  USING (is_active = TRUE OR public.is_admin());

-- Only Admin can INSERT products
DROP POLICY IF EXISTS "Admin insert products" ON public.products;
CREATE POLICY "Admin insert products"
  ON public.products FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

-- Only Admin can UPDATE products
DROP POLICY IF EXISTS "Admin update products" ON public.products;
CREATE POLICY "Admin update products"
  ON public.products FOR UPDATE
  TO authenticated
  USING (public.is_admin());

-- Only Admin can DELETE products
DROP POLICY IF EXISTS "Admin delete products" ON public.products;
CREATE POLICY "Admin delete products"
  ON public.products FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- 5. ORDER MANAGEMENT PERMISSIONS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Customers can view their own orders; Admins can view ALL orders
DROP POLICY IF EXISTS "View orders policy" ON public.orders;
CREATE POLICY "View orders policy"
  ON public.orders FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

-- Customers can insert their orders
DROP POLICY IF EXISTS "Customer insert orders" ON public.orders;
CREATE POLICY "Customer insert orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Only Admins can update order status
DROP POLICY IF EXISTS "Admin update orders status" ON public.orders;
CREATE POLICY "Admin update orders status"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (public.is_admin());

-- 6. STORAGE BUCKET FOR PRODUCT IMAGES
-- (Run this or create a public bucket named 'product-images' in Supabase Dashboard -> Storage)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Allow public read of product images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

CREATE POLICY "Allow authenticated admin upload of product images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'product-images');

-- ==============================================================================
-- 7. SEED INITIAL GROCERY CATEGORIES
-- ==============================================================================
INSERT INTO public.categories (id, name, color_hex) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Fresh Vegetables', '#4CAF50'),
  ('22222222-2222-2222-2222-222222222222', 'Fresh Fruits', '#FF9800'),
  ('33333333-3333-3333-3333-333333333333', 'Dairy & Eggs', '#2196F3'),
  ('44444444-4444-4444-4444-444444444444', 'Bakery & Bread', '#795548'),
  ('55555555-5555-5555-5555-555555555555', 'Beverages & Juices', '#E91E63')
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 8. SEED LIVE SAMPLE GROCERY PRODUCTS (Admin & User Test Data)
-- ==============================================================================
INSERT INTO public.products (id, name, description, price, discount_price, image_url, category_id, stock, unit, rating, review_count, is_featured, is_active) VALUES
  (
    'a1111111-1111-1111-1111-111111111111',
    'Organic Farm Tomatoes',
    'Locally harvested, vine-ripened organic red tomatoes. Rich in vitamins and lycopene.',
    150,
    120,
    'https://images.unsplash.com/photo-1546470427-227c7369a924?w=500&auto=format&fit=crop&q=80',
    '11111111-1111-1111-1111-111111111111',
    50,
    'kg',
    4.8,
    36,
    true,
    true
  ),
  (
    'a2222222-2222-2222-2222-222222222222',
    'Crisp Royal Gala Apples',
    'Sweet and crunchy high-altitude apples. Hand-picked for top freshness.',
    260,
    220,
    'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80',
    '22222222-2222-2222-2222-222222222222',
    35,
    'kg',
    4.9,
    42,
    true,
    true
  ),
  (
    'a3333333-3333-3333-3333-333333333333',
    'Pure Dairy Whole Milk (1L)',
    '100% natural, farm-fresh pasteurized whole milk pouch (1 Litre).',
    180,
    NULL,
    'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80',
    '33333333-3333-3333-3333-333333333333',
    60,
    'litre',
    4.7,
    28,
    false,
    true
  ),
  (
    'a4444444-4444-4444-4444-444444444444',
    'Golden Honey Bananas',
    'Naturally ripened sweet Cavendish bananas rich in potassium and fiber.',
    120,
    99,
    'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500&auto=format&fit=crop&q=80',
    '22222222-2222-2222-2222-222222222222',
    40,
    'dozen',
    4.8,
    19,
    true,
    true
  ),
  (
    'a5555555-5555-5555-5555-555555555555',
    'Artisan Sourdough Loaf',
    'Freshly baked daily using slow-fermented organic flour. Crispy crust and soft airy crumb.',
    190,
    160,
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80',
    '44444444-4444-4444-4444-444444444444',
    20,
    'piece',
    4.6,
    15,
    false,
    true
  ),
  (
    'a6666666-6666-6666-6666-666666666666',
    'Farm Fresh Eggs (12 pcs)',
    'Grade A clean white shell organic eggs from pasture-raised hens.',
    250,
    NULL,
    'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=500&auto=format&fit=crop&q=80',
    '33333333-3333-3333-3333-333333333333',
    45,
    'dozen',
    4.9,
    64,
    true,
    true
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  price = EXCLUDED.price,
  discount_price = EXCLUDED.discount_price,
  stock = EXCLUDED.stock;

-- ==============================================================================
-- HOW TO PROMOTE A USER TO ADMIN:
-- Run this query with the target user's email:
-- UPDATE public.profiles SET user_type = 1 WHERE email = 'your_admin_email@example.com';
-- ==============================================================================

