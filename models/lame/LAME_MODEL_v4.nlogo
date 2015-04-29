;;Autor : Delay E. (Université de Limoges) sur la base d'un travail de E.DELAY et  Bourgoin J. (CIRAD) presenter eu IV congrès du CERVIM
;;15 juillet 2014 reconstrction du modèle cooprératif
;;           * les coop sont des agents
;;           * intégration du temps de travail 

breed [farmers farmer] ;pour ne pas avoir turtles
breed [cooperatives cooperative]
breed [locality] ;pour un seul village

globals[
  ;;les variables d'interface 
  NbFarmer
  InitialCapital
  prix_kg
  cout_ha
  FrontPrice
  reserveSellPrice
  reserveBuyPrice
  coef_Slope ;; multiplication de la pente par ce nombre pour connaitre la contrainte
  coef_dist  ;; multiplication de la distance ......................
  
  gini-index-reserve
  lorenz-points
  materiel_vinif
  taxe_plot
  prixkg
  rendement_G
  
  ;;pour les stats de sortie de modèle
  Viticulteurs  ;; count farmers
  prop_farmer_in_hill ;; nombre de farmer en montagne 
  med_slope  ;; la median de la pente des parcelles viticole
  list_slope_viti ;;liste de toute les pentes des parcelles viti
  list_dist_v ;;liste de toutes les distance au village
  list_failed_plots ;;liste des pentes des parcelles viticole qui sont abandonée 
  ruined_farmers ;;nombre de viticulteur ruiné
  vitipatches ;;nombre de parcelles viticoles
  list_slope_echange_plots ;;pentes des parcelles échangé
  list_nbechanges ;;nombre d'échange qu'on subit ces même parcelles
  meanClust_hill
  meanClust_plain
  
  Capital_Hill
  Capital_Plain
  ]


patches-own [ ;variables pas globales mais attribuées au agents
  alti
  dist_v
  coop ;; who is my coop
  Mzone ;zone de montagne pour l'aide gouvernementale
  owner
  old-owner
  nb_echanges
  annual_bonus_coop
  annual_malus_coop
  rendement
  annualCost
  sold
  price
  cluster ;;pour le calcul de la fragenation
  
  ]

farmers-own [
  capital
  myCooperative
  mySlope
  myplots
  cooperateur
  meanSlope  ;; pente moyenne sur toutes les parcelles du viti
  employer  ;;combien d'employer à besoin le viti
  partTime ;; quelle proportion de son temps est consacrer à la viticulture en pct
  Frag ;;framentation de mon exploitations
  index_clusturing
  
  ]

locality-own [
  LandReserve
  ]

cooperatives-own[
  capital
  coopViticulteur
  bonus-totalCost ; dimine les cout de production des farmers
  malus-totalGain ; diminue les gains par un rachat moins chere du produit 
  ]

;;;;;;;;;;;;;;;;;;;;;;
;; SETUP
;;;;;;;;;;;;;;;;;;;;;;
to setup-fix
  set materiel_vinif 100000
  set taxe_plot 200
  set prixkg prix_kg
  set rendement_G 0 ;((random 10) + 1)
end

to setup-var  
  ;;lien avec les variables de l'interface
  set coef_Slope coef_Slope_i
  set coef_dist coef_dist_i
  set NbFarmer NbFarmer_i
  set InitialCapital InitialCapital_i
  set prix_kg prix_kg_i
  set cout_ha cout_ha_i
  set FrontPrice FrontPrice_i
  set reserveSellPrice reserveSellPrice_i
  set reserveBuyPrice reserveBuyPrice_i
end

