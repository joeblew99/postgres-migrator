--*************************************************************************************************
-- Description  : Audit of changes in PostgreSQL database
-- Authors      : Pawel Kasperek
--                  Copyright 2017 by DAC Software
-- Comment      : Patch restore EDP databases 
--*************************************************************************************************

SET search_path=public,pg_catalog;
SET client_encoding = 'UTF8';
SET client_min_messages = warning;

----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ TABLES: audit.lgo ---------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
-- DROP OLD TABLES
DROP TABLE IF EXISTS audit.logs_audit;
DROP TABLE IF EXISTS audit.logs_tables_events;
DROP TABLE IF EXISTS audit.logs_fields_values;
DROP TABLE IF EXISTS audit.logs;
	
-- CREATE PARENT TABLE logs
CREATE TABLE audit.logs
(
    log_on timestamp with time zone NOT NULL DEFAULT ('now'::text)::timestamp(6) with time zone, -- Log event time on destination server
    log_on_time timestamp with time zone NOT NULL DEFAULT clock_timestamp(), 
    catalog_name text NOT NULL DEFAULT current_database(),
    inet_server inet NOT NULL DEFAULT inet_server_addr(),
    log_session_user text NOT NULL DEFAULT "session_user"(),
    log_current_user text NOT NULL DEFAULT "current_user"(),
    backend_pid integer NOT NULL DEFAULT pg_backend_pid()
)
WITH (
    OIDS=FALSE
);
ALTER TABLE audit.logs OWNER TO postgres;
COMMENT ON TABLE audit.logs IS 'An abstract table stored logs for errors during logging to main logs table.';
COMMENT ON COLUMN audit.logs.log_on IS 'The date of logging changes';
COMMENT ON COLUMN audit.logs.log_on_time IS 'Log event clock time';
COMMENT ON COLUMN audit.logs.catalog_name IS 'The database catalog name on destination server';
COMMENT ON COLUMN audit.logs.inet_server IS 'The database server address on destination server';
COMMENT ON COLUMN audit.logs.log_session_user IS 'The session user on destination server';
COMMENT ON COLUMN audit.logs.log_current_user IS 'The current user on destination server';
COMMENT ON COLUMN audit.logs.backend_pid IS 'The backend pid on destination server';

--CREATE TABLE audit.logs_tables_events
CREATE TABLE audit.logs_tables_events
(
    id bigserial, 	
    call_log_on timestamp with time zone,
    call_server_version text,
    call_inet_server inet,
    call_inet_client inet,
    call_user text,
    call_url text,
    call_application text,
    call_target text,
    call_session text,
    audit audit.audit_type,
    database_name text,
    table_space text,
    table_schema text,
    table_name text,
    table_oid oid,
    constraint_key text[],
    constraint_key_ref text[],
    revision text
)
INHERITS (audit.logs)
WITH (
    OIDS=FALSE
);
ALTER TABLE audit.logs_tables_events OWNER TO postgres;
COMMENT ON TABLE audit.logs_tables_events IS 'A table store information about audit operation type.';
COMMENT ON COLUMN audit.logs_tables_events.id IS 'Log internal identifier';
COMMENT ON COLUMN audit.logs_tables_events.call_log_on IS 'Log event time on call database server';
COMMENT ON COLUMN audit.logs_tables_events.call_server_version IS 'The database version on call server';
COMMENT ON COLUMN audit.logs_tables_events.call_inet_server IS 'The database server address on call server';
COMMENT ON COLUMN audit.logs_tables_events.call_inet_client IS 'The database client address on call server';
COMMENT ON COLUMN audit.logs_tables_events.call_user IS 'The client logging user (in many situation is the database user) that execute current context.';
COMMENT ON COLUMN audit.logs_tables_events.call_url IS 'The url of application from was executed current context.';
COMMENT ON COLUMN audit.logs_tables_events.call_application IS 'The name of application from was executed current context.';
COMMENT ON COLUMN audit.logs_tables_events.call_target IS 'The target on call server';
COMMENT ON COLUMN audit.logs_tables_events.call_session IS 'The session on call server';
COMMENT ON COLUMN audit.logs_tables_events.audit IS 'The type of table audit. This field should be values: 1-INSERT, 2-UPDATE, 3-DELETE, 4-VISIBILITY';
COMMENT ON COLUMN audit.logs_tables_events.database_name IS 'The database name on call server';
COMMENT ON COLUMN audit.logs_tables_events.table_space IS 'The tablespace name of logged table values.';
COMMENT ON COLUMN audit.logs_tables_events.table_schema IS 'The schema name of logged table values.';
COMMENT ON COLUMN audit.logs_tables_events.table_name IS 'The logged table name value.';
COMMENT ON COLUMN audit.logs_tables_events.table_oid IS 'The logged table oid number.';
COMMENT ON COLUMN audit.logs_tables_events.constraint_key IS 'The array of changed table unique identifiers (constraint keys) names.';
COMMENT ON COLUMN audit.logs_tables_events.constraint_key_ref IS 'The array of changed table unique identifiers (constraint keys) values.';
COMMENT ON COLUMN audit.logs_tables_events.revision IS 'The value of a row version.';

