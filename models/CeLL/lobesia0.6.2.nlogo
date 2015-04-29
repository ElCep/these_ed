;; dans ce modele nous essayons d'aggreger les lobesia qui sont au même endroit!

extensions [gis] ;;pour prendre en compte des données SIG


breed [lobesias lobesia]
breed [seeds seed]
breed [traps trap]
breed [obs-traps obs-trap]
breed [parcelles parcelle]

globals [
  parcelles-viticoles    ;;pour charger les données des parcelles viticoles
  parcelles-confuse      ;;pour charger les données des parcelles confuse
  temperatureRaster      ;;pour charger les donénes raster de temperature
  nblobesias
  rotation
  T?
  passoEnergy
  distMove
  generationList ;;stock a list of all generation in one ticks
  phaseList  ;;stock a list of all evolution phase for one ticks
  ageOfDie ;;max day age for an adulte lobesia
  beginPlantDev ;;what day begin de plante developpement
;  distDiffPheromone  ;;distance de diffuion des pheromones
  pheromone_left ;; volume de phéromone lacher par lobesia sur le patches 
  downPherom  ;; pheromone / downPherom a chaque itération
  reprod-distance ;; si il y a des lobesia de l'autre sex a une distance "reprod-distance" il y a reproduction
  visibility-other ;;distance a laquel les males voie les phéromones de femelle
  coeff-diff  ;; de 0 à 1 = 0 a 100 diffusion des phéromone dans les patches voisin
  confusion  ;; si on mets en place un traitement
  lobesias-HotSpot  ;; TRUE FALSE est ce qu'on imagine des hotspot
  radius-hotSpots  ;; rayon de l'aire de diffusion
  nb-egg  ;;nombre d'oeufs par ponte
  TempData ;;list for store temperature data from realword
  timeData ;; liste for store date of the temperature
  toDay ;;time today
  nb-traps ;; how many traps are installed in space
  coeff-diff-trap ;; coef for pheromone diffusion by traps
  rational-traps ;; for conditional placement of traps
  bufferTrapping ;; buffer for trapping zone
  distEffectiveTrap ;; max distance for pheromone trapping use
  aggregation_factor  ;; how many lobesia will be aggregated by patches ...
  population_vector   ;; un vecteur de l'évolution des individus adules pour voire les générations et tout recupérer avec openMole
  realTime          ;; dates des comptages de Eric Noemie
  tick4comptage   ;; date en ticks pour les comptages
  realComptage      ;; comptage des de Eric a associer aux dates
  leastSqrt         ;; somme moindre carré sur les comptage de lobesas Somme des obeserver - théorique au carre
  leastSqrt-Time    ;; distance temps au dernier relever 
  fisrtComptage     ;;On va stocker les valeurs du dernier comptage pour calucler les leastSqrt
  fisrtticks        ;;On va stocker la valeur du dernier ticks ou il y a eu un comptage pour calculer les leastSqrt-Time
  setupDistTrap     ;; distance a laquelle les pièges sont disposé les uns des autres a l'initialisation
  nbcomptage        ;; nombre de comptages dans le modèles
  radius-trap       ;; la distance entre deux pièges
  distanceCand      ;; distance des surafces clandestin
  trapdistance      ;;distance a laquelle on considère que le piège fonctionne
  climatChange      ;; boleen pour ajouter quelques degre au comportement init
  nbClandestin      ;; contient le nombre de parcelles qui ne vont pas installer de diffuseurs de phéromones

  
 
 
 
 ;;stat
 nblobesiasCounted 
 nbegg
 nblarva
 nbcrisalide
 nbadulte
 generation-max
 infestation
 meanfecondation ;;mean of mating for femelle lobesias
 nbFemellesAdulte ;; nb lobesias femelles
 nbMalesAdulte ;; nb lobesias adultes
 nblobesiaTrappedDay  ;; nombre de lobesia male adulte attraber dans les pièges jours
 nblobesiaTrapped  ;; nombre de lobesia male adulte attraber dans les pièges entre deux compatges
 nbTraps_counted   ;; nombre de pièges posé
 surfaces-non-couverte ;;surfaces ou il n'y a pas de pièges
 mindistanceClandestin ;;distance de la parcelle clandestine la plus proche
]

patches-own[
 variety ;;divers variety of vineyard
 viticole ;;boolean to know if patch is viticole
 numParcelle ;;keep in memory ID of parcelles correspnding to crop island
 numSubParcelle ;; kiip ID of subparcelle real plots
 confuse ;; boolean it's a confusing plots or not
 flower-time ;;phenology of flowering
 flower ;; TRUE FALSE?
 greenQuantity ;;
 fruitQuantity ;;
 termicalAcum ;; accumulation termique
 temperature_here  ;;donnée de temperature charger depuis le raster et qui evolut avec les fichier csv a chaque itération!
 unitaTermicaForch
 Ppheromone ;; patch level of pheromone live from femelle
 Ppheromone-trap ;; patch level of pheromone live form trap
 mixed-pheromone ;; the max between Ppheromone and Ppheromone-trap
 occupe  ;; TRUE FALSE if any lobesias here
 outOftrapsInfluence ;; In or out of traps influence
 clandestin?  ;;boleeen pour savoir si la parcelle est clandestine
]

