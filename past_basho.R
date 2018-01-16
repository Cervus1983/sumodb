library(data.world)
set_config(cfg_env(auth_token_var = "DW_API_TOKEN"))

source("sumodb.R")

# 207 tournaments since my birth (2011 March cancelled)
basho <- expand.grid(1983:2017, sprintf("%02d", seq(1, 12, by = 2))) %>% 
	apply(., 1, paste, collapse = ".") %>% 
	setdiff(., c("1983.01", "1983.03", "2011.03")) %>% 
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
	function(x)	upload_data_frame(
		dataset = "cervus/sumo-wrestling-results",
		data_frame = sumodbBout(x, division = NA),
		file_name = paste(x, "csv", sep = ".")
	)
)
