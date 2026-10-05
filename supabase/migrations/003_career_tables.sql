-- trades
CREATE TABLE IF NOT EXISTS public.trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_tamil TEXT NOT NULL,
  description TEXT,
  description_tamil TEXT,
  nsqf_level INTEGER,
  sector TEXT,
  skills TEXT[]
);

-- career_roles
CREATE TABLE IF NOT EXISTS public.career_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trade_id UUID REFERENCES public.trades(id) NOT NULL,
  role_name TEXT NOT NULL,
  role_name_tamil TEXT NOT NULL,
  description TEXT,
  experience_level TEXT
);

-- career_paths
CREATE TABLE IF NOT EXISTS public.career_paths (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trade_id UUID REFERENCES public.trades(id) NOT NULL,
  step_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  title_tamil TEXT NOT NULL,
  description TEXT,
  next_step UUID
);

-- training_providers
CREATE TABLE IF NOT EXISTS public.training_providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  district TEXT,
  city TEXT,
  state TEXT DEFAULT 'Tamil Nadu',
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  phone TEXT,
  email TEXT,
  verified BOOLEAN DEFAULT FALSE
);

-- outcomes
CREATE TABLE IF NOT EXISTS public.outcomes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trade_id UUID REFERENCES public.trades(id) NOT NULL,
  provider_id UUID REFERENCES public.training_providers(id),
  district TEXT,
  placement_rate INTEGER,
  min_salary INTEGER,
  max_salary INTEGER,
  average_salary INTEGER,
  sample_size INTEGER,
  data_year INTEGER,
  verified BOOLEAN DEFAULT FALSE,
  source TEXT
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_trades_name ON public.trades(name);
CREATE INDEX IF NOT EXISTS idx_outcomes_trade_id ON public.outcomes(trade_id);
CREATE INDEX IF NOT EXISTS idx_career_paths_trade_id ON public.career_paths(trade_id);
CREATE INDEX IF NOT EXISTS idx_career_roles_trade_id ON public.career_roles(trade_id);

-- Apply RLS (read-only for all by default)
ALTER TABLE public.trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.career_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.career_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.training_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outcomes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access on trades" ON public.trades FOR SELECT USING (true);
CREATE POLICY "Allow public read access on career_roles" ON public.career_roles FOR SELECT USING (true);
CREATE POLICY "Allow public read access on career_paths" ON public.career_paths FOR SELECT USING (true);
CREATE POLICY "Allow public read access on training_providers" ON public.training_providers FOR SELECT USING (true);
CREATE POLICY "Allow public read access on outcomes" ON public.outcomes FOR SELECT USING (true);
