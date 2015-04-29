;;Autor :  Delay E. (Université de Limoges) en s'inspirant de discution avec Bourgoin J. (CIRAD) et Nicolas Beccu (CNRS)
;;2 septembre intégrer les partTime 

extensions [rserve]

breed [farmers farmer] ;pour ne pas avoir turtles
breed [cooperatives cooperative]
breed [locality] ;pour un seul village

globals[
  gini-index-reserve
  lorenz-points
  materiel_vinif
  taxe_plot
  prixkg
  rendement_G
  memory_size     ;;nombe d'année que le viticulteur prend en compte pour prendre une décision
  memory_size_coop ;;nombre d'année que la coop prend en compte pour prendre une décision sur la redéfinition de son volume de trvail
  coef_Slope
  coef_dist
  vol_mini_coop ;; volume minimum que la coop doit brasser pour exister
  randomValue_indiv ;;valeur de random pour la calcul du prix des individuels prix + random - random
  Seuil_out_coop  ;;seuil pour sortir de la coop une fois la vérif du capital effectué
  resMaxRisque    ;; est un float et definit la valeur max de resistance au risque
  major_indiv  ;; la majoration du prix coop pour que la moyenne de ce que gagne les indiv soit sup à ce que gagne les coop
  pct_capacity_coop ;; valeur de capaciter sup en pct de la coopératve
  rendement_raisin_hecto ;;rendement en en kg d'un hecto litre de vendange
  prop_attendu  ;; proportion de viticulteur qui sont coopérateur a l'initialisation
  pct_augm_capacity ;; % d'augmentation de la capcité d'acceuil si le volume max est atteint
  remuneration_viti ;; le cout du viticulteur
  random_alpha?  ;;pour choisir si la riscophilie des viti se fait au hazard ou non
  nb_coop_contacts ;; nombre de viticulteur coopérateur que les viticulteur non coop vont intéroger pour savoir s'ils re-rentre
  scenarii         ;; definit le scenario appliquer au modele
  espace_in_patches ;; conte le nombre de patche à l'initialisation
  
  ;;pour les stats de sortie de modèle
  prop_farmer_in_hill ;; nombre de farmer en montagne
  nb_coop          ;; nombre absolut de coopérateur dans la simualtion
  prop_cooperateur ;; proportion de cooprérateur
  prop_cooperateur_in_hill ;; proportion de cooperateur en montagne
  med_SmV ;; la mediane des valeur de smv qui génère le comportement des coopérateur à prendre des risques
  mean_SmV ;; moyenne des valeur de smv 
  prop_viti_majSeuil ;; la proportion de viticulteur en activité risquophile (qui a un seuil de risque sup au seuil du monde)
  vitipatches ;; le nombre de patches cultivé
  med_slope          ;; la pente mediane des parcelles cultivé
  ruined_farmers     ;; nombre de viticulteurs ruiné
  Viticulteurs       ;; nombre de viticulteur en actvité
  sum_production_capacity ;;capaciter de production de la coop
  sum_production_kg  ;; capaciter de production du systemes
  sum_production_kg_coop ;;production en coop
  nb_indiv ;; nombre de viticulteur en individuel
  nb_coop_in_game
  init_farmers ;; nombre de fermier à l'initialisation
  gini-index-all  ;; inégalité sur la population initial de vitis
  meanSlope_RV    ;; la pente moyenne des viticulteurs ruinés
  meanSlope_AL    ;; la pente moyenne des viticulteur A LIVE
  bilan_coop_bonus_malus ;;bilan financier de la coop sur les bonus malus
  nb_plots_cooperateur ;; moyenne du nombre de parcelles pour les coopérateur
  nb_plots_indep       ;; moyenne du nombre de parcelles pour les indép
  capital_cooperateur  ;; moyenne des capitaux des cooperateurs
  capital_indep         ;; moyenne des capitaux des independants
  slope_coop             ;; moyenne de la pente des parcelles des viticulteurs en coop
  slope_indep            ;; moyenne de la pente des parcelles des viticulteurs indep
  
  lorenz-points-foncier
  ]


patches-own [ ;variables pas globales mais attribuées au agents
  alti
  coop ;; who is my coop
  Mzone ;zone de montagne pour l'aide gouvernementale
  owner
  annual_bonus_coop
  rendement_parcelles ;; le rendement des parcelles en hecto est charger depuis une image png
  annual_malus_coop
  rendement
  annualCost
  sold
  price
  init ;;flag à l'initialisation
  patch_potCost ;;stok in variable recalculer a chaque fois qu'un viti veux acheter une parcelles
  ]

farmers-own [
  capital
  capital_Foncier
  capital_total ;foncier + eco
  prix_payer
  myCooperative
  myplots
  cooperateur
  would_like_coop ;;boleen qui dit que je voudrait entrer mais ya pas la place
  meanSlope  ;; pente moyenne sur toutes les parcelles du viti
  employer  ;;combien d'employer à besoin le viti
  partTime ;; quelle proportion de son temps est consacrer à la viticulture en pct
  capital_list ;; liste des valeur du capital
  list_slope  ;;liste des pentes des viticulteurs
  my_time ;; liste des valeur de ticks prise en même temps que capital_list
  memory  ;; valeur résultant de la regression linéaire et qui va permettre de calculer si le viti va aller en coop ou pas
  myAlpha ;; valeur qui définit sa résistance au risque 
  mySmV   ;; pour stocker les valeurs du reporter
  ]

locality-own [
  LandReserve
  ]

cooperatives-own[
  capital
  coopViticulteur
  bonus-totalCost ; dimine les cout de production des farmers
  malus-totalGain ; diminue les gains par un rachat moins chere du produit
  production_surface ; pour quelle volume la coop est construite
  production_kg ;; le volume en kg de la coop
  old_production_kg ;;liste des anciennes productions
  production_capacity ;;la production pour laquelle est penser la coop
  my_time_coop  ;temps de la coopérative pour faire sa reg linéaire
  memory_strategie_coop ;; variable qui va définir la stratégie de la coop  si negatif réduction des volumes si positif augmentation
  ]

