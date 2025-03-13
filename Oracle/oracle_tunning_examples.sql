-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------


SELECT *
from all_tab_privs
where table_name in
  (select directory_name 
   from dba_directories where directory_name = 'DATA_PUMP_DIR');

-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------

select 'select (max(length(' || COLUMN_NAME || '))/(1024)) as "Size in KB" from ' || owner || '.' || TABLE_NAME ||';' "maxlobsizeqry" from dba_tab_cols where owner='SCHEMA' and data_type in ('CLOB','BLOB','LOB');


-- to use with DMS + Redshift 
 exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours', 24);


-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------


-- check is all_indexes indexes indices are OK / VALID

select
 index_name
from
  all_indexes
where
  owner not in ('SYS', 'SYSTEM')
  and
  status != 'VALID'
  and (
    status != 'N/A'
    or
    index_name in (
      select
        index_name
      from
        all_ind_partitions
      where
        status != 'USABLE'
        and (
          status != 'N/A'
          or
          index_name in (
            select
              index_name
            from
              all_ind_subpartitions
            where
              status != 'USABLE'
          )
        )
    )
);


-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------


$ sudo su - grid
$ rlwrap sqlplus / as sysdba
SQL> SELECT name, free_mb, total_mb, free_mb/total_mb*100 as percentage
      FROM v$asm_diskgroup;

NAME   				  FREE_MB   TOTAL_MB PERCENTAGE
------------------------------ ---------- ---------- ----------
DATA   				  7128098   12390298 57.5296736
RECO   				  1326737    2047970  64.783029
REDO   				    92309     102398 90.1472685

-- -----------------------------------------------------------------------------------------------------


CHECK::
SQL>
   @?/rdbms/admin/sqltrpt.sql;
-- 

 SELECT f.*,round(f.free_space /decode(f.free_space,0,1,f.tablespace_size), 7) as temp_tax_free FROM dba_temp_free_space f;

alter tablespace TEMP add TEMPFILE '+DATA' size 2048m autoextend on next 1024m maxsize 4096m;

SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300

SELECT
   A.tablespace_name tablespace,
   D.mb_total,
   SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
   D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM
   v$sort_segment A,
(
SELECT
   B.name,
   C.block_size,
   SUM (C.bytes) / 1024 / 1024 mb_total
FROM
   v$tablespace B,
   v$tempfile C
WHERE
   B.ts#= C.ts#
GROUP BY
   B.name,
   C.block_size
) D
WHERE
   A.tablespace_name = D.name
GROUP by
   A.tablespace_name,
   D.mb_total
 / 

 --  V$TEMPSEG_USAGE
 
 SELECT   sl.sid,
           sl.serial#,
           SYSDATE,
           TO_CHAR (sl.start_time, 'DD-MON-YYYY:HH24:MI:SS') start_time,
           ROUND ( (sl.elapsed_seconds / 60), 2) min_elapsed,
           ROUND ( (sl.time_remaining / 60), 2) min_remaining,
           sl.opname,
           sl.MESSAGE
    FROM   v$session_longops sl, v$session s
   WHERE   s.sid = sl.sid AND s.serial# = sl.serial# AND sl.opname like 'Sort%' 
ORDER BY   sl.start_time DESC, sl.time_remaining ASC ;

-- 

SELECT   s.sid "SID",
         s.username "User",
         s.program "Program",
         u.tablespace "Tablespace",
         u.contents "Contents",
         u.extents "Extents",
         u.blocks * 8 / 1024 "Used Space in MB",
         q.sql_text "SQL TEXT",
         a.object "Object",
         k.bytes / 1024 / 1024 "Temp File Size"
  FROM   v$session s,
         v$sort_usage u,
         v$access a,
         dba_temp_files k,
         v$sql q
 WHERE       s.saddr = u.session_addr
         AND s.sql_address = q.address
         AND s.sid = a.sid
         AND u.tablespace = k.tablespace_name;


-- 
TO_READ_URGENTE::

http://blogs.warwick.ac.uk/java/entry/wait_class_network/
https://sites.google.com/site/embtdbo/wait-event-documentation/oracle-network-waits
http://blog.tanelpoder.com/2008/02/10/sqlnet-message-to-client-vs-sqlnet-more-data-to-client/


https://blogs.oracle.com/optimizer/entry/what_is_the_different_between
https://oracle-base.com/articles/11g/sql-plan-management-11gr1#manual_plan_loading
http://www.oracle.com/technetwork/issue-archive/2009/09-mar/o29spm-092092.html

http://www.oracle.com/technetwork/articles/database/create-sql-plan-baseline-2237506.html
http://kerryosborne.oracle-guy.com/2008/09/flush-a-single-sql-statement/


#12c: https://oracle-base.com/articles/12c/adaptive-sql-plan-management-12cr1
#java: http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html



## ######################################################################################
## Oracle Cheat Sheet - Some queries I used to help people, including myself during 
## operational and development assignments
## 
## by: Vinícius A. B. Schmidt
## ######################################################################################

select * from dict where lower(comments) like '%reco%' or lower(table_name) like  '%reco%' ; 
-- --------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------
select name, 
round(space_limit / 1048576) space_limit_in_mb, 
round(space_used / 1048576) space_used_in_mb, 
round((space_used / 1048576) / (space_limit / 1048576),2)*100 percent_usage
from v$recovery_file_dest;


-- --------------------------------------------------------------------------------------
-- Enterprise Manager - Config
-- --------------------------------------------------------------------------------------

$ emctl stop dbconsole
$ emca -repos drop
$ emca -repos create
$ emca -deconfig dbcontrol db
$ emca -config dbcontrol db
$ emctl start dbconsole

-- --------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------

SQL> CREATE TABLE t1 (c1 NUMBER);
Table created.

SQL> CREATE INDEX t1_idx ON t1(c1);
Index created.

SQL> ALTER INDEX t1_idx MONITORING USAGE;
Index altered.


SQL> Prompt this view should be consulted as the owner of the object of interest (e.g. system will mostly see an empty view).
SQL> SELECT table_name, index_name, monitoring, used FROM v$object_usage;
TABLE_NAME                     INDEX_NAME                     MON USE
------------------------------ ------------------------------ --- ---
T1                             T1_IDX                         YES NO

SQL> SELECT * FROM t1 WHERE c1 = 1;
no rows selected

SQL> SELECT table_name, index_name, monitoring, used FROM v$object_usage;
TABLE_NAME                     INDEX_NAME                     MON USE
------------------------------ ------------------------------ --- ---
T1                             T1_IDX                         YES YES

-- reset statics
ALTER INDEX indexname NOMONITORING USAGE;
ALTER INDEX indexname MONITORING   USAGE;

-- monitor running queries
select a.sid, a.username,b.sql_id, b.sql_fulltext from v$session a, v$sql b
where a.sql_id = b.sql_id and a.status = 'ACTIVE' and a.username != 'SYS';


--
select S.USERNAME, s.sid, s.osuser, t.sql_id, sql_text
from v$sqltext_with_newlines t,V$SESSION s
where t.address =s.sql_address
and t.hash_value = s.sql_hash_value
and s.status = 'ACTIVE'
and s.username <> 'SYSTEM'
order by s.sid,t.piece
/


-- locks
select
  object_name, 
  object_type, 
  session_id, 
  type,         -- Type or system/user lock
  lmode,        -- lock mode in which session holds lock
  request, 
  block, 
  ctime         -- Time since current mode was granted
from
  v$locked_object, all_objects, v$lock
where
  v$locked_object.object_id = all_objects.object_id AND
  v$lock.id1 = all_objects.object_id AND
  v$lock.sid = v$locked_object.session_id
order by
  session_id, ctime desc, object_name
/

-- long running
COLUMN percent FORMAT 999.99 

SELECT sid, to_char(start_time,'hh24:mi:ss') stime, 
message,( sofar/totalwork)* 100 percent 
FROM v$session_longops
WHERE sofar/totalwork < 1
/



-- heavy cpu
SELECT se.username, ss.sid, ROUND (value/100) "CPU Usage" 
FROM v$session se, v$sesstat ss, v$statname st 
WHERE ss.statistic# = st.statistic# 
AND name LIKE '%CPU used by this session%' 
AND se.sid = ss.SID 
AND se.username IS NOT NULL 
ORDER BY value DESC;


-- by PID (from SO) -----------------------------
prompt "Please Enter The UNIX Process ID"
set pagesize 50000
set linesize 30000
set long 500000
set head off