lobesias-own[
 phase ;;egg larva crisalide adulte
 phaseNumber ;; pahse numer 1 egg 2 larva ...
 energy ;; how much I'm hangry
 age     ;; max 20 jours
 sex     ;;male femmelle
 heatrequired ;; heat requirement for egg hatching
 normalDist ;estrazione casuale della curva normale da 1 a 100;
 a 
 b
 c
 t
 generation
 unitaDev 
 nb-mating ;;nombre d'accouplement dans la vie d'un adulte Femmelle sex = 1
 reproductionFlag  ;; un drapeau pour dire si la femmelle peut s'accoupler, Si FALSE elle est en gestation...
 gestationTime  ;; la gestation dure 2-3 jours durant lesquel la F adulte ne peut plus s'accoupler source hyppz inra
 aggre_nb ;;if we are in a meta_agent here it's the number of individuals
]

traps-own[ ;;atribut for pheromones traps
  observer  ;;boolean
  lobesias-traps ;; nombre de lobesia adulte male piégé
  parcelleID ;; identification of parcelle
]

to global-fix
  set rotation random 180 ;90
  set trapdistance 2
  set T? 17
  set passoEnergy 4
  set distMove 8
  set beginPlantDev 100
  set downPherom 2
  set reprod-distance 0.5
  set coeff-diff-trap 0.6
  set bufferTrapping 10
  set distEffectiveTrap 15
  set toDay ""
  set aggregation_factor 20
  set setupDistTrap 10
  ;;OpenMole va passer des Double et on va les transformer en simple
;  set visibility-other ceiling visibility-other
;  set coeff-diff ceiling coeff-diff 
;  set radius-hotSpots ceiling radius-hotSpots
  set nb-egg ceiling nb-egg
  import-data
end

to global-variable ;;not used in openmole
  clear-all
  set nblobesias i-NBlobesias
  set rotation i-angle-flight ;360
  set pheromone_left i-pheromone_left
  set ageOfDie i-ageOfDie
  set visibility-other i-visibility-other
  set coeff-diff i-coeff-diff
  set confusion i-confusion
  set lobesias-HotSpot i-lobesias-HotSpot
  set radius-hotSpots i-radius-hotSpots
  set nb-egg i-nb-egg
;  set nb-traps i-nb-traps
  set rational-traps i-rational-traps
  set radius-trap i-radius-trap
  set climatChange climatChange_i
  set nbClandestin i-nbClandestin
;  set distanceCand i-distanceCand 
end

to import-data ;in steup import data from a csv created by R from real banyuls data 
  set TempData []
  file-open "data/temperature_banyuls/rimbau2012_delta.csv"
  while [not file-at-end?][
    let in1 file-read
    set TempData lput in1 TempData
  ]
;  show TempData
  file-close
  
  ;;import date
  set timeData []
  file-open "data/temperature_banyuls/date2012.csv"
  while [not file-at-end?][
    let in1 file-read
    set timeData lput in1 timeData
  ]
;  show timeData
  file-close
  
  ;;import data real pour le calcul des mondre carre
  set realTime []
  file-open "data/comptage/ille_date.csv"
  while [not file-at-end?][
    let in1 file-read
    set realTime lput in1 realTime
  ]
  file-close
  
  ;;import les ticks auquelle sont fait les comptages
  set tick4comptage []
  file-open "data/comptage/ticks4date.csv"
  while [not file-at-end?][
    let in1 file-read
    set tick4comptage lput in1 tick4comptage
  ]
  file-close
  
  ;;import des valeurs de comptages
  set realcomptage []
  file-open "data/comptage/ille_comptage.csv"
  while [not file-at-end?][
    let in1 file-read
    set realcomptage lput in1 realcomptage
  ]
  file-close
  
  
  
  temperatureEvolution
end

