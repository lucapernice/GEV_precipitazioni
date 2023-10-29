#Analisi Esplorativa Dataset Gemona

#-------------------------------------#
# LIBRERIE
library(ggplot2)
library(ggfortify)
library(tseries)
library(evd)
library(extRemes)

#-------------------------------------#

#importo il csv dei dati 
dataset <- read.csv('datasetGemona.csv')
str(dataset)
#head(dataset)

#ricerca valori null
any(is.na(dataset)) #TRUE
sum(is.na(dataset)) #2 NA
na_index <- which(is.na(dataset$UMIDITÀ.RELATIVA.MEDIA)) #righe 201 e 202
dataset[na_index[1],]
dataset[na_index[2],]
boxplot(dataset$PRECIPITAZIONE.MASSIMA.1.ORA ~ dataset$MESE,
        xlab = 'MESE',
        ylab = 'Precipitazioni'
        )

#timeserie delle precipitazioni 
precipitazioni <- ts(dataset$PRECIPITAZIONE.MASSIMA.1.ORA, start = c(2000,1), frequency = 12)
autoplot(precipitazioni,ylab = 'precipitazioni max (1 ora)' )
ggfreqplot(precipitazioni)
acf(as.numeric(precipitazioni), main = '') 
summary(precipitazioni)
#L'autocorrelazione non sembra decadere al crescere dei lag e mostra periodicità (come ci si dovrebbe aspettare!!). I dati non sono indipendenti 

#test di DIckey-Fuller
adf <- adf.test(precipitazioni)
print(adf) #p-value 0.01

#Anche se i dati non sono i.i.d. si fitta comunque il modello GEV
M1 <- fgev(dataset$PRECIPITAZIONE.MASSIMA.1.ORA)


#altre variabili
temperatura_max <- ts(dataset$TEMPERATURA.MASSIMA.ASSOLUTA, start = c(2000,1), frequency = 12)
temperatura_media <-ts(dataset$TEMPERATURA.MEDIA, start = c(2000,1), frequency = 12)
umidita<-ts(dataset$UMIDITÀ.RELATIVA.MEDIA, start = c(2000,1), frequency = 12)
vento<-ts(dataset$VENTO.MEDIO, start = c(2000,1), frequency = 12)



#train set e test set
#Come dati di stima si prendono quelli fino al 2017, i dati del 2018 sono invece di verifica.
t <- seq(1,length(dataset[,1]))
t <- t/(length(dataset[,1])+1)

dataset$t <- t

test <- dataset[dataset$ANNO == 2018,]
train <- dataset[1:216,]
train1 <-replace(train,is.na(train),train$UMIDITÀ.RELATIVA.MEDIA[200])

daym <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
mid_month <- daym/2
c_moy <- cumsum(c(0,daym[1:length(daym)-1])) + mid_month
Nyears <- 18
cmoy_test <- c_moy
cmoy <-rep(c_moy,Nyears)
moy_s<-sin(cmoy*2*pi/366)
test$moy_s <- sin(cmoy_test*2*pi/366)
moy_c <-cos(cmoy*2*pi/366)
test$moy_c <- cos(cmoy_test*2*pi/366)
moy_s4<-sin(cmoy*0.5*pi/366)
moy_c4 <-cos(cmoy*0.5*pi/366)





#variabili per modello sin cos
train1$moy_s <- moy_s
train1$moy_c <- moy_c


#lagged values
lagged_1 <- data.frame(train1)
lagged_1 <- head(lagged_1,n = length(lagged_1[,1])-1)
lagged_1 <- subset(lagged_1, select = -c(ANNO, MESE,t,moy_s,moy_c))

lagged_12 <- data.frame(train1)
lagged_12 <- head(lagged_12,n = length(lagged_1[,1])-11)
lagged_12 <- subset(lagged_12, select = -c(ANNO, MESE,t,moy_s,moy_c))



#train2 is for lag 1
train2 <- data.frame(train1)
train2 <- tail(train2, n = length(train2[,1])-1)
train2$lag1_p <- lagged_1$PRECIPITAZIONE.MASSIMA.1.ORA
train2$lag1_t <- lagged_1$TEMPERATURA.MEDIA
train2$lag1_u <- lagged_1$UMIDITÀ.RELATIVA.MEDIA
train2$lag1_v <- lagged_1$VENTO.MEDIO

#train3 is for lag12
train3 <- data.frame(train1)
train3 <- tail(train3, n = length(train2[,1])-11)
train3$lag12_p <- lagged_12$PRECIPITAZIONE.MASSIMA.1.ORA
train3$lag12_t <- lagged_12$TEMPERATURA.MEDIA
train3$lag12_u <- lagged_12$UMIDITÀ.RELATIVA.MEDIA
train3$lag12_v <- lagged_12$VENTO.MEDIO

