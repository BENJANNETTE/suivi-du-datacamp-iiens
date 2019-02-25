# Datacamp M2DSSAF - Groupe iiens 
Les points hebdomadaires se feront sur le readme.
Ce readme est organisé selon des itérations qui trace l'évolution de notre travail. 
Un rapport qui résume notre travail sur le challenge et nos résultats sera rédigé à la fin du projet.


### Composition de l'équipe

| Nom                     | Prénom                   | Email                   |
| -------------           |-------------             |-------------            |
| EL ATTAOUI                   | Mounia           |    elattaouimounia@hotmail.com           |
| CAUMES                | Celestin                | celestincaumes@gmail.com                 |
| FAIQ                  | Othman                 | othmane.faiq@gmail.com                 |


### Sujet : Elo Merchant Category Recommendation 
https://www.kaggle.com/c/elo-merchant-category-recommendation


### Git (Étapes à respecter par les membres de l'équipes pour mieux gérer nos contributions)

Pour l'initialisation, il faut :
* git clone http//... (à compléter)

Pour une bonne utilisation du dépôt de travail git, veuillez à :
* git pull (pour récupérer le travail distant, non obligatoire)
* par rapport aux branches, afin de garder la branche master la plus propre possible :
  * git checkout -b nom_branche si vous voulez créer un nouveau module (dans ce cas, pull devient obligatoire)
  * git branch nom_branche pour continuer à travailler sur un module existant
* git add *nom du fichier*
* git commit -m "message" (en anglais)
* git push origin nom_branche (afin que tout le monde puisse y avoir accès)

Penser bien à faire de nombreux add/commit afin d'avoir une progression continuelle du projet (et non un gros développement pour que finalement le programme ait besoin d'un débugage...).

Lorsque le module est au point et a été epprouvé par l'ensemble de l'équipe, on peut fusionner la branche à la branche master :
* git pull (obligatoire)
* git checkout master
* git merge nom_branche

À ce moment précis (si le travail est propre), il y a un fort pourcentage qu'on n'ait pas de conflit à régler et donc :
* git push origin master
* git branch -d nom_branche (si vous ne vous en servez plus)

Sinon, il faut régler les conflits soit ensemble ou seul (si vous vous en sentez capable).

----------------------------------------------------------------------------------------------------------------------------
## Bilan de l'itération 1: (Date de présentation du datacamp - 01/02/2019)
Rapport rédigé par: Othman FAIQ

### Évènements 
*Quels sont les évènements qui ont marqué l'itération précédente? Répertoriez ici les évènements qui ont eu un impact sur ce qui était prévu à l'itération précédente.*
> Création de l'équipe et configuratios des outils de travail (github, slack, kaggle ..)
> Une discution entre les membres de l'équipe sur le choix du langage: Mounia et Othman pour Python et Célestin pour R. On s'est mis d'accord de travailler chacun de son coté avec le langage qu'il préfère (dans un premier temps)
> Importation des données et premiers analyses statistiques. Dans un premier temps on a fait tourner un algorithme de régression linéaire sur le dataset train.csv. 

### Rétrospective de l'itération précédente et axes d'améliorations:

### Objectifs pour la prochaine itération:
> Création des répertoires de travail sur github selon l'organisation proposé par le prof (voir photo sur slack)
> Décider un choix final pour le langage utilisé 
> Définir des taches et les affecter aux membres de l'équipe


----------------------------------------------------------------------------------------------------------------------------
## Bilan de l'itération 2: (Du 01/02/2019 au - 15/02/2019)
Rapport rédigé par: Celestin CAUMES

### Évènements 
*Quels sont les évènements qui ont marqué l'itération précédente? Répertoriez ici les évènements qui ont eu un impact sur ce qui était prévu à l'itération précédente.*.   
> Nous avons choisi les 2 languages R et python car Mounia & Othmane sont plus à l'aise avec Python et Celestin est plus à l'aise avec R.    
> Nous avons créé un dossier Iteration 2 avec le notebook de l'importation des données et de la Regression Logistique sous Python.   
> Nous avons également crée un Script R pour la regression Logistique et nous avons fait une premiere soumission.   
> 1ere Submission : Regression GLM Simple sur les données initiales => Place 3620 & Score=3.930.   
> 2eme Submission : Regression GLM avec selection de variable suivant test de Student, grâce au "summary()" de R => Place 3620 & Score=3.930 (pas d'amelioration).   


### Score Final sur l'iteration
Place 3620 & Score=3.930.    


### Rétrospective de l'itération précédente et axes d'améliorations:
Mieux indexer les fichiers dans le Git.    


### Objectifs pour la prochaine itération:
Continuer a chercher des méthodes afin d'améliorer notre score Kaggle.    
 
 




----------------------------------------------------------------------------------------------------------------------------
## Bilan de l'itération 3: (Du 15/02/2019 au -)
Rapport rédigé par: ---

### Évènements 
*Quels sont les évènements qui ont marqué l'itération précédente? Répertoriez ici les évènements qui ont eu un impact sur ce qui était prévu à l'itération précédente.*.     
> Nous avons utilisé le Spark R afin d'importer et croiser les tous les fichiers afin de poser des modèles sur plus de variables explicatives. Nous avons utilisé le Spark R car les fichiers historical_transactions et new_merchant_transactions sont très volumineux (~1Go).       
> Nous avons créé une méthode de prédiction suivant les données train.csv et test.csv : Nous sommes partis du principe que les variables "feature_x" sont qualitatives et non pas quantitatives comme pour GLM. Nous avons créé des fonctions R qui simulent toutes les combinaisons possibles des modalités des variables "feature_x", ensuite elles calcule la valeur moyenne de "target" pour chaque combinaisons de modalité. Puis on prédit sur test.csv.    
> 1ere Submission: Moyenne de "target" suivant les modalités => Place 3735 & Score=3.930.      
> 2eme Submission: Moyenne positive et negative de "target"  suivant les modalités, puis on a choisi suivant le nombre de valeurs positives ou negatives. => Place +3735 & Score=4.183. (Score plus faible).       
> Nous avons choisi de croiser les tables "train" et "test" avec la table "new_merchant" et on a ajouté a "train" et "test" la variable Category_3 afin d'essayer d'améliorer les scores precedent. Nous avons choisi cette variable arbitrairement pour tester notre code.      
> 3eme Submission: Moyenne de "target" suivant les modalités => Score=3.935.       
> 4eme Submission: Moyenne positive et negative de "target" => Score=3.994.     
>



### Rétrospective de l'itération précédente et axes d'améliorations:
> Trouver une solution pour les fichiers volumineux ?? => Spark R et PySpark
>

### Objectifs pour la prochaine itération:
> 
> 
> 





----------------------------------------------------------------------------------------------------------------------------
## Bilan de l'itération 4: (- au -)
Rapport rédigé par: ---

### Évènements 
*Quels sont les évènements qui ont marqué l'itération précédente? Répertoriez ici les évènements qui ont eu un impact sur ce qui était prévu à l'itération précédente.*.    
>      
> 
>  

### Rétrospective de l'itération précédente et axes d'améliorations:
> T
>

### Objectifs pour la prochaine itération:
> 
> 
> 


