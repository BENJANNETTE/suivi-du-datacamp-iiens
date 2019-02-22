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

# Study variables
print(table(table(train[,2]) == 1))
# -> pas de doublons dans les card_id


#####################
#     Regresion     #
#####################
# GLM
RegLG = glm(target~feature_1+feature_2+feature_3, data=train)
new = data.frame(test[,3:5])
colnames(new) = c("feature_1", "feature_2", "feature_3")
Y_predict = predict(RegLG, newdata = new)
Sub_RLogit = samp_sub
Sub_RLogit[,2] = Y_predict
write.table(Sub_RLogit, file="../suivi-du-datacamp-iiens/Submission/Submission_R_GLM1.csv", 
            row.names = F, quote=F, sep=",")

# GLM
summary(RegLG)
# D'apres le test de student on peut elminer la variable "feature_3"
RegLG2 = glm(target~feature_1+feature_2, data=train)
new = data.frame(test[,3:4])
colnames(new) = c("feature_1", "feature_2")
Y_predict = predict(RegLG2, newdata = new)
Sub_RLogit2 = samp_sub
Sub_RLogit2[,2] = Y_predict
write.table(Sub_RLogit2, file="../suivi-du-datacamp-iiens/Submission/Submission_R_GLM2.csv", 
            row.names = F, quote=F, sep=",")


#####################
#     Spark R       #
#####################
sc <- spark_connect(master = "local")
df_histo1 = spark_read_csv(sc, "df_hist1", path_histo1, header = TRUE, delimiter = ",")
df_merch = spark_read_csv(sc, "df_merch", path_merch, header = TRUE, delimiter = ",")
df_new_merch = spark_read_csv(sc, "df_new_merch", path_new_merch, header = TRUE, delimiter = ",")
df_train = spark_read_csv(sc, "df_train", path_train, header = TRUE, delimiter = ",")
df_test = spark_read_csv(sc, "df_test", path_test, header = TRUE, delimiter = ",")

# Attributes for each new df
colnames(df_histo1)
colnames(df_merch)
colnames(df_new_merch)

# 1. Join beetween train, test & df_new_merch
df_join1 = df_train %>% left_join(df_new_merch, by="card_id")
colnames(df_join1)
df_join1 %>% tally()

## number of unique value by colomn
res = data.frame(rep(0, length(colnames(df_join1))), row.names = colnames(df_join1))
for (i in 1:dim(res)[1]) {
  tmp = collect(select(df_join1, colnames(df_join1)[i]))
  res[i,1] = length(table(tmp))
  print(i)
}
rownames(res)[res == 1]

fit = df_train %>% ml_linear_regression(target~feature_1+feature_2+feature_3)
summary(fit)
# Renvoi le meme resultat que pour les GLM "normal"


