library(data.world)
set_config(saved_cfg)

source("sumodb.R")

# 18 years ~ 107 tournaments (2011 March cancelled)
basho <- expand.grid(2000:2017, sprintf("%02d", seq(1, 12, by = 2))) %>% 
	apply(., 1, paste, collapse = ".") %>% 
	setdiff(., "2011.03") %>% 
	sort()

# https://data.world/cervus/sumo-wrestling-banzuke
sapply(
	basho,
	function(x) upload_data_frame(
		dataset = "cervus/sumo-wrestling-banzuke",
		data_frame = sumodbBanzuke(x),
		file_name = paste(x, "csv", sep = ".")
	)
)

# https://data.world/cervus/sumo-wrestling-results
sapply(
	basho,
	function(x) upload_data_frame(
		dataset = "cervus/sumo-wrestling-results",
		data_frame = sumodbBout(x, division = NA),
		file_name = paste(x, "csv", sep = ".")
	)
)
