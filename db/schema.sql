DROP TABLE IF EXISTS journal CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS figure CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS personref CASCADE;
DROP TABLE IF EXISTS footnote CASCADE;
DROP TABLE IF EXISTS patent CASCADE;
DROP TABLE IF EXISTS patent_app CASCADE;

CREATE OR REPLACE FUNCTION hex_to_int(hexval varchar) RETURNS integer AS $$
DECLARE
   result  int;
BEGIN
 EXECUTE 'SELECT x''' || hexval || '''::int' INTO result;
 RETURN result;
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE STRICT;


CREATE OR REPLACE FUNCTION find_in_array( needle anyelement, haystack anyarray) RETURNS integer AS $$
DECLARE
  i integer;
BEGIN
  for i in 1..array_upper(haystack, 1) loop
    if haystack[i] = needle then
      return i;
    end if;
  end loop;
  raise exception 'find_in_array: % not found in %', needle, haystack;
END;
$$ LANGUAGE 'plpgsql';

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
  uid       SERIAL PRIMARY KEY,
  id        TEXT,
  parent    INTEGER REFERENCES article (uid),
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
  position  INT
);

-- --------------------------

CREATE TABLE footnote (
  id      SERIAL PRIMARY KEY,
  n       TEXT,
  article INTEGER REFERENCES article (uid),
  content TEXT
);

-- --------------------------

-- all images associated with an article
--  #figXXXYYY_ZZZ => vol. XXX, tab. YYY, fig. ZZZ
--  #tabXXXYYY     => vol. XXX, tab. YYY
--  #txXXXYYY      => vol. XXX, fig. YYY

CREATE TABLE figure (
  article INTEGER REFERENCES article(uid),
  ref     TEXT,
  reftype TEXT,
  PRIMARY KEY (article, ref)
);

-- --------------------------

CREATE TABLE person (
  uid      SERIAL PRIMARY KEY,
  id       TEXT UNIQUE,
  rolename TEXT,
  addname  TEXT,
  forename TEXT,
  namelink TEXT,
  surname  TEXT,
  pnd      TEXT,
  viaf     TEXT
);

-- --------------------------

CREATE TABLE personref (
  id   TEXT REFERENCES person (id),
  ref  INTEGER REFERENCES article (uid),
  role TEXT,
  PRIMARY KEY (id, ref, role)
);

-- --------------------------

CREATE TABLE patent (
  id      TEXT PRIMARY KEY,
  article INTEGER REFERENCES article (uid),
  subtype TEXT,
  date    DATE,
  xml     TEXT,
  content TEXT,
  title   TEXT,
  place   TEXT
);

-- --------------------------

CREATE TABLE patent_app (
  id       SERIAL PRIMARY KEY,
  patent   TEXT REFERENCES patent (id),
  personid TEXT,
  name     TEXT
);