to setup-env
  import-pcolors "alti.png" ;creation de l'envir avec le fichier image dans le même repertoire, stock les valeurs de l'image
  let conterColor 2
  
 ask patches [
   set alti (pcolor * 50) / 10 ;pour avoi une pente en degret
   ifelse alti >= 5 [set Mzone 1] [set Mzone 0]
   set sold False
   set price FrontPrice
   set owner NOBODY
   set old-owner NOBODY
   ]

 set-default-shape farmers "person"
 set-default-shape locality "house"
 set-default-shape cooperatives "pentagon"

 create-locality 1 [
   setxy 27 0
   set size 5
   set LandReserve (patch-set)
 ]
 
 ask patches [
  set dist_v distance one-of locality 
 ]
 
 create-farmers NbFarmer [
   setxy random-pxcor random-pycor
   set size 3
   set color conterColor
   set mySlope [alti] of patch-here
   set conterColor ifelse-value (conterColor < 140) [conterColor + 10] [conterColor - 139]
   set capital InitialCapital ;nom du slider
   set cooperateur FALSE
   set partTime (random-float 1) + 0.01
   set size partTime
 ]

 
 ask farmers [
   set myplots n-of 10 patches in-radius 5
   ask myplots [ 
     set pcolor [color] of myself
     set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
     set old-owner [who] of myself ;affecte le numéro du farmer à ses parcelles
     calculRendement
     calculCost
   ]
  ]
 
 update-lorenz-and-gini
end

;;setup appeller dans OpenMole 
to common-setup
  setup-fix
  setup-env
  reset-ticks
end

;;setup de l'interface de netlogo
to setup
  clear-all
  setup-fix
  setup-var
  common-setup
  reset-ticks
  stat_1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  RUN TO THE GRID
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to run-to-grid [tmax]
  common-setup
  while [ go-stop?  and ticks <= tmax]
  [go]
  reset-ticks
  
end

to-report go-stop?
  ifelse Viticulteurs < 0 
  [report FALSE][report TRUE]
  
end


;;;;;;;;;;;;;;;;;;;;;;
;; GO
;;;;;;;;;;;;;;;;;;;;;;

to go
  let conterColor 2
;  toseecoop
  ;set rendement_G ((random 10) + 1)
  
  update_coop
  ask farmers [
;    cooperation?
    sellLand
    updateCapital
    buyLand
    MO
    updateEmployer
    calcul-frac
    set label Frag
    ]
  ask patches [
   proc_owner 
  ]
  
  updatePlot
  update-lorenz-and-gini
  stat_1
  
tick  
end


;;;;;;;;;;;;;;;;;;;;;
;; PROCEDURES FOR GO
;;;;;;;;;;;;;;;;;;;;;
to calculRendement ;farmer context, myplots context
   set rendement (2600 + rendement_G) ;25hectolitre/ha * 140 kilo de raisin par hecto = rendement en kg
end

to calculCost ;farmer context, myplots context
    let dist distance one-of locality
    set annualCost cout_ha + (coef_Slope * alti) + (coef_dist * dist)
end


to update_coop
  ask patches with [coop != 0][
    let mycoop cooperatives with [who = [coop] of myself]
    set annual_bonus_coop [bonus-totalCost] of mycoop
    set annual_malus_coop [malus-totalGain] of mycoop
  ]
end

to sellLand
  let totalCost sum [annualCost] of myplots
  if Capital < totalCost [
    if any? myplots [
      let plottosell max-one-of myplots [annualCost] ;delection d'un plot à vendre
      let otherplots (patch-set) ;defintion de la collection de autres plots qui en sont pas à vendre 
      ask plottosell[
        set sold True
        set owner -1 ;identifiant de locality
        set price reserveSellPrice ;prix auquel la reserve vend les parcelles
        set pcolor white
         ]
      set myplots myplots with [not sold]
      ask Locality [
              set LandReserve (patch-set LandReserve plottosell)
              ]
      set Capital Capital + reserveBuyPrice ;prix auquel la reserve achète les parcelles 
        ]
  ]

end


to updateCapital ;instance of farmer (parceque on est dans ask farmers)
  let MOpayante employer - 1 ;on a calculer avant le nombre d'employer dont à besoin chaque exploitation
  if MOpayante < partTime [ set MOpayante 0]
  let salaireMO MOpayante * 20000 ;; un salarier cout 20000 euro par ans
  
  let howIsMyCoop cooperatives with [who = [myCooperative] of myself]
  let totalCost sum [annualCost] of myplots - ((sum[bonus-totalCost] of howIsMyCoop) * (sum [rendement] of myplots)) + salaireMO
  let totalGain (sum [rendement] of myplots) * prixkg + ( sum [malus-totalGain] of howIsMyCoop * (sum [rendement] of myplots))
  set Capital Capital - totalCost + totalGain
  
