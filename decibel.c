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

#include "postgres.h"
#include <string.h>
#include "fmgr.h"
#include "utils/geo_decls.h"
#include "utils/formatting.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

typedef float8 decibel_t;

#define DecibelGetDatum(x) Float8GetDatum(x)
#define DatumGetDecibel(x) DatumGetFloat8(x)
#define PG_GETARG_DECIBEL(n) DatumGetDecibel(PG_GETARG_DATUM(n))
#define PG_RETURN_DECIBEL(x) return DecibelGetDatum(x)

Datum decibel_to_pascal(PG_FUNCTION_ARGS);
Datum pascal_to_decibel(PG_FUNCTION_ARGS);
Datum pascals(PG_FUNCTION_ARGS);
Datum decibel_in(PG_FUNCTION_ARGS);
Datum decibel_out(PG_FUNCTION_ARGS);
Datum decibel_sum(PG_FUNCTION_ARGS);


/* by value */

PG_FUNCTION_INFO_V1(decibel_to_pascal);

Datum
decibel_to_pascal(PG_FUNCTION_ARGS)
{
    float8   arg = PG_GETARG_FLOAT8(0);
    PG_RETURN_FLOAT8( pow( 10, arg / 10.0 ));
}

PG_FUNCTION_INFO_V1(pascal_to_decibel);

Datum
pascal_to_decibel(PG_FUNCTION_ARGS)
{
    float8   arg = PG_GETARG_FLOAT8(0);
    PG_RETURN_FLOAT8( 10 * log10(arg) );
}

PG_FUNCTION_INFO_V1(pascals);
Datum
pascals(PG_FUNCTION_ARGS)
{
    float8   arg = PG_GETARG_DECIBEL(0);
    PG_RETURN_FLOAT8( arg );
}

PG_FUNCTION_INFO_V1(decibel_in);
Datum
decibel_in(PG_FUNCTION_ARGS)
{
  char *val_str = PG_GETARG_CSTRING(0);
  float8 inval = atof( val_str );
  PG_RETURN_DECIBEL( pow( 10, inval / 10.0) );
}

PG_FUNCTION_INFO_V1(decibel_out);
Datum
decibel_out(PG_FUNCTION_ARGS)
{
  float8 val = 10 * log10( PG_GETARG_DECIBEL(0) );
  char* outval = (char*)malloc(255);
  sprintf(outval, "%.*lG", 15, val );
  PG_RETURN_CSTRING(outval);
}