;;;;;;;;;;;;;;;;;;;;;;
;; SETUP
;;;;;;;;;;;;;;;;;;;;;;
to setupGlobal
  set materiel_vinif 10000 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A ajuster
  set pct_capacity_coop 20
  set coef_Slope 50 ;;normalement 80
  set coef_dist 10  ;;normalement 10
  set major_indiv 0.50  ;;variation du prix par rapport au prix fixe
  set pct_augm_capacity 5
  set resMaxRisque 5
  set taxe_plot 200  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A ajuster
  set rendement_G 0 ;((random 10) + 1)
  set rendement_raisin_hecto 125 ;;rendement en kg d'un hecto de vendange sachant qu'il y à 35 hecto à l'hectar
;  set rendement_parcelles 35  ;;rendement par parcelle en hectolitre par hector et une parcelle 1 hectar
  set remuneration_viti 20000
  set nb_coop_contacts 3
end

to setupVariables 
  set vol_mini_coop vol_mini_coop_i
  set scenarii scenarii_i
  set random_alpha? random_alpha_i?
  set prop_attendu prop_attendu_i
  set Seuil_out_coop 1 * 10 ^ Seuil_out_coop_i
;  set Seuil_out_coop Seuil_out_coop_i
  set prixkg prix_kg
  set memory_size memory_size_i ;; le nombre d'année (itération) que le viticulteur prend en compte pour choisir sont orientations économique (coop ou pas coop)
  set memory_size_coop memory_size_coop_i
end

to setup
  clear-all
  ;;close connection to Rserve if one
  ;;connection to Rserve
  rserve:init 6311 "localhost"
  rserve:clear
  
  import-pcolors "rendement.png" ;creation de l'envir avec le fichier image dans le même repertoire, stock les valeurs de l'image
  ask patches [
    ifelse pcolor >= 0[
      set rendement_parcelles 20
    ][
      set rendement_parcelles 45
    ]
  ]
  
  import-pcolors "alti.png" ;creation de l'envir avec le fichier image dans le même repertoire, stock les valeurs de l'image
  let conterColor 2
  setupVariables
  setupGlobal
  
 ask patches [
   set alti (pcolor * 50) / 10
   set pcolor scale-color red alti 0 50
   ifelse alti >= 5 [set Mzone 1] [set Mzone 0]
   set sold False
   set price FrontPrice
   set owner NOBODY
   ]

 set-default-shape farmers "person"
 set-default-shape locality "house"
 set-default-shape cooperatives "pentagon"

 create-locality 1 [
   setxy 27 0
   set size 5
   set LandReserve (patch-set)
 ]
 
 ;;creation des viticulteurs
 create-farmers NbFarmer [
   setxy random-pxcor random-pycor
   set size 3
   set color conterColor
   set conterColor ifelse-value (conterColor < 140) [conterColor + 10] [conterColor - 139]
   set capital InitialCapital ;nom du slider
   set cooperateur FALSE
;   set partTime 1
   set capital_list []
   set my_time []
 ]

 ;;creation d'UNE PARCELLE par les viticulteurs
 ask farmers [
;   set myplots n-of 10 patches in-radius 5 with [owner = NOBODY]
   ;;creation seed
   set myPlots (patch-set one-of patches in-radius 5 with [owner = NOBODY]) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   updateEmployer
   while [employer <= 1] [
    let newplot one-of patches in-radius 5 with [owner = NOBODY]
    set myPlots (patch-set myPlots newplot)
    updateEmployer
   ]
   ask myplots [ 
     set pcolor [color] of myself
     set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
;     calculRendement
;     calculCost
   ]
   set capital_Foncier count myPlots * reserveSellPrice
   set capital_total capital_Foncier + capital
   updateEmployer
  ]
 
 ;;creation de la coopérative
 create-cooperatives nb_coop_init [
   setxy random-xcor random-ycor
   set capital coop_capital
   set old_production_kg []
   set my_time_coop []
   ;let partVariable random-float 1
   let partVariable 0
   set bonus-totalCost bonus + partVariable
   set malus-totalGain malus + partVariable
   set size exp(bonus-totalCost)
   let freeviti farmers with [cooperateur = FALSE]
   ;;on veux un proportion fixe de coop
   let nb_init_viti round ((prop_attendu * (count freeviti)) / 100)
  
   set coopViticulteur n-of nb_init_viti farmers with [cooperateur = FALSE]
   let double_actifs farmers with [employer < 1]
   set coopViticulteur ( turtle-set coopViticulteur double_actifs)
   let whoAMI who
   ask coopViticulteur [
     set cooperateur TRUE
;     set partTime (random-float 1) + 0.01
     let mycooperative_who [who] of myself
     set mycooperative cooperatives with [who = mycooperative_who]
     ask myplots [
       set coop whoAMI
     ] 
   ]
    
;   let freepatches count patches with [owner != 0 and coop = 0]
;   set coopPlots n-of (random freepatches + 1) patches with [owner != 0 and coop = 0]
;   ask coopPlots [
;    set coop [who] of myself 
;   ]
 ]
 

 
 ask cooperatives [
  calcul_coop_size
  set production_capacity production_kg + ((pct_capacity_coop * production_kg) / 100) ;; initialiser comme X pct de du volume initiale
 ]
 
 ifelse random_alpha? [
   ask farmers [
     set myAlpha (random-float resMaxRisque) + 0.1
     set size myAlpha
   ]
 ][
   ask farmers [set myAlpha 1]
   ask n-of (count farmers / 2) farmers [
     set myAlpha resMaxRisque
     set size myAlpha
   ]
 ]
 ask patches [
  calculCost 
  calculRendement
 ]
 
 update_coop
 toseecoop
 set espace_in_patches count patches
 set init_farmers count farmers
 update-lorenz-and-gini
 reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;
;; GO
;;;;;;;;;;;;;;;;;;;;;;

