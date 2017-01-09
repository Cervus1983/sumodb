# interface to http://sumodb.sumogames.de
source("C:/Users/Spel/Desktop/GitHub/sumodb/sumodb.R")

# all tournaments from 2001 through 2016
# tournament <- apply(
# 	expand.grid(
# 		2001:2016,
# 		c("01", "03", "05", "07", "09", "11"), # six tournaments a year
# 		stringsAsFactors = FALSE
# 	) %>% filter(!(Var1 == 2011 & Var2 == "03")), # cancelled (https://en.wikipedia.org/wiki/2011_in_sumo#Tournaments)
# 	1,
# 	paste, collapse = "."
# )

# current tournament
tournament <- "2017.01"

# banzuke
sapply(
	c(tournament),
	function(x) write.csv(
		sumodbBanzukeQuery(basho = x),
		file = paste0("C:/Users/Spel/Desktop/GitHub/sumodb/CSV/", x, ".banzuke.csv"),
		quote = FALSE,
		row.names = FALSE
	)
)

# results
sapply(
	tournament,
	function(x) write.csv(
		sumodbBoutQuery(basho = x) %>% filter(complete.cases(.)),
		file = paste0("C:/Users/Spel/Desktop/GitHub/sumodb/CSV/", x, ".results.csv"),
		quote = FALSE,
		row.names = FALSE
	)
)
