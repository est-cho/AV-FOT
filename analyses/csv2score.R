rm(list = ls())

library(dplyr)
library(ggplot2)

if (substring(getwd(),nchar(getwd())-15,nchar(getwd()))=='/AV-FOT/analyses'){
  setwd("../")
}

data_path <- 'data/'
image_path <- 'analyses/images/'
error_type <- 'MSE'

MAE <- function(timeseries,goal){
  loss <- 0
  for(value in timeseries){
    loss <- loss + abs(value-goal)
  }
  loss/length(timeseries)
}

MSE <- function(timeseries,goal){
  loss <- 0
  for(value in timeseries){
    loss <- loss + abs(value-goal)^2
  }
  loss/length(timeseries)
}

MA <- function(timeseries,goal){
  
}

error <- function(type,timeseries,goal){
  if(type == 'MAE'){
    MAE(timeseries,goal)
  }else if(type == 'MSE'){
    MSE(timeseries,goal)
  }else{
    MA(timeseries,goal)
  }
  
}

files <- list.files(data_path)

# Calculate metric scores per data set
df <- data.frame(x=numeric(),y=numeric(),z=numeric(),metric1=numeric(),metric2=numeric(),color=numeric())
for(file in files){
  data <- read.csv(paste(data_path,file,sep=""),header=TRUE)
  linekeeping_error <- error(error_type, data$color, 33)
  cruisecontrol_error <- error(error_type, data$distance, 200)
  filename_split <- strsplit(file,'_')
  df <- rbind(df,data.frame(x=as.numeric(filename_split[[1]][2]),y=as.numeric(filename_split[[1]][3]),z=as.numeric(filename_split[[1]][4]),metric1=linekeeping_error,metric2=cruisecontrol_error,color=1))
} # Plot 하기 위한 color를 우선 1로 초기화 하였음

grouped_df <- df %>% group_by(x,y,z) %>% summarise(n=n(),mean_metric1=mean(metric1),mean_metric2=mean(metric2)) %>% arrange(x,y,z)
grouped_df$color <- row_number(grouped_df$x) # Plot에 color를 그룹화 한 후 row number로 부여

for(i in 1:nrow(df)){ #df 의 각 행에 color를 바로위의 rownumber에 따라 컬러 부여
  current_row <- df[i,]
  color <- grouped_df %>% filter(x==current_row$x,y==current_row$y,z==current_row$z) %>% .$color
  df$color[i] <- color
}
df$color <- as.factor(df$color)

# Scatter plot of the test data evaluated against the two metrics
ggplot(df,aes(x=metric1,y=metric2,color=color)) + 
  geom_point() + 
  xlab("Lane Keeping Assistant Metric") +
  ylab("Adaptive Cruise Control Metric") +
  theme_bw()

################################################################################
# Filter df with two fixed configs
# Ex) if x_val == 0, then fix y and z axes  
filter_and_boxplot <- function(x_val, y_val, z_val, metric_type) {
  if (x_val == 0) {
    # Config axis: x
    filtered_df <- df %>% 
      filter(y == y_val, z == z_val)
    filtered_df$x = as.factor(filtered_df$x)
    
    if (metric_type == 'lka') {
      ggplot(data=filtered_df, aes(x=x, y=metric1, fill=x)) + 
        geom_boxplot() +
        ylab("Lane Keeping Assistant Metric") +
        theme_bw()
    } else if (metric_type == 'acc') {
      ggplot(data=filtered_df, aes(x=x, y=metric2, fill=x)) + 
        geom_boxplot() +
        ylab("Adaptive Cruise Control Metric") +
        theme_bw()
    }
    
  } else if (y_val == 0) {
    # Config axis: y
    filtered_df <- df %>% 
      filter(x == x_val, z == z_val)
    filtered_df$y = as.factor(filtered_df$y)
    
    if (metric_type == 'lka') {
      ggplot(data=filtered_df, aes(x=y, y=metric1, fill=y)) + 
        geom_boxplot() +
        ylab("Lane Keeping Assistant Metric") +
        theme_bw()
    } else if (metric_type == 'acc') {
      ggplot(data=filtered_df, aes(x=y, y=metric2, fill=y)) + 
        geom_boxplot() +
        ylab("Adaptive Cruise Control Metric") +
        theme_bw()
    }
    
  } else {
    # Config axis: z
    filtered_df <- df %>% 
      filter(x == x_val, y == y_val)
    filtered_df$z = as.factor(filtered_df$z)
    
    if (metric_type == 'lka') {
      ggplot(data=filtered_df, aes(x=z, y=metric1, fill=z)) + 
        geom_boxplot() +
        ylab("Lane Keeping Assistant Metric") +
        theme_bw()
    } else if (metric_type == 'acc') {
      ggplot(data=filtered_df, aes(x=z, y=metric2, fill=z)) + 
        geom_boxplot() +
        ylab("Adaptive Cruise Control Metric") +
        theme_bw()
    }
  }
}

