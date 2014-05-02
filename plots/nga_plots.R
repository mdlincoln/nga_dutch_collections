library("ggplot2")
library("stringr")
library("dplyr")

akw <- 1973

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
collection_data$set <- "Other"
collection_data$set[collection_data$acc_date == 1937] <- "Mellon"
collection_data$set[collection_data$acc_date == 1942] <- "Widener"
collection_data$set[collection_data$acc_date >= akw] <- "Wheelock"
collection_data$set <- as.factor(collection_data$set)
collection_data$set <- factor(collection_data$set, levels=c("Mellon", "Widener", "Other", "Wheelock"))


##### extract room number #####
room_regex <- "room=([[:alpha:]]-[0-9]{3}[-]?[[:alpha:]]?)"
collection_data$room <- str_match(collection_data$location, room_regex)[,2]
collection_data$room[is.na(collection_data$room)] <- "Storage"
collection_data$room <- as.factor(collection_data$room)

collection_data %.% group_by(room) %.% mutate(area=height*width) %.% summarize(num=n(), avg.area=mean(area, na.rm=TRUE))



# Creation date quantiles for pieces from the core collection (Mellon and Widener gifts)
core_gift <- filter(collection_data, acc_date==1942 | acc_date==1937)
core_quantile <- quantile(core_gift$creation_date, probs=seq(0,1,0.05), na.rm=TRUE)

# Creation date quantiles for pieces acquried during Arthur's tenure (1976-present)
arthur_ptgs <- filter(collection_data, acc_date >= akw)
arthur_quantile <- quantile(arthur_ptgs$creation_date, probs=seq(0,1,0.05), na.rm=TRUE)

svg("date_plot.svg", height=8, width=15)
ggplot(collection_data, aes(x=acc_date, y=creation_date, color=set)) +
  geom_point(alpha=1, size=3) + 
  scale_color_brewer(type="qual", palette = 6) +
  annotate("pointrange", alpha=0.6, size=1.5, x=1950,
           y=core_quantile["50%"], ymin=core_quantile["5%"], ymax=core_quantile["95%"]) +
  annotate("text", label="Core", x=1950, y=core_quantile["95%"]+3, angle=90, hjust=0) +
  geom_vline(xintercept=akw) +
  annotate("pointrange", alpha=0.6, size=1.5, x=1985, 
           y=arthur_quantile["50%"], ymin=arthur_quantile["5%"], ymax=arthur_quantile["95%"]) +
  annotate("text", label="Wheelock", x=1985, y=arthur_quantile["95%"]+3,angle=90,  hjust=0) +
  annotate("text", label="Mellon Collection", x=1937, y=1678 , angle=90, hjust=0) +
  annotate("text", label="Widener Collection", x=1942, y=1678 , angle=90, hjust=0)
dev.off()

svg("genres.svg", height=8, width=15)
ggplot(collection_data, aes(genre, fill=set)) +
  geom_bar() +
  coord_flip() +
  theme_bw()
dev.off()

svg("room_facets.svg", height=8, width=15)
ggplot(collection_data, aes(x=acc_date, y=creation_date, size=height*width)) +
  geom_jitter(alpha=0.7) + 
  scale_size(range=c(1,10)) +
  facet_wrap(~ room) +
  theme_bw()
dev.off()

svg("sizes.svg", height=8, width=15)
ggplot(collection_data, aes(x=acc_date, y=height*width, color=creation_date)) +
  geom_point(size=3) +
  facet_wrap(~ genre) +
  theme_bw()
dev.off()