to go
  let conterColor 2
  setupVariables
  maj_simulation_scenario  
  ;set rendement_G ((random 10) + 1)
  
  update_coop
  ask farmers with [color != white][
    cooperation?
    sellLand
    updateCapital
    stat_R
    applied_viti-strat
    buyLand
    MO
    ]
  ask cooperatives [
   calcul_coop_size
   calcul_coop_strategie
   applied_coop_strategie
   coop_die?
  ]
  
  if not any? farmers with [color != white][
   stop 
  ]
  stat_1
  notAnyCoop?
  toseecoop
  
  updatePlot
  update-lorenz-and-gini
  
  
tick  
end


;;;;;;;;;;;;;;;;;;;;;
;; PROCEDURES FOR GO
;;;;;;;;;;;;;;;;;;;;;
to calculRendement ;farmer context, myplots context
   set rendement (rendement_parcelles * rendement_raisin_hecto +  rendement_G) ;35hectolitre/ha * 140 kilo de raisin par hecto = rendement en kg
end

to calculCost ;farmer context, myplots context
    let dist distance one-of locality
    set annualCost cout_ha + (coef_Slope * alti) + (coef_dist * dist)
end


to update_coop
  if any? cooperatives [
      ask patches with [coop != 0][
        let mycoop cooperatives with [who = [coop] of myself]
        set annual_bonus_coop (first [bonus-totalCost] of mycoop) *  rendement_parcelles * rendement_raisin_hecto ;;donne le bonus à la parcelles le bonus de l'interface est pensé au kg de raisin
        set annual_malus_coop (first [malus-totalGain] of mycoop) * rendement_parcelles * rendement_raisin_hecto
      ]
  ]

  ask patches with [coop = 0][
    set annual_bonus_coop 0
    set annual_malus_coop 0
  ]
end

to toseecoop
  ask links [die]
  if see_coop = TRUE [
    ask cooperatives [
      ask coopViticulteur with [color != white][ 
        create-link-to myself
      ]
    ]
  ]
end

to cooperation? ;;farmers context
  ;;est ce que je suis coopérateur?
  ifelse cooperateur = TRUE AND color != white [
   ; JE SUIS COOPERATEUR
   ;Je veux sortir de la coopérative
   ;parce que je suis riche
   let myplots? count myplots
   let totalCost sum [annualCost] of myplots
   if length capital_list >= memory_size AND employer >= 1[
     if capital >= myplots? * taxe_plot + materiel_vinif + totalCost[
       ;;est parce que ne suis pas un trouillard
       set mySmV S_m_V myAlpha
       if mySmV > Seuil_out_coop [
         set cooperateur FALSE
         set would_like_coop FALSE
         ask cooperatives with [who = [myCooperative] of myself][
           set coopViticulteur farmers with [cooperateur = TRUE]
         ]
         set myCooperative 0
         set capital  capital - (myplots? * taxe_plot + materiel_vinif + totalCost)
         set capital_list []
         set my_time []
         ask myPlots [ ;;pour que le plots ne touche plus les bonus
          set coop 0 
         ]
       ]
     ]
   ]
  ][
  ; JE NE SUIS PAS COOPERATEUR
  ; JE veux rentrer ?
  if myPlots != 0 AND color != white[
     if count myPlots > 0 [
     let myprouction_kg  (count myPlots) * rendement_parcelles * rendement_raisin_hecto
     if any? cooperatives[
       let chooseCoop one-of cooperatives
       ;;evaluer les revenu de coopérateurs croisé dans l'année
;       let list_memory_coop []
;       let mean_memory_orther 0
;       if nb_coop > nb_coop_contacts [
;        ask n-of nb_coop_contacts farmers with [cooperateur = TRUE][
;         set list_memory_coop lput memory list_memory_coop
;        ]
;       ]
;       if length list_memory_coop > 0 [
;         set mean_memory_orther mean list_memory_coop
;       ]
       if memory < 0[
;       if memory < 0 OR  mean_memory_orther > memory [ ;;si la memoire des autres coop est supérieur à la mienne je veux rentrer
         ifelse [production_capacity] of chooseCoop >= [production_kg] of chooseCoop + myprouction_kg [;;comenter
;       ;je deviens coopérateur
           set cooperateur TRUE
           set mycooperative [who] of cooperatives with [who = [who] of chooseCoop]
           ask myplots [ ;;je dit a mes plots que la coop est celle-la
             set coop first [mycooperative] of myself
           ] 
           ask chooseCoop [
             set coopViticulteur farmers with [cooperateur = TRUE]
           ]
         ][;;S'il n'y a pas la place dans la coop je fait une demande d'acceptation
         set would_like_coop TRUE
         set mycooperative cooperatives with [who = [who] of chooseCoop]
         ]
       ]
     ] 
    ] 
   ]
  ]
end

to-report S_m_V [#alpha] 
  let m mean capital_list
  let V variance capital_list
  ifelse m > 0 [
    report #alpha * (V + log m 10 ) 
  ][
  report 0
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
           set LandReserve (patch-set LandReserve patches with[owner = -1])
         ]
         set Capital Capital + reserveBuyPrice ;prix auquel la reserve achète les parcelles 
       ]
     ]
     set capital_Foncier count myPlots * reserveSellPrice
     set capital_total capital_Foncier + Capital 
end


to updateCapital ;instance of farmer (parceque on est dans ask farmers)
  
  ;;DEFINITION DU PRIX PAYER AU KG DE RAISIN
  ifelse cooperateur = TRUE  AND any? cooperatives[
   set prix_payer  prixkg
  ][
   set prix_payer random-normal prixkg major_indiv
   if prix_payer < 0 [
     set prix_payer 0
   ]
  ]
  
  ;; DEFINITION DES CHARGES DE PERSONNE MAIN D'OEUVRE + SALAIRE DE CASA
  let MOpayante employer - 1 ;on a calculer avant le nombre d'employer dont à besoin chaque exploitation
  
  if MOpayante < 0 [ set MOpayante 0]
  let VitiSalaire 0
  set VitiSalaire partTime * remuneration_viti
  
  let mainOeuvre MOpayante * remuneration_viti ;; un salarier cout 20000 euro par ans
  let salaireMO mainOeuvre + VitiSalaire ;;prend en charge le cout du viticulteur
  
  let howIsMyCoop cooperatives with [who = [myCooperative] of myself]
  let totalCost sum [annualCost] of myplots - sum [annual_bonus_coop] of myPlots + salaireMO
  let totalGain (sum [rendement] of myplots) * prix_payer -  sum [annual_malus_coop] of myplots
  set Capital Capital - totalCost + totalGain
  
