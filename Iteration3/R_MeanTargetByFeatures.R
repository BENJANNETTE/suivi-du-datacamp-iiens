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
library(stats)


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

createTableUnique = function(num_feat, num_mod_feat, mod_feat) {
  tab = matrix(sort(as.vector(unlist(mod_feat[1]))))
  for (i in 2:num_feat) {
    tab = cbind(tab, rep(0, dim(tab)[1]))
    tmp = tab
    for (j in 1:(num_mod_feat[i]-1)) {
      tab = rbind(tab, tmp)
    }
    p = prod(num_mod_feat[1:(i-1)])
    tab2 = rep(sort(as.vector(unlist(mod_feat[i])))[1], p)
    j = 2
    while (j <= num_mod_feat[i]) {
      tab2 = c(tab2, rep(sort(as.vector(unlist(mod_feat[i])))[j], p))
      j = j + 1
    }
    tab[,dim(tab)[2]] = tab2
  }
  tab = data.frame(cbind(tab, rep(0, dim(tab)[1]), rep(0, dim(tab)[1])))
  colnames(tab)[(dim(tab)[2]-1):(dim(tab)[2])] = c("cpt", "target")
  for (j in 1:dim(tab)[2]) {
    tab[,j] = noquote(as.vector(tab[,j]))
  }
  return(tab)
}
writeInTab = function(tab, new_train, num_feat) {
  for (i in 1:dim(new_train)[1]) {
    features = as.vector(unlist(new_train[i,-dim(new_train)[2]]))
    ind = which(apply(tab[,1:num_feat], 1, function(x) prod(x == features)) == 1)
    tab[ind, dim(tab)[2]-1] = as.numeric(tab[ind, dim(tab)[2]-1]) + 1
    tab[ind, dim(tab)[2]] = as.numeric(tab[ind, dim(tab)[2]]) + as.numeric(new_train$target[i])
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
  tab = matrix(sort(as.vector(unlist(mod_feat[1]))))
  for (i in 2:num_feat) {
    tab = cbind(tab, rep(0, dim(tab)[1]))
    tmp = tab
    for (j in 1:(num_mod_feat[i]-1)) {
      tab = rbind(tab, tmp)
    }
    p = prod(num_mod_feat[1:(i-1)])
    tab2 = rep(sort(as.vector(unlist(mod_feat[i])))[1], p)
    j = 2
    while (j <= num_mod_feat[i]) {
      tab2 = c(tab2, rep(sort(as.vector(unlist(mod_feat[i])))[j], p))
      j = j + 1
    }
    tab[,dim(tab)[2]] = tab2
  }
  tab = data.frame(cbind(tab, rep(0, dim(tab)[1]), rep(0, dim(tab)[1]), rep(0, dim(tab)[1]), rep(0, dim(tab)[1])))
  colnames(tab)[(dim(tab)[2]-3):(dim(tab)[2])] = c("cpt+", "target+", "cpt-", "target-")
  for (j in 1:dim(tab)[2]) {
    tab[,j] = noquote(as.vector(tab[,j]))
  }
  return(tab)
}
writeInTab2 = function(tab, new_train, num_feat) {
  for (i in 1:dim(new_train)[1]) {
    features = as.vector(unlist(new_train[i,-dim(new_train)[2]]))
    ind = which(apply(tab[,1:num_feat], 1, function(x) prod(x == features)) == 1)
    if (new_train$target[i] > 0) {
      tab[ind, dim(tab)[2]-3] = as.numeric(tab[ind, dim(tab)[2]-3]) + 1
      tab[ind, dim(tab)[2]-2] = as.numeric(tab[ind, dim(tab)[2]-2]) + as.numeric(new_train$target[i])
    } else {
      tab[ind, dim(tab)[2]-1] = as.numeric(tab[ind, dim(tab)[2]-1]) + 1
      tab[ind, dim(tab)[2]] = as.numeric(tab[ind, dim(tab)[2]]) + as.numeric(new_train$target[i])
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

join1 = function(df_train, df_new_merch) {
  df_join_tnm1 = df_train %>% 
    left_join(select(df_new_merch, card_id, category_1, category_2, category_3), by="card_id")
  join_tnm1 = collect(select(df_join_tnm1, -first_active_month))
  join_tnm1 = data.frame(matrix(unlist(join_tnm1), ncol=length(colnames(join_tnm1))))
  join_tnm1 = na.omit(join_tnm1)
  join_tnm1 = join_tnm1[join_tnm1$X7 != "NaN", ]
  join_tnm1 = join_tnm1[!duplicated(join_tnm1),]
  # create new_train et new_test
  new_train = join_tnm1[,c(2:4, 7, 5)]
  new_train = data.frame(new_train[!duplicated(new_train),])
  for (j in 1:dim(new_train)[2]) {
    new_train[,j] = noquote(as.vector(new_train[,j]))
  }
  head(new_train)
  new_train[1,1]
  colnames(new_train)[dim(new_train)[2]] = "target"
  return(new_train)
}
join1test = function(df_test, df_new_merch) {
  df_join_tnm1 = df_test %>% 
    left_join(select(df_new_merch, card_id, category_1, category_2, category_3), by="card_id")
  join_tnm1 = collect(select(df_join_tnm1, -first_active_month))
  join_tnm1 = data.frame(matrix(unlist(join_tnm1), ncol=length(colnames(join_tnm1))))
  join_tnm1 = na.omit(join_tnm1)
  join_tnm1 = join_tnm1[join_tnm1$X6 != "NaN", ]
  join_tnm1 = join_tnm1[!duplicated(join_tnm1),]
  # create new_train et new_test
  new_test = join_tnm1[,c(2:4, 6)]
  for (j in 1:dim(new_test)[2]) {
    new_test[,j] = noquote(as.vector(new_test[,j]))
  }
  head(new_test)
  new_test[1,1]
  return(list("new_test"=new_test, "card_id"=noquote(as.vector(join_tnm1$X1))))
}

return_Y = function(nt_card_id, Y_predict, test) {
  res = data.frame("card_id"=nt_card_id, "Y_predict"=Y_predict)
  tmp = data.frame("card_id"=noquote(as.vector(test$card_id)), "val"=rep(0, length(test$card_id)))
  for (i in 1:dim(tmp)[1]) {
    ind = which(res[,1] == tmp[i,1])[1]
    tmp[i,2] = res[ind,2]
    print(i)
  }
  return(tmp[,2])
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
#df_histo1 = spark_read_csv(sc, "df_hist1", path_histo1, header = TRUE, delimiter = ",")
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


# On ajoute des variables grace a spark
colnames(df_new_merch)
df_new_merch %>% tally()
head(df_new_merch)

# Join df_train x df_new_merch
new_train = join1(df_train, df_new_merch)
write.csv(new_train, file="new_train.csv", quote = F, row.names = F)
new_train = read.delim("new_train.csv", header = T, sep=",")
# Join df_test x df_new_merch
new_test = join1test(df_test, df_new_merch)$new_test
nt_card_id = join1test(df_test, df_new_merch)$card_id
write.csv(new_test, file="new_test.csv", quote = F, row.names = F)
new_test = read.delim("new_test.csv", header = T, sep=",")

# join1 df_new_merch
Y_predict = MeanTarget(new_train, new_test)
hist(Y_predict)
new_Y = return_Y(nt_card_id, Y_predict, test)
table(new_Y == 0)
Sub_RMeanTarget_join1 = samp_sub
Sub_RMeanTarget_join1[,2] = new_Y
write.table(Sub_RMeanTarget_join1, file="../suivi-du-datacamp-iiens/Submission/Submission_R_MeanTarget_join1.csv", 
            row.names = F, quote=F, sep=",")

# Score pour join1 = 3.935 (ameliore pas)

# join2 df_new_merch (+ / -)
Y_predict = MeanTarget2(new_train, new_test)
hist(Y_predict)
new_Y = return_Y(nt_card_id, Y_predict, test)
new_Y[is.na(new_Y)] = 0
table(new_Y == 0)
Sub_RMeanTarget_join2 = samp_sub
Sub_RMeanTarget_join2[,2] = new_Y
write.table(Sub_RMeanTarget_join2, file="../suivi-du-datacamp-iiens/Submission/Submission_R_MeanTarget_join2.csv", 
            row.names = F, quote=F, sep=",")
