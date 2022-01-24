rm(list = ls())

if (substring(getwd(),nchar(getwd())-15,nchar(getwd()))=='/AV-FOT/analyses'){
  setwd("../")
}

library(dplyr)
library(ggplot2)
library(grid)
library(rpart)
library(lattice)


data_path <- 'data/'
image_path <- 'analyses/images/3d_plot/'
error_type <- 'MSE'
metric1_label <- "Lane-Keeping MSE"
metric2_label <- "Adaptive Cruise Control MSE"

x_min_lim <- 0.4
x_max_lim <- 0.8

y_min_lim <- 0.6
y_max_lim <- 1.8

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

mean_z_140 <- grouped_df %>% filter(z==140)
mean_z_180 <- grouped_df %>% filter(z==180)
mean_z_220 <- grouped_df %>% filter(z==220)
mean_z_all <- grouped_df %>% filter(z==140 | z==180 | z==220)
min_metric1_all <- min(mean_z_all$mean_metric1)
max_metric1_all <- max(mean_z_all$mean_metric1)
min_metric2_all <- min(mean_z_all$mean_metric2)
max_metric2_all <- max(mean_z_all$mean_metric2)

dummy1 <- data.frame(x=0.3,y=0.3,z=220,n=20,mean_metric1=min_metric1_all,mean_metric2=min_metric2_all)
dummy2 <- data.frame(x=0.9,y=2.1,z=220,n=20,mean_metric1=max_metric1_all,mean_metric2=max_metric2_all)
mean_z_140 <- rbind(mean_z_140,dummy1,dummy2)
mean_z_180 <- rbind(mean_z_180,dummy1,dummy2)
mean_z_220 <- rbind(mean_z_220,dummy1,dummy2)

wireframe(mean_metric1 ~ y*x, data=mean_z_140, scales=list(arrows=FALSE),
          aspect=c(1,1), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = list("", rot = 90),ylim = c(x_min_lim,x_max_lim),xlim=c(y_min_lim,y_max_lim),zlim=c(0,max_metric1_all),
          default.scales=list(font=5))

wireframe(mean_metric1 ~ y*x, data=mean_z_180, scales=list(arrows=FALSE),
          aspect=c(1,1), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = list("", rot = 90),ylim = c(x_min_lim,x_max_lim),xlim=c(y_min_lim,y_max_lim),zlim=c(0,max_metric1_all),
          default.scales=list(font=5))

wireframe(mean_metric1 ~ y*x, data=mean_z_220, scales=list(arrows=FALSE),
          aspect=c(1,1), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = list("", rot = 90),ylim = c(x_min_lim,x_max_lim),xlim=c(y_min_lim,y_max_lim),zlim=c(0,max_metric1_all),
          default.scales=list(font=5))

wireframe(mean_metric2 ~ y*x, data=mean_z_140, scales=list(arrows=FALSE),
          aspect=c(1,1), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = list("", rot = 90),ylim = c(x_min_lim,x_max_lim),xlim=c(y_min_lim,y_max_lim),zlim=c(min_metric2_all,max_metric2_all),
          default.scales=list(font=5))

wireframe(mean_metric2 ~ y*x, data=mean_z_180, scales=list(arrows=FALSE),
          aspect=c(1,1), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = list("", rot = 90),ylim = c(x_min_lim,x_max_lim),xlim=c(y_min_lim,y_max_lim),zlim=c(min_metric2_all,max_metric2_all),
          default.scales=list(font=5))

wireframe(mean_metric2 ~ y*x, data=mean_z_220, scales=list(arrows=FALSE),
          aspect=c(1,1), drape=TRUE,
          par.settings=list(axis.line=list(col='transparent')),
          zlab = list("", rot = 90),ylim = c(x_min_lim,x_max_lim),xlim=c(y_min_lim,y_max_lim),zlim=c(min_metric2_all,max_metric2_all),
          default.scales=list(font=5))