select
   s.username su,
   substr(sa.sql_text,1,540) txt
  from v$process p,
       v$session s,
       v$sqlarea sa 
 where p.addr=s.paddr
   and s.username is not null
   and s.sql_address=sa.address(+)
   and s.sql_hash_value=sa.hash_value(+)
   and spid=&SPID;



-- ------------------------------------------------------------------------------------
SQL> ALTER SYSTEM KILL SESSION 'sid,serial#';
SQL> ALTER SYSTEM KILL SESSION 'sid,serial#,@inst_id';
SQL> ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;

SQL> ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' POST_TRANSACTION;
SQL> ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' IMMEDIATE;


-- ------------------------------------------------------------------------------------
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';



-- ------------------------------------------------------------------------------------
set heading off;
set echo off;
Set pages 999;
set long 90000;
 
spool ddl_list.sql
 
select dbms_metadata.get_ddl('TABLE','DEPT','SCOTT') from dual;
select dbms_metadata.get_ddl('INDEX','DEPT_IDX','SCOTT') from dual;
 
spool off;

-- ------------------------------------------------------------------------------------

DESC dba_segments


Select owner, segment_name,segment_type 
  from dba_segments 
 where tablespace_name='DATA_XXXX_AUTO'
  order by segment_type, owner, segment_name;

-- ------------------------------------------------------------------------------------
CREATE PUBLIC DATABASE LINK link_name
CONNECT TO user_name
IDENTIFIED BY password
USING service_name;
 
CREATE DATABASE LINK link_name
CONNECT TO user_name
IDENTIFIED BY password
USING service_name;

ALTER SESSION CLOSE DATABASE LINK <link_name>;
 
-- drop a public link:w
DROP PUBLIC DATABASE LINK <link_name>;


select * from dba_db_links;
-- ------------------------------------------------------------------------------------

SET LINESIZE 100
COLUMN spid FORMAT A10
COLUMN username FORMAT A10
COLUMN program FORMAT A45

SELECT s.inst_id,
       s.sid,
       s.serial#,
       p.spid,
       s.username,
       s.program
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND';
-- ------------------------------------------------------------------------------------


SELECT 
       s.username,
       count(*)
FROM   gv$session s
       JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE  s.type != 'BACKGROUND'
group by s.username
 order by count(*) desc;

-- ------------------------------------------------------------------------------------
 
 
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
ALTER SESSION SET nls_timestamp_tz_format = 'DD-MON-YYYY HH24:MI:SS.FF TZH:TZM';

 
select  p.spid
       ,s.sql_exec_start
       ,s.sid
       ,s.serial#
       ,s.username
       ,s.status
       ,s.sql_hash_value
       ,s.sql_address
       ,sa.sql_fulltext
  from  v$session s
       ,v$sqlarea sa
       ,v$process p
 where p.addr=s.paddr 
   and s.sql_exec_start < sysdate - (1/24)/60
   and s.sql_address=sa.address(+)
   and s.sql_hash_value=sa.hash_value(+) 
   and  s.status = 'ACTIVE'
order by s.sql_exec_start desc;

-- ------------------------------------------------------------------------------------

select
   tsm.tablespace_name,
   round(tsm.used_percent,3) as used_percent,
   (tsm.used_space * ts.block_size)/1024/1024 as used_space,
   (tsm.tablespace_size * ts.block_size)/1024/1024 as tablespace_size,
   ts.block_size
from
    dba_tablespace_usage_metrics tsm
   ,dba_tablespaces ts
 where tsm.tablespace_name = ts.tablespace_name
order by tsm.used_percent desc; 

-- -------------------------------------------------------------------------------------

 SELECT t1.tablespace_name,
    ROUND(t1.maxbytes   /(1024*1024), 2) TOTAL_REAL_MB,
    ROUND((t1.bytes     - t2.freebytes)/(1024*1024), 2) TOTAL_REAL_USED_MB,
    ROUND((t1.maxbytes  - (t1.bytes - t2.freebytes))/(1024*1024), 2) TOTAL_REAL_FREE_MB,
    ROUND(((t1.maxbytes - (t1.bytes - t2.freebytes))*100)/t1.maxbytes, 2) FREE_PERCENTAGE,
    ROUND((t1.bytes)    /(1024*1024), 2) ALLOCATED_OCCUPIED_SIZE_MB
  FROM
    (SELECT tablespace_name,
      SUM(
      CASE
        WHEN maxbytes = 0
        THEN bytes
        ELSE maxbytes
      END ) maxbytes,
      SUM(bytes) bytes
    FROM dba_data_files
    WHERE status='AVAILABLE'
    GROUP BY tablespace_name
    ) t1,
    (SELECT tablespace_name,
      SUM(bytes) freebytes
    FROM dba_free_space
    GROUP BY tablespace_name
    ) t2
  WHERE t1.tablespace_name = t2.tablespace_name
  ORDER BY free_percentage



-- -------------------------------------------------------------------------------------

COLUMN TABLE_NAME FORMAT A32
COLUMN OBJECT_NAME FORMAT A32
COLUMN OWNER FORMAT A10

SELECT
   owner, 
   table_name, 
   TRUNC(sum(bytes)/1024/1024) Meg,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 UNION ALL
 SELECT i.table_name, i.owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')
WHERE owner in UPPER('&owner')
GROUP BY table_name, owner
HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */
ORDER BY SUM(bytes) desc
; 


-- -------------------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------------------


ALTER SYSTEM SET open_cursors = 400 SCOPE=BOTH;



select a.value, s.username, s.sid, s.serial# from 
v$sesstat a, v$statname b, v$session s 
where a.statistic# = b.statistic#  
and s.sid=a.sid and b.name = 'opened cursors current' 
and s.username is not null;


select  sid ,sql_text, count(*) as "OPEN CURSORS", USER_NAME 
from v$open_cursor where sid in (1543)
 group by sid, sql_text, user_name;
 
 
SELECT  max(a.value) as highest_open_cur, p.value as max_open_cur FROM v$sesstat a, v$statname b, v$parameter p WHERE  a.statistic# = b.statistic#  and b.name = 'opened cursors current' and p.name= 'open_cursors' group by p.value;



-- -------------------------------------------------------------------------------------
BEGIN
  FOR object_info IN
    (SELECT owner,
      table_name
    FROM dba_tables
    WHERE lower(owner) IN ('dw_core')
    AND TEMPORARY       = 'N'
    AND (IOT_TYPE      IS NULL
    AND table_name like 'DMBXXXX%'
    OR IOT_TYPE!        ='IOT_OVERFLOW')
    ORDER BY owner,
      table_name
    )
    LOOP
      BEGIN
        dbms_stats.gather_table_stats(ownname=> object_info.owner, tabname=> object_info.table_name , cascade=> true, estimate_percent=>20, degree => 2);
        dbms_output.put_line('(success) statistic from ' || lower(object_info.owner || '.' || object_info.table_name));
      EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('error calculating statistic from ' || object_info.owner ||'.' || object_info.table_name || ': ' || sqlerrm);
      END;
    END LOOP;
  END;
/


-- -------------------------------------------------------------------------------------
create user &&NEW_USERNAME identified by password_myown;
grant connect, resource to &NEW_USERNAME;

BEGIN
  FOR ROLE_COMMAND IN
  (SELECT 'GRANT '
    || ROLE
    || ' TO &NEW_USERNAME' AS COMMAND
  FROM DBA_ROLES
  WHERE ROLE LIKE 'RL%XXXX%SEL'
  OR ROLE LIKE 'RL%OPS%SEL'
  OR ROLE LIKE 'RL%BEET%SEL'
  OR ROLE LIKE 'RL%CUB%SEL'
  )
  LOOP
    EXECUTE IMMEDIATE ROLE_COMMAND.COMMAND;
  END LOOP;
END;
/

-- -------------------------------------------------------------------------------------

select name into v_name from DBA_SQL_PROFILES; 

dbms_sqltune.alter_sql_profile(v_name, 'STATUS', 'DISABLED');
dbms_sqltune.drop_sql_profile(v_name);
-- -------------------------------------------------------------------------------------

SELECT LPAD(' ', (level-1)*4, ' ') || NVL(s.username, '(oracle)') AS username,
       s.osuser,
       s.sid,
       s.serial#,
       s.lockwait,
       s.status,
       s.module,
       s.machine,
       s.program,
       TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session s
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL
-- -------------------------------------------------------------------------------------

