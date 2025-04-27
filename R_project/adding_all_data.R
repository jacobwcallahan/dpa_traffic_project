library(dplyr)

base_yr = 2022

data_2022 = read.csv(paste("crash_",base_yr, ".csv",sep=""),header = TRUE)

new_empty = c(
  "didcrashoccurinworkzone", "workzonetype", "wereworkerspresent", "workzone",
  "accesscontrol", "flowcondition", "didinvolvesecondarycrash", "toll",
  "urbanrural")

rename_map <- c(
  "illinoiscasenumbericn" = "icn",
  "crashyear" = "crashyr",
  "incapacitatinginjuries" = "ainjuries",
  "nonincapacitatinginjuries" = "binjuries",
  "possibleinjuries" = "cinjuries",
  "primarycausecode" = "cause1code",
  "secondarycausecode" = "cause2code",
  "citytownshipflag" = "city_township_flag",
  "primarycause" = "cause1",
  "secondarycause" = "cause2",
  "crashseveritycode" = "crashseveritycd")



align_to_master <- function(df, master_cols) {
  for (col in master_cols) {
    if (!col %in% colnames(df)) {
      df[[col]] <- NA  # Fill missing columns with NA
    }
  }
  # Also reorder columns to match master exactly
  df <- df[, master_cols]
  return(df)
}

master_df = data_2022

# gets data and lowercases it
colnames(master_df) = tolower(colnames(master_df))

# Replace
colnames(master_df) = sapply(colnames(master_df), function(x) gsub("\\.", replacement = "", x))

master_cols = colnames(master_df)

master_df[] <- lapply(master_df, as.character)

for (yr in 2013:2021) {
  
  df = data.frame(read.csv(paste("crash_",yr, ".csv",sep=""), header = TRUE))
  print(yr)
  print(dim(df))
  # gets data and lowercases it
  colnames(df) = tolower(colnames(df))
  
  # Replace
  colnames(df) = sapply(colnames(df), function(x) gsub("\\.", replacement = "", x))
  
  # remaps some names
  colnames(df) <- sapply(colnames(df), function(x) {
    if (x %in% names(rename_map)) rename_map[[x]] else x
  })
  
  df = align_to_master(df,master_cols)
  df[] <- lapply(df, as.character)
  
  print(dim(df))
  
  master_df = bind_rows(master_df, df)
  
}

dim(master_df)

master_df$y = as.double(master_df$y)
master_df$X = as.double(master_df$X)


sapply(data_2022[],typeof)
sapply(master_df[],typeof)
colnames(master_df)

colnames(master_df)==tolower(colnames(data_2022))

colnames(master_df) = colnames(data_2022)
write.csv(master_df,"crash_13-22.csv")

