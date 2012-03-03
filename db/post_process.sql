CREATE TABLE gbpatents ( id serial, date date, patent_id integer, patent_app text, patent_title text, patent_category text );
COPY gbpatents (date, patent_id, patent_app, patent_title, patent_category) FROM '/home/fw/src/kuwi/dingler/database/patents/gb-patents.csv' WITH CSV DELIMITER AS '|';
