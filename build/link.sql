DROP TABLE IF EXISTS link_edr3 CASCADE;
CREATE TABLE link_edr3 (
  link_id          BIGSERIAL PRIMARY KEY,
  merged_source_id BIGINT NOT NULL,
  edr3_source_id   BIGINT NOT NULL,
  distance         FLOAT(10) NOT NULL
);

ALTER TABLE link_edr3 ADD CONSTRAINT
  FK_link_edr3_0 FOREIGN KEY (merged_source_id)
  REFERENCES merged_sources (source_id) ON DELETE CASCADE;
ALTER TABLE link_edr3 ADD CONSTRAINT
  FK_link_edr3_1 FOREIGN KEY (edr3_source_id)
  REFERENCES edr3_sources (source_id) ON DELETE CASCADE;


INSERT INTO link_edr3
  (merged_source_id,edr3_source_id,distance)
SELECT
  m.source_id AS merged_source_id,
  g.source_id AS edr3_source_id,
  3600.0*q3c_dist(m.ra,m.dec,g.ra,g.dec) AS distance
FROM
  edr3_sources AS g
JOIN
  merged_sources AS m
ON
  q3c_join(g.glon,g.glat,m.glon,m.glat,1.0/3600.0);

CREATE INDEX IF NOT EXISTS link_edr3_merged_source_id
  ON link_edr3 (merged_source_id);
CREATE INDEX IF NOT EXISTS link_edr3_edr3_source_id
  ON link_edr3 (edr3_source_id);
CLUSTER link_edr3_merged_source_id ON link_edr3;
ANALYZE link_edr3;
