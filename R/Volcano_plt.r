##Volcano plot
##https://www.4k8k.xyz/article/qq_36711935/108095320
##https://cloud.tencent.com/developer/article/1486128

##data$change = ifelse(data$padj < cut_off_padjust & abs(data$log2FoldChange) >= cut_off_logFC, ifelse(data$log2FoldChange> cut_off_logFC ,'Up','Down'), 'Stable')
library(ggplot2)
library(ggrepel)
library(dplyr)

data <- read.table("C:/CUHK/Data/RNA-seq/HZM_rnaseq/Young_2_2/Young_2_2_DEG.txt",sep="\t",header=T)

ggplot(data,aes(x = log2FoldChange,y = -log10(pvalue))) + geom_point(aes(color = Regulate))
p <- ggplot(data,aes(x = log2FoldChange,y = -log10(pvalue)))+ geom_point(aes(color = Regulate))+ scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C")) +   
geom_vline(xintercept=c(-1,1),lty=3,col="black",lwd=0.5)+ geom_hline(yintercept = 1.30103,lty=3,col="black",lwd=0.5)+
xlim(-5,5) + ylim(0,7) +  labs(x="log2FC",y="-log10(PValue)")

ggsave(filename = "./HZM_YOUNG/1.png")

ggplot(data,aes(x = log2FoldChange,y = -log10(pvalue)))+
	geom_point(aes(color = Regulate))+
	scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C"))+
	theme_bw()+
	geom_vline(xintercept=c(-0.5,2),lty=3,col="black",lwd=0.5)+ geom_hline(yintercept = 1.30103,lty=3,col="black",lwd=0.5)+
	labs(x="log2FC",y="-log10(PValue)")+
	theme(panel.grid.major = element_blank(),
        panel.grid.minor.x  = element_blank(),
        panel.grid.minor.y  = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(hjust = 0.5,size = 15),
        axis.title = element_text(hjust = 0.5,size = 15),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 20))+
ggtitle("Volcano Plot")

#将超过一定范围的点的值限定在一定范围内
data$pvalue[data$pvalue <= 1e-8] <- 1e-8
data$log2FoldChange[data$log2FoldChange >= 5] <- 5
  

ggplot(data,aes(x = log2FoldChange,y = -log10(pvalue)))+
	geom_point(aes(color = Regulate))+
	scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C"))+
	theme_bw()+
	geom_vline(xintercept=c(-0.5,2),lty=3,col="black",lwd=0.5)+ geom_hline(yintercept = 1.30103,lty=3,col="black",lwd=0.5)+
	#坐标轴
	xlim(-10,10) + ylim(0,10) +  labs(x="log2FC",y="-log10(PValue)")+	
	#注释
	# geom_label_repel(
    # data = subset(data, data$pvalue <= 1e-8 | abs(data$log2FoldChange) >= 4.5),
    # aes(label = symbol),
    # size = 5,fill = "darkred", color = "white",
    # box.padding = unit(0.35, "lines"),
    # point.padding = unit(0.3, "lines")) +
	
	geom_text_repel(
    data = subset(data, data$pvalue <= 1e-9 | data$log2FoldChange >= 10 | data$log2FoldChange <= -5),
    aes(label = symbol),
    size = 4,
    box.padding = unit(0.35, "lines"),
    point.padding = unit(0.3, "lines")) +
	theme(panel.grid.major = element_blank(),
        panel.grid.minor.x  = element_blank(),
        panel.grid.minor.y  = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(hjust = 0.5,size = 15),
        axis.title = element_text(hjust = 0.5,size = 15),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20))+
ggtitle("Volcano Plot")

  
##为了提高图片的层次感，这里提供两种方法。（1）第一种是调节点的透明度，这样基因点聚堆的地方颜色会更深。

