library(dplyr)
library(stringr)

get_clean_data = function(df = NULL) {
  # Accessing Dataset
  if (is.null(df)) {
    df = as.data.frame(read.csv(here::here("final_dataset_test.csv")))
  }
  unclean_data = df
  
  unclean_data$DamagedProperty = as.factor(get_prop_damage_cats(unclean_data$DamagedProperty1))
  
  # Replaces (N/A) with Unable to Determine in Cause1 vector
  unclean_data$Cause1 = ifelse(unclean_data$Cause1 == "(N/A)",
                               "Unable to Determine", unclean_data$Cause1)
  
  # Drops CrashSeverityCD and CrashInjurySeverity as they have collinearity with CrashSeverity
  
  
  # Swapping CrashSeverity to first column
  unclean_data = unclean_data[, c("CrashSeverity", "TotalInjured", 
                                  setdiff(names(unclean_data), 
                                          c("TotalInjured", "CrashSeverity")))]
  
  # This drops certain variables. These variables need to be fixed to conduct analysis on. 
  unclean_data = unclean_data[,!colnames(unclean_data) %in% c("DamagedProperty1","CityClassCode",
                                                              "CityName","CityClassCode",
                                                              "CrashReportCounty","TrafficControlDeviceCond",
                                                              "ClassOfTrafficway","TimeOfCrash",
                                                              "CrashSeverityCd")] 
  
  # unclean_data$TimeOfCrash = as.numeric(sapply(strsplit(unclean_data$TimeOfCrash,":"), function(x) x[1]))
  # 
  # colnames(unclean_data)[colnames(unclean_data) == "TimeOfCrash"] = "HourOfCrash"
  
  orig_data = unclean_data
  
  cols = colnames(orig_data)
  
  num_vars = c("TotalInjured")
  
  for (i in 1:length(orig_data)) {
    if (!colnames(orig_data)[i] %in% num_vars) {
      orig_data[,i] = as.factor(orig_data[,i,drop = TRUE])
    }
  }
  
  return(orig_data)
  
}

get_prop_damage_cats = function(damage_col) {
  # Step 1: Lowercase and clean
  damage_col = tolower(damage_col)
  damage_col[damage_col == " "] <- "none"
  
  # Step 2: Categorize using keyword mapping
  damage_cat <- case_when(
    str_detect(damage_col, "deer") ~ "deer",
    str_detect(damage_col, "sign") ~ "sign",
    str_detect(damage_col, "pole|poll|light") ~ "pole",
    str_detect(damage_col, "tree") ~ "tree",
    str_detect(damage_col, "fence|gate|fencing") ~ "fence",
    str_detect(damage_col, "median|curb|divider") ~ "median",
    str_detect(damage_col, "guard ?rail|gaurd ?rail") ~ "guardrail",
    str_detect(damage_col, "unknown") ~ "none",
    str_detect(damage_col, "post") ~ "post",
    str_detect(damage_col, "trailer") ~ "vehicle",
    str_detect(damage_col, "hydrant") ~ "hydrant",
    str_detect(damage_col, "grass|lawn|field|yard|landscaping") ~ "lawn",
    str_detect(damage_col, "mailbox") ~ "mailbox",
    str_detect(damage_col, "wall") ~ "wall",
    str_detect(damage_col, "cable") ~ "cable",
    str_detect(damage_col, "garage|house|building|residence") ~ "building",
    str_detect(damage_col, "barrier") ~ "barrier",
    str_detect(damage_col, "bridge") ~ "bridge",
    str_detect(damage_col, "bicycle|bike") ~ "bike",
    str_detect(damage_col, "barrels") ~ "barrels",
    str_detect(damage_col, "ditch") ~ "ditch",
    str_detect(damage_col, "object") ~ "object",
    str_detect(damage_col, "rail") ~ "rail",
    str_detect(damage_col, "none") ~ "none",
    TRUE ~ "other"
  )
  
  return(damage_cat)
}
