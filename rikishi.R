library(rvest)
library(stringr)
library(tidyverse)

options(stringsAsFactors = FALSE)


sumodbBanzukeQuery <- function(basho) {
	banzuke_html <- tryCatch(
		read_html(paste0(
			"http://sumodb.sumogames.de/Banzuke.aspx?b=",
			gsub("\\.", "", basho),
			"&w=on&c=on&simple=on"
		)) %>% 
			html_node("td[class=layoutright]") %>% 
			html_node("table[class=banzuke]"),
		error = function(e) {},
		warning = function(w) {}
	)

	banzuke_ids <- tryCatch(
		banzuke_html %>% 
			html_nodes("td[class=shikona], td[class=debut], td[class=retired]") %>% 
			html_node("a") %>% 
			html_attr("href") %>% 
			str_match(., "^Rikishi\\.aspx\\?r=(\\d+)$") %>% 
			.[, 2],
		error = function(e) {},
		warning = function(w) {}
	)

	banzuke_table <- tryCatch(
		banzuke_html %>% html_table(),
		error = function(e) {},
		warning = function(w) {}
	)

	if (!is.null(banzuke_ids) && !is.null(banzuke_table) && length(banzuke_ids) == nrow(banzuke_table)) cbind(
		banzuke_ids,
		banzuke_table
	) %>% 
		mutate(Basho = basho) %>% 
		mutate(
			Height = as.numeric(str_match(`Height/Weight`, "(\\d+\\.?\\d*) cm")[, 2]),
			Weight = as.numeric(str_match(`Height/Weight`, "(\\d+\\.?\\d*) kg")[, 2])
		) %>% 
		select(
			Basho,
			ID = banzuke_ids,
			Rank,
			Shikona = Rikishi,
			Height,
			Weight,
			W,
			L
		)
}
	
