-- ============================================================
-- Saaleh OS — Supabase Schema
-- Creates the sync table for localStorage mirror and RLS.
-- ============================================================

-- 1. Create the sync table
CREATE TABLE IF NOT EXISTS public.sync (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key        TEXT NOT NULL,
  value      JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (user_id, key)
);

-- 2. Index for fast lookups per user
CREATE INDEX IF NOT EXISTS idx_sync_user_id ON public.sync(user_id);
CREATE INDEX IF NOT EXISTS idx_sync_user_key ON public.sync(user_id, key);

-- 3. Auto-update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON public.sync;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.sync
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- 4. Enable Row Level Security
ALTER TABLE public.sync ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies — users can only access their own rows
CREATE POLICY "Users can read own sync data"
  ON public.sync
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sync data"
  ON public.sync
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sync data"
  ON public.sync
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own sync data"
  ON public.sync
  FOR DELETE
  USING (auth.uid() = user_id);
