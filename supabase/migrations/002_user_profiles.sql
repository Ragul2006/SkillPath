-- Create learner_profiles table
CREATE TABLE IF NOT EXISTS public.learner_profiles (
  user_id UUID REFERENCES public.profiles(id) PRIMARY KEY,
  education_level TEXT,
  academic_score TEXT,
  interests TEXT[],
  skills TEXT[],
  preferred_industries TEXT[],
  salary_expectation TEXT,
  willing_to_relocate BOOLEAN DEFAULT FALSE
);

ALTER TABLE public.learner_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Learners can view their own profile" ON public.learner_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Learners can update their own profile" ON public.learner_profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- Create parent_profiles table
CREATE TABLE IF NOT EXISTS public.parent_profiles (
  user_id UUID REFERENCES public.profiles(id) PRIMARY KEY,
  learner_id UUID REFERENCES public.learner_profiles(user_id),
  concerns TEXT[],
  expectations JSONB
);

ALTER TABLE public.parent_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can view their own profile" ON public.parent_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Parents can update their own profile" ON public.parent_profiles
  FOR UPDATE USING (auth.uid() = user_id);
