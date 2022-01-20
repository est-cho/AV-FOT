rm(list = ls())

library(dplyr)
library(ggplot2)
library(ggtext)

if (substring(getwd(),nchar(getwd())-15,nchar(getwd()))=='/AV-FOT/analyses'){
  setwd("../")
}

data_path <- 'data/'
image_path <- 'analyses/images/scatterplot/'
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

### Scatter plot of the test data evaluated against the two metrics ###
x_width <- 800
y_height <- 600
font_size <- 25
filename <- "all"
png(file=paste(image_path,filename,".png",sep=""),width = x_width, height = y_height)

ggplot(df,aes(x=metric1,y=metric2,color=color)) + 
  geom_point() + 
  xlab("Lane Keeping Assistant MSE") +
  ylab("Adaptive Cruise Control MSE") +
  theme(panel.background = element_blank(),axis.line=element_line(size=0.5),text=element_text(family="Times New Roman", face="bold", size=font_size),legend.key = element_rect(fill=NA,size=5),legend.key.height=unit(1.5,'cm')) +
  scale_color_discrete(name="Config") +
  theme_bw()

dev.off()

# Filter 3 configurations for scatter plot
filename <- "scatter_three_configuration_01"

filtered_df <- df %>% filter((x==0.8 & y==1.8 & z==220) | (x==0.4 & y==0.6 & z==220) | (x==0.8 & y==1.8 & z==140))
filtered_df$config <- paste('(',filtered_df$x,',',filtered_df$y,',',filtered_df$z,')',sep='')
filtered_df$config <- as.factor(filtered_df$config)

png(file=paste(image_path, filename,".png",sep=""),width = x_width, height = y_height)

ggplot(filtered_df,aes(x=metric1,y=metric2,group=config)) + 
  geom_point(aes(color=config,shape=config,stroke=3),size=8) + 
  scale_shape_manual(values=c(0,1,2),name="Config.(x,y,z)") +
  xlab("Lane Keeping MSE") +
  ylab("Adaptive Cruise Control MSE") +
  theme(panel.background = element_blank(),axis.line=element_line(size=0.5),text=element_text(family="Times New Roman", face="bold", size=font_size),legend.key = element_rect(fill=NA,size=5),legend.key.height=unit(1.5,"cm")) +
  scale_color_discrete(name="Config.(x,y,z)") +
  guides(shape = guide_legend(override.aes = list(stroke = 3)))

dev.off()
