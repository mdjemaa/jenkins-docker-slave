https://www.developpez.net/forums/blogs/190582-triaguae/b2474/wrappeur-donnees-oracle-posgresql/?fbclid=IwAR1ODVW8C6iR2DqczDUaia57ZXko-PQxa-4zla_rdC-8qndNJOW520HFqVo
https://blog.dbi-services.com/connecting-your-postgresql-instance-to-an-oracle-database/?fbclid=IwAR1Q_2poiprB3pALnyb54BBcquv3PEiR3BrJ1ncnJO5HweT7BDsMKOygxow

postgres=# CREATE EXTENSION oracle_fdw ;
CREATE EXTENSION
postgres=# CREATE SERVER oracle_pg  FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver 'xe')
postgres-# ;
CREATE SERVER
postgres=#create user mapping for postgres server oracle options (user 'xlrelease', password 'xlrelease');
create foreign table INTERVAL_SALES ( prod_id int not null, time_id date, amount_sold numeric) server oracle_pg options (schema 'xlrelease', table 'INTERVAL_SALES');
CREATE FOREIGN TABLE

GRANT USAGE ON FOREIGN SERVER oracle_pg TO postgres ;

create foreign table XL_VERSION (COMPONENT character varying(255) NOT NULL,"VERSION" character varying(255) not null ) server oracle_pg options (schema 'xlrelease', table 'XL_VERSION');
create foreign table xl_users (username character varying(255),"PASSWORD" character varying(255) ) server oracle_pg options (schema 'xlrelease', table 'XL_USERS');

username character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "PASSWORD" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT xl_users_pkey PRIMARY KEY (username)

CREATE TABLE public.xlr_tags
(
    ci_uid numeric NOT NULL,
    tag_value character varying(255)

create foreign table xlr_tags (ci_uid numeric NOT NULL,tag_value character varying(255) ) server oracle_pg options (table 'XLR_TAGS');