CREATE TABLE ticket (
  id      INTEGER PRIMARY KEY,
  bugtype TEXT,
  article TEXT,
  ocrword TEXT,
  email   TEXT,
  note    TEXT,
  created DATETIME,
  changed DATETIME,
  status  TEXT,
  comment TEXT
);
