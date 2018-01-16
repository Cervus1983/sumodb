if (lubridate::month(Sys.Date()) %% 2 == 1) {
	library(data.world)
	set_config(cfg_env(auth_token_var = "DW_API_TOKEN"))
	
	source("sumodb.R")
	
	uploaded <- map_chr(
		get_dataset("cervus/sumo-wrestling-banzuke")$files,
		"name"
	) %>% 
		gsub("\\.csv$", "", .)
	
	basho <- format(Sys.Date(), "%Y.%m")

	if (!(basho %in% uploaded)) upload_data_frame(
		dataset = "cervus/sumo-wrestling-banzuke",
		data_frame = sumodbBanzuke(basho),
		file_name = paste(basho, "csv", sep = ".")
	)
}
