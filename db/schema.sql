DROP TABLE IF EXISTS journal CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS figure CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP FUNCTION IF EXISTS article_trigger();

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
  journal   TEXT REFERENCES journal (id),
  type      TEXT,
  volume    TEXT,
  number    TEXT,
  title     TEXT,
  pagestart TEXT,
  pageend   TEXT,
  facsimile TEXT,
  content   TEXT,
  position  INT,
  tsv       TSVECTOR
);

CREATE INDEX article_tsv_idx ON article USING gin(tsv);

CREATE FUNCTION article_trigger() RETURNS trigger AS $$
begin
  new.tsv :=
     setweight(to_tsvector('german', coalesce(new.title,'')), 'A') ||
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
  id  TEXT,
  ref TEXT REFERENCES article (id),
  PRIMARY KEY (id, ref)
);
