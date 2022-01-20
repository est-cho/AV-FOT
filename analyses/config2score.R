rm(list = ls())

library(dplyr)
library(ggplot2)

if (substring(getwd(),nchar(getwd())-15,nchar(getwd()))=='/AV-FOT/analyses'){
  setwd("../")
}

data_path <- 'data/'
image_path <- 'analyses/images/boxplot/'
error_type <- 'MSE'

lka_label <- "Lane-Keeping MSE\n"
acc_label <- "Adaptive Cruise Control MSE"
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
grouped_df$color <- row_number(grouped_df$x) # Plot에 color를 그룹화 한 후 row number로 부여
grouped_df %>%
  filter(n != 20)
configuration_space <- unique(df[,c('x', 'y', 'z')])

for(i in 1:nrow(df)){ #df 의 각 행에 color를 바로위의 rownumber에 따라 컬러 부여
  current_row <- df[i,]
  color <- grouped_df %>% filter(x==current_row$x,y==current_row$y,z==current_row$z) %>% .$color
  df$color[i] <- color
}
df$color <- as.factor(df$color)


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
        ylab(lka_label) +
        # ggtitle(paste0("Varying Config: x\nFixed Config: (y=",y_val, ", z=", z_val, ")")) +
        theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size))
    } else if (metric_type == 'acc') {
      ggplot(data=filtered_df, aes(x=x, y=metric2, fill=x)) + 
        geom_boxplot() +
        ylab(acc_label) +
        # ggtitle(paste0("Varying Config: x\nFixed Config: (y=",y_val, ", z=", z_val, ")")) +
        theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size))
    }
    
  } else if (y_val == 0) {
    # Config axis: y
    filtered_df <- df %>% 
      filter(x == x_val, z == z_val)
    filtered_df$y = as.factor(filtered_df$y)
    
    if (metric_type == 'lka') {
      ggplot(data=filtered_df, aes(x=y, y=metric1, fill=y)) + 
        geom_boxplot() +
        ylab(lka_label) +
        # ggtitle(paste0("Varying Config: y\nFixed Config: (x=",x_val, ", z=", z_val, ")")) +
        theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size))
    } else if (metric_type == 'acc') {
      ggplot(data=filtered_df, aes(x=y, y=metric2, fill=y)) + 
        geom_boxplot() +
        ylab(acc_label) +
        # ggtitle(paste0("Varying Config: y\nFixed Config: (x=",x_val, ", z=", z_val, ")")) +
        theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size))
    }
    
  } else {
    # Config axis: z
    filtered_df <- df %>% 
      filter(x == x_val, y == y_val)
    filtered_df$z = as.factor(filtered_df$z)
    
    if (metric_type == 'lka') {
      ggplot(data=filtered_df, aes(x=z, y=metric1, fill=z)) + 
        geom_boxplot() +
        ylab(lka_label) +
        # ggtitle(paste0("Varying Config: z\nFixed Config: (x=",x_val, ", y=", y_val, ")")) +
        theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size))
    } else if (metric_type == 'acc') {
      ggplot(data=filtered_df, aes(x=z, y=metric2, fill=z)) + 
        geom_boxplot() +
        ylab(acc_label) +
        # ggtitle(paste0("Varying Config: z\nFixed Config: (x=",x_val, ", y=", y_val, ")")) +
        theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size))
    }
  }
}

x_varying <- configuration_space %>% group_by(y, z) %>% summarize(n=n())
for (i in 1:nrow(x_varying)) {
  # cat("i: ", i, ", y=", x_varying$y[i], ", z=", x_varying$z[i], "\n")
  
  filename <- paste0("boxplot_x_",trimws(x_varying$y[i]), "_", trimws(x_varying$z[i]), "_lka")

  png(file=paste(image_path, filename,".png",sep=""),width = x_width, height = y_width)
  grid.newpage()
  grid.draw(filter_and_boxplot(0, x_varying$y[i], x_varying$z[i], 'lka'))
  dev.off()
}

y_varying <- configuration_space %>% group_by(x, z) %>% summarize(n=n())
for (i in 1:nrow(y_varying)) {
  filename <- paste0("boxplot_",trimws(y_varying$x[i]), "_y_", trimws(y_varying$z[i]), "_acc")
  
  png(file=paste(image_path, filename,".png",sep=""),width = x_width, height = y_width)
  grid.newpage()
  grid.draw(filter_and_boxplot(y_varying$x[i], 0, y_varying$z[i], 'acc'))
  dev.off()
}