select  p.spid
       ,s.sql_exec_start
       ,s.sid
       ,s.serial#
       ,s.username
       ,s.status
       ,s.sql_hash_value
       ,s.sql_address
       ,sa.sql_fulltext
       ,sa.sql_id             -- passar para query abaixo
       ,s.sql_child_number    -- passar para query abaixo
       ,s.machine
       ,s.program
       ,s.osuser
       ,s.EVENT
       ,s.WAIT_CLASS
       ,'alter system kill session '''||s.sid ||','||s.serial#|| ''';' as kill_string
  from  v$session s
       ,v$sqlarea sa
       ,v$process p
 where p.addr=s.paddr 
  -- and s.sql_exec_start < sysdate - (1/24)/60
   and s.username is not null
   and s.sql_address=sa.address(+)
   and s.sql_hash_value=sa.hash_value(+) 
   and s.sid in ( select s.blocking_session from v$session s where blocking_session is not null ) -- blocking_session || sid
  -- and  s.status = 'ACTIVE'
order by s.sql_exec_start desc;

select owner, object_name, object_type, status
from all_objects
 where status <> 'VALID'
 order by object_type, object_name;
 
 
EXEC DBMS_UTILITY.compile_schema(schema => 'OWNER/SCHEMA');

-- --------------------------------------------------------------------------------------


select  p.spid
       ,s.sql_exec_start
       ,s.sid
       ,s.serial#
       ,s.username
       ,s.status
       ,s.sql_hash_value
       ,s.sql_address
       ,sa.sql_fulltext
       ,sa.sql_id             -- passar para query abaixo
       ,s.sql_child_number    -- passar para query abaixo
       ,s.machine
       ,s.program
       ,s.osuser
       ,s.EVENT
       ,s.WAIT_CLASS
       ,'alter system kill session '''||s.sid ||','||s.serial#|| ''';' as kill_string
  from  v$session s
       ,v$sqlarea sa
       ,v$process p
 where p.addr=s.paddr 
   and s.sql_exec_start < sysdate - (1/24)/60
   and s.username is not null
   and s.sql_address=sa.address(+)
   and s.sql_hash_value=sa.hash_value(+) 
   and  s.status = 'ACTIVE'
order by s.sql_exec_start desc;

-- Observar parâmetros....

   select  sbc.child_number
          ,sbc.position
          ,sbc.datatype_string
          ,sbc.name
          ,sbc.value_string
          ,sbc.last_captured
     from V$SQL_BIND_CAPTURE sbc 
    where sbc.sql_id = '4tc9svjg3g36w' 
      and sbc.child_number =  '6'

-- --------------------------------------------------------------------------------------


select regexp_replace('TIMESTAMP(6)', '([A-Z]+)\(([0-9]+)\)','\1') FROM DUAL

-- --------------------------------------------------------------------------------------

select * from v$active_session_history    

-- --------------------------------------------------------------------------------------
$ impdp dw_core CONTENT=DATA_ONLY DIRECTORY=DUMP_DIRECTORY DUMPFILE=expDP_dwprd_dw_core.dmp log=impdp_20151104.log
-- --------------------------------------------------------------------------------------

-- For which SQL currently is waiting on:
select sid, sql_text from v$session s, v$sql q where sid in (select sid from v$session where state in ('WAITING') and wait_class != 'Idle' and event='enq: TX - row lock contention' and (q.sql_id = s.sql_id or q.sql_id = s.prev_sql_id));

-- The blocking session is:
select blocking_session, sid, serial#, wait_class, seconds_in_wait from v$session where blocking_session is not NULL order by blocking_session;

--Oracle ACE Brian Carr has an excellent write up on TX row lock contention:
http://www.rampant-books.com/art_enq_TX_row_lock_contention.htm


-- --------------------------------------------------------------------------------------
-- Rodar quando houver uma mudança muito grande
-- --------------------------------------------------------------------------------------
EXEC dbms_stats.gather_system_stats('NOWORKLOAD');


-- --------------------------------------------------------------------------------------
    begin
         for  r_row in (
            select name          from DBA_SQL_PROFILES
         )
         loop
            dbms_sqltune.alter_sql_profile(r_row.name, 'STATUS', 'DISABLED');
         end loop;
    end; 
    /


-- --------------------------------------------------------------------------------------
-- Change the Constraints to 'UPDATE CASCADE'
-- --------------------------------------------------------------------------------------
set serveroutput on

DECLARE
      CURSOR consCols (theCons VARCHAR2, theOwner VARCHAR2) IS
        select * from user_cons_columns
            where constraint_name = theCons and owner = theOwner
            order by position;
      firstCol BOOLEAN := TRUE;
    begin
        -- For each constraint
        FOR cons IN (select * from user_constraints
            where delete_rule = 'NO ACTION'
            and constraint_name not like '%MODIFIED_BY_FK'  -- these constraints we do not want delete cascade
            and constraint_name not like '%CREATED_BY_FK'
            order by table_name)
        LOOP
            -- Drop the constraint
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || cons.OWNER || '.' || cons.TABLE_NAME || ' DROP CONSTRAINT ' || cons.CONSTRAINT_NAME || ';');
            -- Re-create the constraint
            DBMS_OUTPUT.PUT('ALTER TABLE ' || cons.OWNER || '.' || cons.TABLE_NAME || ' ADD CONSTRAINT ' || cons.CONSTRAINT_NAME 
                                        || ' FOREIGN KEY (');
            firstCol := TRUE;
            -- For each referencing column
            FOR consCol IN consCols(cons.CONSTRAINT_NAME, cons.OWNER)
            LOOP
                IF(firstCol) THEN
                    firstCol := FALSE;
                ELSE
                    DBMS_OUTPUT.PUT(',');
                END IF;
                DBMS_OUTPUT.PUT(consCol.COLUMN_NAME);
            END LOOP;                                    

            DBMS_OUTPUT.PUT(') REFERENCES ');

            firstCol := TRUE;
            -- For each referenced column
            FOR consCol IN consCols(cons.R_CONSTRAINT_NAME, cons.R_OWNER)
            LOOP
                IF(firstCol) THEN
                    DBMS_OUTPUT.PUT(consCol.OWNER);
                    DBMS_OUTPUT.PUT('.');
                    DBMS_OUTPUT.PUT(consCol.TABLE_NAME);        -- This seems a bit of a kluge.
                    DBMS_OUTPUT.PUT(' (');
                    firstCol := FALSE;
                ELSE
                    DBMS_OUTPUT.PUT(',');
                END IF;
                DBMS_OUTPUT.PUT(consCol.COLUMN_NAME);
            END LOOP;                                    

            DBMS_OUTPUT.PUT_LINE(')  ON DELETE CASCADE  ENABLE VALIDATE;');
        END LOOP;
    end;
    
    
-- --------------------------------------------------------------------------------------
-- map All users, roles and privs
-- --------------------------------------------------------------------------------------
select username, user_id, account_status, lock_date, expiry_date, default_Tablespace, created, profile
  from dba_users
 order by username ;
 
select * 
  from dba_profiles 
 order by profile , resource_name ; 
 
select * 
  from dba_roles 
order by role ;

SELECT * 
  FROM dba_role_privs 
 order by grantee, granted_role ;

SELECT *
  FROM dba_sys_privs 
 order by grantee, privilege ;


SELECT *
FROM dba_tab_privs 
order by grantee, owner, table_name, grantor, privilege ;

-- --------------------------------------------------------------------------------------
-- Get locale parameters
-- --------------------------------------------------------------------------------------
SELECT * FROM NLS_DATABASE_PARAMETERS; 


-- --------------------------------------------------------------------------------------
-- 
-- --------------------------------------------------------------------------------------
SELECT owner, sum(bytes)/1024/1024/1000
  FROM dba_segments
 WHERE lower(owner) IN ('schema01','schema09','hr','scott')
 group by owner 
 order by 2 desc

-- --------------------------------------------------------------------------------------
-- Adicionando arquivos a tablespace
-- --------------------------------------------------------------------------------------
SQL> alter tablespace TBS_XXXXX1 add datafile '+DATA' size 100m autoextend on next 100m maxsize 4096m;


-- --------------------------------------------------------------------------------------
-- Exportando grants!
-- --------------------------------------------------------------------------------------
select 'GRANT '||PRIVILEGE||' ON '||OWNER||'.'||TABLE_NAME|| ' TO '||GRANTEE ||'; ' from dba_tab_privs where grantee = 'OWNER_QUE_RECEBE_O_GRANT'
(...)


-- --------------------------------------------------------------------------------------
-- Cache statistics and estimate 
-- --------------------------------------------------------------------------------------
COLUMN size_for_estimate          FORMAT 999,999,999,999 heading 'Cache Size (MB)'
COLUMN buffers_for_estimate       FORMAT 999,999,999 heading 'Buffers'
COLUMN estd_physical_read_factor  FORMAT 999.90 heading 'Estd Phys|Read Factor'
COLUMN estd_physical_reads        FORMAT 999,999,999,999 heading 'Estd Phys| Reads'