ggplot(data,aes(x = log2FoldChange,y = -log10(pvalue)))+
	geom_point(aes(color = Regulate),alpha=0.3,size=3)+
  #通过alpha设定图片元素的透明度
	scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C"))+
	theme_bw()+
	geom_vline(xintercept=c(-0.5,2),lty=3,col="black",lwd=0.5)+ geom_hline(yintercept = 1.30103,lty=3,col="black",lwd=0.5)+
	#坐标轴
	# xlim(-10,15) + ylim(0,10) +  labs(x="log2FC",y="-log10(PValue)")+	
	geom_text_repel(
    data = subset(data, data$pvalue <= 1e-5 | data$log2FoldChange >= 2 & data$pvalue <= 1e-3  | data$log2FoldChange <= -5),
    aes(label = symbol),
    size = 4,
    box.padding = unit(0.35, "lines"),
    point.padding = unit(0.3, "lines")) +	
	theme(panel.grid.major = element_blank(),
        panel.grid.minor.x  = element_blank(),
        panel.grid.minor.y  = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(hjust = 0.5,size = 20),
        axis.title = element_text(hjust = 0.5,size = 20),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 20))+
ggtitle("Volcano Plot")

ggplot(data,aes(x = log2FoldChange,y = -log10(pvalue)))+
	geom_point(aes(color = Regulate),alpha=0.3,size=3)+
  #通过alpha设定图片元素的透明度
	scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C"))+
	theme_bw()+
	##geom_vline(xintercept=c(-0.5,2),lty=3,col="black",lwd=0.5)+ geom_hline(yintercept = 1.30103,lty=3,col="black",lwd=0.5)+
	geom_vline(xintercept=c(-1,1),lty=3,col="black",lwd=0.5)+ geom_hline(yintercept = 1.30103,lty=3,col="black",lwd=0.5)+
	#坐标轴
	# xlim(-10,15) + ylim(0,10) +  labs(x="log2FC",y="-log10(PValue)")+	
	labs(x="Log2FC",y="-Log10(PValue)")+	
	geom_text_repel(
    data = subset(data, data$pvalue <= 1e-6 | data$log2FoldChange >= 3 & data$pvalue <= 1e-3  | data$log2FoldChange <= -2.5),
    aes(label = symbol),
    size = 5,
    box.padding = unit(0.35, "lines"),
    point.padding = unit(0.3, "lines")) +	
	theme(panel.grid.major = element_blank(),
        panel.grid.minor.x  = element_blank(),
        panel.grid.minor.y  = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 24),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(hjust = 0.5,size = 24),
        axis.title = element_text(hjust = 0.5,size = 24),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 24))+
ggtitle("Volcano Plot")
  
##（2）第二种方法是更改点的样式，通过降低单个点的面积来淡化图像。

ggplot(data,aes(x = log2FoldChange,y = -log10(padj)))+
  geom_point(aes(color = Regulate),shape='+')+
  #通过shape设定点的形状
  scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C"))+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor.x  = element_blank(),
        panel.grid.minor.y  = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(hjust = 0.5,size = 15),
        axis.title = element_text(hjust = 0.5,size = 15),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 20))+
  ggtitle("Volcano Plot")
  
##火山图需加上纵向和横向的辅助线
  
  ggplot(data = data,aes(x = `log2(FD)`,y = `-Log10(PValue)`))+
  geom_point(aes(color = Regulate),shape='+')+
  geom_vline(xintercept=c(-1,1),lty=3,col="black",lwd=0.5)+
  geom_hline(yintercept = 3,lty=3,col="black",lwd=0.5)+
  #geom_hline和geom_vline绘制横向和纵向的线条
  scale_color_manual(values=c("Down"="#00008B", "Not Sig"="#808080", "Up"="#DC143C"))+
  scale_y_continuous(limits = c(0,16),breaks = c(0,16))+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor.x  = element_blank(),
        panel.grid.minor.y  = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.text = element_text(hjust = 0.5,size = 15),
        axis.title = element_text(hjust = 0.5,size = 15),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 20))+
  ggtitle("FIGURE")