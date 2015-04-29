breed [vitis viti]
breed [cites cite]
breed [cooperatives cooperative]
breed [parcelles parcelle]

extensions [gis]

globals [MNT_data parcels slope elevation tempAnnual acidity
  meanSlopeTerritory
  meanElevationterritory
  parcellesViticoles ;pour charger les données sur les parcelles
  partieurbanise ;; variable gloabl pour le shp des parties urbanisé
  oldTick
  tickStart
  time
  realSimulationTick ;;pour savoir dans quelle tick on se trouve
  moOnTerritory 
  SlopePatchesInCulture
  ElevationPatchesInCulture
  nbPatchesViti
  meanCapital
  
  freqAcidity ;; valeur pour faire l'histogramme des feq d'acidié sur tout les patches 
  freqAcidityViti ;;valeur pour faire l'histogramme des feq d'acidié sur les patches cultivé
  freqfonc ;; valeur (liste) pour faire l'histo des primes versé aux parcelles
  meanAcidityGlobal ;;varaition de l'acidité des patches viticoles
  indic-proxi
  meanIndice
  meanIndi-proxi
  coopCapital
  Countvitis
  countFriche
  indic-proxi-viti ;;moyenne des indices d'agrégation centré sur chauque patches
  gini-index-reserve
  lorenz-points
  tickStop ;; calcul en fonction du points de départ le nombre de ticks pour explorer le nombre d'année voulu
  nb-annee-exploration ;;definition du nombre d'année que va durée la simulation
  Frag  ;; va stoker la framentation paysagère
  frag_theo ;;stock sous forme de liste les valeurs théorique de fragmentation

  
  
  ;;créetion de variables gloable remplis à partir de l'interface 
  NbVitis
  InitialCapital
  PlotIncome
  reserveBuyPrice
  priceNewPlot
  reserveSellPrice
  mu
  MeanAcidityCoop
  TooHighAcidityCoop;CYRIL:new ;; valeur max de l'acidité a livrer
  acidityBonus
  acidityBonus_tmp  ;;stock
  poidsDistance
  poidsSlope
  minPotAcidity
  maxPotAcidity
  evolTemp
  evolTemp_tmp ;;;pour stock 
  CoopStrategie
  onlyFriche  ;;les viticulteur on seulement le droit de mettre en frich si TRUE ou de vendre si false
  prodCost  ;; le cout de production fixe indépendament de la distance et de la pente
  double-megabole
  ]

patches-own[
 fonc ;;la valeur du bonus/malus en cas de balance...
 couvertViti ; dire si les parcelles sont viticoles
 zoneUrba ;;booleén True si urbanisé et donc que la viticulture ne peut pas s'y installé
 annualCost
 annualGain
 patchElevation
 patchSlope
 patchAcidity
 patchTemperature
 calculINterest
 owner
 production
 payementDiff
 age
 price
 sold
 frich
 ind-temp ;;calcule l'indice d'agregation centré sur les viticulteurs
 ind-temp-viti ;;calcule l'indice d'agrégation pour chaque patches
 cluster ;;stock la variable du cluster auquel le patche appartient E.D
]

vitis-own[
  capital
  oldCapital
  meanAcidity
  employer
  myplots
  landFriche
  indic
]

cites-own[
  LandReserve
]

cooperatives-own [
  capital
]



to setup
ca  ;;clear-all
init-globals
let conterColor 2

;;on stock les variables de température et de bonus
set evolTemp_tmp evolTemp
set acidityBonus_tmp acidityBonus

;;on impose les variables pour le début de la simulation
set evolTemp 0
set acidityBonus 0

;; installation du village
set-default-shape cites "house"
 create-cites 1 [
   setxy 76 55
   set size 5
   set LandReserve (patch-set)
   hatch-cooperatives 1 [
     set capital 100000
     setxy 78 57
     set size 3
   ]
 ]
 ask patches [
  set zoneUrba FALSE 
 ]
 
 gisExtention ; charge l'altitude et la pente dans les patches
 
 ask n-of nbVitis patches with [couvertViti = 1][
  sprout-vitis 1 ;;on fait emerger les viticulteurs des patches qui sont definit comme viticole
  ]
 
  ask vitis [
   set size 3
   set color conterColor
   set conterColor ifelse-value (conterColor < 140) [conterColor + 10] [conterColor - 139]
   set capital InitialCapital ;nom du slider
 ]
  
  set countVitis count vitis

 ask vitis [
   set myplots n-of atPatches patches with [couvertViti = 1]
   set capital InitialCapital
   ask myplots [
     set pcolor [color] of myself
     set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
     let dist distance one-of cites
     set sold False
     set age (random 5) + 5
     if age >= 3 [
     set production TRUE 
     ]
   ]
   set meanAcidity mean [patchAcidity] of myPlots
  ]
  ;;;;; POUR READ CSV
 ;;;partie qui va lire le fichier de fragmenation théorique
 set frag_theo []
 file-open "data/fragmention_theo.csv"
 ;;l'ordre des lignes est l'ordre des plots ... ligne 35 = fragementation théorique avec 35 patches
 while [not file-at-end?][
    let in1 file-read
    set frag_theo lput in1 frag_theo
  ]
 ;  show timeData
  file-close
 
 reset-ticks
 plottheBoule
end

