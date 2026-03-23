-- ============================================
-- Kuttiyattel Family Tree Database Schema
-- ============================================

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Table: persons
-- ============================================
CREATE TABLE IF NOT EXISTS persons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  gender TEXT,
  dob DATE,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments for documentation
COMMENT ON TABLE persons IS 'Stores information about family members';
COMMENT ON COLUMN persons.id IS 'Unique identifier for each person';
COMMENT ON COLUMN persons.name IS 'Full name of the person';
COMMENT ON COLUMN persons.gender IS 'Gender (Male/Female/Other)';
COMMENT ON COLUMN persons.dob IS 'Date of birth';
COMMENT ON COLUMN persons.photo_url IS 'URL to profile photo stored in Supabase Storage';
COMMENT ON COLUMN persons.created_at IS 'Record creation timestamp';

-- ============================================
-- Table: relationships
-- ============================================
CREATE TABLE IF NOT EXISTS relationships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  parent_id UUID REFERENCES persons(id) ON DELETE CASCADE,
  child_id UUID REFERENCES persons(id) ON DELETE CASCADE
);

-- Add comments
COMMENT ON TABLE relationships IS 'Stores parent-child relationships between persons';
COMMENT ON COLUMN relationships.parent_id IS 'Reference to parent person';
COMMENT ON COLUMN relationships.child_id IS 'Reference to child person';

-- ============================================
-- Indexes (CRITICAL for performance)
-- ============================================
CREATE INDEX IF NOT EXISTS idx_parent ON relationships(parent_id);
CREATE INDEX IF NOT EXISTS idx_child ON relationships(child_id);

-- Composite index for faster lookups
CREATE INDEX IF NOT EXISTS idx_relationships_parent_child 
ON relationships(parent_id, child_id);

-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Enable RLS on tables
ALTER TABLE persons ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all data
CREATE POLICY "Allow authenticated users to read persons"
  ON persons FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert persons"
  ON persons FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update persons"
  ON persons FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to delete persons"
  ON persons FOR DELETE
  TO authenticated
  USING (true);

-- Relationships policies
CREATE POLICY "Allow authenticated users to read relationships"
  ON relationships FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert relationships"
  ON relationships FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update relationships"
  ON relationships FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to delete relationships"
  ON relationships FOR DELETE
  TO authenticated
  USING (true);

-- ============================================
-- Sample Data (for testing)
-- ============================================

-- Insert grandfather (root)
INSERT INTO persons (id, name, gender, dob) VALUES 
('00000000-0000-0000-0000-000000000001', 'Grandfather Name', 'Male', '1950-01-15');

-- Insert grandmother
INSERT INTO persons (id, name, gender, dob) VALUES 
('00000000-0000-0000-0000-000000000002', 'Grandmother Name', 'Female', '1955-03-20');

-- Insert father (child of grandfather)
INSERT INTO persons (id, name, gender, dob) VALUES 
('00000000-0000-0000-0000-000000000003', 'Father Name', 'Male', '1975-06-10');

-- Insert mother
INSERT INTO persons (id, name, gender, dob) VALUES 
('00000000-0000-0000-0000-000000000004', 'Mother Name', 'Female', '1980-08-25');

-- Insert child (you)
INSERT INTO persons (id, name, gender, dob) VALUES 
('00000000-0000-0000-0000-000000000005', 'Your Name', 'Male', '2000-12-01');

-- Create relationships
-- Grandfather -> Father
INSERT INTO relationships (parent_id, child_id) VALUES 
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003');

-- Father -> You
INSERT INTO relationships (parent_id, child_id) VALUES 
('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000005');

-- ============================================
-- Useful Queries (for reference)
-- ============================================

-- Find root persons (those who are not children of anyone)
-- SELECT * FROM persons
-- WHERE id NOT IN (SELECT child_id FROM relationships);

-- Find all children of a specific person
-- SELECT p.* FROM persons p
-- INNER JOIN relationships r ON p.id = r.child_id
-- WHERE r.parent_id = '00000000-0000-0000-0000-000000000001';

-- Find all ancestors of a person (recursive)
-- WITH RECURSIVE ancestors AS (
--   SELECT p.*, r.parent_id
--   FROM persons p
--   INNER JOIN relationships r ON p.id = r.child_id
--   WHERE r.child_id = '00000000-0000-0000-0000-000000000005'
--   UNION ALL
--   SELECT p.*, r.parent_id
--   FROM persons p
--   INNER JOIN relationships r ON p.id = r.child_id
--   INNER JOIN ancestors a ON r.parent_id = a.parent_id
-- )
-- SELECT * FROM ancestors;
