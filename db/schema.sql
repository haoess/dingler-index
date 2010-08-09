DROP TABLE IF EXISTS journal CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS figure CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP FUNCTION IF EXISTS article_trigger();
DROP TABLE IF EXISTS patent CASCADE;
DROP FUNCTION IF EXISTS patent_trigger();
DROP TABLE IF EXISTS patent_app CASCADE;

-- --------------------------

CREATE TABLE journal (
  id        TEXT PRIMARY KEY,
  volume    TEXT,
  year      TEXT,
  facsimile TEXT
);

-- --------------------------

CREATE TABLE article (
  id        TEXT PRIMARY KEY,
  parent    TEXT REFERENCES article (id),
  journal   TEXT REFERENCES journal (id),
  type      TEXT,
  subtype   TEXT,
  volume    TEXT,
  number    TEXT,
  title     TEXT,
  pagestart TEXT,
  pageend   TEXT,
  facsimile TEXT,
  front     TEXT,
  content   TEXT,
  position  INT,
  tsv       TSVECTOR
);

CREATE INDEX article_tsv_idx ON article USING gin(tsv);

CREATE FUNCTION article_trigger() RETURNS trigger AS $$
begin
  new.tsv :=
     setweight(to_tsvector('german', coalesce(new.front,'')), 'A') ||
     setweight(to_tsvector('german', coalesce(new.content,'')), 'D');
  return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON article FOR EACH ROW EXECUTE PROCEDURE article_trigger();

-- --------------------------

CREATE TABLE figure (
  id      SERIAL PRIMARY KEY,
  article TEXT REFERENCES article(id),
  url     TEXT
);

-- --------------------------

CREATE TABLE person (
  id   TEXT,
  ref  TEXT REFERENCES article (id),
  role TEXT,
  PRIMARY KEY (id, ref)
);

-- --------------------------

CREATE TABLE patent (
  id      TEXT PRIMARY KEY,
  article TEXT REFERENCES article (id),
  subtype TEXT,
  date    DATE,
  xml     TEXT,
  content TEXT,
  tsv     TSVECTOR
);

CREATE INDEX patent_tsv_idx ON patent USING gin(tsv);

CREATE FUNCTION patent_trigger() RETURNS trigger AS $$
begin
  new.tsv := to_tsvector('german', coalesce(new.content,''));
  return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON patent FOR EACH ROW EXECUTE PROCEDURE patent_trigger();

-- --------------------------

CREATE TABLE patent_app (
  id       SERIAL PRIMARY KEY,
  patent   TEXT REFERENCES patent (id),
  personid TEXT,
  name     TEXT
);
