-- ---------------------------------------------------------------------------
-- Function to generate test values into the table estate_department_catgory 
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- Function to generate test values into estate_department
-- ---------------------------------------------------------------------------
CREATE FUNCTION f_generate_department_estate_category() returns boolean
  LANGUAGE plpgsql volatile AS
$func$
declare
  total_number_of_rows int := 10000;
begin
	
   -- iteract (loop) from 1 until 'total_number_of_rows'
   -- calling random functions from glue "package"
   -- 
   for i in 1..total_number_of_rows
   loop
	insert into   estate_department_category 
	           (  department_category_description
	             ,gravity
	             ,urgency
	             ,tendency
	            ) 
         values ( f_random_string(51,'md5')
                 ,f_random_between(1,5)  -- based on the business rules here I limit my range from 1,5
                 ,f_random_between(1,5)  --  ditto
                 ,f_random_between(1,5)  --  ditto
                 ); 
   end loop;
   -- XXX: Remove automatically return true and test for errors
   return true;
end 
$func$;
-- ---------------------------------------------------------------------------
select * from f_generate_department_estate_category();
-- ---------------------------------------------------------------------------
-- select * from estate_department_category; 
select min(id), max(id), count(*) from estate_department_category; 
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- Function to generate test values into estate_department
-- ---------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION f_generate_department_estate()
  returns boolean
  language plpgsql volatile as
$func$
declare
  r record;
begin
	
	-- using a CTE I can prepare the values
	-- by calling the functions that obtain
	-- random values and set the scenario
	-- to be inserted later into the
	-- estate_department table
	
	-- note that we start with null,
	-- implying the department in question
	-- has no branch, therefore a root branch
	
	-- Main Unit 
	with categ as (
		 select  null::bigint
		        ,id
		        ,f_random_string(51,'md5')
		        ,f_random_string(500,'md5')
		        ,current_timestamp 
		   from estate_department_category m
	)
	insert into estate_department (id_estate_department_branch_of, id_department_category , description, observation, created_at) 
	( select * from categ ); 
	

    -- Budgeting Unit
    FOR r in  SELECT  id as dep_branch_of_id
                     ,f_random_between(1,10000) as cat_id
                     ,f_random_string(51,'md5') as description
                     ,'Child department '||f_random_string(500,'md5') as observation
                     , current_timestamp   as created_at
                FROM estate_department
	LOOP

		insert into  estate_department (id_estate_department_branch_of, id_department_category , description, observation, created_at) 
             values (r.dep_branch_of_id, r.cat_id, r.description, r.observation , r.created_at);
	END LOOP; 

	-- 3rd layer of estate department (OD)
    FOR r in  SELECT  id as dep_branch_of_id
                     ,f_random_between(1,10000) as cat_id
                     ,f_random_string(51,'md5') as description
                     ,'Child department '||f_random_string(500,'md5') as observation
                     , current_timestamp   as created_at
                FROM estate_department
                where estate_department.id_estate_department_branch_of is not null
	LOOP

		insert into  estate_department (id_estate_department_branch_of, id_department_category , description, observation, created_at) 
             values (r.dep_branch_of_id, r.cat_id, r.description, r.observation , r.created_at);
	END LOOP; 


	return true;
end;
$func$;

-- ---------------------------------------------------------------------------
-- 
-- select * from estate_department ; 
-- 
-- ---------------------------------------------------------------------------
select * from f_generate_department_estate();
-- select * from estate_department; 
-- select * from estate_department where id_estate_department_branch_of is not null; 
-- select * from vw_estate_departments_tree where level = 3; 


CREATE OR REPLACE FUNCTION f_generate_generic(p_table_name varchar(63))
  returns boolean
  language plpgsql volatile as
$func$
declare
 
  -- variable for implicit cursor to map columns per table
  cols record;
  column_name text; 
 
  -- with_query_text
  with_query_insert text;
 
  -- dynamic table to  
  cursor_fetch_tables refcursor;

  -- array columns functions
  col_func jsonb[];
  i int := 0;
 
