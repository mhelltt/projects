library(tidyverse)

setwd("/Users/mhelliott/data/Coursera/Case Study 2/Fitabase Data 4.12.16-5.12.16")

filenames = list.files(pattern="*.csv")

list2env(
  lapply(setNames(filenames, make.names(gsub("*_merged.csv$", "", filenames))), 
         read.csv), envir = .GlobalEnv)

# In order to loop through all dataframes here, we need to create a Large list
dfs <- Filter(function(x) is(x, "data.frame"), mget(ls()))

# Clean environment
rm(list=ls(all=TRUE)[sapply(mget(ls(all=TRUE)), class) == "data.frame"])

# Removing duplicate rows in all dfs
remove_duplicates = function(x) {
  x <- x[!duplicated(x), ]
}

lapply(dfs, remove_duplicates)

# Get all of the id's across all tables then filter for unique
get_ids = function(x) {
  return(unique(x$Id))
}

all_ids <- lapply(dfs, get_ids)

unique_ids <- unique(flatten_dbl(all_ids))

# load unique_ids into it's own dataframe
participants <- as.data.frame(unique_ids)

# get a list of the dataframe names in dfs
count_participants = function(x) {
  return(n_distinct(x$Id))
}

n_participants <- lapply(dfs, count_participants)

participation <- as.data.frame(n_participants)

# pivot and rename columns
participation <- pivot_longer(participation, 
                              cols=everything(),
                              names_to = "data_category",
                              names_ptypes = list(data_categories=character()),
                              values_to = "num_participants",
                              values_ptypes = list(num_participants=integer())
)

# add % column
participation$perc_participants <- signif(100*(participation$num_participants / length(unique_ids)), digits=3)

# sort by num_participants
participation <- participation[order(-participation$num_participants),]

View(participation)
# export table
# png("../Figures/participation.png", width=140*ncol(participation), height=25*nrow(participation))
# grid.table(participation)
# dev.off()

# # plot perc_particpation for each data_category
# 
# ggplot(participation,
#        aes(x = reorder(data_category, -perc_participants),
#            y = perc_participants,
#            fill = perc_participants,)) +
#   geom_bar(stat = "identity") +
#   geom_text(aes(label=num_participants), 
#             vjust = 1.5, 
#             color =" white", 
#             size = 3) +
#   xlab("Data Type") +
#   ylab("% Participation") + 
#   scale_y_continuous(labels = function(x) paste0(x, "%")) +
#   theme(axis.text.x = element_text(angle = 45,
#                                    hjust = 1),
#         axis.title = element_text(size = 12),
#         legend.position = "none") +
#   labs(title = "Percent Participation per Data Type")

# check to make sure the minuteSleep has same participants as sleepDay
unique(dfs[["minuteSleep"]][["Id"]]) %in% unique(dfs[["sleepDay"]][["Id"]])

# create table for lower_participation types
lower_part_types <- participation$data_category[participation$num_participants < 33]

lower_dfs <- Filter(function(x) length(unique(x[["Id"]])) < 33, dfs)

# participating in a lower partiipation category means you have higher participation overall
all_higher_ids <- lapply(lower_dfs, function(x) return(unique(x$Id)))

unique_higher_ids <- unique(flatten_dbl(all_higher_ids))

higher_participation <- as.data.frame(unique_higher_ids)

# loop through lower_part_types and add columns with participation for these ids

for(i in 1:length(lower_part_types)) {
   new <- higher_participation$unique_higher_ids %in% dfs[[lower_part_types[i]]][["Id"]]
   higher_participation[, ncol(higher_participation) + 1] <- new
   colnames(higher_participation)[ncol(higher_participation)] <- paste0(lower_part_types[i])
   remove(i)
   remove(new)
}

View(higher_participation)
# png("../Figures/higher_participation.png", height= 24*nrow(higher_participation), width=105*ncol(higher_participation))
# grid.table(higher_participation)
# dev.off()

# unload tables after cleaning
list2env(dfs, envir=.GlobalEnv)

# format dates
dailyActivity$ActivityDate = as.POSIXct(dailyActivity$ActivityDate, format="%m/%d/%Y")
dailyActivity$date <- as.Date(format(dailyActivity$ActivityDate, format = "%Y-%m-%d"))

# lets add who gave which data types
dailyActivity$sleepData <- dailyActivity$Id %in% sleepDay$Id
dailyActivity$heartrateData <- dailyActivity$Id %in% heartrate_seconds$Id
dailyActivity$weightLogData <- dailyActivity$Id %in% weightLogInfo$Id
dailyActivity$allTrue <- (dailyActivity$Id %in% sleepDay$Id & 
                          dailyActivity$Id %in% heartrate_seconds$Id &
                          dailyActivity$Id %in% weightLogInfo$Id)

