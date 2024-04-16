-- -----------------------------------------------------------------------------
-- Try to increment value based on a single event
-- Observed and get from: 
-- https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-random-range/
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_random_between(low INT ,high INT) 
   RETURNS INT AS
$$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$ language 'plpgsql' STRICT;

-- -----------------------------------------------------------------------------
-- Generate Random String Based
-- author: Vinícius Abrahão Bazana Schmidt with help of many
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_random_string(p_size int, p_method varchar(10)) 
   RETURNS TEXT AS
$$
declare
   v_aux text ;	
begin
	
   -- here we choose the method to 
   -- be used during the string generation
   -- with that we achieve ways of testing 
   -- randomization
   case p_method
	   	when 'md5' then
	   	   v_aux :=  md5(random()::text);
	   	when 'sha256' then
	   	   v_aux := encode(sha256('foo'::bytea), 'hex') ;
	   	else
	   	  null;
	end case;
   	-- here I verify if there is enough from
   	-- the pre-established functions md5/sha256
   	-- in that case we trim/substr the string
   	-- otherwise we repeat until achieve the aprox. size
    if length(v_aux) > p_size
   	then
   	   v_aux :=  substr(v_aux,1,p_size);
   	else
   	   v_aux :=  repeat(v_aux, ( p_size / length(v_aux))::int  ) ;
   	end if;
   return v_aux;
END;
$$ language 'plpgsql' STRICT;