to init-globals
  set NbVitis nbVitis-I
  set InitialCapital InitialCapital-I
  set PlotIncome PlotIncome-I
  set reserveBuyPrice reserveBuyPrice-I
  set priceNewPlot priceNewPlot-I
  set reserveSellPrice reserveSellPrice-I
  set mu mu-I
  set MeanAcidityCoop MeanAcidityCoop-I
  set acidityBonus acidityBonus-I
  set poidsDistance poidsDistance-I
  set poidsSlope poidsSlope-I
  set minPotAcidity minPotAcidity-I
  set maxPotAcidity maxPotAcidity-I
  set evolTemp evolTemp-I
  set CoopStrategie CoopStrategie-I
  set onlyFriche onlyFriche-I
  set nb-annee-exploration echeance
  set prodCost prodCost-I ;; données issu du mail de Damien du 21.11.2012 coûts
  set TooHighAcidityCoop TooHighAcidityCoop-I
  set double-megabole double-megabole-I 
end

;;;LE SETUP qui sera appeller sur OpenMole ne contient pas de clear-all
to setup-grid
;ca  ;;clear-all
;init-globals
let conterColor 2

;;on stock les variables de température et de bonus
set evolTemp_tmp evolTemp
set acidityBonus_tmp acidityBonus

;;on impose les variables pour le début de la simulation
set evolTemp 0
set acidityBonus 0

;; installation du village
set-default-shape cites "house"
 create-cites 1 [
   setxy 76 55
   set size 5
   set LandReserve (patch-set)
   hatch-cooperatives 1 [
     set capital 100000
     setxy 78 57
     set size 3
   ]
 ]
 
 gisExtention ; charge l'altitude et la pente dans les patches
 
  create-vitis NbVitis [
   setxy random-pxcor random-pycor
   set size 3
   set color conterColor
   set conterColor ifelse-value (conterColor < 140) [conterColor + 10] [conterColor - 139]
   set capital InitialCapital ;nom du slider
 ]
  
  set countVitis count vitis

 ask vitis [
   set myplots n-of atPatches patches in-radius 5
   set capital InitialCapital
   ask myplots [
     set pcolor [color] of myself
     set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
     let dist distance one-of cites
     set sold False
     set age (random 5) + 5
     if age >= 3 [
     set production TRUE 
     ]
   ]
   set meanAcidity mean [patchAcidity] of myPlots
  ]
 
 ask patches [
  updatePayementDiff 
 ]
 
 ;;;;; POUR READ CSV
 ;;;partie qui va lire le fichier de fragmenation théorique
 set frag_theo []
 file-open "data/fragmention_theo.csv"
 ;;l'ordre des lignes est l'ordre des plots ... ligne 35 = fragementation théorique avec 35 patches
 while [not file-at-end?][
    let in1 file-read
    set frag_theo lput in1 frag_theo
  ]
 ;  show timeData
  file-close
 
 reset-ticks
 plottheBoule
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                  SETUP Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to gisExtention
  ;;chargement des différents jeux de données
;;données raster
set MNT_data gis:load-dataset "geo_data/dtm10mMask4326Decoup.asc"
set slope gis:load-dataset "geo_data/Slope4326Decoup.asc"
set tempAnnual gis:load-dataset "geo_data/TempAnnual2012-4326.asc"
set acidity gis:load-dataset "geo_data/Acidite2012-4326.asc"
set parcellesViticoles gis:load-dataset "geo_data/vitiTotal4326decoup.asc"
set partieurbanise gis:load-dataset "geo_data/partie_urbaniser_AOC-4326.shp"

;;chargement de données vecteur SHP
;set parcels gis:load-dataset "parcellesViticoles/parcellesViticoles4326.shp"

;;fait le lien entre le système de coordonnée netlogo et celui des données
gis:set-world-envelope gis:envelope-of MNT_data ;; par défaut
;gis:set-transformation gis:envelope-of MNT_data [-10 10 -10 10]

;Ajoute par dessu les patches un layer qui représente le MNT
;gis:paint MNT_data 0

;;attribue les valeurs chargées a des paramètres des patches
;gis:apply-raster MNT_data alti
gis:apply-raster slope pcolor

;; la primitive précédente a chargé les valeurs de slope dans pcolor, mais je veux aussi les garder dans un autre 
;; atribut de mes patches

ask patches [
 set patchSlope pcolor
 let dist distance one-of cites
 set annualCost (patchSlope * poidsSlope) + (dist * poidsDistance) + prodCost
; set annualCost (patchSlope) * 100
 set price priceNewPlot
 set age NOBODY
 set production FALSE
]



gis:apply-raster MNT_data pcolor
ask patches [
 set patchElevation pcolor 
]

gis:apply-raster tempAnnual pcolor
ask patches [
 set patchTemperature pcolor 
]

gis:apply-raster acidity pcolor
ask patches [
 set patchAcidity pcolor 
 set pcolor scale-color gray patchElevation 0 1000
 ChooseVis
]
gis:apply-raster parcellesViticoles pcolor
ask patches [
  let tmp pcolor
  if tmp > 0 [
    set couvertViti 1
  ]
]

gis:set-drawing-color brown 
gis:draw partieurbanise 1
ask patches gis:intersecting partieurbanise [set zoneUrba True]