SELECT size_for_estimate, 
      buffers_for_estimate,
      estd_physical_read_factor,
      estd_physical_reads
FROM   v$db_cache_advice
WHERE  name          = 'DEFAULT'
AND    block_size    = (SELECT value
                       FROM   v$parameter
                       WHERE  name = 'db_block_size')
AND    advice_status = 'ON';

-- --------------------------------------------------------------------------------------
--
-- --------------------------------------------------------------------------------------
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

select * from v$log order by first_time;
select * from v$logfile;

alter system switch logfile ; 
alter database drop logfile group 1 ; 
alter database add logfile group 1 ('+REDO','+REDO') size 5G;

-- --------------------------------------------------------------------------------------
select GROUP#, BYTES, STATUS from v$log;
exec rdsadmin.rdsadmin_util.drop_logfile(4);
exec rdsadmin.rdsadmin_util.add_logfile('512M');
exec rdsadmin.rdsadmin_util.switch_logfile;

-- --------------------------------------------------------------------------------------


 select  l.group#, lf.member, l.bytes/1024/1024 mb,  l.status, l.archived
   from  v$logfile lf, v$log l
  where  l.group# = lf.group#
  order  by 1, 2;


-- --------------------------------------------------------------------------------------
--
-- --------------------------------------------------------------------------------------
SELECT t.start_time, s.sid, s.serial#, s.username, s.status,s.schemaname, s.osuser
   , s.process, s.machine, s.terminal, s.program, s.module
   , to_char(s.logon_time,'DD/MON/YY HH24:MI:SS') logon_time
FROM v$transaction t, v$session s
WHERE s.saddr = t.ses_addr
ORDER BY start_time;

-- --------------------------------------------------------------------------------------
--
-- --------------------------------------------------------------------------------------
set linesize 160
column state format a10
column sql_text format a110
column bstate format a10
column bsql_text format a110
column sid_serial format a15
column bsid_serial format a15
break on sql_text

select s.sid||','||s.serial# as sid_serial, s.state, round((sysdate - s.sql_exec_start)*24*60*60,2) as dur, a.sql_text,
       bs.sid||','||bs.serial# as bsid_serial, bs.state as bstate, round((sysdate - bs.sql_exec_start)*24*60*60,2) as bdur, ba.sql_text as bsql_text
from v$session_blockers b
    left join v$session s on s.sid = b.sid
    left join v$sqlarea a on a.hash_value = s.sql_hash_value
    left join v$session bs on b.blocker_sid = bs.sid
    left join v$sqlarea ba on bs.sql_hash_value = ba.hash_value;

-- --------------------------------------------------------------------------------------
-- Clone 'USER' 
-- --------------------------------------------------------------------------------------
select dbms_metadata.get_ddl('USER', '...') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT','...') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','...') FROM DUAL;
SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT','...') FROM DUAL;
SELECT DBMS_METADATA.GET_granted_DDL(‘TABLESPACE_QUOTA’, ‘...’) FROM dual;
-- '...' -> name 


-- --------------------------------------------------------------------------------------
-- Limpar cache do Oracle (incluindo os planos de acesso já cachedados)
-- --------------------------------------------------------------------------------------
 alter system flush shared_pool;
 ALTER SYSTEM FLUSH BUFFER_CACHE;


-- --------------------------------------------------------------------------------------
-- Matar sessões no RDS.
-- --------------------------------------------------------------------------------------
exec rdsadmin.rdsadmin_util.kill(92,24361);
-- http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.Oracle.CommonDBATasks.html#Appendix.Oracle.CommonDBATasks.KillingSession


-- --------------------------------------------------------------------------------------
-- RecycleBin
-- --------------------------------------------------------------------------------------
select sum(space)/1024/1024,owner from dba_recyclebin group by owner order by owner;

PURGE RECYCLEBIN;
-- https://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_9018.htm

-- --------------------------------------------------------------------------------------
-- Reports and Tuning
-- --------------------------------------------------------------------------------------
 $ORACLE_HOME/rdbms/admin/sqltrpt.sql
 @sqltrpt.sql;


-- --------------------------------------------------------------------------------------
-- Size Table Spaces
-- --------------------------------------------------------------------------------------
  SELECT t1.tablespace_name,
    ROUND(t1.maxbytes   /(1024*1024), 2) TOTAL_REAL_MB,
    ROUND((t1.bytes     - t2.freebytes)/(1024*1024), 2) TOTAL_REAL_USED_MB,
    ROUND((t1.maxbytes  - (t1.bytes - t2.freebytes))/(1024*1024), 2) TOTAL_REAL_FREE_MB,
    ROUND(((t1.maxbytes - (t1.bytes - t2.freebytes))*100)/t1.maxbytes, 2) FREE_PERCENTAGE,
    ROUND((t1.bytes)    /(1024*1024), 2) ALLOCATED_OCCUPIED_SIZE_MB
  FROM
    (SELECT tablespace_name,
      SUM(
      CASE
        WHEN maxbytes = 0
        THEN bytes
        ELSE maxbytes
      END ) maxbytes,
      SUM(bytes) bytes
    FROM dba_data_files
    WHERE status='AVAILABLE'
    GROUP BY tablespace_name
    ) t1,
    (SELECT tablespace_name,
      SUM(bytes) freebytes
    FROM dba_free_space
    GROUP BY tablespace_name
    ) t2
  WHERE t1.tablespace_name = t2.tablespace_name
  ORDER BY free_percentage


-- --------------------------------------------------------------------------------------
-- Monitor Sessions ( Active / Inactive )
-- --------------------------------------------------------------------------------------
select USERNAME, status, count(*) from v$sessioN GROUP BY USERNAME,status  
union all 
select 'Total',' - ', count(*) from v$session group by 'Total', ' - ' 
order by 2 ;

-- --------------------------------------------------------------------------------------
-- Monitoring Sessions 
-- --------------------------------------------------------------------------------------
set linesize 32767
set timing on
set serveroutput on
SET TRIMSPOOL ON
SET TRIMOUT ON
SET WRAP OFF
SET PAGESIZE 0
SET NEWPAGE NONE
SET VERIFY OFF
--SET FEEDBACK OFF
--SET HEADING OFF
--SET TERM OFF
--SET TERMOUT OFF

SET SPACE 4
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

select  p.spid
       ,s.sql_exec_start
       ,s.sid
       ,s.serial#
       ,s.username
       ,s.status
       ,s.sql_hash_value
       ,s.sql_address
       --,to_char(sa.sql_fulltext) as sql_fulltext
       ,sa.sql_fulltext
       ,sa.sql_id
       ,s.sql_child_number
       ,s.machine
       ,s.program
       ,s.osuser
       ,'alter system kill session '''||s.sid ||','||s.serial#|| ''';' as kill_string
       ,s.state
       ,s.EVENT
       ,s.WAIT_CLASS
  from  v$session s
       ,v$sqlarea sa
       ,v$process p
 where p.addr=s.paddr
   and s.sql_exec_start < sysdate - (((1/24)/60)/60)
   and s.username is not null
   and s.sql_address=sa.address(+)
   and s.sql_hash_value=sa.hash_value(+)
   and  s.status = 'ACTIVE'
order by s.sql_exec_start desc;

-- --------------------------------------------------------------------------------------
-- Monitor Open Transactions
-- --------------------------------------------------------------------------------------
select s.sid
      ,s.serial#
      ,s.username
      ,s.machine
      ,s.status
      ,s.lockwait
      ,t.used_ublk
      ,t.used_urec
      ,t.start_time
from v$transaction t
inner join v$session s on t.addr = s.taddr;


-- --------------------------------------------------------------------------------------
-- Create APEX User
-- --------------------------------------------------------------------------------------

set serveroutput on;
DECLARE
  n_security_group INTEGER;