to setup-GIS
  ;;import des données raster
  ;;raster de température
  set temperatureRaster gis:load-dataset "data/gis/temperature_zone_crop.asc"
  ;gis:paint temperatureRaster white
  ask patches [
   set clandestin? FALSE
   set viticole FALSE
   set temperature_here gis:raster-sample temperatureRaster patch pxcor pycor
   set temperature_here temperature_here - 2.504503
   set pcolor round (temperature_here * 100)
  ]
  
  
  ;; import des données vector
  set parcelles-viticoles gis:load-dataset "data/gis/parcelles_viti_zone.shp"
  gis:set-world-envelope gis:envelope-of parcelles-viticoles ;; par défaut
  gis:set-drawing-color green 
  gis:draw parcelles-viticoles 1
  ask patches gis:intersecting parcelles-viticoles [
       set viticole True
;       gis:apply-coverage parcelles-viticoles "numero" numParcelle
    ]
  ;;pour envoyer les numéros de parcelles aux patches
  foreach gis:feature-list-of parcelles-viticoles [
    create-parcelles 1 [
       ask patches gis:intersecting ? [
        set numParcelle [who] of myself
      ]
    ]
  ]
  ask parcelles [die]
  
  ;;les parclles qui seront ensuite confusé
  set parcelles-confuse gis:load-dataset "data/gis/parcelles.shp"
  gis:set-drawing-color brown 
  gis:draw parcelles-confuse 1
  ask patches gis:intersecting parcelles-confuse [set confuse True]
  foreach gis:feature-list-of parcelles-confuse [
    create-parcelles 1 [
       ask patches gis:intersecting ? [
        set numSubParcelle [who] of myself
      ]
    ]
  ]
  
  ;;gis:apply-coverage parcelles-viticoles "cépage" variety
  
end


to common-setup
  global-fix
  set nbcomptage 0
;  import-pcolors "campi.png"

  set fisrtComptage 0
  set fisrtticks 0
  set population_vector []
  ask patches [
    set termicalAcum 0
    ;set pcolor variety
    set Ppheromone 0
  ]
  
  
  ifelse lobesias-HotSpot = 1 [
    let vitipatches patches with [viticole = TRUE]
    ask one-of vitipatches [
      sprout-seeds 1 
    ]
    
    ask seeds [
      hatch-traps 1 [
        set size 4
        set color red
        set shape "target"
        set observer TRUE
      ]
      let i 1
      while  [i <= nblobesias][
       ask one-of patches in-radius radius-hotSpots [
        sprout-lobesias 1 [
          createLobesias
        ] 
        set i i + 1
       ]
      ]
      difference-Lobesias
    ]
  ][
     create-lobesias nblobesias [
       setxy random-pxcor random-pycor
       createLobesias
     ]
     difference-Lobesias
  ]
  ask patches with [not any? traps in-radius distEffectiveTrap] [
   set outOftrapsInfluence TRUE 
  ]
  
  cure-pheromone
  integreted_lutte
  update-stat
  reset-ticks
end

to createLobesias
    set color yellow
    set shape "dot"
    set phase "egg" ;;egg larva crisalide adulte
    set phaseNumber 1
    set energy 50;; how much I'm hangry
    set age 0    ;; max 20 jours
    set sex  random 2   ;;male = 0 femmelle = 1
    set gestationTime 0
    set heatrequired 0
    set a 0.397370
    set b 0.183374
    set c 0.187975
    set generation 0
    set aggre_nb 1
end

to difference-Lobesias
  ask lobesias [
    set normalDist random-normal 50 47.5 / 2
    if normalDist <= 5 [
     set  heatrequired 351
     set color 42
    ]
    if normalDist > 5 and  normalDist <= 25 [
     set  heatrequired 374
     set color 43
    ]
    if normalDist > 25 and  normalDist <= 50 [
     set  heatrequired 401
     set color 44
    ]
    if normalDist > 50 and  normalDist <= 75 [
     set  heatrequired 442
     set color 45
    ]
    if normalDist > 75 and  normalDist <= 95 [
     set  heatrequired 518
     set color 46
    ]
    if normalDist > 95 [
      set  heatrequired 600
      set color 48
      ]
  ]
end

to setup
  global-variable
  setup-GIS
  common-setup
  
  
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  RUN TO THE GRID
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to run-to-grid [tmax]
  ;global-variable
  setup-GIS
  common-setup
  while [ go-stop-temp?  AND ticks <= tmax AND go-stop-lobesias?]
  [go]
  reset-ticks
  
end

to-report go-stop-temp?
  ifelse length TempData <= 0
  [report FALSE][report TRUE]
  
end

to-report go-stop-lobesias?
  ifelse count lobesias > 30000 OR not any? lobesias
  [report FALSE][report TRUE]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                         GO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  temperatureEvolution
  
  ask patches [
   set termicalAcum termicalAcum + temperature_here
   devPlant
   color-patches
  ]
  ask lobesias [ 
    ask lobesias with [sex = 0 AND phase = "adulte"][pen-down] 
    goTo
    ;pheromone
    phaseEvolution
    developpement
    eat
    reproduction
    upAdulteAge
;    groupe_agents
    ]
  difference-Lobesias
  cure-pheromone ;;Une grande parties de mécanismes se passe ici
  
  
  
  ;;PLots
  up-plot-histogram-generation
  up-plot-histogram-phase
  update-stat
  if not any? lobesias [
   stop 
  ]
  if length TempData = 0 [
   stop 
  ]
  
  leastSquare
  tick
