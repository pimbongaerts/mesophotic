The following are instructions to download and manipulate the metadata from the "Mesophotic.org" repository in R (https://www.r-project.org/). Electronic notebook by Veronica Radice with contributions from Pim Bongaerts.

### Required packages

For these examples, please install (e.g. using `install.packages(dplyr)`) and load (as detailed below using `require`) the following packages for manipulating and viewing the data:

```{r}
require(dplyr)
require(tidyr)
require(ggplot2)
require(ggstance)
require(ggpubr)
require(tidyverse)
require(cowplot)
```

### Fold-increase of publications (between 2008 and 2018)

You can import the latest database directly from the website into R:

```{r}
publs <- read.csv("http://www.mesophotic.org/publications.csv",
                  as.is=TRUE)
# examine publications up until and including the year 2018 (eliminate the
# latest 2019 publications)
publs <- publs[!(publs$publication_year=="2019"),]
```

Show table dimensions and column names:

```{r}
dim(publs)
colnames(publs)
```

Subset the publication list to those that are validated (i.e. metadata validated by two
different content editors) or those that are included\_in\_stats (i.e. as validated but only
including publications representing (peer-reviewed) scientific articles presenting original data from mesophotic depths):

```{r}
publs_validated <- subset(publs, validated == "true")
publs_for_stats <- subset(publs, included_in_stats == "true")
```

### Example: fold-increase of publications over time

Calculate the fold-increase in publications over the past 10 years (between 2008 and 2018):

```{r}
publs_by_year <- publs_validated %>% 
								 group_by(publication_year) %>%
								 summarise(count=n()) %>%
								 mutate(total_count = cumsum(count))

fold_increase <- publs_by_year[publs_by_year$publication_year==2018, "total_count"] /
                 publs_by_year[publs_by_year$publication_year==2008, "total_count"]
fold_increase
```

### Example: Top 10 research fields

Where fields have multiple values (through so-called “HABTM” associations), such as
research_fields , they are separated by semicolons, for example: Ecology; Community
structure; Disturbances. Therefore, to query any of these fields, we need to separate these into individual rows. Then, we can plot for example the number of publications for each of those fields:

```{r}
# Split `fields` into new rows
publs_fields <- separate_rows(publs_for_stats, "fields", sep=";\\s+")

# Remove rows with no associated `fields`
publs_field <- publs_fields[!(is.na(publs_fields$fields) |
                            publs_fields$fields == ""), ]

# Group by `fields`, count the number of publications and plot

top10_fields <- publs_fields %>%
                group_by(fields) %>%
                summarise(count=n()) %>% 
                top_n(10)

top10_fields$fields <- as.factor(top10_fields$fields) 
top10_fields <- top10_fields %>% arrange(desc(count))
top10_fields

bar_fields <-  ggplot(data = top10_fields, aes(x = count, 
                                               y = reorder(fields, count))) +
               geom_barh(stat="identity") +
               theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
               labs(x = "Publications", y = "Fields") + theme_bw()
bar_fields
```

### Example: Top 10 focusgroups

```{r}
# Split `focusgroups` into new rows
publs_focusgroups <- separate_rows(publs_for_stats, "focusgroups", sep=";\\s+")

# Remove rows with no associated `focusgroups`
publs_focusgroups <- publs_focusgroups[!(is.na(publs_focusgroups$focusgroups) |
                     publs_focusgroups$focusgroups ==""), ]

# count total number of records (rows)
countTotal_focusgroups <- nrow(publs_focusgroups)

count_focusgroups <- publs_focusgroups %>%
                     group_by(focusgroups) %>%
                     summarise(count=n())

# percent of focusgroup counts divided by total number of records of focusgroups (aka rows)
percent_focusgroups <- count_focusgroups %>%
                       mutate(percent=paste0(round(100*count/countTotal_focusgroups,1)))

percent_focusgroups$percent <- as.numeric(percent_focusgroups$percent)

top10_focusgroups <- percent_focusgroups %>%
                     top_n(10, percent) %>%
                     arrange(desc(count))
top10_focusgroups$focusgroups <- as.factor(top10_focusgroups$focusgroups) 
top10_focusgroups

bar_focusgroups <-  ggplot(data = top10_focusgroups, aes(x = percent, 
                                                         y = reorder(focusgroups, count))) +
                    geom_barh(stat="identity") +
                    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                    labs(x = "Percent", y = "Focus Groups") +
                    theme_bw()
bar_focusgroups
```

### Example: Top 10 platforms

```{r}
# Split `platforms` into new rows
publs_platforms <- separate_rows(publs_for_stats, "platforms", sep=";\\s+")

# Remove rows with no associated `platforms`
publs_platforms <- publs_platforms[!(is.na(publs_platforms$platforms) |
                                   publs_platforms$platforms == ""), ]

# Group by `platforms`, count the number of publications and plot

top10_platforms <- publs_platforms %>%
                   group_by(platforms) %>%
                   summarise(count=n()) %>% 
                   top_n(10)

top10_platforms$platforms <- as.factor(top10_platforms$platforms) 
top10_platforms <- top10_platforms %>%
                   arrange(desc(count))

bar_platforms <-  ggplot(data = top10_platforms, aes(x = count, 
                                                     y = reorder(platforms, count))) +
                  geom_barh(stat="identity") +
                  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                  labs(x = "Publications", y = "Platforms") +
                  theme_bw()
bar_platforms
```

### Example: Top 10 locations

```{r}
# Split `locations` into new rows
publs_locations <- separate_rows(publs_for_stats, "locations", sep=";\\s+")

# Remove rows with no associated `locations`
publs_locations <- publs_locations[!(is.na(publs_locations$locations) |
                                   publs_locations$locations == ""), ]

# Group by `locations`, count the number of publications and plot

top10_locations <- publs_locations %>%
                   group_by(locations) %>%
                   summarise(count=n()) %>% 
                   top_n(10)

top10_locations$locations <- as.factor(top10_locations$locations) 
top10_locations <- top10_locations %>% arrange(desc(count))

bar_locations <-  ggplot(data = top10_locations, aes(x = count, 
                                                     y = reorder(locations, count))) +
                  geom_barh(stat="identity") +
                  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                  labs(x = "Publications", y = "Locations") +
                  theme_bw()
bar_locations
```

### Multi-panel figure of top 10 categories

```{r}
#pdf("Fig category bargraphs.pdf", width = 9, height = 6, 
     encoding="MacRoman")

plot <- plot_grid(bar_focusgroups,
                  bar_fields,
                  bar_platforms,
                  bar_locations, 
                  labels = c('a)', 'b)', 'c)', 'd)'), 
                  hjust = -1, 
                  vjust = 1, 
                  align = 'vh',
                  scale = c(1, 1, 1, 1),
                  label_size = 12,
                  ncol = 2,
                  label_fontface = "plain")
plot
#dev.off()
```

### Import data from stats page
Data for the visualizations on the http://mesophotic.org/stats page can be downloaded as CSVs and manipulated too. For example:

```{r}
pubs_over_depth <- read.csv("pubs_over_depth.csv", as.is = TRUE)

pubs_over_depth <- data.frame(pubs_over_depth$Publications, pubs_over_depth$Category)
```

Publications by max depth

```{r}
colnames(pubs_over_depth) <- c("Publications", "Depth")

#pdf("Fig Publications over depth.pdf", width = 8, height = 6, encoding="MacRoman")

g <- ggplot(pubs_over_depth, aes(x = Depth, y = Publications)) +
  geom_area(color="#69b3a2", fill = "#69b3a2") +
  scale_x_reverse(breaks = seq(150, 30, -8), limits = c(150, 30)) +
  scale_y_continuous(breaks = seq(0, 500, 50), limits = c(0, 500)) +
  labs(x = "Depth (m)", y = "Publications") +
  theme_classic()

g + rotate()

#dev.off()
```

Import data Publications over time

```{r}
pubs_over_time <- read.csv("pubs_over_time.csv", as.is = TRUE)
colnames(pubs_over_time) <- c("year", "value")
# modify data frame by creating new variable
pubs_over_time <- mutate(pubs_over_time, category = "Publication")
pubs_over_time$category <- as.factor(pubs_over_time$category)
pubs_over_time
```

Import data Locations (by Year) over time

```{r}
locations_over_time <- read.csv("locations_over_time.csv", as.is = TRUE)
colnames(locations_over_time) <- c("year", "value")
# modify data frame by creating new variable
locations_over_time <- mutate(locations_over_time, 
                              category = "Study location")
locations_over_time$category <- as.factor(locations_over_time$category)
locations_over_time
```

Import data First Authors (by Year) over time

```{r}
people_over_time <- read.csv("people_over_time.csv", as.is = TRUE) # unique first authors
colnames(people_over_time) <- c("year", "value")
# modify data frame by creating new variable
people_over_time <- mutate(people_over_time, category = "First author")
people_over_time$category <- as.factor(people_over_time$category)
people_over_time
```

Import data term "mesophotic" (by Year) over time

```{r}
mesophotic_over_time <- read.csv("mesophotic-mentions-cumulative.csv", 
                                 as.is = TRUE) 
mesophotic_over_time <- mesophotic_over_time[-c(3)]
colnames(mesophotic_over_time) <- c("year", "value")
# modify data frame by creating new variable
mesophotic_over_time <- mutate(mesophotic_over_time, 
                               category = "Term 'mesophotic'")
mesophotic_over_time$category <- as.factor(mesophotic_over_time$category)
mesophotic_over_time
```

Merge data that look at counts (Pubs, Location, etc) over time (by Year)

```{r}
# join data
# append to dataframe as new rows
data_over_time <- bind_rows(locations_over_time, pubs_over_time,
                            mesophotic_over_time, .id = NULL)  # could add people_over_time 
data_over_time$category <- as.factor(data_over_time$category)
data_over_time
```

Publications and Locations over time
Stacked Area chart

```{r}
# designate specific order
data_over_time$category <- factor(data_over_time$category, 
                           levels = c("Publication", "Study location", "Term 'mesophotic'"))  # could add "First author"

# colorblind friendly palette
# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/
# cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#0072B2", "#56B4E9", "#999999", "#E69F00")  # "#E69F00", "#009E73",
# alternate color pallets via color brewer
# scale_fill_brewer(palette="Greens")

#pdf("Fig Series of data over time.pdf", width = 8, height = 5, encoding="MacRoman")

ggplot(data_over_time, aes(x=year, y=value, fill=category)) + 
      geom_area(colour="black", size=.3, alpha=.4) +
      scale_fill_manual(values = cbPalette) +   
      scale_x_continuous(name = "Year", breaks = seq(1990, 2018, 4), limits = c(1990, 2018)) +
      ylab("Number") +
      labs(fill = "Series") +
      theme_classic() +
      theme(legend.title = element_text(), legend.justification = c(0, 1), legend.position = c(0, 1), legend.box.margin=margin(c(5,5,5,5))) 

#dev.off()
```