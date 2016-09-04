module Usmort

using MySQL, DataFrames

export ageca, caprop

ageres = DataFrame(AgeRe27 = collect(1:27), 
	agest = [0;1/12;collect(1:4);collect(5:5:100);-1])

concstr = "CONCAT("
for i in 1:19
	concstr = string(concstr, "Ent", i, ",")
end
concstr = string(concstr, "Ent20)")

function ageca(year, sex, uc, ent = "[A-Y]")
	con = mysql_connect("localhost", "usmuser", "usmort", "Usmort")
	mysql_stmt_prepare(con,
		"""SELECT AgeRe27 FROM Usdeaths WHERE Datayear = ? 
		AND Sex = ? AND UcIcd REGEXP ? AND $concstr REGEXP ?""")
	df = mysql_execute(con,
		[MYSQL_TYPE_SHORT, MYSQL_TYPE_VARCHAR, 
		MYSQL_TYPE_VARCHAR, MYSQL_TYPE_VARCHAR],
		[year, sex, uc, ent])
	mysql_disconnect(con)
	dfre = by(df, :AgeRe27, df -> DataFrame(N=size(df,1)))
	dfrej = sort!(join(ageres, dfre, on = :AgeRe27, kind = :left))
	dfrej[isna(dfrej[:N]), :N] = 0
	return dfrej
end

function caprop(caf1, caf2)
	return DataFrame(AgeRe27 = caf1[:AgeRe27], agest = caf1[:agest], 
		prop = caf1[:N]./caf2[:N])
end

end # module
