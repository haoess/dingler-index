CREATE TABLE journal (
  id TEXT PRIMARY KEY
);

CREATE TABLE article (
  id TEXT PRIMARY KEY,
  journal TEXT REFERENCES journal
);
