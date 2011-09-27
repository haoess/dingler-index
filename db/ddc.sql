CREATE TABLE ddc (
    id        SERIAL PRIMARY KEY,
    subject   TEXT,
    predicate TEXT,
    object    TEXT
);

CREATE INDEX ddc_object_index ON ddc USING btree (object text_pattern_ops);
CREATE INDEX ddc_predicate_index ON ddc USING btree (predicate text_pattern_ops);
CREATE INDEX ddc_subject_index ON ddc USING btree (subject text_pattern_ops);
