# Compte rendu de compréhension - Optimisation

## Compréhension du chapitre 1

Après le premier cours, j'ai compris qu'un problème d'optimisation consiste à chercher la meilleure valeur possible d'une fonction objectif sur un domaine réalisable. Un modèle d'optimisation comporte toujours trois éléments essentiels : les variables de décision, la fonction objectif et les contraintes. Les contraintes peuvent être explicites, par exemple des limites de temps, de budget ou de ressources, mais aussi implicites, comme la non-négativité des variables.

J'ai aussi compris que l'on peut classer les problèmes selon plusieurs critères. D'abord, on distingue les problèmes sans contrainte et les problèmes sous contraintes. Ensuite, on distingue l'optimisation linéaire et l'optimisation non linéaire selon la nature de la fonction objectif et des contraintes. Enfin, la forme standard joue un rôle central, car elle permet d'écrire un problème sous une forme mathématique unifiée, ce qui facilite son analyse et sa résolution.

Ce qui m'a particulièrement marqué dans ce chapitre, c'est que l'optimisation n'est pas seulement une théorie abstraite : elle sert a modeliser des situations reelles, par exemple la planification d'un trajet, l'organisation de la production ou la gestion d'un portefeuille. Le point le plus important pour moi est donc la capacite de traduire un probleme concret en langage mathematique.

## Exemple de modélisation : alimentation saine à coût minimal

Je choisis comme problème pratique la planification d'une alimentation quotidienne pour un étudiant. L'objectif est de minimiser le coût total des repas tout en garantissant un apport nutritionnel suffisant.

On considère trois aliments :

- `x_1` : nombre de portions de riz
- `x_2` : nombre de portions de poulet
- `x_3` : nombre de portions de légumes

Les coûts unitaires sont respectivement `2`, `8` et `3` yuans par portion. On suppose qu'une portion de riz apporte `200` calories et `4` grammes de protéines, une portion de poulet `250` calories et `30` grammes de protéines, et une portion de légumes `50` calories et `2` grammes de protéines.

La fonction objectif est

$$
\min f(x) = 2x_1 + 8x_2 + 3x_3.
$$

Les contraintes explicites sont :

$$
200x_1 + 250x_2 + 50x_3 \ge 2000
$$

$$
4x_1 + 30x_2 + 2x_3 \ge 60
$$

$$
x_1 + x_2 + x_3 \le 10.
$$

Les contraintes implicites sont :

$$
x_1 \ge 0, \quad x_2 \ge 0, \quad x_3 \ge 0.
$$

Ce modèle est un problème d'optimisation linéaire sous contraintes, car la fonction objectif est linéaire et toutes les contraintes sont linéaires.

## Mise sous forme standard

Pour écrire ce problème sous forme standard, on transforme les inégalités en égalités à l'aide de variables d'écart ou d'excès :

$$
200x_1 + 250x_2 + 50x_3 - s_1 = 2000, \quad s_1 \ge 0
$$

$$
4x_1 + 30x_2 + 2x_3 - s_2 = 60, \quad s_2 \ge 0
$$

$$
x_1 + x_2 + x_3 + s_3 = 10, \quad s_3 \ge 0.
$$

En posant

$$
z = (x_1, x_2, x_3, s_1, s_2, s_3)^T,
$$

le problème devient

$$
\min \; c^T z
$$

avec

$$
c = (2, 8, 3, 0, 0, 0)^T
$$

et

$$
Az = b, \quad z \ge 0,
$$

où

$$
A =
\begin{pmatrix}
200 & 250 & 50 & -1 & 0 & 0 \\
4 & 30 & 2 & 0 & -1 & 0 \\
1 & 1 & 1 & 0 & 0 & 1
\end{pmatrix},
\quad
b =
\begin{pmatrix}
2000 \\
60 \\
10
\end{pmatrix}.
$$

## Réflexion personnelle

Cet exercice m'a aidé a mieux comprendre la logique du cours. Avant, je voyais surtout l'optimisation comme un ensemble de formules. Maintenant, je comprends mieux qu'il s'agit d'abord d'un travail de modelisation : choisir les bonnes variables, exprimer clairement l'objectif et traduire les limites reelles en contraintes mathematiques. J'aimerais approfondir, dans les prochains cours, la question suivante : une fois le modele construit, comment choisir la methode la plus adaptee pour le resoudre efficacement ?
