library(lubridate)
library(rvest)
library(tidyverse)


# returns latest basho as yyyy.mm
latest_basho <- function(dt = Sys.Date()) {
	this_year <- seq(
		dt %>% year() %>% `-`(1) %>% paste(., "11", "01", sep = "-") %>% ymd(),
		dt %>% year() %>% paste(., "11", "30", sep = "-") %>% ymd(),
		by = "1 day"
	)
	
	second_sunday <- this_year[
		month(this_year) %% 2 == 1
		& wday(this_year) == 1
		& day(this_year) %in% 8:14
	]
	
	latest_basho_start <- second_sunday[dt > second_sunday] %>% tail(1)
	
	sprintf(
		"%d.%02d",
		year(latest_basho_start),
		month(latest_basho_start)
	)
}


# wrapper
myTry <- function(...) tryCatch(
	...,
	error = function(e) {},
	warning = function(w) {}
)


# http://sumodb.sumogames.de/Banzuke.aspx
sumodbBanzuke <- function(basho = latest_basho()) {
	raw_html <- myTry(
		read_html(
			paste0(
				"http://sumodb.sumogames.de/Banzuke.aspx?b=",
				sub("\\.", "", basho), # yyyy.mm -> yyyymm
				"&h=on&sh=on&bd=on&w=on&spr=on&sps=on&hl=on&c=on&simple=on"
			)
		)
	)
	
	table_banzuke <- myTry(
		raw_html %>%
			html_node("table.banzuke") %>%
			html_table()
	)
	
	ids <- myTry(
		raw_html %>%
			html_node("table.banzuke") %>%
			html_nodes("a") %>%
			html_attr("href") %>%
			grep("^Rikishi\\.aspx\\?r=\\d+$", ., value = TRUE) %>%
			sub("^Rikishi\\.aspx\\?r=", "", .) %>%
			as.integer()
	)
	
	if (nrow(table_banzuke) == length(ids)) cbind(
		basho = basho,
		id = ids,
		table_banzuke %>% 
			set_names(gsub(" ", "_", tolower(names(.)))) %>% 
			transmute(
				rank,
				rikishi,
				heya,
				shusshin,
				birth_date,
				height = as.numeric(str_match(`height/weight`, "([0-9.]+) cm")[, 2]),
				weight = as.numeric(str_match(`height/weight`, "([0-9.]+) kg")[, 2]),
				prev,
				prev_w,
				prev_l
			)
	)
}


# parses single page of Bout query result
sumodbBoutParse <- function(raw_html) {
	table_record <- myTry(
		raw_html %>%
			html_node("table.record") %>%
			html_table(
				fill = TRUE,
				header = FALSE,
				trim = TRUE
			) %>% 
			tail(-2)
	)
	
	rikishi_ids <- myTry(
		raw_html %>%
			html_node("table.record") %>%
			html_nodes("td>a") %>%
			html_attr("href") %>%
			grep("^Rikishi\\.aspx\\?r=\\d+$", ., value = TRUE) %>%
			sub("^Rikishi\\.aspx\\?r=", "", .) %>%
			as.integer()
	)
	
	imgs <- myTry(
		raw_html %>%
			html_node("table.record") %>%
			html_nodes("td.tk_kekka>img") %>%
			html_attr("src") %>%
			grep("^img/.+\\.gif$", ., value = TRUE) %>%
			sub("^img/", "", .) %>%
			sub("\\.gif$", "", .)
	)
	
	if (length(rikishi_ids) == nrow(table_record) * 2) {
		tibble(
			basho = table_record[, 1],
			day = table_record[, 2],
	
			rikishi1_id = rikishi_ids[c(TRUE, FALSE)],
			rikishi1_rank = table_record[, 3],
			rikishi1_shikona = table_record[, 4],
			rikishi1_result = table_record[, 5],
			rikishi1_win = c(
				grepl("shiro|fusensho", imgs[c(TRUE, FALSE)]) * 1,
				rep(NA, nrow(table_record) - length(imgs) / 2)
			),
			
			kimarite = table_record[, 7],
			
			rikishi2_id = rikishi_ids[c(FALSE, TRUE)],
			rikishi2_rank = table_record[, 9],
			rikishi2_shikona = table_record[, 10],
			rikishi2_result = table_record[, 11],
			rikishi2_win = c(
				grepl("shiro|fusensho", imgs[c(FALSE, TRUE)]) * 1,
				rep(NA, nrow(table_record) - length(imgs) / 2)
			)
		)
	}
}


# http://sumodb.sumogames.de/Query_bout.aspx
# default division = makuuchi, other divisions: j, ms, sd, jd, jk, mz
sumodbBout <- function(basho = latest_basho(), day = NA, division = "m") {
	sumodbURL <- c(
		"http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&rowcount=5",
		ifelse(is.na(basho), NA, paste0("year=", basho)),
		ifelse(is.na(day), NA, paste0("day=", day)),
		ifelse(is.na(division), NA, paste0(division, "=on", collapse = "&"))
	) %>% 
		na.omit() %>% 
		paste(collapse = "&")
	
	raw_html <- myTry(read_html(sumodbURL))
	
	chunks <- list()
	
	while (!is.null(raw_html)) {
		chunks[[length(chunks) + 1]] <- sumodbBoutParse(raw_html)
	
		next_page <- raw_html %>% 
			html_nodes("div>a") %>% 
			html_text() %>% 
			grep("^Next$|^Last$", .)
		
		if (length(next_page) > 0) raw_html <- myTry(
			raw_html %>% 
				html_nodes("div>a") %>% 
				html_attr("href") %>% 
				`[`(next_page[1]) %>% 
				paste("http://sumodb.sumogames.de", ., sep = "/") %>% 
				read_html()
		) else raw_html <- NULL
	}
	
	if (length(chunks) > 0) do.call(rbind, chunks)
}