end

to buyLand ;instance of farmer (parceque on est dans ask farmers)
  let totalCost sum [annualCost] of myplots
  ;let potplot patches in-radius 2 with [(owner = 0) or (owner = -1)]
  let potplotfinal (patch-set) ;collection de patchs pot
  ask myplots [
    let potplot patches in-radius 2 with [owner = nobody] ;critère de selection, recherche de voisins potentiels
    set potplotfinal (patch-set potplotfinal potplot) ;renseigne la collection
    ]
  set potplotfinal (patch-set potplotfinal [LandReserve] of Locality) ;on repete locality pour dire de changer d'agent (on est dans une instance ask farmers)
  let potCost 0;cree une variable vide
  
  if any? potplotfinal [
    ask potplotfinal [
      set potCost price + 10 * annualCost ;prise en compte de 10 ans
      ]
    let newplot min-one-of potplotfinal [potCost]
    if Capital > totalCost + [potCost] of newplot [
      ask newplot [
       set pcolor [color] of myself
       set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
       calculRendement
       calculCost
       ]
     
     
     set myplots (patch-set myplots newplot)
     set Capital Capital - [price] of newplot ;slider
     
      ]
    ]
end 

to MO ;farmer context
  if not any? myplots [ ;;c'est la mort du viticulteur
    set capital 0
    set color  white
    set cooperateur FALSE
    ask links with [end1 = farmer [who] of myself][die]
  ]
end
  

to updateEmployer ;vitis context
  if any? myplots [
    set meanSlope (mean [alti] of myPlots) ;la pente est en % le +0.01 est pour interdire les divisions par 0
    if meanSlope = 0 [
     set  meanSlope 10
    ]
    let wk (1 / (meanSlope / 100))
    let nbmyplots count myPlots
    set employer nbmyplots / wk ; calcule le nombre d'homme dont l'exploitation a besoin y compris l'exploitant
    if employer > partTime [
      ifelse partTime >= 1.0 AND employer <= 1.0[
       set partTime employer 
      ][
       set partTime 1
      ]
    ]
    set size partTime
  ]
end

to proc_owner
  if old-owner != owner and ticks >= 49[
   set old-owner owner 
   set nb_echanges nb_echanges + 1 
  ]
end

;;;;;;;;;;;;Calcul de la framentation
;;;;;4 procedures !!
to calcul-frac
  ask patches with [owner != nobody] [
    set plabel ""
    set cluster nobody
  ]
  ask myPlots [
    set plabel ""
    set cluster nobody
    ]
  find-clusters
  if any? myPlots[
    set Frag (max [plabel] of myPlots + 1)
    set index_clusturing Frag / (count myPlots)
  ]
end

to find-clusters ;;appel par calcul-frac
  loop [
    let seed one-of myPlots with [cluster = nobody]
    if seed = nobody
    [ show-clusters
      stop ]
    ask seed
    [ set cluster self
      grow-cluster ]
  ]
end

to show-clusters
  let counter 0
  loop
  [ let p one-of myPlots with [plabel = ""]
    if p = nobody
      [ stop ]
    ask p
    [ ask patches with [cluster = [cluster] of myself AND owner = [owner] of myself]
      [ set plabel counter ] ]
    set counter counter + 1 
    ]
end

to grow-cluster  
  ask neighbors4 with [(cluster = nobody) and
    (pcolor = [pcolor] of myself)]
  [ set cluster [cluster] of myself
    grow-cluster 
   ]
end

;;;;;;;;;;;;;;;;;;;;;
;; PLOTING
;;;;;;;;;;;;;;;;;;;;;

to updatePlot
  set-current-plot "FarmersCapital"
  ask farmers [
    set-plot-pen-color color ;pour renvoyer la couleur du fermier
    plotxy ticks Capital
    ]
  set-current-plot "FamersPlots"
  ask farmers [
    set-plot-pen-color color
    plotxy ticks (count myplots)
    ]
  set-current-plot "LorenzCurve"
  ask farmers [
    plot-pen-reset
    set-plot-pen-interval 100 / count farmers
    plot 0
    foreach lorenz-points plot
    ]
  
  set-current-plot "A"
  ask farmers [
;    let totalCost sum [annualCost] of myplots
;    let totalGain (sum [rendement] of myplots) * prixkg
    set-plot-pen-color color
    plotxy ticks index_clusturing
  ]