begin
	
  for cols in (
		select 
		       cl.relname  as table_name
		      ,atr.attname as column_name
		      ,ty.typname as column_type
		      ,atr.attlen as column_length
		      ,atr.attnum as column_order
		  from pg_attribute atr
		      ,pg_type ty
		      ,pg_class cl
		   where atr.atttypid = ty.oid  
		     and cl.oid = atr.attrelid 
		     and cl.relname = quote_ident(p_table_name) 
		     and atr.attnum > 0
		   order by table_name asc, column_order asc
        )
   loop 
	    --
	     column_name := cols.column_name;
	     case cols.column_type 
	       when 'int8' then 
	          col_func := jsonb_insert(col_func , '{columns,'||i::text||',name, type, function }', '{'||column_name || E',int8\',\'f_random_between(1,10000) }' , true) ;
		   when 'varchar' then
		   --  array_append(col_func[i] , [quote_ident(cols.column) ,'int8','f_random_string(500,''md5''')] ) ;
		      null;
		  end case;
			 
	      i:= i+1;
	      raise notice 'Counter (implicit loop) >> %',i;
   end loop;
  
   raise notice 'was here >> %',col_func::text;
        -- with the array above create the WITH to be used during INSERT
        --     build with text for insert based on array
   		-- build the query so we (someone will also give maintenance on this code) 
   		-- could switch for types and define which function to be used
	    -- 
		-- OPEN cursor_fetch_tables 
		--   FOR EXECUTE format('

		--		           with categ as (
		--						 select  null::bigint
		--						        ,id
		--						        ,f_random_string(51,'md5')
		--						        ,f_random_string(500,'md5')
		--						        ,current_timestamp 
		--						   from estate_department_category m
		--					)
		--					insert into estate_department (id_estate_department_branch_of, id_department_category , description, observation, created_at) 
		--					( select * from categ ); 
	    --     , cols.table_name, cols.column, cols.column_type, cols.column_length, cols.column_order) 
	    --      USING keyvalue;
	    -- loop
	    -- OPEN curs1 FOR EXECUTE format('SELECT * FROM %I WHERE col1 = $1',tabname) USING keyvalue;

   return true;

exception 
   when others then
      raise notice 'Error >> %s',SQLERRM;
      return false;
end;
$func$;


select * from  f_generate_generic(p_table_name => 'estate_department' ) ; 



OR recordvar IN bound_cursorvar [ ( [ argument_name := ] argument_value [, ...] ) ] LOOP
    statements
END LOOP [ label ];

     
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------



create table accounting_event(
	 id 							bigserial		primary key
	,event_name 					varchar(255)	not null
	,description 					varchar(1024)	not null
	,observation					text			not null
	,purpose_function				text			not null
);

-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------





-- -----------------------------------------------------------------------------
-- Function to increment a specific account
-- Returns False if ERROR or not Balance in any of the accounts
-- -----------------------------------------------------------------------------
create or replace function addValueBasedOnEvent(p_event int, p_value double precision ) 
RETURNS boolean AS $$
begin
		null;
exception
	when others then 
	  raise notice 'Unexpected error %',errm;  
end;
$$ language plpgsql;


-- -----------------------------------------------------------------------------
-- Obtain account balance
-- -----------------------------------------------------------------------------
create or replace function getAccountBalance(p_account in int) 
returns double precision as $$
begin
		null;
exception
	when others then 
	  raise notice 'Unexpected error %',errm;
end;
$$ language plpgsql;

-- -----------------------------------------------------------------------------
-- Obtain account, try to add value and that single account and return the balance
-- -----------------------------------------------------------------------------
create or replace function addValueOnAccount(p_account in int, p_value in double precision) 
returns double precision as $$
begin
	  null;
exception
	when others then 
	  raise notice 'Unexpected error %',errm;	
end;
$$ language plpgsql;

-- -----------------------------------------------------------------------------
-- 
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_generate_department_estate_category()
  RETURNS TABLE (name text
               , round int
               , result double precision)
  LANGUAGE plpgsql STABLE AS
$func$
DECLARE
   r mytable%ROWTYPE;
BEGIN
   -- init vars
   name   := 'A';  -- we happen to know initial value
   round  := 1;    -- we happen to know initial value
   result := 1;

   FOR i in 1..1000
   LOOP
      IF (r.name, r.round) <> (name, round) THEN   -- return result before round
         RETURN NEXT;
         name   := r.name;
         round  := r.round;
         result := 1;
      END IF;

      result := result * (1 - r.val/100);
   END LOOP;

   RETURN NEXT;   -- return final result
END
$func$;


-- -----------------------------------------------------------------------------
-- Here we have a loop to insert into department state
-- https://stackoverflow.com/questions/8918755/postgresql-function-with-a-loop
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_generate_department_estate_category()
  RETURNS TABLE (name text
               , round int
               , result double precision)
  LANGUAGE plpgsql STABLE AS
$func$
DECLARE
   r mytable%ROWTYPE;
BEGIN
   -- init vars
   name   := 'A';  -- we happen to know initial value
   round  := 1;    -- we happen to know initial value
   result := 1;

   FOR r in  SELECT *
      FROM   mytable m
      WHERE  m.name = name
      ORDER  BY m.round
   LOOP
      IF (r.name, r.round) <> (name, round) THEN   -- return result before round
         RETURN NEXT;
         name   := r.name;
         round  := r.round;
         result := 1;
      END IF;

      result := result * (1 - r.val/100);
   END LOOP;

   RETURN NEXT;   -- return final result
END
$func$;



-- https://stackoverflow.com/questions/3970795/how-do-you-create-a-random-string-thats-suitable-for-a-session-id-in-postgresql
Create or replace function random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;


-- -----------------------------------------------------------------------------------------------------
--
-- -----------------------------------------------------------------------------------------------------
 select  *
   from  estate_department_class edc 