set meanSlopeTerritory mean[patchSlope]of patches
set meanElevationTerritory mean[patchElevation] of patches
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  if ticks > tickStop [
   stop 
  ]
  if time > 0[
    set evolTemp evolTemp_tmp
    set acidityBonus acidityBonus_tmp
  ]
  
  
  ask patches [set plabel ""]
  ask patches with [owner <= 0][
   ChooseVis
  ]
 
  
  ask patches [
    
    updateAnnualGain
    updatePayementDiff
    updateInterest
    grow-temperature
    grow-acidity
    updateAge
    ]
  
  ask vitis [
    updateEmployer
    updateMeanAcidity
    updateCapital
    ifelse onlyFriche = 0 [FricheLand][sellLand] ;CYRIL:modified    
    if not any? myplots[die]
  ]
  
  ask vitis [
    buyLand
    ]
  photoMaker
  if not any? patches with [owner != 0 AND pcolor != white][
   stop 
  ]
  ;;on va calculer la framentation tout les 10 itérations
  let modulo_time ticks mod 10
  if modulo_time = 0 AND ticks > 1[
    calcul-frac
  ]
  updateCoopCapital
  updateStat
  updatePlot
  
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  RUN TO THE GRID
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to run-to-grid [tmax]
  setup-grid
  while [go-stop?  AND ticks < tmax ]
  [go 
    ]
  reset-ticks
end