end

to buyLand ;instance of farmer (parceque on est dans ask farmers)
  let totalCost sum [annualCost] of myplots
  if memory > 0 AND Capital > totalCost + (employer * remuneration_viti)[ ;;va acheter s'il est capable d'entretenir ce qu'il a déjà et si il est dans une bonne phase économique
    
  ;let potplot patches in-radius 2 with [(owner = 0) or (owner = -1)]
  let potplotfinal (patch-set) ;collection de patchs pot
  ask myplots [
    let potplot patches in-radius 2 with [owner = nobody] ;critère de selection, recherche de voisins potentiels
    set potplotfinal (patch-set potplotfinal potplot) ;renseigne la collection
    set potplotfinal (patch-set potplotfinal [landreserve] of locality)
    ]
  
  if any? potplotfinal [
    let potCost [];cree une variable vide
    ask potplotfinal [
      set patch_potCost price + 10 * annualCost ;prise en compte de 10 ans
      set potCost lput patch_potCost potCost
      ]
    let ordered sort-by > potCost
    let min10ordered []
    ifelse length ordered >= 5 [
      set min10ordered sublist ordered ((length ordered) - 5)  length ordered
    ][
      set min10ordered ordered
    ]
    let shuffle10n shuffle min10ordered
    let onCost first shuffle10n
    
    let newplot one-of potplotfinal with [patch_potCost = onCost]
    if Capital > totalCost + onCost [
      ask newplot [
       set pcolor [color] of myself
       set owner [who] of myself ;affecte le numéro du farmer à ses parcelles
;       calculRendement
;       calculCost
       ]
     
     ask locality [
      set landreserve patches with [owner = -1] 
     ]
     set myplots (patch-set myplots newplot)
     set Capital Capital - [price] of newplot ;slider
     
      ]
    ]
  ]
  
  
  updateEmployer ;;une procedure pour mettre a jour le champ employer

end 



to MO ;farmer context
  if not any? myplots [
;    die
    set capital 0
    set color  white
    if cooperateur = TRUE [
      set cooperateur FALSE
      ask cooperatives with [who = [myCooperative] of myself][
        set coopViticulteur farmers with [cooperateur = TRUE]
      ]
    ]
    set myCooperative 0
    ask links with [end1 = farmer [who] of myself][die]
  ]
  if capital_total < 0 [
    set capital 0
    set color  white
    if cooperateur = TRUE [
      set cooperateur FALSE
      ask cooperatives with [who = [myCooperative] of myself] [
        set coopViticulteur farmers with [cooperateur = TRUE]
      ]
    ]
    ask myPlots [
      set sold True
      set owner -1 ;identifiant de locality
      set price reserveSellPrice ;prix auquel la reserve vend les parcelles
      set pcolor white
    ]
    set myplots myplots with [not sold]
    ask Locality [
      set LandReserve (patch-set LandReserve patches with[owner = -1])
    ]
    
    set myCooperative 0
    ask links with [end1 = farmer [who] of myself][die]
  ]
end
  

to updateEmployer ;vitis context
  
  if count myplots > 0[
    set meanSlope (mean [alti] of myPlots) ;la pente est en degret
    set list_slope  [alti] of myPlots
    let list_prop_temps []
    foreach list_slope [
      let this_slope ?
     if this_slope <= 5.5 [
       set this_slope 5.5
     ]
     let x ((1 / ((tan this_slope) * 100)) * 100) ;; donne la surface max qui peut être cultivé par un Homme par ans
     let proportion_temps (1 * 100) / x   ;; comme on sais que cette serface est 1 hectar et qu'on veut le ramener à un pct de temps de travail 
     set list_prop_temps lput proportion_temps list_prop_temps
    ]
    set employer ((sum list_prop_temps) / 100) ;;ici on divise par 100 pour ramener le pct d'occupation sous forme d'employer
  ]