CREATE INDEX logs_tables_events_id_idx
    ON audit.logs_tables_events
USING btree
(id);

CREATE INDEX logs_tables_events_table_idx
    ON audit.logs_tables_events
USING btree
(table_schema, table_name);

CREATE INDEX logs_tables_events_audit_idx
    ON audit.logs_tables_events
USING btree
(audit);

CREATE INDEX logs_tables_events_log_on_idx
    ON audit.logs_tables_events
USING btree
(log_on);

	
--CREATE TABLE audit.logs_fields_values
CREATE TABLE audit.logs_fields_values
(
    id bigint, 	
    log_on timestamp with time zone NOT NULL DEFAULT ('now'::text)::timestamp(6) with time zone, 
    audit audit.audit_type,
    table_space text,
    table_schema text,
    table_name text,
    table_oid oid,
    field_name text,
    field_type text,
    old_value text,
    new_value text,
    is_primary_key boolean DEFAULT false	
)
WITH (
    OIDS=FALSE
);
ALTER TABLE audit.logs_fields_values OWNER TO postgres;
COMMENT ON TABLE audit.logs_fields_values IS 'A table store information about logging field values and changes.';
COMMENT ON COLUMN audit.logs_fields_values.id IS 'Log internal identifier';
COMMENT ON COLUMN audit.logs_fields_values.log_on IS 'Log event time on destination server';
COMMENT ON COLUMN audit.logs_fields_values.audit IS 'The type of table audit. This field should be values: 1-INSERT, 2-UPDATE, 3-DELETE, 4-VISIBILITY';
COMMENT ON COLUMN audit.logs_fields_values.table_space IS 'The tablespace name of logged table values.';
COMMENT ON COLUMN audit.logs_fields_values.table_schema IS 'The schema name of logged table values.';
COMMENT ON COLUMN audit.logs_fields_values.table_name IS 'The logged table name value.';
COMMENT ON COLUMN audit.logs_fields_values.table_oid IS 'The logged table oid number.';
COMMENT ON COLUMN audit.logs_fields_values.field_name IS 'The logged field name value.';
COMMENT ON COLUMN audit.logs_fields_values.field_type IS 'The logged field type.';
COMMENT ON COLUMN audit.logs_fields_values.old_value IS 'The old (prevoius) value of changed field.';
COMMENT ON COLUMN audit.logs_fields_values.new_value IS 'The new value of changed field.';
COMMENT ON COLUMN audit.logs_fields_values.is_primary_key IS 'Is true if the field is as primary key.';

CREATE INDEX logs_fields_values_id_idx
    ON audit.logs_fields_values
USING btree
(id);

CREATE INDEX logs_fields_values_log_on_idx
    ON audit.logs_fields_values
USING btree
(log_on);

CREATE INDEX logs_fields_values_table_idx
    ON audit.logs_fields_values
USING btree
(table_schema, table_name);

CREATE INDEX logs_fields_values_audit_idx
    ON audit.logs_fields_values
USING btree
(audit);
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ audit.create_audit_views() ------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS audit.pg_tables_with_audit_triggers;

