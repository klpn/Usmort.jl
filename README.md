# Usmort

[![Build Status](https://travis-ci.org/klpn/Usmort.jl.svg?branch=master)](https://travis-ci.org/klpn/Usmort.jl)

This package can be used to perform statistical analysis on [mortality data
files available from
CDC](http://www.cdc.gov/nchs/data_access/vitalstatsonline.htm). The SQL import
scripts should work with data files from 2005 and later; you should, however,
review the
[documentation](http://www.cdc.gov/nchs/nvss/mortality_public_use_data.htm) 
for the years you are interested in in order to understand the structure of the
files.

##Setup
It is assumed that you have Julia installed, as well as access to a
MySQL/MariaDB server where you can create databases.

1. Use the file `src/Usmort.sql` to create the database and the `usmuser` account
   with SELECT rights on the database tables, e.g.  `mysql -u root -p
   <Usmort.sql`.
2. Download the zipped data file for the year you are interested in e.g.  `wget
   ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/DVS/mortality/mort2006us.zip`
   Unzip the file.
   Note that the size of the uncompressed data file is more that 1 GB.
3. Rename the uncompressed data file to `usdeaths` and use
   `src/Usdeathsimp.sql` to import it into the database, e.g.  `mysql -u root -p
   --local-infile=1 <Usdeathsimp.sql`.

##Usage
The function `ageca` is used to build a DataFrame with the number of deaths for
a given sex and year matching regular expressions in the underlying cause of
death and the concatenation of the entity-axis conditions on the death certificate,
grouped by 27 age groups. The function `caprop` returns a DataFrame with the
relative number of deaths for a pair of frames returned by `ageca`.

In order to retrieve all deaths for males in 2006:
```julia
using Usmort
totexpr = "[A-Y]"
totm06 = ageca(2006, "M", totexpr)
```

In order to retrieve all deaths among females in 2006, with influenza or
pneumonia on the death certificate, and then calculate the proportion of these
deaths with circulatory disease as underlying cause:
```julia
using Usmort
totexpr = "[A-Y]"
influiexpr =  "J(09|1[0-8])"
circexpr = "I|F01"
influi06ent = ageca(2006, "F", totexpr, influiexpr)
circinfluif06ent = ageca(2006, "F", circexpr, influiexpr)
circinfluif06entp = caprop(circinfluif06ent, influif06ent)
```

Queries can be refined by using keywords in the `ageca` calls. If a par of
numbers `[a,b]` is given as values of the `edu89` and `edu03` keyword arguments,
the query will select records with the person's education coded according to
the 1989 and 2003 standards with the education level within the interval
defined by `[a,b]`.

Further keyword arguments may be given in the format `Field = [expression,
operator, type]`, where `expression` is an expression to match, `operator` is
the name of a MySQL comparison operator or function like `REGEXP`, and `type`
is a MySQL data type (see the documentation to the [MySQL
package](https://github.com/JuliaDB/MySQL.jl)). See
[`src/Usdeathsimp.sql`](https://github.com/klpn/Usmort.jl/blob/master/src/Usdeathsimp.sql)
for valid field names (and compare their position with the documentation for
the data files). In order to retrieve all 2006 deaths among never-married
females with lower than high school education:
```julia
using Usmort, MySQL
totexpr = "[A-Y]"
lowed89 = [0,8]
lowed03 = [1,1]
totflowedsing06 = ageca(2006, "F", totexpr; edu89 = lowed89, edu03 = lowed03,
	Mart = ["S", "=",  MYSQL_TYPE_VARCHAR])
```

The performance of queries can often be improved by adding indexes on e.g. the
`Sex` and `Datayear` fields in the `Usdeaths` table.