end

to goTo ;;lobesias context

  if phase = "adulte"[
     ifelse sex = 1[ ;; FEMELLE has un normal comportement
            let myMove distMove
            while [myMove > 0][
              right flutter-amount rotation
              forward 1
              set myMove myMove - 1
              pheromone
            ]
         ][;;male try to find femmelle with is pheromone
            let myMove distMove
            while [myMove > 0][
              face one-of patches in-radius visibility-other with-max[mixed-pheromone]
              forward 1
              set myMove myMove - 1
            ]
         ]
  ]
end

to-report flutter-amount [limit]
  ;; This routine takes a number as an input and returns a random value between
  ;; (+1 * input value) and (-1 * input value).
  ;; It is used to add a random flutter to the moth's movements
  report random-float (2 * limit) - limit
end

to temperatureEvolution
  let deltaDay first TempData
  ifelse climatChange = 1[
    ask patches [
      set temperature_here temperature_here + deltaDay + 0.5 ;; ajouter 0.5 degre permet de projeter un changement clim avec augm de 1°c pour 50 ans
    ]
  ][
    ask patches [
      set temperature_here temperature_here + deltaDay
    ]
  ]
  ;set T?  T? + first TempData
  set TempData but-first TempData
  
  set toDay first timeData
  set timeData but-first timeData
end

to phaseEvolution
  if [termicalAcum] of patch-here >= heatrequired AND generation = 0[
   if phase = "egg" [
     set phase "larva"
     set phaseNumber 2
     set shape "bug"
     set a 0.335958
     set b 0.195681
     set c 0.197009
     set t [temperature_here] of patch-here
     set unitaDev 0
   ]
  ]
  if phase = "egg" AND generation > 0 [
     set phase "larva"
     set phaseNumber 2
     set shape "bug"
     set a 0.335958
     set b 0.195681
     set c 0.197009
     set t [temperature_here] of patch-here
     set unitaDev 0
   ]
   if phase = "larva" AND unitaDev >= 1 [
     set phase "crisalide"
     set phaseNumber 3
     set shape "triangle"
     set a 0.439051
     set b 0.311930
     set c 0.313915
     set t [temperature_here] of patch-here
     set unitaDev 0
   ]
   if phase = "crisalide" AND unitaDev >= 1[
     set phase "adulte"
     set phaseNumber 4
     set shape "butterfly"
   ]
end

to developpement
  set unitaDev unitaDev + foncDev t a b c
end

to-report foncDev [tt aa bb cc]
  ;; This routine takes numbers as inputs and returns a value for have the dev phase of lobesias
  ;; it's the tt value how is importante intéressante for that
  ;; it's the environementale tempserature (most be dev if we use GIS data)
  report aa * (e ^ (bb * (tt - 10)) - e ^ (bb * (35 - 10) - cc * (35 - tt)))
end

to eat
  if phase = "larva" [
   set energy passoEnergy
  ]
end

to devPlant ;patches context
  if ticks > beginPlantDev [
    
;    set unitaTermicaForch unitaTermicaForch + foncForc temperature_here
    if unitaTermicaForch >= flower-time [
      set flower TRUE
      set pcolor red
    ]
  ]
  if unitaTermicaForch > flower-time + 5 [
    set flower FALSE
    set pcolor round (temperature_here * 100)
  ]
end

to-report foncForc [tt]
  ;; This routine takes a number as an input and returns a random value between
  ;; (+1 * input value) and (-1 * input value).
  ;; It is used to add a random flutter to the moth's movements
  report 1 / ( 1 + e ^ (-0.2644 * (tt - 16.0644)))
end

to reproduction
  ifelse reproductionFlag = TRUE AND sex = 1 AND [viticole]of patch-here = TRUE[  ;; only femelle can reproduce
   if any? lobesias in-radius reprod-distance with [sex != [sex] of myself AND phase = "adulte" AND mating-proba nb-mating][;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ici on peut/doit rajouter une probabilité qui diminu avec le nombre de fécondation
     let myheatrequired [heatrequired] of self
     let mygeneration [generation] of self
     let where-lay n-of 5 patches in-radius 2
     ask one-of where-lay with-min [count lobesias-here] [
      sprout-lobesias nb-egg [
        set age 0
        set sex  random 2   ;;male = 0 femmelle = 1
        set heatrequired myheatrequired
        set shape "dot"
        set phase "egg"
        set phaseNumber 1
        set generation mygeneration + 1
        set a 0.335958
        set b 0.195681
        set c 0.197009
        set t [temperature_here] of patch-here
        set unitaDev 0
        set aggre_nb 1
      ]
     ]
;    hatch nb-egg [
;      set age 0
;      set sex  random 2   ;;male = 0 femmelle = 1
;      set shape "dot"
;      set phase "egg"
;      set phaseNumber 1
;      set generation generation + 1
;      set a 0.335958
;      set b 0.195681
;      set c 0.197009
;      set t T?
;      set unitaDev 0
;    ]
    set reproductionFlag FALSE
    set gestationTime  0
    set nb-mating nb-mating + 1
   ]  
  ][
    set gestationTime gestationTime + 1
    if gestationTime > 2 [
      set reproductionFlag TRUE
    ]
  ]
  
