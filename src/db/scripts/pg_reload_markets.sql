
--*************************************************************************************************
-- Description  : Replace contacts mail addresses in PostgreSQL database
-- Authors      : Pawel Kasperek
--                  Copyright 2017 by DAC Software
-- Comment      : Patch restore EDP databases 
--*************************************************************************************************

SET search_path=public,pg_catalog;
SET client_encoding = 'UTF8';
SET client_min_messages = warning;

----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ access.replace_partner_contact_mail() -------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS offers.reload_markets();
DROP FUNCTION IF EXISTS offers.reload_markets(p_environment text);

CREATE OR REPLACE FUNCTION offers.reload_markets(p_environment text)
	RETURNS void AS
$BODY$
DECLARE 
	marketrec record;
BEGIN
	FOR marketrec IN SELECT * FROM offers.markets
	LOOP
		-- QARSON FRANCE market
		IF (marketrec.prefix = 'qarson.fr') THEN
			IF (p_environment = 'production') THEN
				UPDATE offers.markets SET link_template='http://qarson.fr/o/S{0}.{1}', revision=revision+1 WHERE market_id=marketrec.market_id;
			ELSE
				UPDATE offers.markets SET link_template='http://www.qarson.fr.rc.e-d-p.net/o/S{0}.{1}?hash={2}', revision=revision+1 WHERE market_id=marketrec.market_id;
			END IF;
		END IF;

		-- EDPAUTO FRANCE Market
		IF (marketrec.prefix = 'edpauto.fr') THEN
			IF (p_environment = 'production') THEN
				UPDATE offers.markets SET link_template='http://www.edpauto.fr/o/S{0}.{1}', revision=revision+1 WHERE market_id=marketrec.market_id;
			ELSE
				UPDATE offers.markets SET link_template='http://www.edpauto.fr.rc.e-d-p.net/o/S{0}.{1}?hash={2}', revision=revision+1 WHERE market_id=marketrec.market_id;
			END IF;
		END IF;

		-- QARSON GERMANY market
		IF (marketrec.prefix = 'qarson.de') THEN
			IF (p_environment = 'production') THEN
				UPDATE offers.markets SET link_template='http://qarson.de/o/S{0}.{1}?hash={2}', revision=revision+1 WHERE market_id=marketrec.market_id;
			ELSE
				UPDATE offers.markets SET link_template='http://www.qarson.de.rc.e-d-p.net/o/S{0}.{1}?hash={2}', revision=revision+1 WHERE market_id=marketrec.market_id;
			END IF;
		END IF;
		
		-- EDPAUTO GERMANY Market
		IF (marketrec.prefix = 'edpauto.de') THEN
			IF (p_environment = 'production') THEN
				UPDATE offers.markets SET link_template='http://www.edpauto.de:69/o/S{0}.{1}?hash={2}', revision=revision+1 WHERE market_id=marketrec.market_id;
			ELSE
				UPDATE offers.markets SET link_template='http://www.edpauto.de.rc.edp/o/S{0}.{1}?hash={2}', revision=revision+1 WHERE market_id=marketrec.market_id;
			END IF;
		END IF;

	END LOOP;

    RETURN;
END;
$BODY$
	LANGUAGE plpgsql VOLATILE STRICT
	COST 100;
ALTER FUNCTION offers.reload_markets(p_environment text)
	OWNER TO postgres;
GRANT EXECUTE ON FUNCTION offers.reload_markets(p_environment text) TO postgres;
GRANT EXECUTE ON FUNCTION offers.reload_markets(p_environment text) TO public;
GRANT EXECUTE ON FUNCTION offers.reload_markets(p_environment text) TO offers;
GRANT EXECUTE ON FUNCTION offers.reload_markets(p_environment text) TO pguser;
COMMENT ON FUNCTION offers.reload_markets(p_environment text) IS 'This temporary procedure to reload markets settings.';
----------------------------------------------------------------------------------------------------------------------------------