end

to update-lorenz-and-gini
  let sorted-wealths sort [Capital] of farmers
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  set gini-index-reserve 0
  set lorenz-points [] ;pour stocker un vecteur, lupt rajoute dans la liste
  repeat count farmers [
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
    set index (index + 1)
    set gini-index-reserve gini-index-reserve + (index / count farmers) - (wealth-sum-so-far / total-wealth)
  ]
   set gini-index-reserve (gini-index-reserve / count farmers) / 0.5
end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STAT 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to stat_1
  if any? farmers with [color != white][
    set prop_farmer_in_hill ((count farmers with[meanSlope > 1 AND color != white]) / (count farmers - (count Farmers with [not any? myplots])))
  ]
  if any? patches with [owner != -1 AND owner != NOBODY][
    set med_slope median[alti] of patches with [owner != -1 AND owner != NOBODY]
    set vitipatches count patches with [owner != -1 AND owner != NOBODY]
  ]
  set ruined_farmers count Farmers with [not any? myplots]
  set Viticulteurs count Farmers
  if ticks = 50 [
    set list_failed_plots [alti] of patches with [owner = -1]
    set list_slope_viti [alti] of patches with [owner != -1 AND owner != NOBODY]
    set list_dist_v [dist_v] of patches with [owner != -1 AND owner != NOBODY]
  ]
   set meanClust_hill mean[index_clusturing] of farmers with [mySlope > 1]
   set meanClust_plain mean[index_clusturing] of farmers with [mySlope <= 1]
   
   set Capital_hill mean[Capital] of farmers with [mySlope > 1 AND color != white]
   set Capital_plain mean[Capital] of farmers with [mySlope <= 1 AND color != white]
   
   set list_slope_echange_plots [alti] of patches with [nb_echanges > 0]
   set list_nbechanges [nb_echanges] of patches with [nb_echanges > 0]
end
@#$#@#$#@
GRAPHICS-WINDOW
753
10
1242
520
49
49
4.84
1
10
1
1
1
0
0
0
1
-49
49
-49
49
0
0
1
ticks
30.0

BUTTON
8
10
74
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
174
10
237
43
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
88
180
121
InitialCapital_i
InitialCapital_i
100
10000
5000
10
1
NIL
HORIZONTAL

PLOT
375
135
732
287
FarmersCapital
Time
Capital
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

SLIDER
10
210
182
243
FrontPrice_i
FrontPrice_i
0
50000
33000
100
1
NIL
HORIZONTAL

BUTTON
76
10
172
43
go forever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
49
181
82
NbFarmer_i
NbFarmer_i
1
300
299
1
1
NIL
HORIZONTAL

SLIDER
7
282
204
315
reserveBuyPrice_i
reserveBuyPrice_i
0
50000
17000
1000
1
NIL
HORIZONTAL

PLOT
375
10
731
135
FamersPlots
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

SLIDER
9
246
206
279
reserveSellPrice_i
reserveSellPrice_i
0
50000
17000
1000
1
NIL
HORIZONTAL

TEXTBOX
205
285
355
313
Prix auquel la réserve achète
11
0.0
1

TEXTBOX
210
249
360
275
Prix auquel la réserve vend aux agriculteurs (17000 prix safer)
8
0.0
1

TEXTBOX
210
214
360
244
Prix d'achat des terres du front pionnier. 33000 euro = achat +implant+4 ans sans prod
8
0.0
1

PLOT
8
321
215
520
LorenzCurve
pop %
wealth %
0.0
100.0
0.0
100.0
false
false
"" ""
PENS
"default" 1.0 0 -5298144 true "" ""
"pen-1" 100.0 0 -16777216 true "plot 0\nplot 100" ""

PLOT
8
525
318
703
Gini Index V. Time
Time
Gini
0.0
100.0
0.0
1.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot gini-index-reserve"

PLOT
1050
525
1240
705
surface viticole
Time
Natural Vegetation %
0.0
10.0
0.0
0.001
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count patches with [owner != nobody]"

