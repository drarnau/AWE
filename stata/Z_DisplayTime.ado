program DisplayTime, nclass
	version 15.1 // STATA version

	syntax, seconds(real) [msg(string)]

	local h = floor(`seconds'/3600)
	local m = floor((`seconds'-(`h'*3600))/60)
	local s = `seconds' - (`m'*60) - (`h'*3600)
	di as text "`msg' " ///
		 as result "`h'" as text " hours, " ///
		 as result "`m'" as text " minutes, and " ///
		 as result %3.2f `s' as text " seconds."
end
