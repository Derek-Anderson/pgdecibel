/*
Copyright (C) 2016  Metropolitan Airports Commission

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/


-- Only allow this SQL to be run by loading as an extension.
\echo Use "CREATE EXTENSION decibel" to load this file. \quit

-- Base type required empty definition
CREATE TYPE decibel;

-- C functions for converting between dB and pascals
CREATE FUNCTION decibelpascal(float8)  RETURNS float8 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION pascaldecibel(float8)  RETURNS float8 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION       pascals(decibel) RETURNS float8 AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

-- C functions for converting to and from cstring using the log math to do the appropriate backend conversion
CREATE FUNCTION decibel_in(cstring)  RETURNS decibel AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;
CREATE FUNCTION decibel_out(decibel) RETURNS cstring AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

-- Actual definition of the decibel type
CREATE TYPE dB ( INPUT = decibel_in, OUTPUT = decibel_out, LIKE = pg_catalog.float8 );

-- Functions used for the casts. All these just pass through the text representation to convert
CREATE OR REPLACE FUNCTION decibel(float8)  RETURNS dB AS 'SELECT $1::text::dB' LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION decibel(float4)  RETURNS dB AS 'SELECT $1::text::dB' LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION decibel(int2)    RETURNS dB AS 'SELECT $1::text::dB' LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION decibel(int4)    RETURNS dB AS 'SELECT $1::text::dB' LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION decibel(int8)    RETURNS dB AS 'SELECT $1::text::dB' LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION decibel(numeric) RETURNS dB AS 'SELECT $1::text::dB' LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION float8(dB)  RETURNS float8  AS 'SELECT $1::text::float8'  LANGUAGE SQL IMMUTABLE STRICT COST 1;
CREATE OR REPLACE FUNCTION num(dB)     RETURNS numeric AS 'SELECT $1::text::numeric' LANGUAGE SQL IMMUTABLE STRICT COST 1;

-- Casts
CREATE CAST (float8 AS dB)  WITH FUNCTION decibel(float8)  AS IMPLICIT;
CREATE CAST (float4 AS dB)  WITH FUNCTION decibel(float4)  AS IMPLICIT;
CREATE CAST (int2 AS dB)    WITH FUNCTION decibel(int2)    AS IMPLICIT;
CREATE CAST (int4 AS dB)    WITH FUNCTION decibel(int4)    AS IMPLICIT;
CREATE CAST (int8 AS dB)    WITH FUNCTION decibel(int8)    AS IMPLICIT;
CREATE CAST (numeric AS dB) WITH FUNCTION decibel(numeric) AS IMPLICIT;
CREATE CAST (dB AS numeric) WITH FUNCTION num(dB)     AS IMPLICIT;
CREATE CAST (dB AS float8)  WITH FUNCTION float8(dB)  AS IMPLICIT;


-- Functions used to back the operators
CREATE OR REPLACE FUNCTION decibel_sum(dB,dB) RETURNS dB AS 'float8pl'  LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_mi(dB,dB)  RETURNS dB AS 'float8mi'  LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_mul(dB,dB) RETURNS dB AS 'float8mul' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_div(dB,dB) RETURNS dB AS 'float8div' LANGUAGE INTERNAL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION decibel_sum(dB,float8) RETURNS dB AS 'float8pl' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_mi(dB,float8) RETURNS dB AS 'float8mi' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_div(dB,float8)  RETURNS dB AS 'float8div' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_mul(dB,float8)  RETURNS dB AS 'float8mul' LANGUAGE INTERNAL IMMUTABLE STRICT;

--CREATE FUNCTION decibel_mi(decibel,float8)   RETURNS decibel AS 'SELECT ($1::text::float8 - $2)::decibel'  LANGUAGE SQL IMMUTABLE STRICT;
--CREATE FUNCTION decibel_sum(decibel,float8)  RETURNS decibel AS 'SELECT ($1::text::float8 + $2)::decibel'  LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION decibel_eq(dB,dB) RETURNS boolean AS 'float8eq' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_ge(dB,dB) RETURNS boolean AS 'float8ge' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_gt(dB,dB) RETURNS boolean AS 'float8gt' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_le(dB,dB) RETURNS boolean AS 'float8le' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_lt(dB,dB) RETURNS boolean AS 'float8lt' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION decibel_ne(dB,dB) RETURNS boolean AS 'float8ne' LANGUAGE INTERNAL IMMUTABLE STRICT;

-- Mathmatical Operator definitions
CREATE OPERATOR +  ( PROCEDURE = decibel_sum, LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR +  ( PROCEDURE = decibel_sum, LEFTARG=dB, RIGHTARG=float8  ); 
CREATE OPERATOR /  ( PROCEDURE = decibel_div, LEFTARG=dB, RIGHTARG=dB  );
CREATE OPERATOR /  ( PROCEDURE = decibel_div, LEFTARG=dB, RIGHTARG=float8  );
CREATE OPERATOR *  ( PROCEDURE = decibel_mul, LEFTARG=dB, RIGHTARG=dB  );
CREATE OPERATOR *  ( PROCEDURE = decibel_mul, LEFTARG=dB, RIGHTARG=float8  );
CREATE OPERATOR -  ( PROCEDURE = decibel_mi,  LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR -  ( PROCEDURE = decibel_mi,  LEFTARG=dB, RIGHTARG=float8  ); 

-- Comparative Operator definitions
CREATE OPERATOR =  ( PROCEDURE = decibel_eq,  LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR <  ( PROCEDURE = decibel_lt,  LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR <= ( PROCEDURE = decibel_le,  LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR >  ( PROCEDURE = decibel_gt,  LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR >= ( PROCEDURE = decibel_ge,  LEFTARG=dB, RIGHTARG=dB );
CREATE OPERATOR != ( PROCEDURE = decibel_ne,  LEFTARG=dB, RIGHTARG=dB );

-- Functions used for min/max aggregates
CREATE FUNCTION decibel_smaller(dB,dB) RETURNS decibel AS 'float8smaller' LANGUAGE INTERNAL IMMUTABLE STRICT;
CREATE FUNCTION decibel_larger(dB,dB)  RETURNS decibel AS 'float8larger'  LANGUAGE INTERNAL IMMUTABLE STRICT;

-- Functiond used for avg aggregate
CREATE FUNCTION decibel_accum(float8[],decibel) RETURNS float8[] AS $$
  SELECT ARRAY[$1[1]+pascals($2),$1[2]+1];
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION decibel_avg(float8[]) RETURNS decibel AS $$
  SELECT pascaldecibel($1[1] / $1[2])::decibel
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Aggregate Functions
CREATE AGGREGATE sum(dB) ( sfunc = decibel_sum, stype = dB );
CREATE AGGREGATE avg(dB) ( sfunc = decibel_accum, stype = float8[], finalfunc=decibel_avg, initcond='{0,0,0}' );
CREATE AGGREGATE max(dB) ( sfunc = decibel_larger,  stype=dB );
CREATE AGGREGATE min(dB) ( sfunc = decibel_smaller, stype=dB );
--*/
