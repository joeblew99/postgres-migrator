--*************************************************************************************************
-- Description  : Terminate connections to PostgreSQL database
-- Authors      : Pawel Kasperek
--                  Copyright 2017 by DAC Software
-- Comment      : Patch for restrore EDP databases 
--*************************************************************************************************

SET search_path=public,pg_catalog;
SET client_encoding = 'UTF8';
SET client_min_messages = warning;

----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ Change procid to pid in pg_stat_activity -----------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pge_terminate_backend(is_current_backend boolean DEFAULT true)
  	RETURNS void AS
$BODY$
DECLARE
	backend_rec record;
BEGIN
	FOR backend_rec IN SELECT * FROM pg_stat_activity WHERE pid <> pg_backend_pid()
	LOOP
		PERFORM pg_terminate_backend(backend_rec.pid);
	END LOOP;

	IF (is_current_backend) THEN
		PERFORM pg_terminate_backend((SELECT p.pid FROM pg_stat_activity p WHERE p.pid = pg_backend_pid() LIMIT 1)::integer);
	END IF;
	
	RETURN;
END;
$BODY$
	LANGUAGE plpgsql VOLATILE
	COST 100;
ALTER FUNCTION public.pge_terminate_backend(boolean)
  	OWNER TO postgres;
COMMENT ON FUNCTION public.pge_terminate_backend(boolean) IS 'Terminated all backend processes.';

----------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pge_terminate_backend_to_db(dbnames text[], is_current_backend boolean DEFAULT true)
	RETURNS void AS
$BODY$
DECLARE
	backend_rec record;
BEGIN
	FOR backend_rec IN SELECT p.* FROM pg_stat_activity p, unnest(dbnames) AS db WHERE p.datname=db AND p.pid <> pg_backend_pid()
	LOOP
		PERFORM pg_terminate_backend(backend_rec.pid);
	END LOOP;

	IF (is_current_backend) THEN
		PERFORM pg_terminate_backend((SELECT p.pid FROM pg_stat_activity p, unnest(dbnames) AS db WHERE p.datname=db and p.pid = pg_backend_pid() LIMIT 1)::integer);
	END IF;

	RETURN;
END;
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
ALTER FUNCTION public.pge_terminate_backend_to_db(text[], boolean)
	OWNER TO postgres;
COMMENT ON FUNCTION public.pge_terminate_backend_to_db(text[], boolean) IS 'Terminated all backend processes to set databases.';

----------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.pge_terminate_backend_to_db(is_current_backend boolean DEFAULT true)
	RETURNS void AS
$BODY$
DECLARE
	backend_rec record;
BEGIN
	FOR backend_rec IN SELECT p.* FROM pg_stat_activity p WHERE p.datname=current_catalog and p.pid <> pg_backend_pid()
	LOOP
		PERFORM pg_terminate_backend(backend_rec.pid);
	END LOOP;

	IF (is_current_backend) THEN
		PERFORM pg_terminate_backend((SELECT p.pid FROM pg_stat_activity p WHERE p.datname=current_catalog and p.pid = pg_backend_pid() LIMIT 1)::integer);
	END IF;

	RETURN;
END;
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
ALTER FUNCTION public.pge_terminate_backend_to_db(boolean)
	OWNER TO postgres;
COMMENT ON FUNCTION public.pge_terminate_backend_to_db(boolean) IS 'Terminated all backend processes to current database.';

----------------------------------------------------------------------------------------------------------------------------------
