DROP TABLE IF EXISTS event_category;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS category;

CREATE TABLE event (
  id          SERIAL PRIMARY KEY,
  title       TEXT,
  startyear   INTEGER,
  startmonth  INTEGER,
  startday    INTEGER,
  endyear     INTEGER,
  endmonth    INTEGER,
  endday      INTEGER,
  link        TEXT,
  image       TEXT,
  description TEXT
);

CREATE TABLE category (
  id   SERIAL PRIMARY KEY,
  name TEXT
);

CREATE TABLE event_category (
  id       SERIAL PRIMARY KEY,
  event    INTEGER REFERENCES event (id) ON DELETE CASCADE,
  category INTEGER REFERENCES category (id) ON DELETE CASCADE
);
