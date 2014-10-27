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
  proc_name = quote_ident('action_' || split_part(req->>'uri', '/', 3));
  proc = 'SELECT app.' || proc_name || '($1)';
  IF proc_name <> '' AND app.is_proc_exists(proc_name) THEN
    EXECUTE proc INTO res USING req;
    RETURN res;
  ELSE
    RETURN json_build_object('error', ('[' || proc_name || '] not exists'), 'status', 500);
  END IF;
END
$$;

CREATE OR REPLACE FUNCTION
app.action_echo(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
 SELECT req
$$;


CREATE OR REPLACE FUNCTION
app.action_procs(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT json_agg(pg_proc.*)::jsonb
  FROM pg_proc WHERE proname ilike 'action_%'
$$;

CREATE OR REPLACE FUNCTION
app.action_series(req jsonb) RETURNS jsonb
LANGUAGE sql AS $$
  SELECT json_agg(generate_series)::jsonb
  FROM generate_series(1,100);
$$;


--}}}
