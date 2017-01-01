# interface to http://sumodb.sumogames.de
source("sumodb.R")

# all tournaments
tournament <- apply(
	expand.grid(
		2001:2016,
		c("01", "03", "05", "07", "09", "11") # six tournaments a year
	),
	1,
	paste, collapse = "."
)

# banzuke
sapply(
	c(tournament, "2017.01"),
	function(x) write.csv(
		sumodbBanzukeQuery(basho = x),
		file = paste0("CSV/", x, ".banzuke.csv"),
		quote = FALSE,
		row.names = FALSE
	)
)

# results
sapply(
	tournament,
	function(x) write.csv(
		sumodbBoutQuery(basho = x),
		file = paste0("CSV/", x, ".results.csv"),
		quote = FALSE,
		row.names = FALSE
	)
)