BEGIN

    SELECT workspace_id
    INTO n_security_group 
    FROM apex_workspaces
    WHERE workspace = 'SUPORTE';

    wwv_flow_api.set_security_group_id(n_security_group );
    dbms_output.put_line('N_Security_Group: '||n_security_group || ' .');


      APEX_UTIL.CREATE_USER(
          p_user_name              => 'VSCHMIDT',
          p_web_password           => 'xxx1',
          p_default_schema         => 'SUPORTE',
          p_change_password_on_first_use => 'Y',
          p_developer_privs        => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL');
END;
/

-- --------------------------------------------------------------------------------------
-- IndeXES STats
-- --------------------------------------------------------------------------------------
create index IDXDM_T01_DATA_ABERTURA_DESC on dmxxx_t01(DATA_ABERTURA desc) online TABLESPACE INDEX_DW_CORE;

begin 
    for rr in ( select * from user_indexes where index_name like 'IDXDM_%' ) 
    loop
            DBMS_STATS.GATHER_INDEX_STATS ( OWNNAME=>'DW_CORE'
                                           , INDNAME=>rr.index_name);
    end loop;
end;
/  

-- --------------------------------------------------------------------------------------
-- Cursor Dinâmico
-- --------------------------------------------------------------------------------------
DECLARE
   TYPE EmpCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
   emp_cv   EmpCurTyp;  -- declare cursor variable
   my_ename VARCHAR2(15);
   my_sal   NUMBER := 1000;
BEGIN
   OPEN emp_cv FOR  -- open cursor variable
      'SELECT ename, sal FROM emp WHERE sal > :s' USING my_sal;
   ...
END;


-- --------------------------------------------------------------------------------------
-- Materialized View
-- --------------------------------------------------------------------------------------
grant resource to dw_lab;
grant connect to dw_lab;
grant session to dw_lab;
GRANT CREATE  MATERIALIZED VIEW TO dw_lab;
GRANT CREATE  TABLE TO dw_lab;
grant ALTER   SNAPSHOT to dw_lab;
grant unlimited tablespace to dw_lab;
grant select on  <tables_in_view> to dw_lab with grant option;

create materialized view MV_DMdddd_FATO as select * from dw_core.DMdddd_T01 mwhere rownum <=0;

declare
begin
        dbms_snapshot.refresh('MV_DMXXX_FATO', 'F');
exception
       when others then
        dbms_output.put_line('Erro inesperado'||SQLERRM);
end;
/

* Run $ORACLE_HOME/admin/utlxmv.sql under your schema.

* Execute:

 DBMS_MVIEW.EXPLAIN_MVIEW('
 SELECT  field1 
   FROM    table_1 a
   LEFT JOIN
            table_2 b 
    ON      a.field1 = b.field2
    ');

* Run:

    SELECT  *
    FROM    mv_capabilities_table


* Other create sample: 

CREATE MATERIALIZED VIEW mv_dmxyz_fato_min_max
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND WITH ROWID
ENABLE QUERY REWRITE
AS
   SELECT  T01A.PAIS_ID,
      T01A.PDC_ID,
      T01A.PRODH_ID,
      MIN(T01A.PRECO_UNIT) PRECO_MIN,
      MAX(T01A.PRECO_UNIT) PRECO_MAX
    FROM DW_CORE.DXYZ_T01 T01A
    GROUP BY T01A.PAIS_ID,
      T01A.PDC_ID,
      T01A.PRODH_ID
;

- http://docs.oracle.com/cd/B28359_01/server.111/b28313/advmv.htm


-- --------------------------------------------------------------------------------------
-- Query Hints && Tuning Docs
-- --------------------------------------------------------------------------------------
http://docs.oracle.com/cd/E11882_01/server.112/e41573/toc.htm
https://docs.oracle.com/cd/E11882_01/server.112/e41084/sql_elements006.htm
http://docs.oracle.com/cd/B19306_01/server.102/b14200/sql_elements006.htm
https://docs.oracle.com/cd/B12037_01/server.101/b10752/hintsref.htm#25769
https://docs.oracle.com/database/121/TGSQL/tgsql_transform.htm

-- --------------------------------------------------------------------------------------
-- PL/SQL
-- --------------------------------------------------------------------------------------
http://docs.oracle.com/cd/B28359_01/appdev.111/b28370/dynamic.htm




-- --------------------------------------------------------------------------------------
-- RMAN - Cleaning Archives (when v$recovery_file_dest is full)
-- --------------------------------------------------------------------------------------
export ORACLE_SID=apex
rman target / << EOF
run
{
	delete noprompt archivelog all completed before 'sysdate - 4/24';
}
EOF

-- --------------------------------------------------------------------------------------
-- RMAN - Backup (Complete)
-- --------------------------------------------------------------------------------------

 rman target / << EOF
    configure controlfile autobackup off;

    run {
      allocate channel c1  device type disk maxpiecesize 10G;
      allocate channel c2  device type disk maxpiecesize 10G;
      allocate channel c3  device type disk maxpiecesize 10G;
      allocate channel c4  device type disk maxpiecesize 10G;
      allocate channel c5  device type disk maxpiecesize 10G;
      allocate channel c6  device type disk maxpiecesize 10G;
      allocate channel c7  device type disk maxpiecesize 10G;
      allocate channel c8  device type disk maxpiecesize 10G;
      allocate channel c9  device type disk maxpiecesize 10G;
      allocate channel c10 device type disk maxpiecesize 10G;
      allocate channel c11 device type disk maxpiecesize 10G;
      allocate channel c12 device type disk maxpiecesize 10G;
      allocate channel c13 device type disk maxpiecesize 10G;
      allocate channel c14 device type disk maxpiecesize 10G;
      allocate channel c15 device type disk maxpiecesize 10G;
      allocate channel c16 device type disk maxpiecesize 10G;

      delete noprompt expired backup;
      crosscheck backup;

      backup tag 'archivelog_${archive_hour}' format '${archive_home}/%d_archivelog_%e-%p.bkp' archivelog all delete input;
      backup incremental level 0 as compressed backupset database format '${backup_home}/%d_backupset_%s-%p.bkp' tag='backupset_${backup_date}' plus archivelog format '${backup_home}/%d_archivelog_%e-%p.bkp' tag='archivelog_${backup_date}' delete input;
      backup tag 'archivelog_${backup_date}' format '${backup_home}/%d_archivelog_%e-%p.bkp' archivelog all delete input;

      backup spfile format '${backup_home}/spfile.bkp';
      backup current controlfile for standby format '${backup_home}/controlfile_stdby.bkp';
      backup current controlfile format '${backup_home}/controlfile.bkp';

      release channel c1;
      release channel c2;
      release channel c3;
      release channel c4;
      release channel c5;
      release channel c6;
      release channel c7;
      release channel c8;
      release channel c9;
      release channel c10;
      release channel c11;
      release channel c12;
      release channel c13;
      release channel c14;
      release channel c15;
      release channel c16;
  }
EOF

sqlplus -S / as sysdba << EOF
  create pfile='${backup_home}/pfileprodbr.ora' from spfile;
EOF




-- --------------------------------------------------------------------------------------
-- RMAN - Incremental
-- --------------------------------------------------------------------------------------

rman target / << EOF
    configure controlfile autobackup off;
    run {
      allocate channel c1  device type disk maxpiecesize 10G;

      delete noprompt expired backup;
      crosscheck backup;

      delete noprompt archivelog all;
      backup as compressed backupset incremental level 1 for recover of tag='${backup_tag}' format '${backup_home}/%d_backupset_differential_%s-%p.bkp' database;
      backup spfile format '${backup_home}/spfile.bkp';
      backup current controlfile for standby format '${backup_home}/controlfile_stdby.bkp';
      backup current controlfile format '${backup_home}/controlfile.bkp';

      release channel c1;
  }
EOF

-- --------------------------------------------------------------------------------------
-- RMAN - Archive
-- --------------------------------------------------------------------------------------
rman target / << EOF
    run {
      configure controlfile autobackup off;

      allocate channel c1 device type disk maxpiecesize 2G;
      allocate channel c2 device type disk maxpiecesize 2G;

      backup tag 'archivelog_${archive_hour}' format '${archive_home}/%d_archivelog_%s-%p.bkp' archivelog all delete input;
      backup current controlfile format '${archive_home}/controlfile.bkp';

      release channel c1;
      release channel c2;
  }
EOF


-- --------------------------------------------------------------------------------------
-- Sample to remove duplicities
-- --------------------------------------------------------------------------------------
    delete from data_mart_prod where rowid in ( 
        select to_del_rowid
          from (
                select taux.* 
                      , row_number() over ( partition by  pais_id, prodh_id, hosp_id  order by   prodh_id, hosp_id ) as numpos
                from (
                      select   pais_id, prodh_id, hosp_id
                             , count(*)  over (partition by pais_id, prodh_id, hosp_id order by  prodh_id, hosp_id ) as count1
                             , rowid as to_del_rowid
                        from dmboofa_prodh  
                ) taux 
                where count1 > 1  
           )
           where numpos >1 );
           
           
           
           
           
-- --------------------------------------------------------------------------------------
-- (TO CLASSIFY)
-- --------------------------------------------------------------------------------------         
select * from V$SESSION_WAIT ; 

--
select * from ( 
    select sw.wait_class, sw.seconds_in_wait ,sw.state, count(*) 
    from V$SESSION_WAIT sw 
    group by sw.wait_class, sw.seconds_in_wait ,sw.state 
) 
order by seconds_in_wait desc  ; 

--
select sw.wait_class, sw.state, count(*) 
from V$SESSION_WAIT sw 
group by sw.wait_class,sw.state ;


           
select count(*) from dba_sql_plan_baselines;

select  * from dba_sql_plan_baselines order by created desc;



select 
   s.sql_text, 
   b.created,
   b.plan_name, 
   b.origin, 
   b.accepted 
from 
   dba_sql_plan_baselines b, 
   v$sql s 
where 
   s.exact_matching_signature = b.signature and 
   s.sql_plan_baseline = b.plan_name;
   
   
   
   
   
   SELECT b.sql_handle, b.plan_name, s.child_number, 
  s.plan_hash_value, s.executions
FROM v$sql s, dba_sql_plan_baselines b
WHERE s.exact_matching_signature = b.signature(+)
  AND s.sql_plan_baseline = b.plan_name(+)
  /
   
   
   
select s.physical_write_bytes, s.physical_read_bytes, s.locked_total, s.pinned_total ,  s.* 
from v$sql s order by s.PHYSICAL_WRITE_BYTES desc ;  


select sj.state, sj.enabled, sj.last_start_date,   sj.* 
from dba_scheduler_jobs sj
order by 2 desc;
           


-- --------------------------------------------------------------------------------------
-- Tempo médio de execuções
-- --------------------------------------------------------------------------------------         



SELECT *
FROM
  (SELECT FIRST_LOAD_TIME,
    LAST_LOAD_TIME,
    executions,
    parsing_schema_name,
    TO_CHAR((ELAPSED_TIME/(1000000))/executions, '999.99999')
    || ' segundos' AS AVG_TIME,
    MODULE,
    SQL_FULLTEXT
  FROM V$SQL
  WHERE parsing_schema_name='${schema_name}'
    --and executions > 1000
  ORDER BY (ELAPSED_TIME/(1000000))/executions DESC
  )
WHERE ROWNUM <= 10;
           
           
           
-- -------------------------------------------------------------------------------------------------------------------





[ref.:http://www.oracle.com/technetwork/articles/sql/11g-dataguard-083323.html ]

Abrir DG para escrita!
-- ------------------------------------
ssh ec2-user@dataguard.host

$ dgmgrl /

> convert database dgprodbr to snapshot standby;

---
sqlplus / as sysdba

> update publcschema.usuarios set email = '-', password='1234';
> commit;

> update opmebr.usuarios set email = '-';
> commit;

> alter trigger schema_name.LG_USUARIO disable;
> update publcschema.usuario set usr_email='-', usr_senha = '1234';

> alter trigger schema_name.LG_EMPRESA disable;
> update publcschema.empresa set emp_email='-';


> alter trigger schema_name.LG_USUARIO_BO disable;
> update pub.usuario_bo set ubo_senha='1234',ubo_email='1234’;

> update publcschema.usuarios set CRYPTPASSWORD = null;

> commit;
---


Voltar DG para "physical"
-- ------------------------------------

$ dgmgrl sys/passwd@dataguard

> convert database dgprodbr to physical standby;


#TNS for dataguard communication: DO NOT CHANGE IT!!!
#producao_eu =
#(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = cloud.loremipslum.com.br)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (service_name = prod)))

producao_eu =
(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = cloud.loremipslum.com.br)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (service_name = dataguard)))

TCP)(HOST = sandboxeu.db.cloud.XPTO.com.br)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = sandbox)))