filter_and_boxplot(0, 0.6, 220, 'lka') 
filter_and_boxplot(0, 0.6, 200, 'lka')
filter_and_boxplot(0, 1.2, 220, 'lka')
filter_and_boxplot(0, 1.2, 200, 'lka')
filter_and_boxplot(0, 1.8, 220, 'lka')
filter_and_boxplot(0, 1.8, 200, 'lka')

filter_and_boxplot(0, 0.6, 220, 'acc') 
filter_and_boxplot(0, 0.6, 200, 'acc')
filter_and_boxplot(0, 1.2, 220, 'acc') # Not flat
filter_and_boxplot(0, 1.2, 200, 'acc')
filter_and_boxplot(0, 1.8, 220, 'acc')
filter_and_boxplot(0, 1.8, 200, 'acc')

filter_and_boxplot(0.4, 0, 220, 'lka') 
filter_and_boxplot(0.4, 0, 200, 'lka')
filter_and_boxplot(0.6, 0, 220, 'lka')
filter_and_boxplot(0.6, 0, 200, 'lka')
filter_and_boxplot(0.8, 0, 220, 'lka')
filter_and_boxplot(0.8, 0, 200, 'lka')

filter_and_boxplot(0.4, 0, 220, 'acc') 
filter_and_boxplot(0.4, 0, 200, 'acc')
filter_and_boxplot(0.6, 0, 220, 'acc')
filter_and_boxplot(0.6, 0, 200, 'acc')
filter_and_boxplot(0.8, 0, 220, 'acc')
filter_and_boxplot(0.8, 0, 200, 'acc')

################################################################################

library(plot3D)
library(lattice)
library(scatterplot3d)

fixed_z <- df %>%
  filter(z == 220)

max(fixed_z$metric1)
min(fixed_z$metric1)
s3d <- scatterplot3d(fixed_z$x, fixed_z$y, fixed_z$metric1,pch=16, cex.symbols=1,
                     xlab = 'x', ylab='y', zlab='Lane Keeping Assistant Metric')

grouped_df %>% filter(z==220) %>% arrange(desc(mean_metric2))
grouped_df %>% filter(z==220) %>% arrange(mean_metric2)


wireframe(metric1 ~ x*y, data=fixed_z, scales=list(arrows=FALSE), zlim = c(0, 180),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = 'Metric 1')

wireframe(metric1 ~ y*x, data=fixed_z, scales=list(arrows=FALSE), zlim = c(0, 180),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = 'Lane Keeping Assistant Metric')

wireframe(metric2 ~ x*y, data=fixed_z, scales=list(arrows=FALSE), zlim = c(90000, 200000),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = 'Adaptive Cruise Control Metric')


wireframe(metric2 ~ y*x, data=fixed_z, scales=list(arrows=FALSE), zlim = c(90000, 200000),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = 'Adaptive Cruise Control Metric')

wireframe(metric2 ~ y*x, data=fixed_z, scales=list(arrows=FALSE), zlim = c(90000, 200000),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = 'Adaptive Cruise Control Metric')


