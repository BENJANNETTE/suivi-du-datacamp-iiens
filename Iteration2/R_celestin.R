#####################
#     Library       #
#####################
library(glm2)
library(NLP)

#####################
#     Function      #
#####################

#####################
#     Import        #
#####################
path_train = "../suivi-du-datacamp-iiens/data/train.csv"
path_test = "../suivi-du-datacamp-iiens/data/test.csv"
path_samp_sub = "../suivi-du-datacamp-iiens/data/sample_submission.csv"

train = read.delim(path_train, header = T, sep=",")
test = read.delim(path_test, header = T, sep=",")
samp_sub = read.delim(path_samp_sub, header=T, sep=",")

# Study variables
print(table(table(train[,2]) == 1))
# -> pas de doublons dans les card_id

#####################
#     Regresion     #
#####################
# Logistic
RegLG = glm(target~feature_1+feature_2+feature_3, data=train)
new = data.frame(test[,3:5])
colnames(new) = c("feature_1", "feature_2", "feature_3")
Y_predict = predict(RegLG, newdata = new)

Sub_RLogit = samp_sub
Sub_RLogit[,2] = Y_predict
write.table(Sub_RLogit, file="../suivi-du-datacamp-iiens/Submission/Submission_R_Logistic1.csv", 
            row.names = F, quote=F, sep=",")