# ggplot(data = dailyActivity, aes(x = date, y = TotalSteps)) +
#   geom_point(aes(group = Id, color = sleepData)) +
#   facet_wrap(vars(sleepData))
# 
# ggplot(data = dailyActivity, aes(x = date, y = Calories)) +
#   geom_point(aes(group = Id, color = sleepData)) +
#   facet_wrap(~sleepData)

meta_sleep <- dailyActivity %>% 
  group_by(sleepData) %>% 
  summarize(meanSteps = mean(TotalSteps),
            meanDistance = mean(TotalDistance),
            meanVeryActiveDistance = mean(VeryActiveDistance),
            meanSedentaryMinutes = mean(SedentaryMinutes),
            meanCalories = mean(Calories)
            )
  # pivot_longer(cols=-1) %>% 
  # arrange(name)

# ggplot(data=meta_sleep, aes(x=sleepData, y=value, fill=sleepData)) +
#   geom_bar(stat="identity") +
#   facet_wrap(~name, scales='free_y') +
#   scale_fill_manual(values=c("#c5d4de", "#81b7db")) +
#   labs(title = "Summary Data on sleepData vs no sleepData",
#        x="",
#        y="Values")

meta_heartrate <- dailyActivity %>% 
  group_by(heartrateData) %>% 
  summarize(meanSteps = mean(TotalSteps),
            meanDistance = mean(TotalDistance),
            meanVeryActiveDistance = mean(VeryActiveDistance),
            meanSedentaryMinutes = mean(SedentaryMinutes),
            meanCalories = mean(Calories)
  )

# ggplot(data=meta_heartrate, aes(x=heartrateData, y=value, fill=heartrateData)) +
#   geom_bar(stat="identity") +
#   facet_wrap(~name, scales='free_y') +
#   scale_fill_manual(values=c("#c5d4de", "#81b7db")) +
#   labs(title = "Summary Data on heartrateData vs no heartrateData",
#        x="",
#        y="Values")

meta_weightlog <- dailyActivity %>% 
  group_by(weightLogData) %>% 
  summarize(meanSteps = mean(TotalSteps),
            meanDistance = mean(TotalDistance),
            meanVeryActiveDistance = mean(VeryActiveDistance),
            meanSedentaryMinutes = mean(SedentaryMinutes),
            meanCalories = mean(Calories)
  )

meta_alltrue <- dailyActivity %>% 
  group_by(allTrue) %>% 
  summarize(meanSteps = mean(TotalSteps),
            meanDistance = mean(TotalDistance),
            meanVeryActiveDistance = mean(VeryActiveDistance),
            meanSedentaryMinutes = mean(SedentaryMinutes),
            meanCalories = mean(Calories)
            )

hourlyIntensities$ActivityHour=as.POSIXct(hourlyIntensities$ActivityHour, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())
hourlyIntensities$time <- format(hourlyIntensities$ActivityHour, format = "%H:%M:%S")
hourlyIntensities$date <- format(hourlyIntensities$ActivityHour, format = "%m/%d/%y")

hourlyIntensities$heartrateData <- hourlyIntensities$Id %in% heartrate_seconds$Id
hourlyIntensities$weightLogData <- hourlyIntensities$Id %in% weightLogInfo$Id

intensities_heartrate <- hourlyIntensities %>% 
  group_by(time, heartrateData) %>%
  drop_na() %>% 
  summarize(mean_total_int = mean(TotalIntensity))

# this turns the chr 'time' column into a POSIXct only for the purpose of displaying 12-hour clock times on ggplot
# inserted date is now wrong, since these are aggregated time slots
intensities_heartrate$time=as.POSIXct(intensities_heartrate$time, format="%H:%M:%S")

ggplot(data=intensities_heartrate, aes(x=time, y=mean_total_int, fill=heartrateData)) + 
  geom_histogram(stat="identity") +
  scale_x_datetime(date_labels = "%I %p", date_breaks="2 hours") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title="Hourly Intensities",subtitle="No Heartrate Data vs Heartrate Data",
       x="",
       y="Mean Total Intensities") +
  facet_wrap(~heartrateData) + 
  scale_fill_manual(values=c("#d98686", "#d44e4e"))

intensities_weightlog <- hourlyIntensities %>% 
  group_by(time, weightLogData) %>%
  drop_na() %>% 
  summarize(mean_total_int = mean(TotalIntensity))

# this turns the chr 'time' column into a POSIXct only for the purpose of displaying 12-hour clock times on ggplot
# inserted date is now wrong, since these are aggregated time slots
intensities_weightlog$time=as.POSIXct(intensities_weightlog$time, format="%H:%M:%S")

ggplot(data=intensities_weightlog, aes(x=time, y=mean_total_int, fill=weightLogData)) + 
  geom_histogram(stat="identity") +
  scale_x_datetime(date_labels = "%I %p", date_breaks="2 hours") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title="Hourly Intensities",subtitle="No Weightlog Data vs Weightlog Data",
       x="",
       y="Mean Total Intensities") +
  facet_wrap(~weightLogData) + 
  scale_fill_manual(values=c("#90d197", "#62cc6d"))