#####################
#     Library       #
#####################
library(glm2)
library(NLP)
library(dplyr)
library(sparklyr)
options(sparklyr.java9 = TRUE)
Sys.setenv(JAVA_HOME = "/Library/Java/JavaVirtualMachines/jdk1.8.0_192.jdk/Contents/Home")
library(rlist)


#####################
#     Function      #
#####################
createTableUnique = function(num_feat, num_mod_feat, mod_feat) {
  tab = matrix(0, nrow=prod(num_mod_feat), ncol=num_feat)
  for (i in 1:num_feat) {
    tab[,i] = rep(sort(as.vector(unlist(mod_feat[i]))), prod(num_mod_feat)/num_mod_feat[i])
  }
  tab = data.frame(cbind(tab, rep(0, dim(tab)[1]), rep(0, dim(tab)[1])))
  colnames(tab)[(dim(tab)[2]-1):(dim(tab)[2])] = c("cpt", "target")
  return(tab)
}
writeInTab = function(tab, new_train, num_feat) {
  for (i in 1:dim(new_train)[1]) {
    features = as.vector(unlist(new_train[i,-dim(new_train)[2]]))
    ind = which(apply(tab[,1:num_feat], 1, function(x) prod(x == features)) == 1)
    tab[ind, dim(tab)[2]-1] = tab[ind, dim(tab)[2]-1] + 1
    tab[ind, dim(tab)[2]] = tab[ind, dim(tab)[2]] + new_train$target[i]
    print(i)
  }
  return(tab)
}
predictWithTab = function(tab, new_test, num_feat) {
  tmp = rep(0, dim(new_test)[1])
  for (i in 1:length(tmp)) {
    features = as.vector(unlist(new_test[i,]))
    ind = which(apply(tab[,1:num_feat], 1, function(x) prod(x == features)) == 1)
    tmp[i] = tab$target[ind]
    print(i)
  }
  return(tmp)
}
MeanTarget = function(new_train, new_test) {
  num_feat = dim(new_train)[2] - 1
  num_mod_feat = as.vector(apply(new_train[,-dim(new_train)[2]], 2, function(x) length(unique(x))))
  mod_feat = apply(new_train[,-dim(new_train)[2]], 2, unique)
  tab = createTableUnique(num_feat, num_mod_feat, mod_feat)
  tab = writeInTab(tab, new_train, num_feat)
  tmp = tab[,dim(tab)[2]] / tab[,dim(tab)[2]-1]
  tmp[is.na(tmp)] = 0
  tab[,dim(tab)[2]] = tmp
  Y_pred = predictWithTab(tab, new_test, num_feat)
  return(Y_pred)
}

