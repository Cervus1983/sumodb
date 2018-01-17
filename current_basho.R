# data.world (you'll need your own account)
library(data.world)
set_config(cfg_env(auth_token_var = "DW_API_TOKEN"))

# interface to http://sumodb.sumogames.de
source("sumodb.R")

# wrapper for data frame concatenation
dfapply <- function(...) do.call(rbind, lapply(...))

# https://data.world/cervus/sumo-banzuke
banzuke <- dfapply(
	seq(1, 12, by = 2),
	function(mm) sumodbBanzuke(sprintf("%s.%02d", format(Sys.Date(), "%Y"), mm))
)

if (!is.null(banzuke)) upload_data_frame(
	dataset = paste(Sys.getenv("DW_USER"), "sumo-banzuke", sep = "/"),
	data_frame = banzuke,
	file_name = paste(format(Sys.Date(), "%Y"), "csv", sep = ".")
)

# https://data.world/cervus/sumo-results
results <- sumodbBout(format(Sys.Date(), "%Y"), division = c("m", "j"))

if (!is.null(results)) upload_data_frame(
	dataset = paste(Sys.getenv("DW_USER"), "sumo-results", sep = "/"),
	data_frame = results,
	file_name = paste(format(Sys.Date(), "%Y"), "csv", sep = ".")
)
