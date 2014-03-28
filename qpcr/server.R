library(shiny)
library(ggplot2)
library(reshape)

shinyServer(function(input, output) {
  
  #read in text file
  datasetInput<-reactive({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    dataset<-read.table(inFile$datapath, header=TRUE, sep="\t", quote='',row.names=1)
    return(dataset)
  })
  
  calculateAll<-reactive({
    
    calcSE<-function(ss){
      newss<-ss
      for(i in 1:nrow(ss)){
        for(j in 1:ncol(ss)){
          newss[i,j]<-sqrt(ss[1,j]^2 + ss[i,j]^2)
        }
      }
      return(newss)
    }
    
    norm2gene<-function(values,se){
      ref<-values[1,]
      dv<-values
      for(i in 1:ncol(dv)) dv[,i]<-dv[,i]-ref[i]
      
      dse<-calcSE(se)
      return(list(dv,dse))
    }
    
    norm2samp<-function(values,se,n2g=TRUE){
      d2<-values
      for(i in 1:ncol(values)) {
        d2[,i]<-values[,i]-values[,1]
      }
      
      if(n2g!=TRUE) se<-calcSE(se)

      return(list(d2,se))
    }
    
    dataset<-datasetInput()
    numconds<-input$conditions
    numreps<-ncol(dataset)/numconds
    group<-rep(1:numconds,each=numreps)

    ng<-input$normalizegene
    ns<-input$normalizesamp
    # mean and stdev
    dvals<-do.call(cbind,by(t(dataset),group,function(x) colMeans(x)))
    dst<-do.call(cbind,by(t(dataset),group,function(x) apply(x,2,sd)))
    dst[is.na(dst)]<-0
    print(dst)
    ndvals<-dvals
    ndst<-dst
    if(ng==T) {
      vals<-norm2gene(dvals,dst)
      ndvals<-vals[[1]]
      ndst<-vals[[2]]
    }
    if(ns==T) {
      vals<-norm2samp(ndvals,ndst,ng)
      ndvals<-vals[[1]]
      ndst<-vals[[2]]
    }
    
  return(list(dvals,dst,ndvals,ndst))  
  })

  preparePlot<-reactive({
    lg2<-input$plotlog2
    normgene<-input$displayng
    normcond<-input$displaync
    
    vals<-calculateAll()
    ddct<-vals[[3]]
    se<-vals[[4]]
    ylabel<-"log2ratio"
    cholder<-colnames(ddct)
    rholder<-rownames(ddct)
    if(normgene==FALSE){
      rholder<-rholder[2:length(rholder)]
      ddct<-data.frame(ddct[2:nrow(ddct),])
      se<-data.frame(se[2:nrow(se),])
    }
    if(normcond==FALSE){
      cholder<-cholder[2:length(cholder)]
      ddct<-data.frame(ddct[,2:ncol(ddct)])
      se<-data.frame(se[,2:ncol(se)])
    }
    if(lg2==FALSE){
      #no se bars for fold change plots
      holder<-colnames(ddct)
      maxddct<-2^-(ddct+se)
      minddct<-2^-(ddct-se)
      ddct<-(maxddct+minddct)/2
      se<-maxddct-ddct
      ylabel<-input$ylabel
    } else {
      ddct<-(-ddct)
      ylabel<-paste("log2(",input$ylabel,")",sep="")
    }
    colnames(ddct)<-colnames(se)<-cholder
    rownames(ddct)<-rownames(se)<-rholder
    mct<-melt(as.matrix(ddct))
    mse<-melt(as.matrix(se))
    final<-cbind(mct,mse[,3])
    colnames(final)<-c("Gene","Sample","log2ratio","SE")
    final$Sample<-as.factor(final$Sample)
    dispEB<-input$errorbars
    
    a<-ggplot(final,aes(x=Gene,y=log2ratio,fill=Sample))+ylab(ylabel)+geom_bar(position=position_dodge(),stat = "identity")+ theme_classic(base_size=18)+scale_fill_grey()+geom_hline(yintercept=0)
    if(dispEB==TRUE){
      a<-a+geom_errorbar(aes(ymin=log2ratio-SE, ymax=log2ratio+SE),
                         width=.2,                    # Width of the error bars
                         position=position_dodge(.9))
    }
      
    return(a)
  })
  
  
  output$contents <- renderTable({
    dd<-datasetInput()
  })
  
  output$mean<-renderTable({
    dataset<-calculateAll()[[1]]
  })
  
  output$stdev<-renderTable({
    dataset<-calculateAll()[[2]]
  })
  
  output$deltact<-renderTable({
    dataset<-calculateAll()[[3]]
  })
  
  output$deltasd<-renderTable({
    dataset<-calculateAll()[[4]]
  })
    
  
  output$graph<-renderPlot({
    pp<-preparePlot()
    print(pp)
  })
  
  output$downloadPlot<-downloadHandler(
    filename="qpcr.pdf",
    content = function(FILE=NULL) {
      pdf(file=FILE, onefile=T, width=12,height=8)
      print(preparePlot())
      dev.off()
    }
    )
})

