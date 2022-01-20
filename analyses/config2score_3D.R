rm(list = ls())

library(dplyr)
library(ggplot2)

if (substring(getwd(),nchar(getwd())-15,nchar(getwd()))=='/AV-FOT/analyses'){
  setwd("../")
}

data_path <- 'data/'
image_path <- 'analyses/images/3d_plot/'
error_type <- 'MSE'
metric1_label <- "Lane-Keeping MSE"
metric2_label <- "Adaptive Cruise Control MSE"

x_width <- 600
y_width <- 450
font_size <- 20

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


library(plot3D)
library(lattice)
library(scatterplot3d)

fixed_z <- df %>%
  filter(z == 220)

max(fixed_z$metric1)
min(fixed_z$metric1)
s3d <- scatterplot3d(fixed_z$x, fixed_z$y, fixed_z$metric1,pch=16, cex.symbols=1,
                     xlab = 'x', ylab='y', zlab=metric1_label)

fixed_mean_z <- grouped_df %>% filter(z==220)

s3d_mean_lka <- scatterplot3d(fixed_mean_z$x, fixed_mean_z$y, fixed_mean_z$mean_metric1,pch=16, cex.symbols=1,
                     xlab = 'x', ylab='y', zlab=metric1_label)
s3d_mean_acc <- scatterplot3d(grouped_df$x, grouped_df$y, grouped_df$mean_metric2,pch=16, cex.symbols=1,
                          xlab = 'x', ylab='y', zlab=metric2_label)


grouped_df %>% filter(z==220) %>% arrange(desc(mean_metric2))
grouped_df %>% filter(z==220) %>% arrange(mean_metric2)

wireframe(mean_metric1 ~ x*y, data=fixed_mean_z, scales=list(arrows=FALSE), zlim = c(0, 300),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = metric1_label)

wireframe(metric1 ~ y*x, data=fixed_z, scales=list(arrows=FALSE),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = metric1_label)


wireframe(metric1 ~ x*y, data=fixed_z, scales=list(arrows=FALSE), zlim = c(0, 180),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = metric1_label)

wireframe(metric1 ~ y*x, data=fixed_z, scales=list(arrows=FALSE), zlim = c(0, 180),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = metric1_label)


wireframe(metric2 ~ x*y, data=fixed_z, scales=list(arrows=FALSE),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = metric2_label)


wireframe(metric2 ~ x*y, data=fixed_z, scales=list(arrows=FALSE), zlim = c(90000, 200000),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = metric2_label)


wireframe(metric2 ~ y*x, data=fixed_z, scales=list(arrows=FALSE), zlim = c(90000, 200000),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = metric2_label)

wireframe(metric2 ~ y*x, data=fixed_z, scales=list(arrows=FALSE), zlim = c(90000, 200000),
          aspect=c(1,.6), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')), 
          zlab = metric2_label)

