library(rvest)
library(stringr)
library(tidyverse)

options(stringsAsFactors = FALSE)


# extracts unique hoshi types from page {x} ----
extract_hoshi <- function(x) lapply(
	x %>% 
		read_html %>% 
		html_nodes("td.hoshi"),
	function(node) {
		m <- node %>% 
			html_nodes("img") %>% 
			html_attr("src") %>% 
			str_match(., "^img/hoshi_(.+)\\.gif$")
		
		if (ncol(m) == 2) return(unique(m[, 2]))
	}
) %>% unlist %>% unique()


# loop through all available rikishi
hoshi <- character(0)

for (i in 9367:12430) {
	hoshi <- union(
		hoshi,
		extract_hoshi(
			paste("http://sumodb.sumogames.de/Rikishi.aspx?r", i, sep = "=")
		)
	)
	cat(i, hoshi, "\n")
}



shiro yasumi kuro fusenpai fusensho empty hikiwake

[1] "kuro"     "yasumi"   "shiro"    "fusenpai" "fusensho" "hikiwake"
[7] "empty" 