Monitoramento de Bases:
$ /home/oracle/jobs/monitoring/check_tablespace.sh

Analyzing tablespaces...

  WARNING: Imminent error in host prod-asdfg.db.cloud.asdfasdf.com.br:srv_administrator with tablespace DATA_XYZP_AUTO [ 3% free space - 40239.19 mb of 1343488 mb ]

  WARNING: Imminent error in host prod-asdfg.db.cloud.asdfasdf.com.br:srv_administrator with tablespace TBS_XYZP_INDEX [ 12.29% free space - 3021.13 mb of 24576 mb ]

  WARNING: Imminent error in host prod-asdfg.db.cloud.asdfasdf.com.br:srv_administrator with tablespace TBS_XYZP_DATA [ 17.68% free space - 29691.13 mb of 167936 mb ]

Done

[16:43:20] oracle@prodbr:monitoring $ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Fri Sep 25 16:44:12 2015

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options

SQL> alter tablespace TBS_XXXXXXX_DATA add datafile '+DATA' size 100m autoextend on next 100m maxsize 4096m;

Tablespace altered.

SQL> alter tablespace TBS_XXXXXXX_DATA add datafile '+DATA' size 100m autoextend on next 100m maxsize 4096m;

Tablespace altered.


-- ---------------------------------------------------------



>>> EM

emcli login -username=sysman -password=asdfasdfasdf

emcli delete_target -name="apex-br.db.cloud.asdfasdfa.com.br:3872" -type="oracle_emd" -delete_monitored_targets -async

https://cloudcontrol.db.cloud.asdfasdfad.com.br:7802/em/login.jsp


>>> ASM

$ asmcmd lsdg

ASMCMD> lsdg

ASMCMD> cd DATA_TEMP

ASMCMD> ls




# for i in a b c d e f g h i j k l m n o p q r ; do echo -e "n\np\n1\n\n\nw\n"| fdisk /dev/xvda$i; done;

# oracleasm listdisks
# oracleasm createdisk DATA_001 /dev/xvdaa1

# oracleasm createdisk DATA_002 /dev/xvdab1
# su - grid

$ sqlplus / as sysasm

SQL> CREATE DISKGROUP DATA NORMAL redundancy disk '/dev/oracleasm/disks/DATA_001','/dev/oracleasm/disks/DATA_002' ;

SQL> alter diskgroup data add disk '/dev/oracleasm/disks/DATA_003','/dev/oracleasm/disks/DATA_004';
SQL> select name, path from v$asm_disk where path = '/dev/oracleasm/disks/DATA_2TB_11';

SQL> alter diskgroup data drop disk DATA_0004 ;

select * from V$ASM_DISK_IOSTAT ;
select * from V$ASM_OPERATION ;








-- --- ---- -------- Apagar plano de execução

select ADDRESS, HASH_VALUE from V$SQLAREA where SQL_ID = 21aq24s9s1n69;

exec DBMS_SHARED_POOL.PURGE ('000000085FD77CF0, 808321886', 'C');

--- --- -- -- 

-- -----------------------------------------------------------------
-- (DBAs) URLs e Procedimentos de Monitoramento:
-- -----------------------------------------------------------------

>> https://cloudcontrol.db.cloud.asdfasdf.com.br:7802/em/login.jsp

>> http://monitoring-nv.cloud.asdfasdf.com.br/prod/check_mk/

>> Monitoramento Check_Mk
http://monitoring.cloud.asdfasdf.com.br/prod


tail -F /u01/app/oracle/diag/rdbms/apex/apex/trace/alert_apex.log
tail -F /u01/app/oracle/diag/rdbms/xxxdwprd/xxxwprd/trace/alert_xxxdwprd.log
tail -F /u01/app/oracle/diag/rdbms/prodbr/prodbr/trace/alert_prodbr.log
tail -F /u01/app/oracle/diag/rdbms/dataguard/dataguard/trace/alert_dataguard.log

-- [RDS]
SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','alert_xxx.log'));             
--^^^^
-- http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.Oracle.html

select message_text from alertlog;
select message_text from listenerlog;

select * from dict where upper(table_name) = upper('v$temp_space_header') ; 



--
/* Bash / Shell / Korn 
To find the largest 10 files (linux/bash):
find . -type f -print0 | xargs -0 du | sort -n | tail -10 | cut -f2 | xargs -I{} du -sh {}

To find the largest 10 directories:
find . -type d -print0 | xargs -0 du | sort -n | tail -10 | cut -f2 | xargs -I{} du -sh {}
Only difference is -type {d:f}.
*/
-- http://www.oracle.com/technetwork/issue-archive/2012/12-jan/o12plsql-1408561.html (date-time / timestamp)
-- https://oracle-base.com/articles/misc/oracle-dates-timestamps-and-intervals 



SELECT tablespace_name "Tablespace",
  SUM(total_bytes)    	/ (1024 * 1024) "Size (MB)",
  SUM(bytes_free)     	/ (1024 * 1024) "Free (MB)",
  ROUND((SUM(bytes_free)  * 100 / SUM(total_bytes)),2) "% Free",
  ROUND(((SUM(total_bytes)-SUM(bytes_free))*100/SUM(total_bytes)),2) "% Used"
