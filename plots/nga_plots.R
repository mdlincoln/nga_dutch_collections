library("ggplot2")
library("stringr")
library("dplyr")

collection_data <- read.csv("../collection_data.csv", stringsAsFactors=FALSE)
collection_data$medium <- as.factor(collection_data$medium)
collection_data$artist <- as.factor(collection_data$artist)
collection_data$genre <- as.factor(collection_data$genre)
collection_data$onview <- as.factor(collection_data$onview)

##### Extract hight and width measurements #####
dim_regex <- "([0-9]{1,}[.]?[0-9]?) [x×] ([0-9]{1,}[.]?[0-9]?)"
collection_data$width <- as.numeric(str_match(collection_data$dimensions, dim_regex)[,2])
collection_data$height <- as.numeric(str_match(collection_data$dimensions, dim_regex)[,3])

##### extract year created #####
date_regex <- "([0-9]{4})"
collection_data$creation_date <- as.numeric(str_match(collection_data$created, date_regex)[,2])

##### exctract accession year #####
acc_regex <- "([0-9]{4})[.]"
collection_data$acc_date <- as.numeric(str_match(collection_data$accession, acc_regex)[,2])

#### Collection set?
collection_data$set[collection_data$acc_date == 1937] <- "Mellon"
collection_data$set[collection_data$acc_date == 1942] <- "Widener"
collection_data$set[collection_data$acc_date >= 1976] <- "Wheelock"
collection_data$set[collection_data$acc_date == NA] <- "Other"
collection_data$set <- as.factor(collection_data$set)

##### extract room number #####
room_regex <- "room=([[:alpha:]]-[0-9]{3}[-]?[[:alpha:]]?)"
collection_data$room <- str_match(collection_data$location, room_regex)[,2]
collection_data$room[is.na(collection_data$room)] <- "Storage"
collection_data$room <- as.factor(collection_data$room)

collection_data %.% group_by(room) %.% mutate(area=height*width) %.% summarize(num=n(), avg.area=mean(area, na.rm=TRUE))



# Creation date quantiles for pieces from the core collection (Mellon and Widener gifts)
core_gift <- filter(collection_data, acc_date==1942 | acc_date==1937)
core_quantile <- quantile(core_gift$creation_date, probs=seq(0,1,0.1), na.rm=TRUE)

# Creation date quantiles for pieces acquried during Arthur's tenure (1976-present)
arthur_ptgs <- filter(collection_data, acc_date >= 1974)
arthur_quantile <- quantile(arthur_ptgs$creation_date, probs=seq(0,1,0.1), na.rm=TRUE)

ggplot(collection_data, aes(x=acc_date, y=creation_date, color=medium, size=height*width)) + 
  geom_point(alpha=1, shape=22) + 
  scale_size(range=c(5,30)) +
  annotate("pointrange", alpha=0.2, ymin=core_quantile["10%"], ymax=core_quantile["90%"], xmin=1930, xmax=1974) +
  geom_vline(xintercept=1974) +
  annotate("rect", alpha=0.2, ymin=arthur_quantile["10%"], ymax=arthur_quantile["90%"], xmin=1974, xmax=2014)

ggplot(filter(collection_data, medium %in% c("oil on canvas", "oil on panel")), aes(x=acc_date, y=height*width, color=medium)) + geom_point(shape=1) + geom_smooth()
