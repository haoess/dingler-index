COPY place (plid, place, latitude, longitude) FROM '/home/fw/src/kuwi/dingler/database/places/places.csv' WITH CSV DELIMITER AS '|';

CREATE TABLE gbpatents ( id serial, date date, patent_id integer, patent_app text, patent_title text, patent_category text );