FROM
  (SELECT fs.tablespace_name,
	fs.file_name,
	fs.bytes total_bytes,
	df.free_bytes bytes_free
  FROM dba_data_files fs,
	(SELECT file_id,
  	SUM(bytes) free_bytes
	FROM dba_free_space df
	GROUP BY file_id
	) df
  WHERE df.file_id(+)=fs.file_id
  )
GROUP BY tablespace_name
UNION ALL
  (SELECT tablespace_name,
	SUM(bytes_free   	+bytes_used)/(1024*1024),
	SUM(bytes_free)  	/(1024*1024),
	ROUND(SUM(bytes_free)*100/(SUM(bytes_free+bytes_used)),2),
	ROUND(SUM(bytes_used)*100/(SUM(bytes_free+bytes_used)),2)
  FROM v$temp_space_header
  GROUP BY tablespace_name
  )
ORDER BY 1 DESC;


SELECT
    name                                 	group_name
  , sector_size                          	sector_size
  , block_size                           	block_size
  , allocation_unit_size                 	allocation_unit_size
  , state                                	state
  , type                                 	type
  , total_mb                             	total_mb
  , (total_mb - free_mb)                 	used_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
FROM
	v$asm_diskgroup
ORDER BY
	name ;

-- https://jhdba.wordpress.com/2012/03/06/the-mother-of-all-asm-scripts/
-- https://labite.wordpress.com/2012/10/24/scripts-to-monitore-oracle-asm-disks/
-- http://dba.stackexchange.com/questions/36160/how-to-monitor-space-usage-on-asm-diskgroups









$ rlwrap sqlplus / as sysdba

SQL*Plus: Release 11.2.0.4.0 Production on Thu Jan 28 16:08:43 2016

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options

SQL> @sqltrpt.sql


$ pwd
/u01/app/oracle/product/11.2.0/db_1/rdbms/admin


-- -----------------------------------------------------------------------------------------
-- Profiles
-- -----------------------------------------------------------------------------------------
alter profile asdfasdf_profile limit SESSIONS_PER_USER 200;


-- -----------------------------------------------------------------------------------------
-- Show FKs without Indexes
-- -----------------------------------------------------------------------------------------


WITH
ref_int_constraints AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       col.owner,
       col.table_name,
       col.constraint_name,
       con.status,
       con.r_owner,
       con.r_constraint_name,
       COUNT(*) col_cnt,
       MAX(CASE col.position WHEN 01 THEN col.column_name END) col_01,
       MAX(CASE col.position WHEN 02 THEN col.column_name END) col_02,
       MAX(CASE col.position WHEN 03 THEN col.column_name END) col_03,
       MAX(CASE col.position WHEN 04 THEN col.column_name END) col_04,
       MAX(CASE col.position WHEN 05 THEN col.column_name END) col_05,
       MAX(CASE col.position WHEN 06 THEN col.column_name END) col_06,
       MAX(CASE col.position WHEN 07 THEN col.column_name END) col_07,
       MAX(CASE col.position WHEN 08 THEN col.column_name END) col_08,
       MAX(CASE col.position WHEN 09 THEN col.column_name END) col_09,
       MAX(CASE col.position WHEN 10 THEN col.column_name END) col_10,
       MAX(CASE col.position WHEN 11 THEN col.column_name END) col_11,
       MAX(CASE col.position WHEN 12 THEN col.column_name END) col_12,
       MAX(CASE col.position WHEN 13 THEN col.column_name END) col_13,
       MAX(CASE col.position WHEN 14 THEN col.column_name END) col_14,
       MAX(CASE col.position WHEN 15 THEN col.column_name END) col_15,
       MAX(CASE col.position WHEN 16 THEN col.column_name END) col_16,
       par.owner parent_owner,
       par.table_name parent_table_name,
       par.constraint_name parent_constraint_name
  FROM dba_constraints  con,
       dba_cons_columns col,
       dba_constraints par
 WHERE con.constraint_type = 'R'
   AND con.owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS')
   AND con.owner NOT IN ('SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF')
   and con.owner in ('MYOWNBR','MYOWN', 'MYOWNFNX','CATALOGO', 'MYOWN', 'OPMYOWNMEBR', 'MYOWN')
   AND col.owner = con.owner
   AND col.constraint_name = con.constraint_name
   AND col.table_name = con.table_name
   AND par.owner(+) = con.r_owner
   AND par.constraint_name(+) = con.r_constraint_name
 GROUP BY
       col.owner,
       col.constraint_name,
       col.table_name,
       con.status,
       con.r_owner,
       con.r_constraint_name,
       par.owner,
       par.constraint_name,
       par.table_name
),
ref_int_indexes AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       r.owner,
       r.constraint_name,
       c.table_owner,
       c.table_name,
       c.index_owner,
       c.index_name,
       r.col_cnt
  FROM ref_int_constraints r,
       dba_ind_columns c,
       dba_indexes i
 WHERE c.table_owner = r.owner
   AND c.table_name = r.table_name
   AND c.column_position <= r.col_cnt
   AND c.column_name IN (r.col_01, r.col_02, r.col_03, r.col_04, r.col_05, r.col_06, r.col_07, r.col_08,
                         r.col_09, r.col_10, r.col_11, r.col_12, r.col_13, r.col_14, r.col_15, r.col_16)
   AND i.owner = c.index_owner
   AND i.index_name = c.index_name
   AND i.table_owner = c.table_owner
   AND i.table_name = c.table_name
   AND i.index_type != 'BITMAP'
 GROUP BY
       r.owner,
       r.constraint_name,
       c.table_owner,
       c.table_name,
       c.index_owner,
       c.index_name,
       r.col_cnt
HAVING COUNT(*) = r.col_cnt
)
SELECT /*+ NO_MERGE */
       *
  FROM ref_int_constraints c
 WHERE NOT EXISTS (
SELECT NULL
  FROM ref_int_indexes i
 WHERE i.owner = c.owner
   AND i.constraint_name = c.constraint_name
)
 ORDER BY
       1, 2, 3;

-- -----------------------------------------------------------------------------------------
-- Managing Stats
-- -----------------------------------------------------------------------------------------

select * from dba_autotask_client where client_name = 'auto optimizer stats collection' ; 

select * from DBA_AUTOTASK_JOB_HISTORY order by window_start_time desc; 

select * from dba_autotask_client ;

select count(*) from dba_scheduler_job_log where additional_info like '%GATHER_STATS_PROG%' ;

select * from dba_scheduler_job_log where additional_info like '%GATHER_STATS_PROG%' order by log_date desc;

select * from sys.dba_tab_modifications where table_owner = 'DW_CORE';

BEGIN
  DBMS_AUTO_TASK_ADMIN.disable(
    client_name => 'auto optimizer stats collection',
    operation   => NULL,
    window_name => NULL);
END;
/

BEGIN
  DBMS_AUTO_TASK_ADMIN.enable(
    client_name => 'auto optimizer stats collection',
    operation   => NULL,
    window_name => NULL);
END;
/
-- http://docs.oracle.com/cd/E25178_01/server.1111/e16638/stats.htm
-- https://oracle-base.com/articles/11g/automated-database-maintenance-task-management-11gr1
-- https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:1133388300346992024





select  s.username
       ,s.status
       ,s.machine
       ,s.program
       ,s.osuser
       ,count(*) as qtde_conn
    -- ,'alter system kill session '''||s.sid ||','||s.serial#|| ''';' as kill_string
  from  v$session s
       ,v$sqlarea sa
       ,v$process p
 where p.addr=s.paddr
   --and s.sql_exec_start < sysdate - (((1/24)/60)/60)
   and s.username is not null and s.username != 'SYS'
   and s.sql_address=sa.address(+)
   and s.sql_hash_value=sa.hash_value(+)
  --  and  s.status = 'ACTIVE'
group by s.username
       ,s.status
       ,s.machine
       ,s.program
       ,s.osuser 
  order by s.status, s.username, s.program;
  
-- ASM queries and views
https://docs.oracle.com/cd/E11882_01/server.112/e18951/asmviews.htm#OSTMG10030



-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------

 select di.OWNER, di.index_name, ds.bytes/1024/1024 idx_size, di.degree 
  from dba_indexes di
      ,dba_segments ds
 where di.index_name = ds.segment_name
   and di.owner in ('MYOWN2','MYOWN') 
   and di.index_name = 'SYS_C00114326'
 ORDER BY di.owner desc, 3 desc;

