# data.world (you'll need your own account)
library(data.world)
set_config(cfg_env(auth_token_var = "DW_API_TOKEN"))

# interface to http://sumodb.sumogames.de
source("sumodb.R")

# wrapper for data frame concatenation
dfapply <- function(...) do.call(rbind, lapply(...))

# https://data.world/cervus/sumo-banzuke
dfapply(
	1983:2017,
	function(yyyy) upload_data_frame(
		dataset = paste(Sys.getenv("DW_USER"), "sumo-banzuke", sep = "/"),
		data_frame = dfapply(
			seq(1, 12, by = 2),
			function(mm) sumodbBanzuke(sprintf("%s.%02d", yyyy, mm))
		),
		file_name = paste(yyyy, "csv", sep = ".")
	)
)

# https://data.world/cervus/sumo-results
dfapply(
	1983:2017,
	function(yyyy) upload_data_frame(
		dataset = paste(Sys.getenv("DW_USER"), "sumo-results", sep = "/"),
		data_frame = sumodbBout(yyyy, division = c("m", "j")),
		file_name = paste(yyyy, "csv", sep = ".")
	)
)