end

to-report mating-proba [x]
  let mating? random 100
  let proba-mating 100 / (x + 1)
;  show mating? <= proba-mating
  report mating? <= proba-mating
  
end

to upAdulteAge
  if phase = "adulte" [
    set age age + 1
    if age > ageOfDie [die]
  ]
end

to pheromone ;; lobesia procedure
  if phase = "adulte" AND sex = 1[
      ask patch-here [
        set Ppheromone pheromone_left
      ]
  ]
end

to lowpheromne
  set Ppheromone Ppheromone / downPherom
end

to pheromonesDiff
  diffuse Ppheromone coeff-diff
  diffuse Ppheromone-trap coeff-diff-trap
end

to color-patches
    ifelse mixed-pheromone > 0.001 [
      set pcolor scale-color blue mixed-pheromone 0 100
    ][
    ifelse flower = TRUE [
      set pcolor red
    ][
       set pcolor round (temperature_here * 100)
    ]
     
    ]
    if misedShow [
      set pcolor scale-color blue mixed-pheromone 0 100
    ]
end

to cure-pheromone
  ask traps with [observer = TRUE][
    if any? lobesias in-radius trapdistance with [phase = "adulte" and sex = 1][
     set lobesias-traps count lobesias in-radius trapdistance with [phase = "adulte" and sex = 1]
     ask lobesias in-radius trapdistance with [phase = "adulte" and sex = 1][
      die
      show "pan"
     ]
    ]
  ]
  ask traps [
    ask patch-here [
      set Ppheromone-trap pheromone_left
    ]
  ]
  
  
  pheromonesDiff
  ask patches [
   lowpheromne
   ifelse Ppheromone != 0 OR Ppheromone-trap != 0 [
    let listPhe list Ppheromone Ppheromone-trap
    set mixed-pheromone  max listPhe
   ][
   set mixed-pheromone 0
   ] 
   
  ]
  ;;gere la distance max d'effet des pièges
  ask patches with [outOftrapsInfluence = TRUE][
    set  Ppheromone-trap 0
  ]
end

