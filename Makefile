IMAGE=jasmine-psql
VER=0.1
OPTS=
PSRC=build/extension.sql \
     build/table.sql \
     build/sirius.sql \
     build/merge.sql \
     build/user.sql
PSQL=psql -h localhost -p 15432 -d jasmine -U admin
PGDUMP=docker-compose exec catalog pg_dump -d jasmine -U admin

.INTERMEDIATE: combined.sql
.PHONY: build-psql initialize dump index link

build-psql:
	docker build $(OPTS) -t $(IMAGE):$(VER) psql


combined.sql: $(PSRC)
	cat $(PSRC) > $@

initialize: combined.sql
	$(PSQL) -f $<

index: bulid/index.sql
	$(PSQL) -f $<

link: build/link.sql
	$(PSQL) -f $<

psql/sql/pg_dump.sql:
	{ echo "BEGIN;"; $(PGDUMP) --section=pre-data; echo "COMMIT;"; } \
	    | tr -d '\r' > psql/sql/pg_dump.sql

psql/sql/pg_post.sql.temp:
	{ echo "BEGIN;"; $(PGDUMP) --section=post-data; echo "COMMIT;"; } \
	    | tr -d '\r' > psql/sql/pg_post.sql.temp

dump: psql/sql/pg_dump.sql psql/sql/pg_post.sql.temp


test:
	mkdocs serve

update:
	mkdocs gh-deploy
