library(yardstick)
library(dplyr)
library(caret)
library(pROC)

get_f1_vals = function(ytest, yhats) {
  cats = as.vector(unique(ytest))
  lagged_cats = lag(cats, 1)
  lagged_cats[1] = cats[length(cats)]
  
  fix_0_preds <- cbind(truth = cats, predictions = lagged_cats)
  
  pred_df = tibble(truth = ytest,predictions = yhats)
  
  pred_df = rbind(pred_df, fix_0_preds)
  
  f1_macro <- f_meas(pred_df, truth, estimate = predictions, estimator = "macro")
  
  f1_weighted <- f_meas(pred_df, truth = truth, estimate = predictions, estimator = "macro_weighted")
  
  return(data.frame(Macro_F1 = f1_macro$.estimate, Weighted_F1 = f1_weighted$.estimate))
}

get_train_test = function(data, target_class, train_pct = .8, 
                          data_slice_pct = 1, stratified = TRUE, 
                          oversample = FALSE, oversampled_cat = NULL, return_indices = FALSE, seed = NULL) {
  
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Checks if data_slice is viable
  if (data_slice_pct != 1 | data_slice_pct != 0) {
    data_slice = data[createDataPartition(data[,target_class], p = data_slice_pct, list = FALSE),]
  } else {
    data_slice = data
  }
  
  # if oversampling wants to be performed
  if (!oversample) {
    
    # If not oversampled, if the data wants to be stratified
    if (stratified) {
      train.inds = createDataPartition(data_slice[,target_class], p = train_pct, list = FALSE)
      test.inds = setdiff(seq_len(nrow(data_slice)), train.inds)
    } else {
      train.inds = sample.int(nrow(data_slice), train_pct * nrow(data_slice))
      test.inds = setdiff(seq_len(nrow(data_slice)), train.inds)
    }
    
    train = data_slice[train.inds,]
    test = data_slice[test.inds,]
    
    # Oversampling the data
  } else {
    if (data_slice_pct != 1 | data_slice_pct != 0) {
      warning("Unable to slice data when performing oversampling. ")
    }
    
    cat_vals = table(data[,target_class])
    
    if (is.null(oversampled_cat)) {
      oversampled_cat = names(cat_vals)[which.min(cat_vals)]
      warning(paste("oversampled_cat is null, choosing smallest category to oversample:",oversampled_cat))
    }
    
    train.inds = createDataPartition(data[,target_class], p = train_pct, list = FALSE)
    
    train = data[train.inds,]
    test = data[-train.inds,]
    
  
    n_samples <- floor(cat_vals[oversampled_cat] * train_pct)
    
    # 1. Filter minority and majority separately
    minority <- train %>% filter(CrashSeverity == oversampled_cat)
    majority <- train %>% filter(CrashSeverity != oversampled_cat)
    
    # 2. Sample
    minority_sampled <- minority %>% sample_n(size = n_samples, replace = FALSE)
    majority_sampled <- majority %>% sample_n(size = n_samples, replace = FALSE)
    
    # 3. Combine
    train <- bind_rows(minority_sampled, majority_sampled) %>% sample_frac(1) # Samples rows
    
    # Now get the new indices relative to full data
    train.inds <- which(rownames(data) %in% rownames(train))
    
    # Turns test df into same size as train df
    test_pct = nrow(train) / nrow(test)
    if (test_pct < 1) {
      test.inds = as.vector(createDataPartition(test[,target_class], p = test_pct, list = FALSE))
      test = data[test.inds,]
    }
  }

  # Returns indices or not
  if (return_indices) {
    return(list(train = train.inds, test = test.inds))
  } else {
    return(list(train = train, test = test))
  }

}

plot_roc_OvR <- function(probs, actual) {
  prob_df <- as.data.frame(probs)
  
  # Ensure actual is a factor with the correct levels
  actual <- factor(actual)
  classes <- levels(actual)
  
  # Check that column names match class levels
  if (!all(classes %in% colnames(prob_df))) {
    stop("Column names of probs must match the class labels in actual.")
  }
  
  # Generate One-vs-Rest ROC curves
  roc_list <- lapply(classes, function(cls) {
    roc(response = actual == cls, predictor = prob_df[[cls]], levels = c(FALSE, TRUE))
  })
  
  names(roc_list) <- classes
  
  # Plot the first ROC
  plot.roc(roc_list[[1]], col = 1, legacy.axes = TRUE, main = "One-vs-Rest ROC Curves")
  
  # Add others
  sapply(2:length(roc_list), function(i) {
    lines.roc(roc_list[[i]], col = i)
  })
  
  # Add AUCs to legend
  aucs <- sapply(roc_list, auc)
  legend_labels <- paste0(names(roc_list), " vs Rest (AUC = ", round(aucs, 3), ")")
  
  legend("bottomright", legend = legend_labels, col = 1:length(roc_list), lwd = 2)
}