;  if any? myplots [
;    set meanSlope (mean [alti] of myPlots) ;la pente est en degret
;;    let exSlope 0
;    let nbmyplots count myPlots
;    let wk 0 
;    ifelse meanSlope <= 0 [
;     set wk (nbmyplots * 10) / 100 ;;si on est dans le plat on peut cultiver seul 10 parcelles pour occuper 100% de son temps
;    ][
;     let exSlope meanSlope * nbmyplots ;;1 ha à 0 degret = 10% du temps de travail donc 10% * (pente_moyenne * nombre de parcelle)
;     set size (exSlope / 100) * 10
;     set wk 1 /(exSlope / 100)
;    ]
;    set employer wk ; calcule le nombre d'homme dont l'exploitation a besoin y compris l'exploitant
;  ]
;  if any? myplots [
;    set meanSlope (mean [alti] of myPlots) ;la pente est en degret
;    let exSlope 0
;    let nbmyplots count myPlots
;    let wk 0 
;    ifelse meanSlope = 0 [
;     set wk (nbmyplots * 10) / 100 ;;si on est dans le plat on peut cultiver seul 10 parcelles pour occuper 100% de son temps
;    ][
;     set exSlope 10 * (meanSlope * nbmyplots) ;;0degret = 10% du temps de travail donc 10% * (pente_moyenne * nombre de parcelle)
;     set wk exSlope / 100
;    ]
;    set employer wk ; calcule le nombre d'homme dont l'exploitation a besoin y compris l'exploitant
;  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             COOPERATIVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calcul_coop_size ;; coopérative context
  let list_coop_plot []
  ask coopViticulteur [
   set list_coop_plot lput (count myPlots) list_coop_plot 
  ] 
  set production_surface sum list_coop_plot 
  let list_rendement_parcellR []
  ask coopViticulteur [
     ask myplots [
      set  list_rendement_parcellR lput rendement_parcelles list_rendement_parcellR
     ]
  ]
  let production_in_hecto sum list_rendement_parcellR
  set production_kg production_in_hecto * rendement_raisin_hecto ;;35hecto/ha et 105kg par hecto
  let bonus_distrubue production_kg * bonus-totalCost
  let malus_recolte production_kg * malus-totalGain
  set bilan_coop_bonus_malus malus_recolte - bonus_distrubue

end

to calcul_coop_strategie ;;coop context
  ifelse length old_production_kg <= memory_size_coop[
    set old_production_kg lput production_kg old_production_kg
    set my_time_coop lput ticks my_time_coop
  ][
    set old_production_kg lput production_kg old_production_kg
    set old_production_kg remove-item 0 old_production_kg
    
    set my_time_coop lput ticks my_time_coop
    set my_time_coop remove-item 0 my_time_coop
  ]
  ifelse length old_production_kg >= memory_size_coop[
    
    ;; send the memory to R
    rserve:put "yc" old_production_kg
    rserve:put "xc" my_time_coop
    
    ;      (rserve:putagent "farmers" self "capital_list" "my_time")
    ;      show rserve:get "farmers$capital_list"
    
    ;; calculate correlation between weight and height
    rserve:eval "fmc <- lm(yc ~ xc)"
    set memory_strategie_coop rserve:get "fmc$coefficient[2]"
    ;     let co_dir rserve:get "co_dir"
    ;     show co_dir
  ][
    set memory_strategie_coop 0
  ]
end

to applied_coop_strategie ;;coop context
  let wante_enter farmers with [would_like_coop = TRUE AND cooperateur = FALSE]
  ;; si les volumes de vendange apporter diminue alors memory_strategie_coop < 0 = REGRESSION
  if memory_strategie_coop < 0 AND not any? wante_enter [
    set production_capacity production_capacity - ((pct_capacity_coop * (production_capacity - production_kg)) / 100)
    if production_capacity <= 0 [
      set production_capacity 0
    ]
  ]
      
  if memory_strategie_coop > 0 OR any? wante_enter [
    let list_coop_plot_add []
    ask wante_enter [
      set list_coop_plot_add lput (count myPlots) list_coop_plot_add 
    ]
    let production_surface_add sum list_coop_plot_add 
    let production_kg_add production_surface_add * rendement_parcelles * rendement_raisin_hecto ;;25hecto/ha et 105kg par hecto
    set production_capacity production_kg + ((pct_capacity_coop * production_kg) / 100) + production_kg_add
  ]
;  [
;  ;; Si les volumes apporté augmentes  
;  ;;si la capacité de production de la coop est inférieur aux volumes que les viticulteurs veulent faire entrer
;;    if production_capacity <= production_kg [
;      ;;on augmente la capacité de production de la coop de 5%
;;      set production_capacity production_kg + ((pct_capacity_coop * production_kg) / 100)
;      set production_capacity production_kg * 2
;;    ] 
;;    ;;si la capcité de production est superieur aux volumes produite on ne fait rien
;;;      set production_capacity production_capacity + ((production_capacity - production_kg) / 2)
;    
;  ]
end
  
to coop_die? ;;cooperative context
  if count coopViticulteur <= 0 [
    die
  ]
  if production_kg < vol_mini_coop [
;   ask farmers with[partTime < 1][
;     die 
;    ]
;   ask farmers with[partTime >= 1][
;     ifelse capital >= materiel_vinif [
;       set capital capital - materiel_vinif 
;     ][
;       MO
;     ]
;    ]
    ask farmers with[color != white][
     ifelse capital >= materiel_vinif [
       set capital capital - materiel_vinif 
     ][
       MO
     ]
    ]
    
    ask coopViticulteur [
      set myCooperative 0
      set cooperateur FALSE
    ]
   die 
  ]
  
end

to notAnyCoop? ;;observateur context
    ;; s'il n'y a plus de coopératives
  if not any? cooperatives [
    ask farmers with [employer < 1][
     killcoop_partTime 
    ]
    ask farmers with[color != white AND employer >= 1][
     ifelse capital >= materiel_vinif [
       set capital capital - materiel_vinif 
     ][
       MO
     ]
    ]
  ]
end

to killcoop_partTime
   if count cooperatives <= 0 [
    ask myPlots [
      set sold True
      set owner -1 ;identifiant de locality
      set price reserveSellPrice ;prix auquel la reserve vend les parcelles
      set pcolor white
    ]
    set cooperateur FALSE
    set employer 0
    set myplots myplots with [not sold]
    ask Locality [
      set LandReserve (patch-set LandReserve patches with[owner = -1])
    ]
    set myCooperative 0
    ask links with [end1 = farmer [who] of myself][die]
  ]
end

to maj_simulation_scenario
  if scenarii = 1 [ ;;scenario 1 la coopérative disparait
    if ticks = 30 [
     ask one-of cooperatives [die] 
    ]
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
  set-current-plot "price"
  ask farmers [
    set-plot-pen-color color
    plotxy ticks prix_payer
    ]
  set-current-plot "capacité de production"
  ask cooperatives[
    set-plot-pen-color green
    plotxy ticks production_capacity
    set-plot-pen-color red
    plotxy ticks production_kg
  ]
  
  set-current-plot "coop_stratégie"
  ask cooperatives[
    set-plot-pen-color color
    plotxy ticks memory_strategie_coop
  ]
  set-current-plot "median et mean SmV"
  ask farmers with [color != white][
    set-plot-pen-color color
    plotxy ticks mySmV 
  ]
end

to update-lorenz-and-gini
  let sorted-wealths sort [Capital] of farmers with [color != white]
  let total-wealth sum sorted-wealths
  let wealth-sum-so-far 0
  let index 0
  set gini-index-reserve 0
  set lorenz-points [] ;pour stocker un vecteur, lupt rajoute dans la liste
  let nb_true_farmers count farmers with [color != white]
  repeat nb_true_farmers[
    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
    set index (index + 1)
    set gini-index-reserve gini-index-reserve + (index / nb_true_farmers) - (wealth-sum-so-far / total-wealth)
  ]
   set gini-index-reserve (gini-index-reserve / nb_true_farmers) / 0.5
   
   let sorted-wealths-f sort [Capital] of farmers
   let total-wealth-f sum sorted-wealths-f
   let wealth-sum-so-far-f 0
   let index-f 0
   set gini-index-all 0
   set lorenz-points-foncier [] ;pour stocker un vecteur, lupt rajoute dans la liste
;   let nb_true_farmers count farmers with [color != white]
   repeat count farmers[
     set wealth-sum-so-far-f (wealth-sum-so-far-f + item index-f sorted-wealths-f)
     set lorenz-points-foncier lput ((wealth-sum-so-far-f / total-wealth-f) * 100) lorenz-points-foncier
     set index-f (index-f + 1)
     set gini-index-all gini-index-all + (index-f / count farmers) - (wealth-sum-so-far-f / total-wealth-f)
   ]
   set gini-index-all (gini-index-all / count farmers) / 0.5

;  let sorted-wealths sort [capital_Foncier] of farmers
;  let total-wealth sum sorted-wealths
;  let wealth-sum-so-far 0
;  let index 0
;  set gini-index-reserve 0
;  set lorenz-points [] ;pour stocker un vecteur, lupt rajoute dans la liste
;  repeat count farmers[
;    set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
;    set lorenz-points lput ((wealth-sum-so-far / total-wealth) * 100) lorenz-points
;    set index (index + 1)
;    set gini-index-reserve gini-index-reserve + (index / count farmers) - (wealth-sum-so-far / total-wealth)
;  ]
;   set gini-index-reserve (gini-index-reserve / count farmers) / 0.5
end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STAT 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to stat_1
  if any? farmers with [color != white][
    if any? farmers with[meanSlope > 10 AND color != white][
      set prop_farmer_in_hill ((count farmers with[meanSlope > 10 AND color != white]) / (count farmers - (count Farmers with [not any? myplots])))
    ]
    
    set nb_coop (count farmers with[cooperateur = TRUE AND color != white])
    set prop_cooperateur ((count farmers with[cooperateur = TRUE AND color != white]) / (count farmers - (count Farmers with [not any? myplots])))
    set meanSlope_AL mean[meanSlope]of farmers with [color != white]
    let list_plot_indi []
    let list_capital_ind []
    let list_slop_ind []
    ask farmers with [cooperateur != TRUE AND color != white][
        let countPlots count myPlots
        set list_plot_indi lput countPlots list_plot_indi
        set list_capital_ind lput capital list_capital_ind
        set list_slop_ind lput alti list_slop_ind
      ]
      set nb_plots_indep mean list_plot_indi
      set capital_indep mean list_capital_ind
      set slope_indep mean list_slop_ind
      
  ]
  
  
  if any? Farmers with [cooperateur = TRUE][
      set prop_cooperateur_in_hill ((count farmers with[meanSlope > 10 AND color != white AND cooperateur = TRUE]) / (count farmers with [cooperateur = TRUE AND color != white]))
      let list_plot_coop []
      let list_capital_coop []
      let list_slope_coop []
      ask farmers with [cooperateur = TRUE AND color != white][
        let countPlots count myPlots
        set list_plot_coop lput countPlots list_plot_coop
        set list_capital_coop lput capital list_capital_coop
        set list_slope_coop lput alti list_slope_coop
      ]
      set nb_plots_cooperateur mean list_plot_coop
      set capital_cooperateur mean list_capital_coop
      set slope_coop mean list_slope_coop
  ]
  
  if any? patches with [owner != -1 AND owner != NOBODY][
    set med_slope median[alti] of patches with [owner != -1 AND owner != NOBODY]
    set vitipatches count patches with [pcolor != white AND owner != NOBODY]
  ]
  
  set med_SmV median[mySmV] of farmers with [color != white]
  set mean_SmV mean[mySmV] of farmers with [color != white]
  set prop_viti_majSeuil (count farmers with [color != white AND mySmV >= Seuil_out_coop ]) / (count farmers with [color != white])
  set ruined_farmers count Farmers with [not any? myplots]
  set Viticulteurs count Farmers
  set nb_indiv count farmers with [any? myPlots AND cooperateur = FALSE]
  if any? farmers with[color = white][
    set meanSlope_RV mean[meanSlope]of farmers with[color = white]
  ]
  
  let list_rendement_parcellR []
  ask cooperatives [
    ask coopViticulteur [
      ask myplots [
        set  list_rendement_parcellR lput rendement_parcelles list_rendement_parcellR
      ]
    ]
  ]
  let sum_rendement_parcellaire sum list_rendement_parcellR
  set sum_production_kg  sum_rendement_parcellaire * rendement_raisin_hecto ;;25hecto/ha et 105kg par hecto
  
  ;;COOPERATIVES
  set sum_production_capacity sum[production_capacity] of cooperatives
  set sum_production_kg_coop sum[production_kg] of cooperatives
  set nb_coop_in_game count cooperatives
end

to stat_R ;;Viti contexte;; des opération stat issu de R 
  ;; create R list from turtles

    ;;definition de la taille de la mémoire 
    ifelse length capital_list >= memory_size[
      set capital_list lput capital capital_list
      set capital_list remove-item 0 capital_list
      if length capital_list != memory_size [
        show "ATTENTION la taille difff"
        show word "long " length capital_list
        ]
      
    ][
     set capital_list lput capital capital_list
    ]
end
  
to applied_viti-strat ;; viti context
  if any? myPlots [
    ifelse length capital_list = memory_size[

      ;; send the capital memory to R
      rserve:put "yv" capital_list 
      
      ;  une variable de R
      rserve:put "size" memory_size
      rserve:eval "xv<<-seq(1:size)"

     ;; calculate correlation between weight and height
     ;; we need 2 vector whit same length !!
       rserve:eval "fmv <- lm(yv ~ xv)"
;       set memory rserve:get "fmv$coefficient[2]" 
;      rserve:eval "fmv <- lm(viti.df$yv ~ viti.df$xv)"
      set memory rserve:get "fmv$coefficient[2]"
      ;; remove the variable
      rserve:eval "rm(yv)"
      rserve:eval "rm(fmv)"
      

    ][
      set memory 0
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
785
10
1274
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
195
10
261
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
270
10
333
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
InitialCapital
InitialCapital
100
10000
10000
10
1
NIL
HORIZONTAL

PLOT
375
162
560
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
FrontPrice
FrontPrice
0
50000
33000
100
1
NIL
HORIZONTAL

BUTTON
255
115
351
148
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
NbFarmer
NbFarmer
1
300
300
1
1
NIL
HORIZONTAL

SLIDER
7
282
179
315
reserveBuyPrice
reserveBuyPrice
0
50000
17000
1000
1
NIL
HORIZONTAL

PLOT
355
10
540
150
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
181
279
reserveSellPrice
reserveSellPrice
0
50000
17000
1000
1
NIL
HORIZONTAL

TEXTBOX
185
286
335
314
Prix auquel la réserve achète
11
0.0
1

TEXTBOX
190
250
340
276
Prix auquel la réserve vend aux agriculteurs (17000 prix safer)
8
0.0
1

TEXTBOX
190
215
340
245
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
843
525
1210
705
patches cultivé
Time
cultivé %
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot vitipatches / espace_in_patches"
"surf" 1.0 0 -2674135 true "" "plot 0.24"

SLIDER
385
600
418
719
bonus
bonus
0
1
0.075
0.005
1
NIL
VERTICAL

SLIDER
428
600
461
718
malus
malus
0
1
0.05
0.005
1
NIL
VERTICAL

MONITOR
1715
555
1770
600
Nbcoop
count farmers with [cooperateur = TRUE]
17
1
11

MONITOR
1690
490
1796
535
FamersRuined
count Farmers with [not any? myplots]
1
1
11

TEXTBOX
1795
465
1898
491
Les farmers ruiné deviennent Blanc
10
0.0
1

SLIDER
800
526
833
676
coop_capital
coop_capital
0
100000
0
1
1
NIL
VERTICAL

SLIDER
760
526
793
676
nb_coop_init
nb_coop_init
0
3
1
1
1
NIL
VERTICAL

SWITCH
615
610
737
643
see_coop
see_coop
0
1
-1000

SLIDER
5
125
177
158
prix_kg
prix_kg
0
10
1.5
0.05
1
NIL
HORIZONTAL

MONITOR
1490
20
1627
65
rendement-random
rendement_G
1
1
11

SLIDER
5
160
177
193
cout_ha
cout_ha
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
"cooperateur" 1.0 0 -7500403 true "" "plot prop_cooperateur"
"1/2" 1.0 0 -2674135 true "" "plot 0.5"
"cooperateur in hill" 1.0 0 -955883 true "" "plot prop_cooperateur_in_hill"

BUTTON
260
45
347
78
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

MONITOR
1720
285
1787
330
parTime
count farmers with[employer < 1 and color != white]
17
1
11

SLIDER
570
645
742
678
Seuil_out_coop_i
Seuil_out_coop_i
1
20
6
1
1
NIL
HORIZONTAL

TEXTBOX
575
685
725
715
plus le seuil est haut plus on réduit les viticulteurs qui veulent sortir à ceux qui sont aventureux
8
0.0
1

TEXTBOX
180
140
210
158
1.5 init
8
0.0
1

TEXTBOX
180
175
225
193
2300 init
8
0.0
1

PLOT
1285
315
1485
465
median et mean SmV
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
"default" 1.0 0 -16777216 true "" "plot med_SmV"
"pen-1" 1.0 0 -7500403 true "" "plot mean_SmV"
"pen-2" 1.0 0 -2674135 true "" "plot Seuil_out_coop_i"

BUTTON
265
80
342
113
go100
if ticks <= 101 [go]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1795
490
1870
535
prop_runied
count Farmers with [not any? myplots] / count farmers
2
1
11

PLOT
580
290
780
440
price
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""
"pen-1" 1.0 0 -817084 true "" "plot prix_kg"
"pen-2" 1.0 0 -2674135 true "" "plot 0"

PLOT
1285
10
1485
160
coop_stratégie
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
"pen-1" 1.0 0 -5298144 true "" "plot 0"

PLOT
1285
165
1485
315
capacité de production
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
1285
465
1485
615
prop viticulteur risqueLike
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
"default" 1.0 0 -16777216 true "" "plot prop_viti_majSeuil"

INPUTBOX
475
620
565
680
prop_attendu_i
80
1
0
Number

PLOT
545
5
780
155
volume Coop VS Volume total
NIL
NIL
0.0
10.0
240000.0
3000000.0
true
true
"" ""
PENS
"volum" 1.0 0 -16777216 true "" "plot sum_production_kg"
"Coop_cap" 1.0 0 -7500403 true "" "plot sum_production_capacity"
"prod_coop" 1.0 0 -2674135 true "" "plot sum_production_kg_coop"
"vol_min" 1.0 0 -955883 true "" "plot vol_mini_coop"

INPUTBOX
220
660
379
720
vol_mini_coop_i
0
1
0
Number

TEXTBOX
215
720
403
740
volume mini pour justier une coop en kg\n
8
0.0
1

PLOT
563
163
778
283
farmers runied
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
"runiés" 1.0 0 -16777216 true "" "plot count farmers with [not any? myplots]"

MONITOR
1715
615
1770
660
indiv
count farmers with [any? myPlots AND cooperateur = FALSE]
17
1
11

PLOT
8
529
208
679
gini
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
"Capital" 1.0 0 -16777216 true "" "if ticks > 10[\nplot gini-index-reserve\n]"
"foncier" 1.0 0 -7500403 true "" "if ticks > 10[\nplot gini-index-all\n]"

MONITOR
225
560
292
605
gini-total
gini-index-all
2
1
11

MONITOR
1690
440
1752
485
farmers
count farmers with [color != white]
17
1
11

MONITOR
1715
350
1802
395
NIL
init_farmers
1
1
11

SLIDER
220
620
365
653
memory_size_coop_i
memory_size_coop_i
2
10
6
1
1
NIL
HORIZONTAL

SLIDER
225
320
370
353
memory_size_i
memory_size_i
2
10
4
1
1
NIL
HORIZONTAL

MONITOR
1285
620
1389
665
NIL
meanSlope_RV
2
1
11

MONITOR
1286
668
1390
713
NIL
meanSlope_AL
2
1
11

BUTTON
130
10
197
43
close
rserve:close
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
230
155
365
188
random_alpha_i?
random_alpha_i?
1
1
-1000

MONITOR
1490
205
1568
250
Bilan coop
bilan_coop_bonus_malus
2
1
11

TEXTBOX
1391
628
1481
653
pente moy des vitis ruiné
8
0.0
1

TEXTBOX
1391
678
1476
698
pente moy des viti vivant
8
0.0
1

PLOT
1495
270
1695
420
nombre de cooperateurs VS other
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
"coop" 1.0 0 -16777216 true "" "plot count farmers with [cooperateur = TRUE AND color != white]"
"indep" 1.0 0 -7500403 true "" "plot count farmers with [cooperateur != TRUE AND color != white]"

TEXTBOX
1350
275
1500
293
green : production_capacity
8
0.0
1

SLIDER
1510
445
1682
478
scenarii_i
scenarii_i
0
2
0
1
1
NIL
HORIZONTAL

MONITOR
1510
555
1600
600
NIL
nb_plots_cooperateur
1
1
11

MONITOR
1510
615
1600
660
NIL
nb_plots_indep
1
1
11

TEXTBOX
1515
520
1605
550
Nombre de parcelles moyen par viticulteur en coop
8
0.0
1

TEXTBOX
1525
665
1600
710
Nombre de parcelles moyen par viticulteur en indep
8
0.0
1

TEXTBOX
1535
600
1840
626
----------------------------------------------------------------------------
12
0.0
1

MONITOR
1610
615
1707
660
NIL
capital_indep
2
1
11

MONITOR
1610
555
1702
600
capital coop
capital_cooperateur
2
1
11

TEXTBOX
1700
430
1850
448
viticulteurs total
8
0.0
1

MONITOR
1775
555
1862
600
NIL
slope_coop
1
1
11

MONITOR
1775
615
1867
660
NIL
slope_indep
1
1
11

PLOT
375
290
575
440
Parcelles en landreserve
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
"default" 1.0 0 -16777216 true "" "plot count patches with[owner = -1]"

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
  <experiment name="experiment_effect_bonus" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>rserve:close</final>
    <timeLimit steps="50"/>
    <metric>gini-index-reserve</metric>
    <metric>gini-index-all</metric>
    <metric>prop_farmer_in_hill</metric>
    <metric>prop_cooperateur</metric>
    <metric>Viticulteurs</metric>
    <metric>ruined_farmers</metric>
    <metric>prop_viti_majSeuil</metric>
    <metric>vitipatches</metric>
    <metric>med_slope</metric>
    <metric>sum_production_capacity</metric>
    <metric>sum_production_kg</metric>
    <metric>sum_production_kg_coop</metric>
    <metric>nb_indiv</metric>
    <metric>nb_coop_in_game</metric>
    <metric>meanSlope_RV</metric>
    <metric>meanSlope_AL</metric>
    <metric>bilan_coop_bonus_malus</metric>
    <metric>nb_plots_cooperateur</metric>
    <metric>nb_plots_indep</metric>
    <metric>capital_cooperateur</metric>
    <metric>capital_indep</metric>
    <metric>slope_coop</metric>
    <metric>slope_indep</metric>
    <enumeratedValueSet variable="prop_attendu_i">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coop_capital">
      <value value="25926"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prix_kg">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FrontPrice">
      <value value="33000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveBuyPrice">
      <value value="17000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bonus" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="cout_ha">
      <value value="2300"/>
    </enumeratedValueSet>
    <steppedValueSet variable="malus" first="0.1" step="0.1" last="1"/>
    <enumeratedValueSet variable="nb_coop_init">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="see_coop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Seuil_out_coop_i">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vol_mini_coop_i">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbFarmer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialCapital">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory_size_coop_i">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveSellPrice">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory_size_i">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random_alpha_i?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_effect_bonus_WC" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>rserve:close</final>
    <timeLimit steps="50"/>
    <metric>gini-index-reserve</metric>
    <metric>gini-index-all</metric>
    <metric>prop_farmer_in_hill</metric>
    <metric>prop_cooperateur</metric>
    <metric>Viticulteurs</metric>
    <metric>ruined_farmers</metric>
    <metric>prop_viti_majSeuil</metric>
    <metric>vitipatches</metric>
    <metric>med_slope</metric>
    <metric>sum_production_capacity</metric>
    <metric>sum_production_kg</metric>
    <metric>sum_production_kg_coop</metric>
    <metric>nb_indiv</metric>
    <metric>nb_coop_in_game</metric>
    <metric>meanSlope_RV</metric>
    <metric>meanSlope_AL</metric>
    <metric>bilan_coop_bonus_malus</metric>
    <metric>nb_plots_cooperateur</metric>
    <metric>nb_plots_indep</metric>
    <metric>capital_cooperateur</metric>
    <metric>capital_indep</metric>
    <metric>slope_coop</metric>
    <metric>slope_indep</metric>
    <enumeratedValueSet variable="prop_attendu_i">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coop_capital">
      <value value="25926"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prix_kg">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="FrontPrice">
      <value value="33000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveBuyPrice">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bonus">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cout_ha">
      <value value="2300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="malus">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb_coop_init">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="see_coop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Seuil_out_coop">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vol_mini_coop_i">
      <value value="500000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NbFarmer">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="InitialCapital">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory_size_coop_i">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reserveSellPrice">
      <value value="17000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory_size_i">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random_alpha_i?">
      <value value="true"/>
      <value value="false"/>
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
