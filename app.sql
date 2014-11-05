--db:app
--{{{
CREATE SCHEMA IF NOT EXISTS app;

CREATE OR REPLACE FUNCTION
app.is_proc_exists(name text) RETURNS boolean
LANGUAGE sql AS $$
SELECT EXISTS (
  SELECT * FROM pg_proc WHERE proname = name
)
$$;

CREATE OR REPLACE FUNCTION
app.openresty(req jsonb)
RETURNS jsonb
LANGUAGE plpgsql AS $$
DECLARE
  proc_name varchar;
  proc varchar;
  res jsonb;
BEGIN
  proc_name = quote_ident(lower(req->>'meth') || '_action_' || split_part(req->>'uri', '/', 3));
  proc = 'SELECT app.' || proc_name || '($1)';
  RAISE NOTICE '%', proc_name;
  IF proc_name <> '' AND app.is_proc_exists(proc_name) THEN
    EXECUTE proc INTO res USING req;
    RETURN res;
  ELSE
    RETURN json_build_object('error', ('[' || proc_name || '] not exists'), 'status', 500);
  END IF;
END
$$;

CREATE OR REPLACE FUNCTION
app.get_action_echo(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
 SELECT req
$$;


CREATE OR REPLACE FUNCTION
app.get_action_procs(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT json_agg(pg_proc.*)::jsonb
  FROM pg_proc WHERE proname ilike '%_action_%'
$$;

CREATE OR REPLACE FUNCTION
app.get_action_tables(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT json_agg(t.*)::jsonb
  FROM information_schema.tables t;
$$;

CREATE OR REPLACE FUNCTION
app.get_action_series(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT json_agg(generate_series)::jsonb
  FROM generate_series(1,100);
$$;

CREATE OR REPLACE FUNCTION
app.get_action_countries(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT json_agg(c.*)::jsonb
  FROM countries c
  where title ilike coalesce(req#>>'{params,q}', '') || '%'
$$;

CREATE OR REPLACE FUNCTION
app.get_action_columns(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  select coalesce(json_agg(c.*)::jsonb, req)
  from information_schema.columns c
  where table_schema = req#>>'{params,s}'
  and table_name = req#>>'{params,t}'
$$;

CREATE OR REPLACE FUNCTION
app.get_action_migrations(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT coalesce(json_agg(m.*)::jsonb, '[]'::jsonb)
  FROM migrations m
$$;

CREATE OR REPLACE FUNCTION
app.post_action_migrations(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
 WITH inser AS (
   INSERT INTO migrations (up, down)
   VALUES (
      ((req#>>'{request_body, data}')::jsonb)->>'up',
      ((req#>>'{request_body, data}')::jsonb)->>'down'
   )
   RETURNING *
 )
 SELECT json_agg(i.*)::jsonb
   FROM inser i;
$$;

CREATE OR REPLACE FUNCTION
app.post_action_migration_up(req jsonb) RETURNS jsonb
LANGUAGE plpgsql AS $$
DECLARE
  mg text;
  res text;
BEGIN
  raise notice 'req: %', req;
  SELECT m.up into mg from migrations m
  where id = (req#>>'{request_body, params,id}')::integer
  limit 1;
  EXECUTE mg;
  RETURN json_build_object('sql', mg::text);
END;
$$;

--}}}
--{{{
select app.post_action_migration_up('{"params":{"id":1}}'::jsonb);
--}}}

--{{{
select * from migrations;
--}}}

--{{{
\set seed `pwd`/'seeds/countries.txt'

create table countries (code varchar(2), title varchar(255));

COPY countries FROM
:'seed' DELIMITER '|' CSV;
--}}}
--{{{
select lower('UPS');
--}}}

--}}}
--{{{
drop table migrations;
create table migrations (
  id serial primary key,
  done boolean,
  up text,
  down text
);
--}}}
--{{{
do $$
begin
  begin
    create table yyy(a int);
    create table yyy(a int); -- this will cause an error
  exception when others then
    raise notice 'The transaction is in an uncommittable state. '
    'Transaction was rolled back';
    raise notice '% %', SQLERRM, SQLSTATE;
  end;
  raise notice 'Thats ok';
end;
$$ language 'plpgsql';
--}}}
--{{{
select json_agg(c.*)
from information_schema.columns c
where table_schema = 'public'
and table_name = 'migrations'
--}}}
