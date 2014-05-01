library("ggplot2")
library("stringr")
library("dplyr")

collection_data <- read.csv("../collection_data.csv", stringsAsFactors=FALSE)
collection_data$medium <- as.factor(collection_data$medium)
collection_data$artist <- as.factor(collection_data$artist)

##### Extract hight and width measurements #####
dim_regex <- "([0-9]{1,}[.]?[0-9]?) x ([0-9]{1,}[.]?[0-9]?)"
collection_data$width <- as.numeric(str_match(collection_data$dimensions, dim_regex)[,2])
collection_data$height <- as.numeric(str_match(collection_data$dimensions, dim_regex)[,3])

##### extract year created #####
date_regex <- "([0-9]{4})"
collection_data$creation_date <- as.numeric(str_match(collection_data$created, date_regex)[,2])

##### exctract accession year #####
acc_regex <- "([0-9]{4})[.]"
collection_data$acc_date <- as.numeric(str_match(collection_data$accession, acc_regex)[,2])

ggplot(collection_data, aes(x=acc_date, y=creation_date, size=height, color=medium)) + geom_point(shape=1) + scale_area(range=c(5,30))

ggplot(filter(collection_data, medium %in% c("oil on canvas", "oil on panel")), aes(x=acc_date, y=height*width, color=medium)) + geom_point(shape=1) + geom_smooth()