to-report go-stop?
  ifelse ticks <= tickStop [
    report TRUE
  ][
  report FALSE
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                  GO Procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to ChooseVis
  if visualisationType = "patchInterst" [
    set pcolor scale-color gray calculINterest 0 8000
  ]
  if  visualisationType = "Slope" [
    set pcolor  scale-color red patchSlope 0 30
  ]
  if visualisationType = "Acidity" [
    set pcolor  scale-color green patchAcidity 0 20
  ]
  if visualisationType = "elevation"[
    set pcolor  scale-color brown patchElevation 0 1000
  ]
  if visualisationType ="couvertVegetal"[
    set pcolor scale-color black couvertViti 0 1
  ]
  if visualisationType = "limAcidity3" [
   ifelse patchAcidity < MeanAcidityCoop [
     set pcolor red
   ][
     set pcolor green
   ]
  ]
  if visualisationType = "who_have_bonus" [
    ifelse double-megabole = 0 [
      ifelse patchAcidity > MeanAcidityCoop AND patchAcidity <  TooHighAcidityCoop[
        set pcolor red
      ][
      set pcolor green
      ]
    ][
      ifelse patchAcidity < MeanAcidityCoop [
        set pcolor red
      ][
      set pcolor green
      ]
    ]
  ]
end

to updateAnnualGain
  set annualGain plotIncome  
end

to updatePayementDiff ;patches Context 
  if owner > 0 and frich != TRUE [
      if CoopStrategie = "MaxAcidity" [ ;; pour avoir le max d'acidité on va donner une prime sur les patches acide < 3 et un malus sur les patche acide < 3
        let prime 0
        ifelse patchAcidity > MeanAcidityCoop [
          set payementDiff acidityBonus
          set prime acidityBonus * -1
        ][                                               ;;CYRIL: ici j'ai simplifié en ifelse, mais quand je reregarde, je ne comprends plus pourquoi tu multiplies par -1 d'un coté la prime et de l'autre le paymendiff?
          set payementDiff acidityBonus * -1             ;; par ce que les bonus des vitis sont des malus pour la coop
          set prime acidityBonus
        ]
        set annualGain annualGain + payementDiff
        ask cooperatives [
          set capital capital + prime
        ]
      ]
      if CoopStrategie = "equivalenceBalance"[
        ;;utilisation d'un reporter
        set payementDiff megabole patchAcidity MeanAcidityCoop TooHighAcidityCoop minPotAcidity maxPotAcidity mu acidityBonus   ;CYRIL:modified  ;CYRIL:new
        set annualGain annualGain + payementDiff
        ask cooperatives [
          set capital capital - [payementDiff] of myself
        ]
      ]
  ]
end

to updateCoopCapital
   if CoopStrategie = "equivalenceBalance"[
    let listpayementDiff []
    ask patches with [owner > 0 and frich != TRUE] [
      set  listpayementDiff lput payementDiff listpayementDiff
    ]
    ask cooperatives [
      set capital capital - (sum listpayementDiff)
    ] 
   ]
end

to-report simple-megabole [x th mini maxi zz answer]
  let tmp 0
  let incr 0
  ifelse(x >= th) [
    set tmp ( (x - th)^ zz )
    set incr answer / ((maxi - th)^ zz)
  ][
    set tmp ( - (  (th - x)^ zz ) )
    set incr ( answer / ((th - mini)^ zz))
  ]
  report tmp * incr
end

to-report megabole [x th th2 mini maxi zz answer]
ifelse double-megabole = 0
[
  let tmp 0
  let incr 0
  
  ifelse (x < th)[
        set tmp ( - (  (th - x)^ zz ) )
        set incr ( answer / ((th - mini)^ zz))
  ][
        ifelse( x < ((th + th2) / 2))[
              set tmp (x - th)^ zz 
              set incr answer / (((th2 - th) / 2)^ zz)
        ][
              ifelse(x < th2)[
                    set tmp (th2 - x)^ zz
                    set incr answer / (((th2 - th) / 2)^ zz) 
              ][
                    set tmp ( - ( (x - th2)^ zz ) )
                    set incr ( answer / ((th - mini)^ zz))
                    ;ou? set incr ( answer / ((maxi - th2)^ zz))
              ]
        ]
  ]
  report tmp * incr
][
  report simple-megabole x th mini maxi zz answer
]
end

to grow-temperature
  ;;in patches context
  set patchTemperature patchTemperature + evolTemp
  
end

to grow-acidity
  ;;in patches context
  set patchAcidity patchAcidity - evolTemp * 0.7 ;; dans l'article de Van Leeuven 2004 l'acidité est expliqué a 70% par le milesim
end



to updateAge
  if age != NOBODY [
   set age age + 1 
  if age >= 3 [
   set production TRUE 
  ]
  ]
end

to updateInterest ;;patch context
  set  calculINterest (annualGain  - annualCost)
end

to updateEmployer ;vitis context
  if any? myplots [
    ifelse empty? [patchSlope] of myPlots with [frich != TRUE][
      die
    ][
      let meanSlope (mean [patchSlope] of myPlots with [frich != TRUE]) ;la pente est en % le +0.01 est pour interdire les divisions par 0
      if meanSlope = 0 [
        set  meanSlope 10
      ]
      let wk (1 / (meanSlope / 100))
      let nbmyplots count myPlots
      set employer nbmyplots / wk ; calcule le nombre d'homme dont l'exploitation a besoin y compris l'exploitant
    ]
  ]
end

to updateMeanAcidity ;;vitis context
;  let tmpMeanAcidity mean [patchAcidity] of myPlots
  set meanAcidity mean [patchAcidity] of myPlots
end

to sellLand ;;viti context
  if any? myplots [
    ;;regarde s'il y a des terre improd
    let badland no-patches
    set badland myPlots with [calculINterest < 1]
    if any? badland [
      let theBadLand min-one-of badland [calculINterest]
;      let theBadLand one-of badland with [calculINterest < 1]
      ask theBadLand [
        set frich TRUE 
        set pcolor white
      ]
      set landFriche myPlots with [frich = TRUE]
      set myPlots myPlots with [frich != TRUE]
      ]
    
    if capital < oldCapital [
      let listloop [1 1 1 1 1]
      let activePlots myPlots with [frich != TRUE]
      let lessGoodLand activePlots with-min [calculINterest]
      ask lessGoodLand [
        set sold True
        set owner -1 ;identifiant de locality
        set price reserveSellPrice ;prix auquel la reserve vend les parcelles
        set pcolor scale-color gray patchElevation 0 1000
      ]
      set myplots myplots with [sold != True]
      set capital capital + reserveBuyPrice
      ask cites [
        set LandReserve (patch-set LandReserve lessGoodLand)
      ]
    ]
  ]
     
end

;CYRIL:procédure rajoutée:
to FricheLand ;;viti context
  if any? myplots [
    ;;regarde s'il y a des terre improd
    let badland no-patches
    set badland myPlots with [calculINterest < 1]
    if any? badland [
      let theBadLand min-one-of badland [calculINterest]
;      let theBadLand one-of badland with [calculINterest < 1]
      ask theBadLand [
        set frich TRUE 
        set pcolor white
      ]
      set landFriche myPlots with [frich = TRUE]
      set myPlots myPlots with [frich != TRUE]
      ]
    
    if capital < oldCapital [
      let activePlots myPlots with [frich != TRUE]
      let lessGoodLand activePlots with-min [calculINterest]
      ask lessGoodLand [
        set frich TRUE 
        set pcolor white
      ]
      set landFriche myPlots with [frich = TRUE]
      set myPlots myPlots with [frich != TRUE]
    ]
  ]
     
end

to updateCapital ;instance of vitis  
  let MOpayante employer - 1 ;on a calculer avant le nombre d'employer dont à besoin chaque exploitation
  if MOpayante < 0 [ set MOpayante 0]
  let salaireMO MOpayante * 20000
  let bonusPaymentDiff sum[payementDiff] of myPlots
  
 
   
  let totalCost (sum [annualCost] of myplots) + salaireMO
  let totalGain (sum [annualGain] of myplots with [production = TRUE]) + bonusPaymentDiff
  set oldCapital Capital
  set Capital (Capital + (totalGain - totalCost ))
    
end

to buyLand ;instance of vitis (parceque on est dans ask farmers)
  
  let totalCost sum [annualCost] of myplots
  ;let potplot patches in-radius 2 with [(owner = 0) or (owner = -1)]
  let potplot (patch-set)
  let potplotfinal (patch-set) ;collection de patchs pot
  ask myplots [
    ifelse any? patches with [owner <= 0 and couvertViti = 1][
      set potplot patches with [owner <= 0 and couvertViti = 1]
    ][
      set potplot patches in-radius 2 with [owner <= 0 AND zoneurba = FALSE]
    ]
    set potplotfinal (patch-set potplotfinal potplot) ;renseigne la collection
;    ask potplotfinal [
;     set pcolor yellow 
;    ]
    ]
  let potCost 0;cree une variable vide
  if any? potplotfinal [
    ask potplotfinal [
      set potCost price + 10 * annualCost ;prise en compte de 10 ans
      ]
    let newplot (patch-set)
    ifelse meanAcidity < MeanAcidityCoop[
      set newplot max-one-of potplotfinal [patchAcidity]
;      let plotMaxannualGain potplotfinal with-max[annualGain]
;      set newplot min-one-of plotMaxannualGain [annualCost]
;      set newplot min-one-of (potplotfinal with-max[annualGain])[annualCost] ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ][
    set newplot min-one-of potplotfinal [annualCost]
    ]

    if newplot != NOBODY [
    if Capital > totalCost + [potCost] of newplot and capital > oldCapital [
;      if [annualGain] of newplot > [annualCost] of newplot [
        ask newplot [
          set pcolor [color] of myself
          set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
          set annualGain PlotIncome ;nom du slider
          set age 0
          set production FALSE
;          set slod FALSE
        ]
        set myplots (patch-set myplots newplot)
        set Capital Capital - [price] of newplot ;slider
;      ]
    ]
    ]
    ]
end

to updateStat
  
  set SlopePatchesInCulture 0
  if any? patches with [owner > 0 and frich != TRUE][
    set SlopePatchesInCulture (mean [patchSlope] of patches with [owner > 0 and frich != TRUE])
    set ElevationPatchesInCulture (mean [patchElevation] of patches with [owner > 0 and frich != TRUE])
  ]
  

  set moOnTerritory sum [employer] of vitis
  
  set nbPatchesViti (count patches with [owner > 0 and frich != TRUE])
  if any? vitis [
    set meanCapital mean[capital] of vitis
  ]
  
  let iAcidity []
  ask patches [
   set iAcidity lput patchAcidity iAcidity 
  ]
  set freqAcidity iAcidity
  ;;; préparation des données pour les histogramme d'acidité
  let pAcidity []
  if any? patches with [owner > 0 and frich != TRUE] [
    ask patches with [owner > 0 and frich != TRUE][
      set pAcidity lput patchAcidity pAcidity 
    ]
    set freqAcidityViti pAcidity
  ]
  
  ;;préparation des données pour l'histogramme de fonc (prime par patches atribuer par la coop)
  let pFonc []
  if any? patches with [owner > 0 and frich != TRUE][
    ask patches with [owner > 0 and frich != TRUE][
;     set pFonc lput fonc pFonc
      set pFonc lput  payementDiff pFonc
    ]
    set freqfonc pFonc
  ]
  
  set oldTick ticks
  set meanAcidityGlobal mean[patchAcidity] of patches with [owner > 0 and frich != TRUE]
  
  set coopCapital mean[capital] of cooperatives
  set countVitis count vitis
  set countFriche count patches with [frich = TRUE]
  
  ;;;;;;;;;Indice d'agregation de pixel
  ;;au niveau du viticulteur
  ask vitis [
   let ni count myPlots
   let  rtheo sqrt ( ni / pi )
   set indic count myPlots in-radius rtheo
   
   ask myPLots[
    set ind-temp count other patches in-radius rtheo with [pcolor = [pcolor] of myself]
   ]
   set indic-proxi mean [ind-temp] of myPlots
  ]
  set meanIndi-proxi mean[indic-proxi] of vitis
  set meanIndice mean [(indic + 1) / (count myPlots + 1)] of vitis
  
 
  
  
  ;;à l'échelle des patces viticoles
  
;  let vitipatches patches with [owner > 0 and frich != TRUE]
;  let  rtheo sqrt ( count vitipatches / pi )
;  ask vitipatches[
;    set ind-temp-viti count other patches in-radius rtheo with [owner > 0 and frich != TRUE]
;  ]
;  set indic-proxi-viti mean [ind-temp-viti] of vitipatches
  
  ;;MAJ indice de gini

  let sorted-wealths sort [Capital] of vitis
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  set gini-index-reserve 0
  set lorenz-points [] ;pour stocker un vecteur, lupt rajoute dans la liste
  repeat Countvitis [
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
    set index (index + 1)
    set gini-index-reserve gini-index-reserve + (index / Countvitis) - (wealth-sum-so-far / total-wealth)
  ]
   set gini-index-reserve (gini-index-reserve / Countvitis) / 0.5
   
   ;;calcul du temps de simulation
   set realSimulationTick ticks
   ;;on commence a prendre en compte le temps de simualtion une fois que la vigne a l'emprise actuelle
   if any? patches with [owner <= 0 and couvertViti = 1][
     set tickStart tickStart + 1
   ]
   if not any? patches with [owner <= 0 and couvertViti = 1][
     set time time + 1
   ]
   set tickStop tickStart + nb-annee-exploration
  
end

to photoMaker
  if auto-photo = TRUE [
    if ticks = 1 OR ticks = 200 OR ticks = 400 OR ticks = 600 [
      photo
    ]
  ]
end

to photo
;  ask patches with [patchAcidity < 3][set pcolor red]
  export-view (word "View-on-tick-" time"- bonus" acidityBonus " mu " mu ".png")
end

to plottheBoule ;CYRIL: modified
  set-current-plot "fonction repartition coop"
  clear-plot
  let listAcidity minPotAcidity-I
  let anser 0
  while [listAcidity <= maxPotAcidity-I] [
    set anser megabole listAcidity MeanAcidityCoop-I  TooHighAcidityCoop-I minPotAcidity-I maxPotAcidity-I mu-I acidityBonus-I
    plotxy listAcidity anser
    set listAcidity listAcidity + 0.1
  ]
end

;;;;;;;;;;;;Calcul de la framentation ;;;;; Etienne
to calcul-frac
  ask patches [
    set plabel ""
    set cluster nobody
    ]
  find-clusters
  let Frag_real (max [plabel] of patches + 1);CYRIL: tu pourrais mettre let counter 1 dans show-clusters pour ne pas avoir à rajouter + 1 ici, non? -> OUI c'est vrai :-D
  set Frag Frag_real / item nbPatchesViti frag_theo 
end

to find-clusters
  loop [
    let seed one-of patches with [(cluster = nobody) and owner > 0 and frich != TRUE] ;CYRIL: il manquait les deux dernières conditions ici!!
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
  [ let p one-of patches with [(plabel = "" ) and owner > 0 and frich != TRUE] ;CYRIL: il manquait les deux dernières conditions ici!!
    if p = nobody
      [ stop ]
    ask p
    [ ask patches with [cluster = [cluster] of myself]
      [ set plabel counter ] ]
    set counter counter + 1 
    ]
end

to grow-cluster  
;  ask neighbors4 with [(cluster = nobody) and ;;;ICI on choisie ce qu'on veux regarder
;    (pcolor = [pcolor] of myself)]
  ask neighbors4 with [(cluster = nobody) and owner > 0 and frich != TRUE]
  [ set cluster [cluster] of myself
    grow-cluster 
   ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                         PLOTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to updatePlot
  set-current-plot "Vtis-Acidity"
  ask vitis [
    if any? myPlots [
      set-plot-pen-color color ;pour renvoyer la couleur du fermier
      plotxy ticks meanAcidity
    ]
  ]
  set-plot-pen-color red
  plotxy ticks meanAcidityGlobal
  
  set-current-plot "Vitis-Capital"
  ask vitis [
    set-plot-pen-color color ;pour renvoyer la couleur du fermier
    plotxy ticks capital
    ]
  
  set-current-plot "MO-viticole"
  plotxy ticks moOnTerritory
  
  set-current-plot "meanSlope elevation"
  set-plot-pen-color red
  plotxy ticks SlopePatchesInCulture
  set-plot-pen-color blue
  plotxy ticks ElevationPatchesInCulture
 
 set-current-plot "HistAcidity"
  ;;pour réaliser un histogram on a besoin d'une liste
  set-plot-x-range 0 ( (max freqAcidity) + 5)
;  set-histogram-num-bars 8
  histogram freqAcidity
  let maxbar modes freqAcidity
  let maxrange length filter [ ? = item 0 maxbar ] freqAcidity
;  set-plot-y-range 0 max list 10 maxrange
 set-plot-y-range 0 1000
 
 set-current-plot "HistAcidityViticole"
  ;;pour réaliser un histogram on a besoin d'une liste
  set-plot-x-range -4 ( (max freqAcidityViti) + 5)
;  set-histogram-num-bars 8
  histogram freqAcidityViti
  let maxbarV modes freqAcidityViti
  let maxrangeV length filter [ ? = item 0 maxbarV ] freqAcidityViti
;  set-plot-y-range 0 max list 10 maxrangeV
 set-plot-y-range 0 500
 
 set-current-plot "histo-remun-coop"
 ;;pour réaliser un histogram on a besoin d'une liste
  set-plot-x-range ( (min freqfonc) - 5) ( (max freqfonc) + 5)
  set-histogram-num-bars 20
  histogram freqfonc
  let maxbarF modes freqfonc
  let maxrangeF length filter [ ? = item 0 maxbarF ] freqfonc
;  set-plot-y-range 0 max list 10 maxrangeF
 set-plot-y-range 0 500
 
 set-current-plot "indic-proxi"
 plotxy ticks meanIndi-proxi
 
 set-current-plot "indic"
 ask vitis [
   set-plot-pen-color color ;pour renvoyer la couleur du fermier
   plotxy ticks indic
 ]
 set-current-plot "meanIndicOfvitis"
 plotxy ticks meanIndice
 
end
@#$#@#$#@
GRAPHICS-WINDOW
235
10
577
325
-1
-1
4.06
1
10
1
1
1
0
0
0
1
0
81
0
69
0
0
1
ticks
30.0

BUTTON
5
10
79
43
NIL
Setup
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
170
10
233
43
NIL
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
5
100
177
133
NbVitis-I
NbVitis-I
1
50
50
1
1
NIL
HORIZONTAL

SLIDER
5
175
182
208
InitialCapital-I
InitialCapital-I
0
100000
6000
1000
1
NIL
HORIZONTAL

SLIDER
580
10
752
43
evolTemp-I
evolTemp-I
0
1
0.02
0.01
1
NIL
HORIZONTAL

PLOT
580
225
780
375
Temporal evolution of acidity and temperature
time
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"acidity" 1.0 0 -16777216 true "" "plotxy ticks mean [patchAcidity] of patches"
"temperature" 1.0 0 -7500403 true "" "plotxy ticks mean [patchTemperature] of patches"

PLOT
785
70
985
220
Vtis-Acidity
time
mean Acidity
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""
"3 acidity" 1.0 0 -2674135 true "" "plot MeanAcidityCoop-I"

INPUTBOX
5
215
90
275
PlotIncome-I
5900
1
0
Number

INPUTBOX
5
280
90
340
priceNewPlot-I
33000
1
0
Number

PLOT
785
375
985
495
Vitis-Capital
time
capital
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""
"0" 1.0 0 -7500403 true "" "plot 0"

INPUTBOX
105
210
200
270
reserveBuyPrice-I
17000
1
0
Number

INPUTBOX
100
280
200
340
reserveSellPrice-I
17000
1
0
Number

BUTTON
85
10
167
43
goStep
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

CHOOSER
755
10
947
55
CoopStrategie-I
CoopStrategie-I
"MinProdCost" "MaxAcidity" "equivalenceBalance"
2

SLIDER
240
365
417
398
MeanAcidityCoop-I
MeanAcidityCoop-I
2
4
3
0.1
1
NIL
HORIZONTAL

PLOT
785
510
985
660
MO-viticole
Time
main-d'oeuvre
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
240
400
412
433
acidityBonus-I
acidityBonus-I
0
10000
1000
100
1
NIL
HORIZONTAL

CHOOSER
240
440
407
485
visualisationType
visualisationType
"patchInterst" "elevation" "Slope" "Acidity" "limAcidity3" "couvertVegetal" "who_have_bonus"
3

TEXTBOX
590
50
740
70
Incremente une élévation de la température annuel
8
0.0
1

TEXTBOX
955
15
1035
45
choix du type de comportement territorial
8
0.0
1

TEXTBOX
415
455
500
490
Choix du type de viualisation des patches 
8
0.0
1

TEXTBOX
415
405
550
451
Bonus/malus pour les patches avec acidité +/- 3. La répartition varie en fonction de CoopStrategie et mu
8
0.0
1

TEXTBOX
420
370
500
395
acidité demander par la coop
8
0.0
1

MONITOR
175
100
232
137
nbViti
countVitis
0
1
9

PLOT
1195
70
1395
220
MeanSlope elevation
time
Slope - Elevation
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

BUTTON
1050
10
1122
43
NIL
photo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1055
45
1145
70
prend une photo du viewer
9
0.0
1

PLOT
580
70
780
220
MeanAcidity
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
"default" 1.0 0 -16777216 true "" "plotxy ticks meanAcidityGlobal"
"pen-1" 1.0 0 -7500403 true "" "plot MeanAcidityCoop-I"

PLOT
1395
70
1660
375
HistAcidity
Acidity
freq patches
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
1395
375
1660
610
HistAcidityViticole
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
"default" 1.0 1 -16777216 true "" ""

BUTTON
10
55
107
88
go 100
if ticks < 100 [\n go\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1130
10
1267
43
auto-photo
auto-photo
1
1
-1000

SLIDER
240
325
405
358
mu-I
mu-I
0
5
0
0.1
1
NIL
HORIZONTAL

PLOT
1195
465
1395
615
indic-proxi
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
"default" 1.0 0 -16777216 true "" ""

PLOT
990
525
1190
675
indic
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

PLOT
990
375
1190
525
meanIndicOfvitis
NIL
NIL
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

MONITOR
1195
375
1350
420
NIL
log meanIndice 2
17
1
11

PLOT
785
225
985
375
capital of coop
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
"default" 1.0 0 -16777216 true "" "plot coopCapital"
"pen-1" 1.0 0 -7500403 true "" "plot 0"

PLOT
985
70
1185
220
parcelles viti
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
"default" 1.0 0 -16777216 true "" "plot count patches with [owner > 0 and frich != TRUE]"

PLOT
990
225
1190
375
histo-remun-coop
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
"default" 1.0 1 -16777216 true "" ""

PLOT
1195
225
1395
375
parcelles bonus /parcelles malus
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
"default" 1.0 0 -16777216 true "" "plot count patches with [owner > 0 and frich != TRUE]"
"pen-1" 1.0 0 -7500403 true "" "plot count patches with [patchAcidity > 3]"

PLOT
580
375
780
525
fonction repartition coop
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
"default" 1.0 0 -16777216 true "" ""

BUTTON
1465
25
1537
58
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

TEXTBOX
410
330
560
351
qualificationde la stratégie de la coop
9
0.0
1

SLIDER
240
490
412
523
poidsDistance-I
poidsDistance-I
0
100
2
1
1
NIL
HORIZONTAL

SLIDER
240
530
412
563
poidsSlope-I
poidsSlope-I
0
100
5
1
1
NIL
HORIZONTAL

TEXTBOX
420
505
570
576
valeur multipliant la distance et la pente, pour donner plus d'importance à l'une ou à l'autre
9
0.0
1

SLIDER
115
55
225
88
atPatches
atPatches
0
30
10
1
1
NIL
HORIZONTAL

INPUTBOX
240
570
335
630
minPotAcidity-I
-4
1
0
Number

INPUTBOX
340
570
425
630
maxPotAcidity-I
12
1
0
Number

MONITOR
1195
420
1350
465
NIL
indic-proxi-viti
17
1
11

PLOT
1195
615
1395
765
indic-proxi-viti 
time
indic-proxi-viti
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot indic-proxi-viti"

PLOT
580
525
780
675
Gini on vitis capital
time
gini
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (gini-index-reserve)"

PLOT
5
465
205
615
couvertSimulé VS couvert réel
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
"default" 1.0 0 -16777216 true "" "plot count patches with [couvertViti = 1]"
"pen-1" 1.0 0 -7500403 true "" "plot count patches with [owner > 0 and frich != TRUE]"

MONITOR
10
355
72
400
NIL
tickStop
17
1
11

TEXTBOX
75
365
165
395
la simulation s'arrète au bout de n ticks
8
0.0
1

SLIDER
240
635
412
668
echeance
echeance
50
600
100
10
1
NIL
HORIZONTAL

MONITOR
10
405
67
450
NIL
time
17
1
11

TEXTBOX
75
415
225
433
time dans la simulation
9
0.0
1

SLIDER
5
135
177
168
prodCost-I
prodCost-I
1000
3000
2500
100
1
NIL
HORIZONTAL

MONITOR
10
620
67
665
Friche
count patches with [frich = TRUE]
17
1
11

SLIDER
430
595
575
628
TooHighAcidityCoop-I
TooHighAcidityCoop-I
0
20
6
0.1
1
NIL
HORIZONTAL

BUTTON
555
420
617
453
replot
plotTHEboule
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1400
615
1660
765
Framentation vine landscape
time
nb cluster
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Frag"

SLIDER
430
560
575
593
onlyFriche-I
onlyFriche-I
0
1
0
1
1
NIL
HORIZONTAL

SLIDER
430
635
575
668
double-megabole-I
double-megabole-I
0
1
0
1
1
NIL
HORIZONTAL

TEXTBOX
465
555
555
573
0 = TRUE 1 = FALSE
8
0.0
1

TEXTBOX
455
665
550
683
0 = TRUE ; 1 = FALSE
8
0.0
1

MONITOR
130
675
262
720
NIL
realSimulationTick
17
1
11

@#$#@#$#@
## LOG BOOK:
-v0.89: rajouté une procédure ou les vitis ne mettent qu'en friche (plus de vente à la commune) pour deux raisons: une parcelle n'est pas rentable ou ils manquent de capital

-V0.90 ajouter le calcul de l'indice d'agrégation calculé sur l'ensembles des patches cultivé et l'indice de gini sur le capital des viticulteurs. le behavior space a été mis a jour avec l'indice de gini et d'agrégation du paysage

-V0.90 est optimiser pour entre envoyé sur la MOLE ... 
http://www.openmole.org/documentation/concepts/tasks/the-netlogotask/build-a-headless-version-of-a-netlogo-code/
 * toutes les variables de l'interface se sont vue atribué un I (pour interface),elle sont stocker dans des variables globale 
 * un setup grid est créer ne contenant pas la procedure clear-all est retiré (va savoir pourquoi, en faut la réponce est là http://www.openmole.org/documentation/concepts/tasks/the-netlogotask/netlogo-on-the-grid/)

-v0.91 ompenMole a intégrer les donnés SIG pour la couverture végétal actuelle ET des zones ou la viticulture est impossible (ville et mer)... on à suprimé le choix des parcelles en radius autour du viticulteur à l'inititaisation, dans la procédure buyLand, un ifelse de plus : Si il y a encore des parcelles actuellement en vigne libre je prend celle là. Sinon je prend une autre dans un radius de 2 autour de mes parcelles.

## RESULTATS OBSERVES:

-v0.89: mu > 0 fait toujours moins bien que mu=0 en terme d'acidité, mais l'aspect spatial pourrait être intéressant?

-v0.90: l'indice d'agrégation sur l'ensemble des patches n'est peut être pas d'un intérêt magnifique la courbe à la même aspect que la courbe qui compte les patches viticole. L'indice de gini est-ce qu'il est avec des problèmes quand un viticulteur est "bloqué par les autres, son capital flambe et cela crée des inégalités dans la répartition ... gini s'approche de 1.

-v0.91 ompenMole le bouton go 50 ans part du principe qu'il faut 60 ticks pour arrivé a l'état actuelle de la viticulture sur le cru. Dans ces condition pour explorer le modèle a 50 ans il faut faire le faire tourner 110 ticks.
Le comportement s'en trouve largement modifié.

## TODO LIST:
-v0.89: pourquoi ne pas re-réfléchir à une coop qui doit balancer son budget :-)
Finalement, l'approche vers un réalisme plus poussée risque d'être impossible (comment fixer une dynamique sur une observation ponctuelle actuelle) donc je reviens un peu sur ma position et j'entends mieux ton idée de rester sur une exploration de comportement de la coop sur des comportements de vitis réalistes mais pas réels. Qu'est-ce que t'en dis?
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
  <experiment name="experiment-WoCoop" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>meanSlopeTerritory</metric>
    <metric>meanElevationterritory</metric>
    <metric>time</metric>
    <metric>moOnTerritory</metric>
    <metric>SlopePatchesInCulture</metric>
    <metric>ElevationPatchesInCulture</metric>
    <metric>nbPatchesViti</metric>
    <metric>meanCapital</metric>
    <metric>meanAcidityGlobal ;;varaition de l'acidité des patches viticoles</metric>
    <metric>indic-proxi</metric>
    <metric>meanIndice</metric>
    <metric>meanIndi-proxi</metric>
    <metric>Countvitis</metric>
    <metric>countFriche</metric>
    <metric>indic-proxi-viti ;;moyenne des indices d'agrégation centré sur chauque patches</metric>
    <metric>gini-index-reserve</metric>
    <metric>coopCapital</metric>
    <enumeratedValueSet variable="poidsSlope-I">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualisationType">
      <value value="&quot;Acidity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="echeance">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxPotAcidity-I">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CoopStrategie-I">
      <value value="&quot;MinProdCost&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialCapital-I">
      <value value="6000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveSellPrice-I">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="onlyFriche-I">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanAcidityCoop-I">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minPotAcidity-I">
      <value value="-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PlotIncome-I">
      <value value="5900"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priceNewPlot-I">
      <value value="33000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="auto-photo">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolTemp-I">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveBuyPrice-I">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prodCost-I">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbVitis-I">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acidityBonus-I">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="atPatches">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poidsDistance-I">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu-I">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-CoopAcidity-VarMu-bonus" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>meanSlopeTerritory</metric>
    <metric>meanElevationterritory</metric>
    <metric>time</metric>
    <metric>moOnTerritory</metric>
    <metric>SlopePatchesInCulture</metric>
    <metric>ElevationPatchesInCulture</metric>
    <metric>nbPatchesViti</metric>
    <metric>meanCapital</metric>
    <metric>meanAcidityGlobal ;;varaition de l'acidité des patches viticoles</metric>
    <metric>indic-proxi</metric>
    <metric>meanIndice</metric>
    <metric>meanIndi-proxi</metric>
    <metric>Countvitis</metric>
    <metric>countFriche</metric>
    <metric>indic-proxi-viti ;;moyenne des indices d'agrégation centré sur chauque patches</metric>
    <metric>gini-index-reserve</metric>
    <metric>coopCapital</metric>
    <enumeratedValueSet variable="poidsSlope-I">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualisationType">
      <value value="&quot;Acidity&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="echeance">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maxPotAcidity-I">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CoopStrategie-I">
      <value value="&quot;equivalenceBalance&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialCapital-I">
      <value value="6000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveSellPrice-I">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="onlyFriche-I">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MeanAcidityCoop-I">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minPotAcidity-I">
      <value value="-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PlotIncome-I">
      <value value="5900"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priceNewPlot-I">
      <value value="33000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="auto-photo">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolTemp-I">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveBuyPrice-I">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prodCost-I">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbVitis-I">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="acidityBonus-I" first="1000" step="1000" last="5000"/>
    <enumeratedValueSet variable="atPatches">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="poidsDistance-I">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="mu-I" first="0" step="0.5" last="1.5"/>
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
