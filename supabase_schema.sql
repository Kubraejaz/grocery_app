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

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile and admins to read all profiles
CREATE POLICY "Allow users to read profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1
  ));

-- Allow users to update their own profile
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
CREATE POLICY "Public read active products"
  ON public.products FOR SELECT
  USING (is_active = TRUE OR EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1
  ));

-- Only Admin can INSERT products
CREATE POLICY "Admin insert products"
  ON public.products FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1)
  );

-- Only Admin can UPDATE products
CREATE POLICY "Admin update products"
  ON public.products FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1)
  );

-- Only Admin can DELETE products
CREATE POLICY "Admin delete products"
  ON public.products FOR DELETE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1)
  );

-- 5. ORDER MANAGEMENT PERMISSIONS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Customers can view their own orders; Admins can view ALL orders
CREATE POLICY "View orders policy"
  ON public.orders FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1)
  );

-- Customers can insert their orders
CREATE POLICY "Customer insert orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Only Admins can update order status
CREATE POLICY "Admin update orders status"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND user_type = 1)
  );

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
-- HOW TO PROMOTE A USER TO ADMIN:
-- Run this query with the target user's email:
-- UPDATE public.profiles SET user_type = 1 WHERE email = 'your_admin_email@example.com';
-- ==============================================================================

