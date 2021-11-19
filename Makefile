IMAGE=jasmine-psql
VER=0.1
OPTS=
PSRC=build/table.sql build/user.sql build/extension.sql
PSQL=psql -h localhost -p 15432 -d jasmine -U admin
PGDUMP=docker-compose exec catalog pg_dump -d jasmine -U admin

.INTERMEDIATE: combined.sql
.PHONY: build-psql initialize

build-psql:
	docker build $(OPTS) -t $(IMAGE):$(VER) psql


combined.sql: $(PSRC)
	cat $(PSRC) > $@

initialize: combined.sql
	# $(PSQL) -f $<
	{ echo "BEGIN;"; $(PGDUMP) --section=pre-data; echo "COMMIT;"; } \
	    | tr -d '\r' > psql/sql/pg_dump.sql
	{ echo "BEGIN;"; $(PGDUMP) --section=post-data; echo "COMMIT;"; } \
	    | tr -d '\r' > psql/sql/pg_post.sql.temp