to integreted_lutte
  if confusion = 1 [
;    if not any? traps with[observer = FALSE] AND (count traps) <= nb-traps - 1[
    if not any? traps with[observer = FALSE][     
       install-trapping
       ask patches with [any? traps in-radius distEffectiveTrap][
         set outOftrapsInfluence FALSE
       ]
    ]
  ]
end

to install-trapping ;;observer context
  let vitipatches patches with [viticole = TRUE]
  
  if rational-traps = 0 [ ;;disposition aléatoire
    create-traps nb-traps [
        set color red
        show "pan patche"
        move-to one-of vitipatches
      ]
  ]
  
  if rational-traps = 1 [ ;;disposition autour de seed aléatoire
    let tappingZone patch-set[]
    ask one-of seeds [
      set tappingZone patches in-radius (radius-hotSpots + bufferTrapping)
    ]
    ask n-of nb-traps  tappingZone [
      if not any? traps-here[
        sprout-traps 1  
      ]
    ]
  ]
  
  if rational-traps = 2 [ ;;disposition organiser à l'échelle de la zone
      let myparcelle patches with [viticole = TRUE]
      let surface-lute count myparcelle
      let surface-trap pi * (radius-trap ^ 2)
      if any? myparcelle with [not any? other traps in-radius radius-trap] [
        while [surface-lute > surface-trap AND any? myparcelle with [not any? other traps in-radius radius-trap]][
          if any? myparcelle with [not any? other traps in-radius radius-trap][
            let goodplaceFotraping one-of myparcelle with [not any? other traps in-radius radius-trap]
            create-traps 1 [
              set color red
              move-to goodplaceFotraping
          ] 
          ]
          set surface-lute count myparcelle
        ]
      ]
  ]
  
  if rational-traps = 3 [ ;;disposition organiser à l'échelle de la PARCELLE
    let list-parcelles remove-duplicates [numParcelle] of patches with [viticole = TRUE]
    foreach list-parcelles [
      let myparcelle patches with [numParcelle = ? AND numParcelle != 0]
      let surface-lute count myparcelle
      let surface-trap pi * (radius-trap ^ 2)
      if any? myparcelle with [not any? other traps with [parcelleID = ?] in-radius radius-trap] [
        while [surface-lute > surface-trap AND any? myparcelle with [not any? other traps with [parcelleID = ?] in-radius radius-trap]][
          if any? myparcelle with [not any? other traps with [parcelleID = ?] in-radius radius-trap][
            let goodplaceFotraping one-of myparcelle with [not any? other traps with [parcelleID = ?] in-radius radius-trap]
            create-traps 1 [
              set color red
              set parcelleID ?
              move-to goodplaceFotraping
            ]
          ]
          set surface-lute count myparcelle
        ]
      ]
    ]
  ]
  
    if rational-traps = 4 [ ;;disposition organiser à l'échelle de la zone mais avec des passagé clandestin
      let myparcelle patches with [viticole = TRUE]
      let surface-lute count myparcelle
      let surface-trap pi * (radius-trap ^ 2)
      if any? myparcelle with [not any? other traps in-radius radius-trap] [
        while [surface-lute > surface-trap AND any? myparcelle with [not any? other traps in-radius radius-trap]][
          if any? myparcelle with [not any? other traps in-radius radius-trap][
            let goodplaceFotraping one-of myparcelle with [not any? other traps in-radius radius-trap]
            create-traps 1 [
              set color red
              move-to goodplaceFotraping
          ] 
          ]
          set surface-lute count myparcelle
        ]
      ]
      ;;on fait la liste des parcelles viticole
      let list-parcelles remove-duplicates [numParcelle] of patches with [viticole = TRUE];;On récupère tout les parcelles
      set list-parcelles sort list-parcelles
      let plotsClandestin n-of nbClandestin list-parcelles
      foreach plotsClandestin [
       ask patches with [numParcelle = ?][
         set clandestin? TRUE
         if any? traps-here[
          ask  traps-here [
           die 
          ]
         ]
       ]
      ]
      set surfaces-non-couverte count patches with[clandestin? = TRUE]
      ask patches with [clandestin? = TRUE][set pcolor red]
      ask seeds [
        let distance_foyer_infection min-one-of patches with[clandestin? = TRUE][distance myself]
        set mindistanceClandestin distance distance_foyer_infection
      ]
       
;      let list-parcelles remove-duplicates [numParcelle] of patches with [viticole = TRUE];;On récupère tout les parcelles
;      set surfaces-non-couverte count patches with [numParcelle = first list-parcelles] ;;on sait qui est la parcelles enlevé
;;    set list-parcelles but-first list-parcelles ;;On enlève une parcelles de la liste
;      if any? myparcelle with [not any? other traps in-radius radius-trap AND numParcelle != first list-parcelles] [
;        while [surface-lute > surface-trap AND any? myparcelle with [not any? other traps in-radius radius-trap AND numParcelle != first list-parcelles]][
;          if any? myparcelle with [not any? other traps in-radius radius-trap AND numParcelle != first list-parcelles][
;            let goodplaceFotraping one-of myparcelle with [not any? other traps in-radius radius-trap AND numParcelle != first list-parcelles]
;            create-traps 1 [
;              set color red
;              move-to goodplaceFotraping
;          ] 
;          ]
;          set surface-lute count myparcelle
;        ]
;      ]
  ]
    
end

to trap-butterflies
  
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                PLOTING ZONE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to up-plot-histogram-generation
  if any? lobesias [
    ;;;FOR plot an histogram of GENERATION
    let tpsgenerationList []
    ask lobesias [
      set tpsgenerationList lput generation tpsgenerationList
    ]
    set generationList tpsgenerationList
    ;;we select a plot in interface 
    set-current-plot "generation"
    ;;pour réaliser un histogram on a besoin d'une liste
    set-plot-x-range 0 ( (max generationList) + 5)
    histogram generationList
    let maxbar modes generationList
    let maxrange length filter [ ? = item 0 maxbar ] generationList
    set-plot-y-range 0 max list 10 maxrange
  ]
end
  
to up-plot-histogram-phase
  if any? lobesias [
    ;;FOR plot histogram of phases
    let tpsPhaseList []
    ask lobesias [
      set tpsPhaseList lput phaseNumber tpsPhaseList
    ]
    set phaseList tpsPhaseList
    ;;we select a plot in interface 
    set-current-plot "Evolution phase"
    ;;pour réaliser un histogram on a besoin d'une liste
    set-plot-x-range 0 ( (max phaseList) + 1)
    histogram phaseList
    let maxbar modes phaseList
    let maxrange length filter [ ? = item 0 maxbar ] phaseList
    set-plot-y-range 0 max list 10 maxrange
  ]
end

to update-stat
  set nbTraps_counted count traps
  set nblobesiasCounted sum[aggre_nb] of lobesias
  set nblobesiaTrappedDay sum [lobesias-traps] of traps
  set nblobesiaTrapped nblobesiaTrapped + nblobesiaTrappedDay
  set nbegg sum[aggre_nb] of lobesias with [phase = "egg"]
  set nblarva sum[aggre_nb] of lobesias with [phase = "larva"]
  set nbcrisalide sum[aggre_nb] of lobesias with [phase = "crisalide"]
  set nbadulte sum[aggre_nb] of lobesias with [phase = "adulte"]
;  set nblobesiasCounted count lobesias
;  set nbegg count lobesias with [phase = "egg"]
;  set nblarva count lobesias with [phase = "larva"]
;  set nbcrisalide count lobesias with [phase = "crisalide"]
;  set nbadulte count lobesias with [phase = "adulte"]
  if any? lobesias with [phase = "adulte"][
    set nbFemellesAdulte count lobesias with[sex = 1 and phase = "adulte"]
    set nbMalesAdulte count lobesias with[sex = 0 and phase = "adulte"]
  ]
  set nbFemellesAdulte count lobesias with[sex = 1 and phase = "adulte"]
  set nbMalesAdulte count lobesias with[sex = 0 and phase = "adulte"]
  if any? lobesias with [sex = 1 and phase = "adulte"] [
    set meanfecondation mean[nb-mating] of lobesias with[sex = 1 and phase = "adulte"]
  ]
  ask patches [
    ifelse any? lobesias-here [
     set occupe TRUE
    ][
     set occupe FALSE
    ]
  ]
  set infestation count patches with [occupe = TRUE]
  if any? lobesias with [phase = "adulte"] [
    set generation-max max[generation] of lobesias with [phase = "adulte"]
  ]
  ;;conservation des population de lobesias dans un vecteur
  set population_vector lput nbadulte population_vector
end

to leastSquare
  foreach realTime [
   if ? = toDay[
     set nbcomptage nbcomptage + 1
     set fisrtComptage first realComptage
     let thisSqrt (fisrtComptage - nblobesiaTrapped) ^ 2
     set realComptage but-first realComptage
     set leastSqrt (leastSqrt * nbcomptage + thisSqrt) / (nbcomptage + 1)
     set nblobesiaTrapped 0  ;;on remet a zero le papier pheromone
   ] 
  ]
  
  ;;fitness avec le temps a atteindre
  foreach realTime [
   if ? = toDay[
     set fisrtticks read-from-string (first tick4comptage)
     set tick4comptage but-first tick4comptage
     ;let thisSqrtT (fisrtticks - ticks) ^ 2
     let thisSqrtT ( 126 - ticks) ^ 2
     set leastSqrt-Time thisSqrtT
   ] 
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
230
10
742
363
-1
-1
2.0
1
10
1
1
1
0
1
1
1
0
250
0
160
0
0
1
ticks
30.0

BUTTON
13
23
86
56
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
91
23
154
56
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

PLOT
905
10
1105
160
generation
generation
nb
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
1110
10
1310
160
Evolution phase
phase
nb
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
905
160
1380
450
population Lobesias
time
pop
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"lobesias" 1.0 0 -7500403 true "" "plot nblobesiasCounted"
"egg" 1.0 0 -2674135 true "" "plot nbegg"
"larva" 1.0 0 -955883 true "" "plot nblarva"
"crisalide" 1.0 0 -6459832 true "" "plot nbcrisalide"
"adulte" 1.0 0 -1184463 true "" "plot nbadulte"

BUTTON
15
60
78
93
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
10
195
182
228
i-visibility-other
i-visibility-other
0
4
3
0.01
1
NIL
HORIZONTAL

TEXTBOX
25
230
175
265
distance à laquelle les moles voies les pheromones des femmelle
8
0.0
1

SLIDER
9
251
181
284
i-coeff-diff
i-coeff-diff
0
1
0.8
0.001
1
NIL
HORIZONTAL

SLIDER
15
485
187
518
i-ageOfDie
i-ageOfDie
8
17
16
1
1
NIL
HORIZONTAL

PLOT
745
10
905
175
generation
time
nb-generation
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot generation-max"

SLIDER
15
375
160
408
i-radius-hotSpots
i-radius-hotSpots
1
20
9
0.1
1
NIL
HORIZONTAL

PLOT
750
500
910
620
infestation
time
nb patches with lobesias
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot infestation"

SLIDER
15
520
187
553
i-nb-egg
i-nb-egg
10
60
10
1
1
NIL
HORIZONTAL

TEXTBOX
20
470
170
488
nb ticks for adulte life
9
0.0
1

TEXTBOX
15
555
165
573
nb egg by fecondation
9
0.0
1

MONITOR
745
180
902
217
nb of lobesias
sum[aggre_nb] of lobesias\n;count lobesias
17
1
9

MONITOR
745
220
852
257
lobesias Femelle
count lobesias with [sex = 1]
17
1
9

MONITOR
745
260
847
305
lobesias male
count lobesias with [sex = 0]
17
1
11

PLOT
1310
10
1510
160
mean fecondation femelle
time
mean FF
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot meanfecondation"

MONITOR
745
305
880
338
fecondation by Femelle adulte
meanfecondation
17
1
8

BUTTON
95
65
177
98
go 129
if ticks < 129 [\ngo\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
15
585
172
645
i-confusion
1
1
0
Number

TEXTBOX
30
650
180
668
0 or 1 For FALSE or TRUE
9
0.0
1

INPUTBOX
15
315
140
375
i-lobesias-HotSpot
1
1
0
Number

TEXTBOX
25
300
175
318
0 or 1 For FALSE or TRUE
8
0.0
1

INPUTBOX
9
131
114
191
i-NBlobesias
50
1
0
Number

PLOT
920
460
1235
610
F vs M adultes
time
individus
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"femelles" 1.0 0 -4699768 true "" "plot nbFemellesAdulte"
"Males" 1.0 0 -13345367 true "" "plot nbMalesAdulte"

PLOT
220
555
450
740
Temperature
time
temperature
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot T?"

MONITOR
750
340
830
377
NIL
toDay
17
1
9

TEXTBOX
835
345
985
363
date of the tick
8
0.0
1

BUTTON
120
100
202
133
go 200
if ticks < 200 [\ngo\n]
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
750
415
890
448
i-rational-traps
i-rational-traps
0
5
4
1
1
NIL
HORIZONTAL

PLOT
460
555
660
705
nombre d'adulte
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
"default" 1.0 0 -4079321 true "" "plot nbadulte"

TEXTBOX
690
650
840
668
1 patch = 2 metres
9
0.0
1

TEXTBOX
1405
185
1555
230
1 accouplement = 3 jours de ponte
12
0.0
1

SLIDER
15
415
192
448
i-pheromone_left
i-pheromone_left
0
1000
100
1
1
NIL
HORIZONTAL

MONITOR
1395
278
1464
323
NIL
leastSqrt
2
1
11

MONITOR
1395
328
1503
373
NIL
leastSqrt-Time
2
1
11

MONITOR
1390
410
1517
455
NIL
nblobesiaTrapped
0
1
11

SWITCH
1245
475
1382
508
misedShow
misedShow
0
1
-1000

SLIDER
190
140
223
286
i-angle-flight
i-angle-flight
0
360
170
10
1
NIL
VERTICAL

INPUTBOX
695
385
745
445
i-radius-trap
10
1
0
Number

INPUTBOX
695
460
745
520
i-distanceCand
200
1
0
Number

TEXTBOX
755
450
920
501
* radius est la distance entre les pièges\n* nb traps le nombre de pièges dans le modèle\n* rationnal trap 0 = aléatoire 1= autour de seed 2 organiser a l'échelle du BV 3 = organiser parcelle 4= passager clandestin dans une situation rt2
7
0.0
1

INPUTBOX
610
385
690
445
i-nbClandestin
5
1
0
Number

MONITOR
585
450
690
487
NIL
mindistanceClandestin
1
1
9

TEXTBOX
1410
520
1500
550
si changement climatique is 1 =  + 0.5°C
8
0.0
1

INPUTBOX
1250
520
1407
580
climatChange_i
0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

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
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment-confusion-effect2" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>nblobesiasCounted</metric>
    <metric>nbegg</metric>
    <metric>nblarva</metric>
    <metric>nbcrisalide</metric>
    <metric>nbadulte</metric>
    <metric>generation-max</metric>
    <metric>infestation</metric>
    <enumeratedValueSet variable="i-lobesias-HotSpot">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i-NBlobesias">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="i-coeff-diff" first="0.2" step="0.2" last="1"/>
    <enumeratedValueSet variable="i-ageOfDie">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="i-visibility-other" first="0" step="2" last="10"/>
    <enumeratedValueSet variable="i-radius-hotSpots">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i-confusion">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-confusion-effect2-true" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="150"/>
    <metric>nblobesiasCounted</metric>
    <metric>nbegg</metric>
    <metric>nblarva</metric>
    <metric>nbcrisalide</metric>
    <metric>nbadulte</metric>
    <metric>generation-max</metric>
    <metric>infestation</metric>
    <enumeratedValueSet variable="i-lobesias-HotSpot">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i-NBlobesias">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="i-coeff-diff" first="0.2" step="0.2" last="1"/>
    <enumeratedValueSet variable="i-ageOfDie">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="i-visibility-other" first="0" step="2" last="10"/>
    <enumeratedValueSet variable="i-radius-hotSpots">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i-confusion">
      <value value="true"/>
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
