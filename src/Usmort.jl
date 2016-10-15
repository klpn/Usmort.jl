module Usmort

using MySQL, DataFrames, PyCall, PyPlot
import JSON
export ageca, caprop, framedict, propplot, stackdimplot, groupyearplot

datapath = joinpath(Pkg.dir("Usmort"), "data", "usmort.json")
usmortdata = JSON.parsefile(datapath; dicttype = Dict{Symbol,Any})
dims = usmortdata[:dims]
cas = usmortdata[:cas]
sexlabels = usmortdata[:sexlabels]

PyDict(matplotlib["rcParams"])["axes.formatter.use_locale"] = true

ageres = DataFrame(AgeRe27 = collect(1:27), 
	agest = [0;1/12;collect(1:4);collect(5:5:100);-1])

concstr = "CONCAT("
for i in 1:19
	concstr = string(concstr, "Ent", i, ",")
end
concstr = string(concstr, "Ent20)")

function ageca(year, sex, uc, ent = "[A-Y]";
	edu89 = [0, 99], edu03 = [1, 9], kwargs...)
	qstr = """SELECT AgeRe27 FROM Usdeaths WHERE Datayear = ? 
		AND Sex = ? AND UcIcd REGEXP ? AND $concstr REGEXP ?"""
	partypes = [MYSQL_TYPE_SHORT, MYSQL_TYPE_VARCHAR, 
		MYSQL_TYPE_VARCHAR, MYSQL_TYPE_VARCHAR]
	pars = [year, string(sex), uc, ent]
	if edu89[2]-edu89[1]<99
		qstr = """$qstr AND ((Edurep=0 AND Edu89>=? AND Edu89<=?) 
		OR (Edurep=1 AND Edu03>=? AND Edu03<=?))"""
		partypes = [partypes; fill(MYSQL_TYPE_SHORT, 4)]
		pars = [pars; edu89[1]; edu89[2]; edu03[1]; edu03[2]]
	end
	for (key, val) in kwargs
		qstr = "$qstr AND $key $(val[2]) ?"
		partypes = [partypes; val[3]]
		pars = [pars; val[1]]
	end
	con = mysql_connect("localhost", "usmuser", "usmort", "Usmort")
	mysql_stmt_prepare(con, qstr)
	df = mysql_execute(con, partypes, pars)
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

function framedict(year, sex, uc, dim, ent = :tot; extraargs...)
	frames = []
	groupdicts = dims[dim][:groups]
	extraargsdict = Dict(extraargs)
	for grno in 1:size(groupdicts, 1)
		code = groupdicts[grno][:code]
		if dim == :ed
			dimdict = Dict(
				:edu89 => [code[1], code[2]],
				:edu03 => [code[3], code[4]],
				)
		else
			dimdict = Dict(
				dim => [code, "=", UInt32(dims[dim][:sqltype])]
				)
		end
		pardict = merge(extraargsdict, dimdict)
		frame = ageca(year, sex, cas[uc][:expr], cas[ent][:expr]; pardict...)
		push!(frames, frame)
	end
	ns = map((x)->x[:N], frames)
	totframe = copy(frames[1])
	totframe[:N] = foldr(.+, ns)

	return Dict(:year=>year, :sex=>sex, :uc=>uc, :dim=>dim, :ent=>ent, :frames=>frames,
		:totframe=>totframe)
end

function calabel(framedict)
	if framedict[:ent] == :tot
		return cas[framedict[:uc]][:label]
	else
		return "($(cas[framedict[:uc]][:label])|$(cas[framedict[:ent]][:label]))"
	end
end

function propplot(framedict1, framedict2, ages = 10:26)
	groupdicts = dims[framedict1[:dim]][:groups]
	for grno in 1:size(groupdicts, 1)
		prop = caprop(framedict1[:frames][grno],
			framedict2[:frames][grno])
		plot(prop[ages, :agest], prop[ages, :prop],
			label = groupdicts[grno][:label])
	end
	yr = framedict1[:year]
	sexlabel = sexlabels[framedict1[:sex]]
	ca1label = calabel(framedict1)
	ca2label = calabel(framedict2)
	dimlabel = dims[framedict1[:dim]][:label]
	xlabel("Ålder")
	ylabel("Dödsfall $ca1label/$ca2label")
	title("Andel dödsfall givet $dimlabel $sexlabel USA $yr")
	legend(loc=2, framealpha = 0.5)
	grid(1)
	show()
end

function stackdimplot(framedict, ages = 10:26)
	propars = map((x) -> caprop(x, framedict[:totframe])[:prop],
		framedict[:frames])
	propars_ages = map((x) -> x[ages], propars)
	dimlabs = map((x)->x[:label], dims[framedict[:dim]][:groups])
	stackplot(framedict[:totframe][ages, :agest], propars_ages,
		labels = dimlabs,
		colors = ["b","g","r","c","m","y","k","w"])
	yr = framedict[:year]
	sexlabel = sexlabels[framedict[:sex]]
	dimlabel = ucfirst(dims[framedict[:dim]][:label])
	xlabel("Ålder")
	ylabel("Andel")
	title("$dimlabel givet dödsorsak $(calabel(framedict)) $sexlabel USA $yr")
	ylim(0,1)
	legend(loc=2, framealpha = 0.5)
	show()
end

function groupyearplot(framedicts1, framedicts2, grno, ages = 10:26)
	for fdind in 1:size(framedicts1, 1)
		framedict1 = framedicts1[fdind]
		framedict2 = framedicts2[fdind]
		if grno == 0
			frame1 = framedict1[:totframe]
			frame2 = framedict2[:totframe]
			grlab = ""
		else
			frame1 = framedict1[:frames][grno]
			frame2 = framedict2[:frames][grno]
			grlab = dims[framedict1[:dim]][:groups][grno][:label]
		end
		prop = caprop(frame1, frame2)
		plot(prop[ages, :agest], prop[ages, :prop],
			label = "$(framedict1[:year]) $grlab")
	end
	legend(loc=2, framealpha = 0.5)
	framedict1 = framedicts1[1]
	framedict2 = framedicts2[1]
	sexlabel = sexlabels[framedict1[:sex]]
	ca1label = calabel(framedict1)
	ca2label = calabel(framedict2)
	xlabel("Ålder")
	ylabel("Dödsfall $ca1label/$ca2label")
	if grno == 0
		dimlabel = ""
	else
		dimlabel = "givet $(dims[framedict1[:dim]][:label]) "
	end
	title("Dödsfall $dimlabel$sexlabel USA")
	grid(1)
	show()
end

end # module
