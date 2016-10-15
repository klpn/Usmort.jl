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

Data for some causes of death and dimensions such as race, level of education,
martial status and place of death is imported from the file
[`data/usmort.json`](https://github.com/klpn/Usmort.jl/blob/master/data/usmort.json),
which can be easily extended.

In order to retrieve all deaths for males in 2006:
```julia
using Usmort
totexpr = Usmort.cas[:tot][:expr] 
totm06 = ageca(2006, :M, totexpr)
```

In order to retrieve all deaths among females in 2006 with respiratory
infection (ICD-10 J00--J22) on the death certificate, and then calculate
the proportion of these deaths with circulatory disease as underlying cause:
```julia
using Usmort
totexpr = Usmort.cas[:tot][:expr] 
respinfexpr = Usmort.cas[:respinf][:expr] 
circexpr = Usmort.cas[:circ][:expr] 
respinf06ent = ageca(2006, :F, totexpr, respinfexpr)
circrespinff06ent = ageca(2006, :F, circexpr, respinfexpr)
circrespinff06entp = caprop(circrespinff06ent, respinff06ent)
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
totexpr = Usmort.cas[:tot][:expr] 
lowed89 = [0,8]
lowed03 = [1,1]
totflowedsing06 = ageca(2006, :F, totexpr; edu89 = lowed89, edu03 = lowed03,
	Mart = ["S", "=",  MYSQL_TYPE_VARCHAR])
```

The performance of queries can often be improved by adding indexes on e.g. the
`Sex` and `Datayear` fields in the `Usdeaths` table.

There are some functions to help with visualization along the dimensions
defined in `data/usmort.json`. Plots are made with
[matplotlib](https://github.com/matplotlib/matplotlib), called via
[PyPlot](http://github.com/JuliaPy/PyPlot.jl).

In order to plot age-specific proportions of deaths in 2006 due to tumors (as
underlying cause) among females for different levels of education:
```julia
using Usmort
ed06ftot = framedict(2006, :F, :tot, :ed)
ed06ftum = framedict(2006, :F, :tum, :ed)
propplot(ed06ftum, ed06ftot)
```

In order to plot age-specific proportions of deaths in 2006 due to respiratory
infection (as mentioned on the death certificate) among females for different
levels of education:
```julia
using Usmort
ed06ftot = framedict(2006, :F, :tot, :ed)
ed06ftotrespinf = framedict(2006, :F, :tot, :ed, :respinf)
propplot(ed06ftotrespinf, ed06ftot)
```

In order to plot age-specific proportions of deaths in 2006 due to respiratory
infection among females stacked by place of death:
```julia
using Usmort
place06frespinf  = framedict(2006, :F, :respinf, :dplace)
stackdimplot(place06frespinf)
```

In order to plot age-specific proportions of deaths in 2006 and 2014 due to
tumors among females with short education:
```julia
using Usmort
ed06ftot = framedict(2006, :F, :tot, :ed)
ed06ftum = framedict(2006, :F, :tum, :ed)
ed14ftot = framedict(2014, :F, :tot, :ed)
ed14ftum = framedict(2014, :F, :tum, :ed)
edftum = [ed06ftum, ed14ftum]
edftot = [ed06ftot, ed14ftot]
groupyearplot(edftum, edftot, 1)
```