createTableUnique2 = function(num_feat, num_mod_feat, mod_feat) {
  tab = matrix(0, nrow=prod(num_mod_feat), ncol=num_feat)
  for (i in 1:num_feat) {
    tab[,i] = rep(sort(as.vector(unlist(mod_feat[i]))), prod(num_mod_feat)/num_mod_feat[i])
  }
  tab = data.frame(cbind(tab, rep(0, dim(tab)[1]), rep(0, dim(tab)[1]), rep(0, dim(tab)[1]), rep(0, dim(tab)[1])))
  colnames(tab)[(dim(tab)[2]-3):(dim(tab)[2])] = c("cpt+", "target+", "cpt-", "target-")
  return(tab)
}
writeInTab2 = function(tab, new_train, num_feat) {
  for (i in 1:dim(new_train)[1]) {
    features = as.vector(unlist(new_train[i,-dim(new_train)[2]]))
    ind = which(apply(tab[,1:num_feat], 1, function(x) prod(x == features)) == 1)
    if (new_train$target[i] > 0) {
      tab[ind, dim(tab)[2]-3] = tab[ind, dim(tab)[2]-3] + 1
      tab[ind, dim(tab)[2]-2] = tab[ind, dim(tab)[2]-2] + new_train$target[i]
    } else {
      tab[ind, dim(tab)[2]-1] = tab[ind, dim(tab)[2]-1] + 1
      tab[ind, dim(tab)[2]] = tab[ind, dim(tab)[2]] + new_train$target[i]
    }
    print(i)
  }
  return(tab)
}
predictWithTab2 = function(tab, new_test, num_feat) {
  tmp = rep(0, dim(new_test)[1])
  for (i in 1:length(tmp)) {
    features = as.vector(unlist(new_test[i,]))
    ind = which(apply(tab[,1:num_feat], 1, function(x) prod(x == features)) == 1)
    if (tab[ind,dim(tab)[2]-3] < tab[ind,dim(tab)[2]-1]) {
      tmp[i] = tab[ind,dim(tab)[2]]
    } else {
      tmp[i] = tab[ind,dim(tab)[2]-2]
    }
    print(i)
  }
  return(tmp)
}
MeanTarget2 = function(new_train, new_test) {
  num_feat = dim(new_train)[2] - 1
  num_mod_feat = as.vector(apply(new_train[,-dim(new_train)[2]], 2, function(x) length(unique(x))))
  mod_feat = apply(new_train[,-dim(new_train)[2]], 2, unique)
  tab = createTableUnique2(num_feat, num_mod_feat, mod_feat)
  tab = writeInTab2(tab, new_train, num_feat)
  tmpp = tab[,dim(tab)[2]-2] / tab[,dim(tab)[2]-3]
  tmpn = tab[,dim(tab)[2]] / tab[,dim(tab)[2]-1]
  tmpp[is.na(tmpp)] = 0
  tmpn[is.na(tmpn)] = 0
  tab[,dim(tab)[2]-2] = tmpp
  tab[,dim(tab)[2]] = tmpn
  Y_pred = predictWithTab2(tab, new_test, num_feat)
  return(Y_pred)
}



#####################
#     Import        #
#####################
path_train = "../suivi-du-datacamp-iiens/data/train.csv"
path_test = "../suivi-du-datacamp-iiens/data/test.csv"
path_samp_sub = "../suivi-du-datacamp-iiens/data/sample_submission.csv"
path_histo1 = "../suivi-du-datacamp-iiens/data/historical_transactions1.csv"
path_histo2 = "../suivi-du-datacamp-iiens/data/historical_transactions2.csv"
path_merch = "../suivi-du-datacamp-iiens/data/merchants.csv"
path_new_merch = "../suivi-du-datacamp-iiens/data/new_merchant_transactions.csv"

train = read.delim(path_train, header = T, sep=",")
test = read.delim(path_test, header = T, sep=",")
samp_sub = read.delim(path_samp_sub, header=T, sep=",")


#####################
#     Spark R       #
#####################
sc <- spark_connect(master = "local")
df_histo1 = spark_read_csv(sc, "df_hist1", path_histo1, header = TRUE, delimiter = ",")
df_merch = spark_read_csv(sc, "df_merch", path_merch, header = TRUE, delimiter = ",")
df_new_merch = spark_read_csv(sc, "df_new_merch", path_new_merch, header = TRUE, delimiter = ",")
df_train = spark_read_csv(sc, "df_train", path_train, header = TRUE, delimiter = ",")
df_test = spark_read_csv(sc, "df_test", path_test, header = TRUE, delimiter = ",")


#####################
#     Main          #
#####################
# Mean target value by combinaisons
## Nous sommes partie du fait que les variables features sont qualtitatives et pas quantitatives !
## On garde que les features et target => new_train
new_train = train[,3:6]
new_test = test[,3:5]
Y_predict = MeanTarget(new_train, new_test)
hist(Y_predict)
hist(train$target)
Sub_RMeanTarget_1 = samp_sub
Sub_RMeanTarget_1[,2] = Y_predict
write.table(Sub_RMeanTarget_1, file="../suivi-du-datacamp-iiens/Submission/Submission_R_MeanTarget_1.csv", 
            row.names = F, quote=F, sep=",")
Y_predict = MeanTarget2(new_train, new_test)
Sub_RMeanTarget_2 = samp_sub
Sub_RMeanTarget_2[,2] = Y_predict
write.table(Sub_RMeanTarget_2, file="../suivi-du-datacamp-iiens/Submission/Submission_R_MeanTarget_2.csv", 
            row.names = F, quote=F, sep=",")


# Ecrire dans README
# 1. moyenne target suivant features, Score : 3.930
# 2. moyenne target (+ / -) suivant features, Score : 4.183
