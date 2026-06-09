## Jeu de tennis et chaîne de Markov

On note $p$ la probabilité que le serveur gagne un point, et

$$
q=1-p
$$

la probabilité que le receveur gagne un point. On suppose que les points sont indépendants.

### 1. États de la chaîne

Avant l'égalité $40$-$40$, on décrit l'état par

$$
(a,b),
$$

où $a$ est le nombre de points gagnés par le serveur et $b$ celui du receveur. Tant que le jeu n'est pas terminé, on a les transitions

$$
(a,b)\to(a+1,b) \quad \text{avec probabilité } p,
$$

$$
(a,b)\to(a,b+1) \quad \text{avec probabilité } q.
$$

Quand le score atteint $3$-$3$, c'est-à-dire $40$-$40$, on utilise les états

$$
D,\quad A_S,\quad A_R,\quad W_S,\quad W_R.
$$

Ici $D$ désigne l'égalité, $A_S$ l'avantage serveur, $A_R$ l'avantage receveur, $W_S$ la victoire du serveur et $W_R$ la victoire du receveur.

Les transitions après l'égalité sont

$$
D\to A_S \quad \text{avec probabilité } p,
$$

$$
D\to A_R \quad \text{avec probabilité } q,
$$

$$
A_S\to W_S \quad \text{avec probabilité } p,
$$

$$
A_S\to D \quad \text{avec probabilité } q,
$$

$$
A_R\to D \quad \text{avec probabilité } p,
$$

$$
A_R\to W_R \quad \text{avec probabilité } q.
$$

Enfin, $W_S$ et $W_R$ sont absorbants :

$$
W_S\to W_S,\qquad W_R\to W_R.
$$

### 2. Nature de la chaîne

Le jeu forme une chaîne de Markov homogène, car le prochain état dépend seulement du score actuel, pas de l'historique des points précédents.

Pour écrire la matrice de transition complète, on prend l'ordre des états suivant :

$$
\begin{aligned}
&(0,0),(1,0),(0,1),(2,0),(1,1),(0,2),(3,0),(2,1),(1,2),(0,3),\\
&(3,1),(2,2),(1,3),(3,2),(2,3),D,A_S,A_R,W_S,W_R.
\end{aligned}
$$

Dans cet ordre, la matrice de transition est

$$
\scriptsize
P=
\begin{pmatrix}
0&p&q&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0\\
0&0&0&p&q&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0\\
0&0&0&0&p&q&0&0&0&0&0&0&0&0&0&0&0&0&0&0\\
0&0&0&0&0&0&p&q&0&0&0&0&0&0&0&0&0&0&0&0\\
0&0&0&0&0&0&0&p&q&0&0&0&0&0&0&0&0&0&0&0\\
0&0&0&0&0&0&0&0&p&q&0&0&0&0&0&0&0&0&0&0\\
0&0&0&0&0&0&0&0&0&0&q&0&0&0&0&0&0&0&p&0\\
0&0&0&0&0&0&0&0&0&0&p&q&0&0&0&0&0&0&0&0\\
0&0&0&0&0&0&0&0&0&0&0&p&q&0&0&0&0&0&0&0\\
0&0&0&0&0&0&0&0&0&0&0&0&p&0&0&0&0&0&0&q\\
0&0&0&0&0&0&0&0&0&0&0&0&0&q&0&0&0&0&p&0\\
0&0&0&0&0&0&0&0&0&0&0&0&0&p&q&0&0&0&0&0\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&p&0&0&0&0&q\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&q&0&0&p&0\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&p&0&0&0&q\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&p&q&0&0\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&q&0&0&p&0\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&p&0&0&0&q\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&1&0\\
0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&0&1
\end{pmatrix}.
$$

La chaîne est finie et absorbante. Les états $W_S$ et $W_R$ sont des états absorbants. Tous les autres états sont transitoires, car le jeu finit presque sûrement par une victoire du serveur ou du receveur.

Ce n'est pas une marche aléatoire simple sur tout le jeu : avant $40$-$40$, l'état est un score à deux coordonnées $(a,b)$. En revanche, après $40$-$40$, la partie ressemble à une petite marche aléatoire entre $D$, $A_S$ et $A_R$, avec absorption en $W_S$ ou $W_R$.

### 3. Probabilité que le serveur gagne le jeu

On note

$$
G(p)=\mathbb P(\text{le serveur gagne le jeu en partant de }0:0).
$$

Le serveur peut gagner avant l'égalité par les scores

$$
4:0,\quad 4:1,\quad 4:2.
$$

S'il gagne par $4:k$, avec $k=0,1,2$, alors le dernier point est gagné par le serveur. Parmi les $3+k$ premiers points, le serveur en a gagné $3$ et le receveur $k$. Donc

$$
\mathbb P(4:k)=\binom{3+k}{k}p^4q^k.
$$

La probabilité que le serveur gagne avant l'égalité est donc

$$
\sum_{k=0}^{2}\binom{3+k}{k}p^4q^k
=p^4+4p^4q+10p^4q^2.
$$

La probabilité d'arriver à l'égalité est la probabilité que chacun ait gagné $3$ points après $6$ échanges :

$$
\mathbb P(D)=\binom{6}{3}p^3q^3=20p^3q^3.
$$

Soit $h$ la probabilité que le serveur gagne le jeu en partant de l'état $D$. À partir de l'égalité :

- le serveur gagne deux points de suite avec probabilité $p^2$ ;
- le receveur gagne deux points de suite avec probabilité $q^2$ ;
- chacun gagne un point avec probabilité $2pq$, et on revient à $D$.

Ainsi,

$$
h=p^2+2pqh.
$$

Donc

$$
h=\frac{p^2}{1-2pq}.
$$

Comme

$$
1-2pq=p^2+q^2,
$$

on obtient

$$
h=\frac{p^2}{p^2+q^2}.
$$

Finalement,

$$
\boxed{
G(p)
=
p^4+4p^4q+10p^4q^2
+20p^3q^3\frac{p^2}{p^2+q^2}
}
$$

avec $q=1-p$.

Si $p=\frac12$, alors par symétrie

$$
G\left(\frac12\right)=\frac12.
$$
