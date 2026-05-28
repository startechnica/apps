--
-- $Id: 4d2d3aac9b86bf5dbf16e1e51b4b9b0fb73f6f3f $
--
-- schema.sql                       rlm_sql - FreeRADIUS SQL Module
--
--     Database schema for SQLite rlm_sql module
--
-- ---------------------------------------------------------------------------
-- Loading path
--
--   Unlike MySQL/PostgreSQL, this file is NOT loaded by the chart's
--   `db-bootstrap` init container — that container only runs for client/server
--   dialects (the SQLite database is a local file inside the FreeRADIUS pod,
--   so a "wait for TCP / run client" model doesn't apply).
--
--   Instead, FreeRADIUS's rlm_sql driver loads it natively via the
--   `bootstrap` directive on first open of an empty database file. See the
--   sqlite{} block in `templates/modules/sql.yaml`:
--       bootstrap = "${modconfdir}/${..:name}/main/sqlite/schema.sql"
--   `${modconfdir}` resolves to `/etc/freeradius/mods-config`, so the
--   upstream image's bundled schema at
--   `/etc/freeradius/mods-config/sql/main/sqlite/schema.sql` is what
--   actually runs by default.
--
--   This file is shipped for users who want to override that upstream
--   schema (e.g. extra columns / indexes) — set
--   `bootstrap.database.schemaConfigMap` to a ConfigMap whose `schema.sql`
--   key holds this content, then mount it over the upstream path via
--   `extraVolumes` / `extraVolumeMounts`.
-- ---------------------------------------------------------------------------

--
-- Table structure for table 'radacct'
--
CREATE TABLE IF NOT EXISTS radacct (
    radacctid           INTEGER PRIMARY KEY AUTOINCREMENT,
    acctsessionid       TEXT NOT NULL DEFAULT '',
    acctuniqueid        TEXT NOT NULL DEFAULT '' UNIQUE,
    username            TEXT NOT NULL DEFAULT '',
    realm               TEXT DEFAULT '',
    nasipaddress        TEXT NOT NULL DEFAULT '',
    nasportid           TEXT DEFAULT NULL,
    nasporttype         TEXT DEFAULT NULL,
    acctstarttime       DATETIME DEFAULT NULL,
    acctupdatetime      DATETIME DEFAULT NULL,
    acctstoptime        DATETIME DEFAULT NULL,
    acctinterval        INTEGER DEFAULT NULL,
    acctsessiontime     INTEGER DEFAULT NULL,
    acctauthentic       TEXT DEFAULT NULL,
    connectinfo_start   TEXT DEFAULT NULL,
    connectinfo_stop    TEXT DEFAULT NULL,
    acctinputoctets     INTEGER DEFAULT NULL,
    acctoutputoctets    INTEGER DEFAULT NULL,
    calledstationid     TEXT NOT NULL DEFAULT '',
    callingstationid    TEXT NOT NULL DEFAULT '',
    acctterminatecause  TEXT NOT NULL DEFAULT '',
    servicetype         TEXT DEFAULT NULL,
    framedprotocol      TEXT DEFAULT NULL,
    framedipaddress     TEXT NOT NULL DEFAULT '',
    framedipv6address   TEXT NOT NULL DEFAULT '',
    framedipv6prefix    TEXT NOT NULL DEFAULT '',
    framedinterfaceid   TEXT NOT NULL DEFAULT '',
    delegatedipv6prefix TEXT NOT NULL DEFAULT '',
    class               TEXT DEFAULT NULL
);
CREATE INDEX IF NOT EXISTS radacct_active_session_idx   ON radacct (acctuniqueid)     WHERE acctstoptime IS NULL;
CREATE INDEX IF NOT EXISTS radacct_bulk_close_idx       ON radacct (nasipaddress, acctstarttime) WHERE acctstoptime IS NULL;
CREATE INDEX IF NOT EXISTS radacct_username_idx         ON radacct (username);
CREATE INDEX IF NOT EXISTS radacct_framedipaddress_idx  ON radacct (framedipaddress);
CREATE INDEX IF NOT EXISTS radacct_framedipv6address_idx ON radacct (framedipv6address);
CREATE INDEX IF NOT EXISTS radacct_framedipv6prefix_idx  ON radacct (framedipv6prefix);
CREATE INDEX IF NOT EXISTS radacct_framedinterfaceid_idx ON radacct (framedinterfaceid);
CREATE INDEX IF NOT EXISTS radacct_delegatedipv6prefix_idx ON radacct (delegatedipv6prefix);
CREATE INDEX IF NOT EXISTS radacct_acctsessionid_idx    ON radacct (acctsessionid);
CREATE INDEX IF NOT EXISTS radacct_acctsessiontime_idx  ON radacct (acctsessiontime);
CREATE INDEX IF NOT EXISTS radacct_acctstarttime_idx    ON radacct (acctstarttime);
CREATE INDEX IF NOT EXISTS radacct_acctinterval_idx     ON radacct (acctinterval);
CREATE INDEX IF NOT EXISTS radacct_acctstoptime_idx     ON radacct (acctstoptime);
CREATE INDEX IF NOT EXISTS radacct_nasipaddress_idx     ON radacct (nasipaddress);
CREATE INDEX IF NOT EXISTS radacct_class_idx            ON radacct (class);

--
-- Table structure for table 'radcheck'
--
CREATE TABLE IF NOT EXISTS radcheck (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username   TEXT NOT NULL DEFAULT '',
    attribute  TEXT NOT NULL DEFAULT '',
    op         CHAR(2) NOT NULL DEFAULT '==',
    value      TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radcheck_username_idx ON radcheck (username, attribute);

--
-- Table structure for table 'radgroupcheck'
--
CREATE TABLE IF NOT EXISTS radgroupcheck (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    groupname  TEXT NOT NULL DEFAULT '',
    attribute  TEXT NOT NULL DEFAULT '',
    op         CHAR(2) NOT NULL DEFAULT '==',
    value      TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radgroupcheck_groupname_idx ON radgroupcheck (groupname, attribute);

--
-- Table structure for table 'radgroupreply'
--
CREATE TABLE IF NOT EXISTS radgroupreply (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    groupname  TEXT NOT NULL DEFAULT '',
    attribute  TEXT NOT NULL DEFAULT '',
    op         CHAR(2) NOT NULL DEFAULT '=',
    value      TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radgroupreply_groupname_idx ON radgroupreply (groupname, attribute);

--
-- Table structure for table 'radreply'
--
CREATE TABLE IF NOT EXISTS radreply (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username   TEXT NOT NULL DEFAULT '',
    attribute  TEXT NOT NULL DEFAULT '',
    op         CHAR(2) NOT NULL DEFAULT '=',
    value      TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radreply_username_idx ON radreply (username, attribute);

--
-- Table structure for table 'radusergroup'
--
CREATE TABLE IF NOT EXISTS radusergroup (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username   TEXT NOT NULL DEFAULT '',
    groupname  TEXT NOT NULL DEFAULT '',
    priority   INTEGER NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS radusergroup_username_idx ON radusergroup (username);

--
-- Table structure for table 'radpostauth'
--
-- Note: SQLite has no `ON UPDATE CURRENT_TIMESTAMP` equivalent, but rows in
--       this table are insert-only, so DEFAULT CURRENT_TIMESTAMP is enough.
--
CREATE TABLE IF NOT EXISTS radpostauth (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username   TEXT NOT NULL DEFAULT '',
    pass       TEXT NOT NULL DEFAULT '',
    reply      TEXT NOT NULL DEFAULT '',
    authdate   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    class      TEXT DEFAULT NULL
);
CREATE INDEX IF NOT EXISTS radpostauth_username_idx ON radpostauth (username);
CREATE INDEX IF NOT EXISTS radpostauth_class_idx    ON radpostauth (class);

--
-- Table structure for table 'nas'
--
CREATE TABLE IF NOT EXISTS nas (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    nasname     TEXT NOT NULL,
    shortname   TEXT,
    type        TEXT DEFAULT 'other',
    ports       INTEGER,
    secret      TEXT NOT NULL DEFAULT 'secret',
    server      TEXT,
    community   TEXT,
    description TEXT DEFAULT 'RADIUS Client'
);
CREATE INDEX IF NOT EXISTS nas_nasname_idx ON nas (nasname);
