DROP TABLE IF EXISTS journal CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS figure CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP FUNCTION IF EXISTS article_trigger();
DROP FUNCTION IF EXISTS article_title_trigger();
DROP TABLE IF EXISTS footnote CASCADE;
DROP FUNCTION IF EXISTS footnote_trigger();
DROP TABLE IF EXISTS patent CASCADE;
DROP FUNCTION IF EXISTS patent_trigger();
DROP TABLE IF EXISTS patent_app CASCADE;

-- --------------------------

CREATE TABLE journal (
  id        TEXT PRIMARY KEY,
  volume    TEXT,
  barcode   TEXT,
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
  tsv       TSVECTOR,
  titletsv  TSVECTOR
);

CREATE INDEX article_tsv_idx ON article USING gin(tsv);
CREATE INDEX article_titletsv_idx ON article USING gin(titletsv);

CREATE FUNCTION article_trigger() RETURNS trigger AS $$
begin
  new.tsv :=
     setweight(to_tsvector('german', coalesce(new.front,'')), 'A') ||
     setweight(to_tsvector('german', coalesce(new.content,'')), 'D');
  return new;
end
$$ LANGUAGE plpgsql;

CREATE FUNCTION article_title_trigger() RETURNS trigger AS $$
begin
  new.titletsv := to_tsvector('german', coalesce(new.front,''));
  return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON article FOR EACH ROW EXECUTE PROCEDURE article_trigger();

CREATE TRIGGER tsvectorupdate_title BEFORE INSERT OR UPDATE
ON article FOR EACH ROW EXECUTE PROCEDURE article_title_trigger();

-- --------------------------

CREATE TABLE footnote (
  id      SERIAL PRIMARY KEY,
  n       TEXT,
  article TEXT REFERENCES article (id),
  content TEXT,
  tsv     TSVECTOR
);

CREATE INDEX footnote_tsv_idx ON article USING gin(tsv);

CREATE FUNCTION footnote_trigger() RETURNS trigger AS $$
begin
  new.tsv := to_tsvector('german', coalesce(new.content,''));
  return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON footnote FOR EACH ROW EXECUTE PROCEDURE footnote_trigger();

-- --------------------------

-- all images associated with an article
--  #figXXXYYY_ZZZ => vol. XXX, tab. YYY, fig. ZZZ
--  #tabXXXYYY     => vol. XXX, tab. YYY
--  #txXXXYYY      => vol. XXX, fig. YYY

CREATE TABLE figure (
  article TEXT REFERENCES article(id),
  ref     TEXT,
  reftype TEXT,
  PRIMARY KEY (article, ref)
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
