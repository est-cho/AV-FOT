rm(list = ls())
setwd("~/Projects/selab/AV-FOT")

library(ggplot2)
library(grid)
library(rpart)

data_path <- 'data/'
image_path <- 'analyses/images/'

files <- list.files(data_path)

for(file in files){
  data <- read.csv(paste(data_path,file,sep=""),header=TRUE)
  
  data$tick <- seq.int(nrow(data))
  color <- ggplot(data,aes(x=tick,y=color)) + geom_point(size=0.5,col=2) +
    theme(axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.text.x = element_blank(),panel.background = element_blank(),axis.line=element_line(size=0.5)) +
    xlim(c(0,300)) +
    ylim(c(0,100))
  
  distance <- ggplot(data,aes(x=tick,y=distance)) + geom_point(size=0.5,col=3) +
    theme(axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.text.x = element_blank(),panel.background = element_blank(),axis.line=element_line(size=0.5)) +
    xlim(c(0,300)) +
    ylim(c(0,1000))
  
  angle <- ggplot(data,aes(x=tick,y=angle)) + geom_point(size=0.5,col=4) +
    theme(axis.title.x = element_blank(),axis.ticks.x = element_blank(),axis.text.x = element_blank(),panel.background = element_blank(),axis.line=element_line(size=0.5)) +
    xlim(c(0,300)) +
    ylim(c(-25,25))
  
  speed <- ggplot(data,aes(x=tick,y=speed)) + geom_point(size=0.5,col=5) +
    theme(panel.background = element_blank(),axis.line=element_line(size=0.5)) +
    xlim(c(0,300)) +
    ylim(c(0,500)) 
  
  filename <- substring(file,1,nchar(file)-4)
  png(file=paste(image_path, filename,".png",sep=""),width = 600, height = 350)
  grid.newpage()
  grid.draw(rbind(ggplotGrob(color),ggplotGrob(distance),ggplotGrob(angle),ggplotGrob(speed)))
  dev.off()
}