-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------



SELECT ROUND(((ur * (ups * dbs)) + (dbs * 24))/ut*100,0) AS "%"
FROM (SELECT VALUE AS ur
      FROM v$parameter
      WHERE NAME = 'undo_retention'),
  (SELECT (SUM (undoblks) / SUM (((end_time - begin_time) * 25200))
  ) AS ups
FROM v$undostat),
  (SELECT block_size AS dbs
   FROM dba_tablespaces
   WHERE tablespace_name = (SELECT VALUE
                            FROM v$parameter
                            WHERE NAME = 'undo_tablespace')),
  (SELECT sum(bytes) as ut
   FROM dba_data_files
   WHERE tablespace_name = (SELECT VALUE
                            FROM v$parameter
                            WHERE NAME = 'undo_tablespace'));
                            
                            
-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------
                           
                            
select TO_CHAR(MIN(Begin_Time),'DD-MON-YYYY HH24:MI:SS')
                 "Begin Time",
    TO_CHAR(MAX(End_Time),'DD-MON-YYYY HH24:MI:SS')
                 "End Time",
    SUM(Undoblks)    "Total Undo Blocks Used",
    SUM(Txncount)    "Total Num Trans Executed",
    MAX(Maxquerylen)  "Longest Query(in secs)",
    MAX(Maxconcurrency) "Highest Conc. Transac. Count",
    SUM(Ssolderrcnt),
    SUM(Nospaceerrcnt)
from V$UNDOSTAT;

-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------

select
    ( select sum(bytes)/1024/1024 from dba_data_files
       where tablespace_name like 'UND%' )  allocated,
    ( select sum(bytes)/1024/1024 from dba_free_space
       where tablespace_name like 'UND%')  free,
    ( select sum(bytes)/1024/1024 from dba_undo_extents
       where tablespace_name like 'UND%') USed
from dual
/

-- https://www.ibm.com/support/knowledgecenter/SSBNJ7_1.4.1/admin/t_tnpm_wls_admin_guide_systemmaint_resizeundotblspaces.html



-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------


SELECT * FROM v$dataguard_stats;
select current_scn from v$database ;  -- rodar no primario e no dataguard para comparar os valores.
select scn_to_timestamp(56940646730 ) at_primary, scn_to_timestamp(56940643347) as at_dataguard from dual  ;


-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------
select 'CREATE SYNONYM '||table_name||' FOR username_schema.'||table_name|| ' ;' as crt_syn from user_tables order by table_name;




-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------

COLUMN TABLE_NAME FORMAT A32
COLUMN OBJECT_NAME FORMAT A32
COLUMN OWNER FORMAT A10

SELECT
   owner, 
   table_name, 
   TRUNC(sum(bytes)/1024/1024) Meg,
   ROUND( ratio_to_report( sum(bytes) ) over () * 100) Percent
FROM
(SELECT segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
 UNION ALL
 SELECT i.table_name, i.owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')
WHERE owner in UPPER('&owner')
GROUP BY table_name, owner
HAVING SUM(bytes)/1024/1024 > 10  /* Ignore really small tables */
ORDER BY SUM(bytes) desc
;



-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------

 $ impdp monitor/xxxxxxx CONTENT=DATA_ONLY DIRECTORY=DATA_PUMP  DUMPFILE=expDP_producao_eu_pxxxxxx.dmp log=impdp_20160928b.log EXCLUDE=TABLE:\"IN \(\'AUDIT_TABLE\',\'LOG_ACOES\',\'EMAIL_FILA\'\) \"  table_exists_action=append  PARALLEL=1




-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------

# ls -la /dev/oracleasm/disks/DATA_2TB_11
brw-rw---- 1 grid oinstall 202, 16385 Nov  7 17:22 /dev/oracleasm/disks/DATA_2TB_11
# ls -la /dev/* | grep "202, 16385"
# oracleasm deletedisk DATA_2TB_11


-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------


DECLARE
   in_filename VARCHAR2(100);
   src_file   BFILE;
   v_content  BLOB;
   v_blob_len INTEGER;
   v_file     utl_file.file_type;
   v_buffer   RAW(32767);
   v_amount   BINARY_INTEGER := 32767;
   v_pos      INTEGER := 1;
BEGIN
    in_filename := 'Test.txt';
   src_file := bfilename('DIR_UTL_COM_TEST', in_filename);
   dbms_lob.fileopen(src_file, dbms_lob.file_readonly);
   v_content  := utl_compress.lz_compress(src_file, 9);
   v_blob_len := dbms_lob.getlength(v_content);
   v_file     := utl_file.fopen('DIR_UTL_COM_TEST',
                                in_filename || '.gz',
                                'wb');
   WHILE v_pos < v_blob_len LOOP
      dbms_lob.READ(v_content, v_amount, v_pos, v_buffer);
      utl_file.put_raw(v_file, v_buffer, TRUE);
      v_pos := v_pos + v_amount;
   END LOOP;
   utl_file.fclose(v_file);

EXCEPTION
   WHEN OTHERS THEN
      IF utl_file.is_open(v_file) THEN
         utl_file.fclose(v_file);
      END IF;
      RAISE;
END;

-- -----------------------------------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------------------------------


--clear columns
--column tablespace format a20
column total_mb format 999,999,999,999.99
column used_mb format 999,999,999,999.99
column free_mb format 999,999,999.99
column pct_used format 999.99
column graph format a25 heading "GRAPH (X=5%)"
column status format a10
compute sum of total_mb on report
compute sum of used_mb on report
compute sum of free_mb on report
break on report
--set lines 200 pages 100
select  total.ts tablespace,
        DECODE(total.mb,null,'OFFLINE',dbat.status) status,
        total.mb total_mb,
        NVL(total.mb - free.mb,total.mb) used_mb,
        NVL(free.mb,0) free_mb,
        DECODE(total.mb,NULL,0,NVL(ROUND((total.mb - free.mb)/(total.mb)*100,2),100)) pct_used,
        CASE WHEN (total.mb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
        ELSE '['|| DECODE(free.mb,
                             null,'XXXXXXXXXXXXXXXXXXXX',
                             NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.mb)/(total.mb) * 100, 2))/5),'X'),20,'-'),
                '--------------------'))||']'
         END as GRAPH
from
        (select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_data_files group by tablespace_name) total,
        (select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name
UNION ALL
select  sh.tablespace_name,
        'TEMP',
        SUM(sh.bytes_used+sh.bytes_free)/1024/1024 total_mb,
        SUM(sh.bytes_used)/1024/1024 used_mb,
        SUM(sh.bytes_free)/1024/1024 free_mb,
        ROUND(SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free)*100,2) pct_used,
        '['||DECODE(SUM(sh.bytes_free),0,'XXXXXXXXXXXXXXXXXXXX',
              NVL(RPAD(LPAD('X',(TRUNC(ROUND((SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free))*100,2)/5)),'X'),20,'-'),
                '--------------------'))||']'
FROM v$temp_space_header sh
GROUP BY tablespace_name
order by 6
/


SQL>  @?/rdbms/admin/sqltrpt.sql;

 rlwrap sqlplus / as sysasm

impdp user@tnshost DIRECTORY=DATA_PUMP_DIR DUMPFILE=dump_file.dmp

imp vschmidt file=dump.20160210.dmp fromuser=userA touser=userB

$ rlwrap sqlplus / as sysdba @sga2.sql

SQL*Plus: Release 11.2.0.4.0 Production on Tue Jan 12 17:16:19 2016

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options


Pool         Name                          Allocated         Free     % Free
------------ -------------------------- ------------ ------------ ----------
shared pool  free memory                 704,643,072   92,554,008      13.13
large pool   free memory                  67,108,864   58,523,648      87.21
java pool    free memory                  33,554,432    1,915,328       5.71
streams pool free memory                  67,108,864   66,416,184      98.97

SQL> quit
Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options
[17:16:33] oracle@prod-dw:monitoring $ more sga2.sql
COLUMN pool    HEADING "Pool"
COLUMN name    HEADING "Name"
COLUMN sgasize HEADING "Allocated" FORMAT 999,999,999
COLUMN bytes   HEADING "Free" FORMAT 999,999,999

SELECT
    f.pool
  , f.name
  , s.sgasize
  , f.bytes
  , ROUND(f.bytes/s.sgasize*100, 2) "% Free"
FROM
    (SELECT SUM(bytes) sgasize, pool FROM v$sgastat GROUP BY pool) s
  , v$sgastat f
WHERE
    f.name = 'free memory'
  AND f.pool = s.pool
/