train3$lag1_p <- lagged_1$PRECIPITAZIONE.MASSIMA.1.ORA[12:215]
train3$lag1_t <- lagged_1$TEMPERATURA.MEDIA[12:215]
train3$lag1_u <- lagged_1$UMIDITÀ.RELATIVA.MEDIA[12:215]
train3$lag1_v <- lagged_1$VENTO.MEDIO[12:215]

x <- c(rep(1,12))
x <- c(x,test$moy_s, test$moy_c)
matmu <- matrix(x,nrow = 3, byrow = TRUE)


x4 <- c(x,test$t)
matmu4 <- matrix(x4,nrow = 4, byrow = TRUE)

x6 <- c(x4,test$TEMPERATURA.MASSIMA.ASSOLUTA,test$VENTO.MEDIO, test$UMIDITÀ.RELATIVA.MEDIA)
matmu6 <- matrix(x6,nrow = 7, byrow = TRUE)

#-------------------------------------#

#MODELLI BOZZA

#-------------------------------------#



modello1 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, period = 'month')

modello2 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, 
                 data = train1,
                 location.fun = ~ moy_s + moy_c)

modello3 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, 
                 data = train1,
                 location.fun = ~ moy_s + moy_c,
                 scale.fun = ~ moy_s + moy_c)

modello4 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, 
                 data = train1,
                 location.fun = ~ moy_s + moy_c + t)
                 

modello5 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, 
                 data = train1,
                 location.fun = ~ moy_s + moy_c + t,
                 scale.fun = ~ moy_s + moy_c + t)

modello6 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, 
                 data = train1,
                 location.fun = ~ moy_s + moy_c + t + TEMPERATURA.MASSIMA.ASSOLUTA+ VENTO.MEDIO + UMIDITÀ.RELATIVA.MEDIA,
                 scale.fun = ~ moy_s + moy_c + t)


modello7 <- fevd(x = train$PRECIPITAZIONE.MASSIMA.1.ORA, 
             data = train1,
             location.fun = ~ moy_s + moy_c + t + TEMPERATURA.MASSIMA.ASSOLUTA+ VENTO.MEDIO + UMIDITÀ.RELATIVA.MEDIA
            )





#-------------------------------------#

#VEROSIMIGLIANZA

#-------------------------------------#

#modello1
like1 <- levd(test$PRECIPITAZIONE.MASSIMA.1.ORA, 
              location =modello1$results$par['location'],
              scale= modello1$results$par['scale'],
              shape =modello1$results$par['shape'],
              type = 'GEV', negative = TRUE, log = TRUE)

#modello2



#modello3

l <-  c((modello3$results$par[1:3])%*%matmu)
s <- c((modello3$results$par[4:6])%*%matmu)




like3 <- levd(test$PRECIPITAZIONE.MASSIMA.1.ORA,
              location =l,
              scale =s,
              shape = modello3$results$par['shape'])

#modello 4
l4 <- c((modello4$results$par[1:4])%*%matmu4)

like4 <- levd(test$PRECIPITAZIONE.MASSIMA.1.ORA,
              location =l4,
              scale =modello4$results$par['scale'],
              shape = modello4$results$par['shape'])

#modello 5
l5 <-  c((modello5$results$par[1:4])%*%matmu4)
s5 <- c((modello5$results$par[5:8])%*%matmu4)

like5 <- levd(test$PRECIPITAZIONE.MASSIMA.1.ORA,
              location =l5,
              scale =l5,
              shape = modello5$results$par['shape'])
#modello 6
l6 <-  c((modello6$results$par[1:7])%*%matmu6)
s6 <- c((modello6$results$par[8:11])%*%matmu4)
like6 <- levd(test$PRECIPITAZIONE.MASSIMA.1.ORA,
              location =l6,
              scale =l6,
              shape = modello6$results$par['shape'])
#modello7
l7 <-  c((modello7$results$par[1:7])%*%matmu6)
like7 <- levd(test$PRECIPITAZIONE.MASSIMA.1.ORA,
              location =l7,
              scale =modello7$results$par['scale'],
              shape = modello7$results$par['shape'])

#confronto return level

par(mfrow=c(1,1))
par(cex=1, mar=c(3,2,2,2))
plot(modello2,'rl',rperiods = c(2,24,240,600),period = 'm', main = '')
plot(modello3,'rl',rperiods = c(2,24,240),period = 'm', main = '')

par(mfrow = c(1,2))
plot(modello3,'qq', main = '')
plot(modello3, 'density', main = '')
plot(modello5,'qq', main = 'modello 5')
plot(modello5, 'density', main = '', ylim = c(0,0.4))
plot(modello6,'qq', main = 'modello 6')
plot(modello6, 'density', main = '',ylim = c(0,0.4))
plot(modello7,'qq', main = 'modello 7')
plot(modello7, 'density', main = '')