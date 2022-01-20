rm(list = ls())

if (substring(getwd(),nchar(getwd())-15,nchar(getwd()))=='/AV-FOT/analyses'){
  setwd("../")
}

library(ggplot2)
library(grid)
library(rpart)

data_path <- 'data/'
image_path <- 'analyses/images/timeseries/'

xlim_max <- 231
font_size <- 20
x_width <- 600
y_width <- 400
font_size <- 20

files <- list.files(data_path)

for(file in files){
  data <- read.csv(paste(data_path,file,sep=""),header=TRUE)
  
  data$tick <- seq.int(nrow(data))
  color <- ggplot(data,aes(x=tick,y=color)) + geom_point(size=0.5,col=2) +
    theme(axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.text.x = element_blank(),panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size)) +
    xlim(c(0,xlim_max)) +
    xlab('Time (x50ms)') +
    ylab('Color') +
    ylim(c(0,100))
  
  distance <- ggplot(data,aes(x=tick,y=distance)) + geom_point(size=0.5,col=3) +
    theme(axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.text.x = element_blank(),panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size)) +
    xlim(c(0,xlim_max)) +
    xlab('Time (x50ms)') +
    ylab('Distance') +
    ylim(c(0,1000))
  
  angle <- ggplot(data,aes(x=tick,y=angle)) + geom_point(size=0.5,col=4) +
    theme(axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.text.x = element_blank(),panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size)) +
    xlim(c(0,xlim_max)) +
    xlab('Time (x50ms)') +
    ylab('Angle') +
    ylim(c(-25,25))
  
  speed <- ggplot(data,aes(x=tick,y=speed)) + geom_point(size=0.5,col=5) +
    theme(panel.background = element_blank(),axis.line=element_line(size=0.5), text=element_text(family="Times New Roman", face="bold", size=font_size)) +
    xlim(c(0,xlim_max)) +
    xlab('Time (x50ms)') +
    ylab('Speed') +
    ylim(c(0,800)) 
  
  config_time <- substring(file,5,nchar(file)-4)
  filename <- paste0("timeseries_",config_time)
  png(file=paste(image_path, filename,".png",sep=""),width = x_width, height = y_width)
  grid.newpage()
  grid.draw(rbind(ggplotGrob(color),ggplotGrob(distance),ggplotGrob(angle),ggplotGrob(speed)))
  dev.off()
}
