library(dplyr)
library(ggplot2)

rm(list = ls())
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

df <- data.frame(x=numeric(),y=numeric(),z=numeric(),metric1=numeric(),metric2=numeric(),color=numeric())
for(file in files){
  data <- read.csv(paste(data_path,file,sep=""),header=TRUE)
  linekeeping_error <- error(error_type,data$color,33)
  cruisecontrol_error <- error(error_type,data$distance,200)
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

ggplot(df,aes(x=metric1,y=metric2,color=color,shape=color)) + geom_point()




