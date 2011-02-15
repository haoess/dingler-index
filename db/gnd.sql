CREATE TABLE gnd (
    id        SERIAL PRIMARY KEY,
    subject   TEXT,
    predicate TEXT,
    object    TEXT
);

CREATE INDEX gnd_object_index ON gnd USING btree (object text_pattern_ops);
CREATE INDEX gnd_predicate_index ON gnd USING btree (predicate text_pattern_ops);
CREATE INDEX gnd_subject_index ON gnd USING btree (subject text_pattern_ops);
