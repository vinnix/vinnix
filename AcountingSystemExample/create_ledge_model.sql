
-- ---------------------------------------------------------------------------
-- Accounting System Based on Integrated Finances Ledge Mechanism
-- 
-- “Follow me.” 
-- 
--    https://en.wikipedia.org/wiki/Thomas_Aquinas
--    https://en.wikipedia.org/wiki/Saint_Joseph
--    https://en.wikipedia.org/wiki/Matthew_the_Apostle
-- 
-- This is an initially "basic" system with the intention of teach, practice
-- and consolidate some of my memories and experiences I had by programing and
-- learning accouting. From ancient times, when in family conversations, school
-- and past work experiences.
--
-- "Jesus Saves" (therefore hit "Control-S" everyone and then) ;-) 
-- 
-- Copyright 2024 © Vinícius Abrahão Bazana Schmidt
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- Technical Sugestions:
-- ---------------------------------------------------------------------------
-- Before inquiring for specific questions I should have used to regular data-types
-- https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-NUMERIC-TABLE
--
-- and how to create functions and triggers:
--
-- https://www.postgresql.org/docs/current/sql-createfunction.html
-- https://www.postgresql.org/docs/current/sql-createtrigger.html
-- 
-- ---------------------------------------------------------------------------

-- New and Remarkable Features:

-- Hash for each important record that prevent manual intervention directly on database
-- The idea is only the system and the key-owner can add a value in the ledge
-- The key is compiled inside the database/keystore
-- Infinit departments 
-- ---------------------------------------------------------------------------



-- "ABSOLUTELY"[?] ALL TABLES WILL BE LOGGED FOR EACH TRANSCTION
-- 

-- ---------------------------------------------------------------------------
-- This table is used solely and only to clasify and categorise what I
-- as 'estate_department' and should NEVER be used for accounting purposes
-- It may help you to break, reports and even politically restructure a department
-- ---------------------------------------------------------------------------
create table estate_department_category (
	 id						       bigserial	 	primary key
	,department_category_description  text 			not null
	,gravity					   smallint			default 3
	,urgency					   smallint 		default 3
	,tendency					   smallint			default 3
);


-- ---------------------------------------------------------------------------
-- It's not necessary to specify the 'child' as it can be referenced from 
-- "bottom to up", using those records that has no "father". 
-- 
-- However, technically, speaking I am using a self-referenced table, therefore
-- it can be broken into initifity levels of departments, not only 3.
-- 
-- ---------------------------------------------------------------------------
create table estate_department (
	 id					 			bigserial		primary key
	,id_estate_department_branch_of bigint			null
	,id_department_category			bigint			not null
	,description					varchar(1000)	not null
	,observation					text			not null
	,created_at						timestamp		not null
 	,constraint 					fk_estate_department_branch_of
      foreign key					(id_estate_department_branch_of) 
      references estate_department	(id)
 	,constraint 					fk_estate_department_category
      foreign key					(id_department_category) 
      references estate_department_category	(id)  
);


-- ---------------------------------------------------------------------------
-- Recursive View to map multi-layer (N:M) estate departments
--  Inspired on: https://stackoverflow.com/questions/24898681/what-is-the-equivalent-postgresql-syntax-to-oracles-connect-by-start-with
-- ---------------------------------------------------------------------------
create or replace view vw_estate_departments_tree as (
	 with recursive cte as (
	       select 
		          1 as level
		         ,id
		         ,id_estate_department_branch_of
		         ,ed.description
		         ,ed.id_department_category
		         ,ed.observation
		     from estate_department ed
		    where id_estate_department_branch_of is null
	  union all
		 select  c.level + 1 as level
		        ,ed.id
		       	,ed.id_estate_department_branch_of
		       	,ed.description
		       	,ed.id_department_category
		       	,ed.observation
		   from  cte c
		   join estate_department ed
		   on ( c.id = ed.id_estate_department_branch_of )
	     ) select * 
		     from cte
		    order by level
  ) ;

		
select * from 	vw_estate_departments_tree;
 
		         
		   -- alter table estate_department drop column id_department_category;     
		    -- no need to drop the column, because, we can have a _history / _log
            -- table that saves the category of each change
 -- ---------------------------------------------------------------------------
-- Events used to "dispatch" money/values into multiple accounts depending
-- on the nature of the account
-- Partitioned by Fiscal Year
-- ---------------------------------------------------------------------------
create table accounting_event(
	 id 							bigserial		primary key
	,event_name 					varchar(255)	not null
	,description 					varchar(1024)	not null
	,observation					text			not null
	,purpose_function				text			not null
);


-- ---------------------------------------------------------------------------
-- Accounting table (representation of accounts)
-- Partitioned by Fiscal Year
-- ---------------------------------------------------------------------------
create table account(
	 id									 bigserial		primary key
	,acc_number							 varchar(255)	not null
	,description						 varchar(1024)	not null
	,observation						 text			not null
	,fiscal_year						 smallint		not null
	,allow_invert_balance				 boolean		not null default 'false'
	,alarm_when_trying_to_invert_balance boolean		not null default 'true'
	,nature_of_account 					 char(1) 		
	,constraint check_nature_account 	 check(nature_of_account in('C','D'))
);

-- ---------------------------------------------------------------------------
-- Connection between each event and its accounts
--
--  accounting_event[N:M] <---> account[N:M]
-- ---------------------------------------------------------------------------
create table event_launches_into_account(
	 event_id					 		 bigint
	,launch_order						 bigint
	,account_source_id					 bigint
	,account_destiny_id					 bigint
	,description						 text			not null
	,allow_launch_invert_balance		 boolean		not null
	,alarm_when_trying_to_invert_balance boolean		not null
	,nature_of_operation				 char(1)		not	null
	,constraint check_nature_operation 	 check(nature_of_operation in('C','D'))
 	,constraint 						 fk_laucher_account_src
      foreign key 						 (account_source_id) 
      references 						 account (id)
  	,constraint 						 fk_laucher_account_dstny
      foreign key 						 (account_destiny_id) 
      references 						 account (id)
	,constraint 						 fk_laucher_event
      foreign key 						 (event_id) 
      references accounting_event		 (id)
    ,primary key						 (event_id, launch_order, account_source_id, account_destiny_id)
);

-- ---------------------------------------------------------------------------
-- 
-- Ledge System
-- 
-- ---------------------------------------------------------------------------
create table ledge_oltp (
	 id 				    	bigserial not null
	,id_fiscal_year				bigint    not null   
	,id_fiscal_quarter			bigint    not null
	,value				 		real	  not null
	,account_source_id			bigint    not null
	,account_destiny_id			bigint    not null
	,event_id					bigint    not null
	,launch_order				bigint    not null
	,id_estate_department		bigint    not null
	,id_bill					bigint    not null
	,id_project					bigint	  not null
	,id_budget					bigint    not null
	,id_order_to_pay			bigint    null
	,inserted_at 				timestamp not null
	,extra_attributes 			jsonb	  not null
	,security_hash 				text 	  not null
	,constraint 						 fk_laucher_has
      foreign key 						 (  event_id
      									   ,launch_order
                                           ,account_source_id
                                           ,account_destiny_id
                                          ) 
      references event_launches_into_account ( event_id
      										  ,launch_order
                                              ,account_source_id
                                              ,account_destiny_id
                                              )
   	,constraint 					fk_estate_department
      foreign key					(id_estate_department) 
      references estate_department	(id)
    ,primary key				    (id)
 );
create index idx_ledge_fiscal_year_month on ledge_oltp (id_fiscal_year, id_fiscal_quarter) ;



