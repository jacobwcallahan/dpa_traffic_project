library(dplyr)
library(reshape2)
library(DBI)
library(RSQLite)
source("get_clean_data.R")


all_data <- read.csv("crash_13-22.csv", header = TRUE)
colnames(all_data)
final_data = read.csv("final_dataset.csv",header = TRUE)

table(all_data$LightingCond)

clean_data <- all_data %>%
  mutate(RoadwayFunctionalClass = case_when(
    RoadwayFunctionalClass != "(UNK)" ~ RoadwayFunctionalClass,
    Toll == "Illinois Toll Highway Com" ~ "Interstate",
    Toll == "No Toll" | Toll=="Not Toll" ~ "Other Principal Arterial",
    UrbanRural == "Urban" & FlowCondition == "Free Flow" ~ "Principal Arterial",
    UrbanRural == "Urban" & FlowCondition == "Slow" ~ "Major Collector",
    UrbanRural == "Urban" & (FlowCondition == "Stopped" |FlowCondition =="Slow") ~ "Minor Arterial",
    UrbanRural == "Rural" & FlowCondition == "Stopped" ~ "Major Collector",
    UrbanRural == "Rural" & FlowCondition == "Slow" ~ "Minor Collector",
    TRUE ~ "Unknown"
  ))

clean_data <- clean_data %>% 
  mutate(across(everything(), ~ ifelse(is.na(.) | . == "(UNK)", "Unknown", .)))

clean_data <- clean_data %>%
  mutate(
    Cause1 = ifelse((is.na(Cause1) | Cause1 == "") & !is.na(Cause2) & Cause2 != "", Cause2, Cause1),
    Cause2 = ifelse((is.na(Cause2) | Cause2 == "") & !is.na(Cause1) & Cause1 != "", Cause1, Cause2)
  )

clean_data$CityClass <- trimws(clean_data$CityClass)

new_cols = c(names(final_data), "CrashYr","CrashMonth")

clean_data <- clean_data[, intersect(names(clean_data), new_cols), drop = FALSE]


colnames(data)
colnames(clean_data)



table(clean_data$RoadwayFunctionalClass)

# ------------------------------------------------


clean_data <- clean_data %>%
  mutate(RoadwayFunctionalClass = case_when(

    RoadwayFunctionalClass %in% c(
      "Local Road or Street",
      "Local Road or Street (Non-Urban)",
      "Local Road or Street (Urban)"
    ) ~ "Local Road or Street",
    
    RoadwayFunctionalClass %in% c(
      "Major Collector",
      "Major Collector (Non-Urban)"
    ) ~ "Major Collector",
    
    RoadwayFunctionalClass %in% c(
      "Minor Arterial",
      "Minor Arterial (Non-Urban)",
      "Minor Arterial (Urban)"
    ) ~ "Minor Arterial",
    
    RoadwayFunctionalClass %in% c(
      "Other Principal Arterial",
      "Other Principal Arterial (PAS)"
    ) ~ "Other Principal Arterial",
    
    RoadwayFunctionalClass %in% c(
      "Minor Collector",
      "Minor Collector (Non-Urban)"
    ) ~ "Minor Collector",
    
    RoadwayFunctionalClass %in% c(
      "InterState",
      "Interstate (PAS)",
      "InterState (PAS)"
    ) ~ "InterState",
    
    RoadwayFunctionalClass %in% c(
      "Freeway and Expressway",
      "Freeway and Expressway (PAS)",
      "Freeway and Expressway (Urban Only) (PAS)"
    ) ~ "Freeway and Expressway",
    
    
    
    TRUE ~ "Other"
  ))



table(clean_data$RoadwayFunctionalClass)



clean_final_df = get_clean_data(final_data)

lighting_cats = as.character(unique(clean_final_df$LightingCond))

clean_data = clean_data[(clean_data$LightingCond %in% lighting_cats),]
clean_data = clean_data[(trimws(clean_data$CrashInjurySeverity) != "Holes"),]


new_df = get_clean_data(clean_data)

con = dbConnect(SQLite(), "crashes.db")

dbWriteTable(con, "crashes", new_df, overwrite = TRUE)

dbDisconnect(con)