CREATE OR REPLACE VIEW audit.pg_tables_with_audit_triggers AS 
 SELECT DISTINCT ON (triggers.trigger_name) triggers.trigger_name, triggers.event_object_schema AS schema_name, triggers.event_object_table AS table_name
   FROM information_schema.triggers
  WHERE str_contains(triggers.action_statement::text, 'audit.audit_tracker'::text) OR str_contains(triggers.action_statement::text, 'audit.audit_tracking'::text);
ALTER TABLE audit.pg_tables_with_audit_triggers OWNER TO postgres;
COMMENT ON VIEW audit.pg_tables_with_audit_triggers IS 'Retrieves list of audit triggers and tables names.';

----------------------------- create view: audit.pg_tables_with_auditinfo_type_column -------------------------------------------
DROP VIEW IF EXISTS audit.pg_tables_with_auditinfo_type_column;

CREATE OR REPLACE VIEW audit.pg_tables_with_auditinfo_type_column AS 
 SELECT inf_col.table_schema AS schema_name, inf_col.table_name, inf_col.column_name
   FROM information_schema.columns inf_col, information_schema.tables inf_tab
  WHERE inf_col.data_type::text = 'USER-DEFINED'::text AND inf_col.udt_name::text = 'auditinfo'::text AND inf_tab.table_catalog::text = inf_col.table_catalog::text AND inf_tab.table_schema::text = inf_col.table_schema::text AND inf_tab.table_name::text = inf_col.table_name::text AND inf_tab.table_type::text = 'BASE TABLE'::text;
ALTER TABLE audit.pg_tables_with_auditinfo_type_column OWNER TO postgres;
COMMENT ON VIEW audit.pg_tables_with_auditinfo_type_column IS 'Retrieves list of tables contains audit columns of auditinfo type.';

----------------------------- create view: audit.pg_tables_with_disabled_audit_triggers -----------------------------------------
DROP VIEW IF EXISTS audit.pg_tables_with_disabled_audit_triggers;

CREATE OR REPLACE VIEW audit.pg_tables_with_disabled_audit_triggers AS 
 SELECT DISTINCT ON (inf_trg.trigger_name) inf_trg.trigger_name, inf_trg.event_object_schema AS schema_name, inf_trg.event_object_table AS table_name
   FROM information_schema.triggers inf_trg, pg_trigger pg_trg
  WHERE (str_contains(inf_trg.action_statement::text, 'audit.audit_tracker'::text) OR str_contains(inf_trg.action_statement::text, 'audit.audit_tracking'::text)) AND inf_trg.trigger_name::name = pg_trg.tgname AND pg_trg.tgenabled = 'D'::"char";
ALTER TABLE audit.pg_tables_with_disabled_audit_triggers OWNER TO postgres;
COMMENT ON VIEW audit.pg_tables_with_disabled_audit_triggers IS 'Retrieves information about disabled audit triggers and its tables names.';

----------------------------- create view: audit.pg_tables_with_enabled_audit_triggers -----------------------------------------
DROP VIEW IF EXISTS audit.pg_tables_with_enabled_audit_triggers;

CREATE OR REPLACE VIEW audit.pg_tables_with_enabled_audit_triggers AS 
 SELECT DISTINCT ON (inf_trg.trigger_name) inf_trg.trigger_name, inf_trg.event_object_schema AS schema_name, inf_trg.event_object_table AS table_name, pg_trg.tgenabled AS _enabled_trigger_type
   FROM information_schema.triggers inf_trg, pg_trigger pg_trg
  WHERE (str_contains(inf_trg.action_statement::text, 'audit.audit_tracker'::text) OR str_contains(inf_trg.action_statement::text, 'audit.audit_tracking'::text)) AND inf_trg.trigger_name::name = pg_trg.tgname AND pg_trg.tgenabled <> 'D'::"char";
ALTER TABLE audit.pg_tables_with_enabled_audit_triggers OWNER TO postgres;
COMMENT ON VIEW audit.pg_tables_with_enabled_audit_triggers IS 'Retrieves information about enabled audit triggers and its tables names.';
----------------------------------------------------------------------------------------------------------------------------------
