DROP TABLE IF EXISTS admin;
DROP TABLE IF EXISTS event_category;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS category;

CREATE TABLE admin (
  id        SERIAL PRIMARY KEY,
  username  TEXT,
  email     TEXT,
  passwd    TEXT,
  lastlogin TIMESTAMP,
  created   TIMESTAMP
);
insert into admin (username, passwd) values ('fw', 'b382dadad7873325694ea95e82f6df24a9f92d4d');

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
