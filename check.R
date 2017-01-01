library(dplyr)
library(httr)
library(stringr)

options(stringsAsFactors = FALSE)


# all files with tournament results
basho <- str_match_all(
	content(GET(url = "https://github.com/Cervus1983/sumodb/tree/all-divisions/CSV"), "text"),
	">([0-9]{4}\\.[0-9]{2})\\.results\\.csv<"
)[[1]][, 2]


# fetch 'em
df <- do.call(
	rbind,
	lapply(
		basho,
		function(x) read.csv(
			paste0("https://raw.githubusercontent.com/Cervus1983/sumodb/all-divisions/CSV/", x, ".results.csv")
		)
	)
)


# sanity check
df %>% count(win1)
df %>% count(win2)
