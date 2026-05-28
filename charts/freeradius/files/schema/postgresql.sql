--
-- $Id: 6e21a0a4f6a82761cf17e6c2b6b3a8c2bda0f8f9 $
--
-- schema.sql                       rlm_sql - FreeRADIUS SQL Module
--
--     Database schema for PostgreSQL rlm_sql module
--
--     To load:
--         psql -U radius -d radius -f schema.sql
--
--                                   Mike Machado <mike@innercite.com>
--

--
-- Table structure for table 'radacct'
--
CREATE TABLE IF NOT EXISTS radacct (
    radacctid           bigserial PRIMARY KEY,
    acctsessionid       varchar(64) NOT NULL,
    acctuniqueid        varchar(32) NOT NULL UNIQUE,
    username            varchar(64) NOT NULL,
    realm               varchar(64),
    nasipaddress        inet NOT NULL,
    nasportid           varchar(32),
    nasporttype         varchar(32),
    acctstarttime       timestamp with time zone,
    acctupdatetime      timestamp with time zone,
    acctstoptime        timestamp with time zone,
    acctinterval        bigint,
    acctsessiontime     bigint,
    acctauthentic       varchar(32),
    connectinfo_start   varchar(128),
    connectinfo_stop    varchar(128),
    acctinputoctets     bigint,
    acctoutputoctets    bigint,
    calledstationid     varchar(50) NOT NULL DEFAULT '',
    callingstationid    varchar(50) NOT NULL DEFAULT '',
    acctterminatecause  varchar(32) NOT NULL DEFAULT '',
    servicetype         varchar(32),
    framedprotocol      varchar(32),
    framedipaddress     inet,
    framedipv6address   inet,
    framedipv6prefix    cidr,
    framedinterfaceid   varchar(44),
    delegatedipv6prefix cidr,
    class               varchar(64)
);

-- For use by update-, stop- and simul_* queries
CREATE INDEX IF NOT EXISTS radacct_active_session_idx
    ON radacct (acctuniqueid)
    WHERE acctstoptime IS NULL;

-- For backwards compatibility / when active-session lookup is by composite key.
CREATE INDEX IF NOT EXISTS radacct_bulk_close
    ON radacct (nasipaddress, acctstarttime)
    WHERE acctstoptime IS NULL;

-- Indexes commonly used to filter accounting records.
CREATE INDEX IF NOT EXISTS radacct_username_idx       ON radacct (username);
CREATE INDEX IF NOT EXISTS radacct_framedipaddress_idx ON radacct (framedipaddress)    WHERE framedipaddress IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_framedipv6address_idx ON radacct (framedipv6address) WHERE framedipv6address IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_framedipv6prefix_idx  ON radacct (framedipv6prefix)  WHERE framedipv6prefix IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_framedinterfaceid_idx ON radacct (framedinterfaceid) WHERE framedinterfaceid IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_delegatedipv6prefix_idx ON radacct (delegatedipv6prefix) WHERE delegatedipv6prefix IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_acctsessionid_idx  ON radacct (acctsessionid);
CREATE INDEX IF NOT EXISTS radacct_acctsessiontime_idx ON radacct (acctsessiontime)    WHERE acctsessiontime IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_acctstarttime_idx  ON radacct (acctstarttime);
CREATE INDEX IF NOT EXISTS radacct_acctinterval_idx   ON radacct (acctinterval)        WHERE acctinterval IS NOT NULL;
CREATE INDEX IF NOT EXISTS radacct_acctstoptime_idx   ON radacct (acctstoptime);
CREATE INDEX IF NOT EXISTS radacct_nasipaddress_idx   ON radacct (nasipaddress);
CREATE INDEX IF NOT EXISTS radacct_class_idx          ON radacct (class)               WHERE class IS NOT NULL;

--
-- Table structure for table 'radcheck'
--
CREATE TABLE IF NOT EXISTS radcheck (
    id         serial PRIMARY KEY,
    username   varchar(64) NOT NULL DEFAULT '',
    attribute  varchar(64) NOT NULL DEFAULT '',
    op         char(2)     NOT NULL DEFAULT '==',
    value      varchar(253) NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radcheck_username_idx ON radcheck (username, attribute);

--
-- Table structure for table 'radgroupcheck'
--
CREATE TABLE IF NOT EXISTS radgroupcheck (
    id         serial PRIMARY KEY,
    groupname  varchar(64) NOT NULL DEFAULT '',
    attribute  varchar(64) NOT NULL DEFAULT '',
    op         char(2)     NOT NULL DEFAULT '==',
    value      varchar(253) NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radgroupcheck_groupname_idx ON radgroupcheck (groupname, attribute);

--
-- Table structure for table 'radgroupreply'
--
CREATE TABLE IF NOT EXISTS radgroupreply (
    id         serial PRIMARY KEY,
    groupname  varchar(64) NOT NULL DEFAULT '',
    attribute  varchar(64) NOT NULL DEFAULT '',
    op         char(2)     NOT NULL DEFAULT '=',
    value      varchar(253) NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radgroupreply_groupname_idx ON radgroupreply (groupname, attribute);

--
-- Table structure for table 'radreply'
--
CREATE TABLE IF NOT EXISTS radreply (
    id         serial PRIMARY KEY,
    username   varchar(64) NOT NULL DEFAULT '',
    attribute  varchar(64) NOT NULL DEFAULT '',
    op         char(2)     NOT NULL DEFAULT '=',
    value      varchar(253) NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS radreply_username_idx ON radreply (username, attribute);

--
-- Table structure for table 'radusergroup'
--
CREATE TABLE IF NOT EXISTS radusergroup (
    id         serial PRIMARY KEY,
    username   varchar(64) NOT NULL DEFAULT '',
    groupname  varchar(64) NOT NULL DEFAULT '',
    priority   integer     NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS radusergroup_username_idx ON radusergroup (username);

--
-- Table structure for table 'radpostauth'
--
-- Note: PostgreSQL keeps `authdate` honest via DEFAULT only; there is no
--       direct equivalent of MySQL's `ON UPDATE CURRENT_TIMESTAMP`. Rows are
--       insert-only here, so the default is sufficient. If you need
--       update-tracking, attach a BEFORE UPDATE trigger.
--
CREATE TABLE IF NOT EXISTS radpostauth (
    id         bigserial PRIMARY KEY,
    username   varchar(64) NOT NULL DEFAULT '',
    pass       varchar(64) NOT NULL DEFAULT '',
    reply      varchar(32) NOT NULL DEFAULT '',
    authdate   timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    class      varchar(64)
);
CREATE INDEX IF NOT EXISTS radpostauth_username_idx ON radpostauth (username);
CREATE INDEX IF NOT EXISTS radpostauth_class_idx    ON radpostauth (class) WHERE class IS NOT NULL;

--
-- Table structure for table 'nas'
--
CREATE TABLE IF NOT EXISTS nas (
    id          serial PRIMARY KEY,
    nasname     varchar(128) NOT NULL,
    shortname   varchar(32),
    type        varchar(30)  DEFAULT 'other',
    ports       integer,
    secret      varchar(60)  NOT NULL DEFAULT 'secret',
    server      varchar(64),
    community   varchar(50),
    description varchar(200) DEFAULT 'RADIUS Client'
);
CREATE INDEX IF NOT EXISTS nas_nasname_idx ON nas (nasname);
