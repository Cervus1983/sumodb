# interface to http://sumodb.sumogames.de


library(dplyr)
library(stringr)
library(XML)

options(stringsAsFactors = FALSE)


# http://stackoverflow.com/a/30947988/17216
getSrc <- function(node, ...) {
	ifelse(
		xmlName(node) == "td" && !is.null(node[["img"]]),
		xmlGetAttr(node[["img"]], "src"),
		xmlValue(node)
	)
}


# one page with a query output
sumodbPage <- function(url) {
	tryCatch(
		readHTMLTable(
			doc = url,
			elFun = getSrc,
			skip.rows = 1,
			trim = TRUE,
			which = 1
		),
		error = function(e) {},
		warning = function(w) {}
	)
}


# entire output of a Bout Query
sumodbBoutQueryPages <- function(url) {
	i <- 0
	dfl <- list()
	
	# 1000 rows per page
	repeat {
		df <- sumodbPage(paste0(url, "&offset=", 1000 * i))

		if(is.null(df)) {
			break
		} else {
			i <- i + 1
			dfl[[i]] <- df
		}
	}
	
	# merge pages
	df <- do.call(rbind, dfl)

	if(!is.null(df)) df %>%
		# rename columns
		rename(
			basho = V1,
			day = V2,
			rank1 = V3,
			shikona1 = V4,
			result1 = V5,
			win1 = V6,
			kimarite = V7,
			win2 = V8,
			rank2 = V9,
			shikona2 = V10,
			result2 = V11
		)
}


# Bout Query wrapper
# example (results of a basho): sumodbBoutQuery(basho = "2016.11", division = "m")
# example (head-to-head): sumodbBoutQuery(basho = NA, shikona1 = "Hakuho", shikona2 = "Harumafuji")
sumodbBoutQuery <- function(
	basho = substr(Sys.Date(), 1, 4), # default: this year
	day = NA,
	division = NA, # subset of c("m", "j", "ms", "sd", "jd", "jk", "mz")
	shikona1 = NA,
	rank1 = NA,
	shikona2 = NA,
	rank2 = NA
) {
	df <- sumodbBoutQueryPages(
		paste(
			"http://sumodb.sumogames.de/Query_bout.aspx?show_form=0&rowcount=5&east1=on",
			ifelse(is.na(basho), "", paste0("year=", basho)),
			ifelse(is.na(day), "", paste0("day=", day)),
			ifelse(is.na(division), "", paste0(division, "=on", collapse = "&")),
			ifelse(is.na(shikona1), "", paste0("shikona1=", shikona1)),
			ifelse(is.na(rank1), "", paste0("rank1=", rank1)),
			ifelse(is.na(shikona2), "", paste0("shikona2=", shikona2)),
			ifelse(is.na(rank2), "", paste0("rank2=", rank2)),
			sep = "&"
		)
	)
	
	# clean up
	if(!is.null(df)) df %>%	mutate(
		day = as.integer(day),
		win1 = recode(win1, "img/hoshi_kuro.gif" = 0, "img/hoshi_shiro.gif" = 1, "img/hoshi_fusenpai.gif" = 0, "img/hoshi_fusensho.gif" = 1),
		kimarite = str_match(kimarite, "(\\w+)$")[, 2],
		win2 = recode(win2, "img/hoshi_kuro.gif" = 0, "img/hoshi_shiro.gif" = 1, "img/hoshi_fusenpai.gif" = 0, "img/hoshi_fusensho.gif" = 1)
	)
}


# Banzuke Query wrapper, returns Makuuchi Banzuke
# example: sumodbBanzukeQuery(basho = "2016.11")
sumodbBanzukeQuery <- function(basho) {
	df <- tryCatch(
		readHTMLTable(
			doc = paste0("http://sumodb.sumogames.de/Banzuke.aspx?b=", gsub("\\.", "", basho), "&w=on&c=on"),
			trim = TRUE,
			which = 6 # found by trial & error
		),
		error = function(e) {},
		warning = function(w) {}
	)
	
	if(!is.null(df)) df %>%
		setNames(tolower(names(.))) %>%
		mutate(basho = basho) %>%
		select(
			basho,
			rank,
			rikishi,
			`height/weight`
		) %>%
		mutate(
			height = as.numeric(str_match(`height/weight`, "([0-9.]+) cm")[, 2]),
			weight = as.numeric(str_match(`height/weight`, "([0-9.]+) kg")[, 2])
		) %>%
		select(-`height/weight`)
}
