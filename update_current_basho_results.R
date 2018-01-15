if (lubridate::month(Sys.Date()) %% 2 == 1) {
	library(data.world)
	set_config(cfg_env(auth_token_var = "DW_API_TOKEN"))
	
	source("sumodb.R")
	
	basho <- format(Sys.Date(), "%Y.%m")

	upload_data_frame(
		dataset = "cervus/sumo-wrestling-results",
		data_frame = sumodbBout(basho, division = NA),
		file_name = paste(basho, "csv", sep = ".")
	)
}
