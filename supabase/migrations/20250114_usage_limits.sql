-- Create usage_limits table for tracking daily AI usage
CREATE TABLE IF NOT EXISTS public.usage_limits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Enable RLS (Row Level Security)
ALTER TABLE public.usage_limits ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own usage data
CREATE POLICY "Users can manage their own usage data" ON public.usage_limits
  FOR ALL USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX idx_usage_limits_user_date ON public.usage_limits (user_id, date);

-- Create function to increment usage count
CREATE OR REPLACE FUNCTION increment_usage_count(p_user_id UUID, p_date DATE)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  INSERT INTO public.usage_limits (user_id, date, usage_count)
  VALUES (p_user_id, p_date, 1)
  ON CONFLICT (user_id, date)
  DO UPDATE SET 
    usage_count = usage_limits.usage_count + 1,
    updated_at = NOW()
  RETURNING usage_count INTO v_count;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to get usage count
CREATE OR REPLACE FUNCTION get_usage_count(p_user_id UUID, p_date DATE)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT usage_count INTO v_count
  FROM public.usage_limits
  WHERE user_id = p_user_id AND date = p_date;
  
  RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql;