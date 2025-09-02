-- Supabase Schema for Juey App
-- Run this in Supabase SQL Editor to set up the database

-- Enable UUID extension if not already
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  tag_ids TEXT[] DEFAULT '{}', -- Array of tag IDs
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  is_completed BOOLEAN DEFAULT FALSE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Tags table
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  color TEXT NOT NULL, -- Hex color code
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Suggestions table
CREATE TABLE suggestions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  suggested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  accepted BOOLEAN -- NULL for pending, TRUE for accepted, FALSE for rejected
);

-- Patterns table
CREATE TABLE patterns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  frequency TEXT NOT NULL, -- e.g., 'daily', 'weekly', 'monthly'
  last_done TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  total_count INTEGER DEFAULT 1,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Profiles table (for usernames and avatars, linked to Supabase auth)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE,
  avatar_url TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
CREATE INDEX idx_tags_user_id ON tags(user_id);
CREATE INDEX idx_suggestions_user_id ON suggestions(user_id);
CREATE INDEX idx_patterns_user_id ON patterns(user_id);
CREATE INDEX idx_patterns_task_id ON patterns(task_id);

-- Row Level Security (RLS) policies (assuming Supabase auth)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE patterns ENABLE ROW LEVEL SECURITY;

-- Policies: Users can only access their own data
CREATE POLICY tasks_policy ON tasks FOR ALL USING (auth.uid() = user_id);
CREATE POLICY tags_policy ON tags FOR ALL USING (auth.uid() = user_id);
CREATE POLICY suggestions_policy ON suggestions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY patterns_policy ON patterns FOR ALL USING (auth.uid() = user_id);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_policy ON profiles FOR ALL USING (auth.uid() = id);