MONITOR
265
95
371
140
FamersRuined
count Farmers with [not any? myplots]
1
1
11

PLOT
375
285
730
449
A
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

TEXTBOX
275
143
378
169
Les farmers ruiné deviennent Blanc
10
0.0
1

SLIDER
5
125
177
158
prix_kg_i
prix_kg_i
0
10
1.5
0.05
1
NIL
HORIZONTAL

MONITOR
250
335
332
380
rendement
rendement_G
1
1
11

SLIDER
5
160
177
193
cout_ha_i
cout_ha_i
0
4000
2300
100
1
NIL
HORIZONTAL

PLOT
375
445
730
595
prop de coopérateur
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"farmers in hill" 1.0 0 -16777216 true "" "plot prop_farmer_in_hill"
"pen-2" 1.0 0 -2674135 true "" "plot 0.5"
"frag_hill" 1.0 0 -7500403 true "" "plot meanClust_hill"
"frag_plain" 1.0 0 -955883 true "" "plot meanClust_plain"

BUTTON
185
50
272
83
50 ticks
if ticks <= 50 [go]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
190
135
250
170
Prix au Kg est env 1.5 en 2013
8
0.0
1

SLIDER
220
395
370
428
coef_Slope_i
coef_Slope_i
0
200
90
10
1
NIL
HORIZONTAL

SLIDER
220
430
370
463
coef_dist_i
coef_dist_i
0
100
10
5
1
NIL
HORIZONTAL

PLOT
375
595
730
715
median of slope viti
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot med_slope"

TEXTBOX
185
175
335
193
2300
12
0.0
1

PLOT
765
525
1050
705
Capiytal
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Hill" 1.0 0 -16777216 true "" "plot Capital_Hill"
"plain" 1.0 0 -7500403 true "" "plot Capital_plain"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

Ce propose d'étudier l'impacte des aides (subsidy) aux territoires de montagne, et des taxes(prix d'achat et de mise en culture de parcelles jusqu'alors naturel) dans un contexte agricole. 
Il permet également de voire l'émergence de comportement coopératif qui permette au agriculteurs de diminuer leurs cout de production en échange d'une perte en therme de revenu. 
Plusieurs indicateurs sont a la disposition de l'observateur pour comprendre se qui se passe dans la modélisation. 
L'indice de Gini qui per met d'évaluer la répartition équitable sur le territoire du capital
La surface de végétation naturel qui permet de voire la vitesse de colonisation du milieu

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)


## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment-find-alpha-beta" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="51"/>
    <metric>gini-index-reserve</metric>
    <metric>prop_farmer_in_hill</metric>
    <metric>med_slope</metric>
    <metric>count farmers</metric>
    <metric>ruined_farmers</metric>
    <metric>vitipatches</metric>
    <metric>list_slope_viti</metric>
    <metric>list_dist_v</metric>
    <metric>list_slope_echange_plots</metric>
    <metric>list_nbechanges</metric>
    <enumeratedValueSet variable="reserveSellPrice_i">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbFarmer_i">
      <value value="300"/>
    </enumeratedValueSet>
    <steppedValueSet variable="coef_dist_i" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="prix_kg_i">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveBuyPrice_i">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FrontPrice_i">
      <value value="33000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialCapital_i">
      <value value="5000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="coef_Slope_i" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="cout_ha_i">
      <value value="2300"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-long-time" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>gini-index-reserve</metric>
    <metric>prop_farmer_in_hill</metric>
    <metric>med_slope</metric>
    <metric>count farmers</metric>
    <metric>ruined_farmers</metric>
    <metric>vitipatches</metric>
    <metric>meanClust_hill</metric>
    <metric>meanClust_plain</metric>
    <metric>Capital_Hill</metric>
    <metric>Capital_Plain</metric>
    <enumeratedValueSet variable="reserveSellPrice_i">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbFarmer_i">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coef_dist_i">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prix_kg_i">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveBuyPrice_i">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FrontPrice_i">
      <value value="33000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialCapital_i">
      <value value="5000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="coef_Slope_i" first="60" step="10" last="90"/>
    <enumeratedValueSet variable="cout_ha_i">
      <value value="2300"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
