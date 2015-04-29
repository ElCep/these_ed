;;Modèle VICTOR pour VIticulture Consomation TOuRaine
;;Auteur Etienne DELAY (université de Limoges GEOLAB)

;   This file is part of VICTOR : Agent Based Model (ABM)  on 
;   viticolture in a montaneous landscape focusing on Chardonnay and 
;   Climate Change (CC)
;
;   VICTOR is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   VICTOR is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with CHAMOMiLE.  If not, see <http://www.gnu.org/licenses/>.

__includes [
  "moranIndex.nls"
]

breed [local_cities local_citie]

globals [
  ;;
  listPop
  listRendementIndex
  nbRI
  listLocalCerealD
  oldAreaVine
  oldAreaCereal
  sumCereal
  sumVine
  populationTotal
  capitalTotal
  cerealSoil ;;nb patches plus adapter à la céréale non occupé
  wineSoil  ;;nb de patches plus adapter a la vigne non occupé
  cerealOnCerealSoil 
  wineOnWineSoil
  villageGoodposition
  Shannon
  logS
]

patches-own[
  rendementIndex
  alti
  sol
  cultureHistory ;; un historique de culture +1 quand il y a de la vigne -1 quand elles est part
  patchOwner
  vineAge
  typeCrop
  oldtypeCrop
  nbVariationCrop
]

local_cities-own[
 population
 chomeur
 localtype ;type de villages (hameau, village...)
 LocalCerealDemand ; la demande local directement converte en patch
 importCereal ;le nombre d'équivalent parcelles qu'il faut import pour couvrir les besoin locaux en cereal
 importWine ;le nombre d'équivalent parcelles qu'il faut import pour couvrir les besoin locaux en vin
 LocalVineDemand ;demande local en vin
 supCereal
 supVine
 capital
 oldCapital
 mycereal
 myVinplots
 strategie
 coefStrategie
 modeStartegie
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;   SETUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all 
  set WinePriceInput 50
  set CerealPriceInput 50
  set oldAreaVine count patches with [typeCrop = 2]
  set oldAreaCereal count patches with [typeCrop = 2]
  set listRendementIndex [] ;;initialise la list pour shannon
;  import-pcolors "montagne1.png"
ifelse Isotrope = FALSE [
;    import-pcolors "alti.png"
    import-pcolors "montagne3.png"
    ask patches [
      set alti pcolor
    ]
    import-pcolors "sol.png"
    ask patches [
      ifelse pcolor < 8 [
      set sol 2
      ][
      set sol 1
      ]
    ]
][
  ask patches [
      set alti pcolor
      updateRI
    ]
]

; Definition de la forme des tortues
  set-default-shape local_cities "house"
  initialPatches
  initialLocalCities ;;creation des villages et hameau
  initialHamlet ;;creation des hameaux
  initialCrop ;;Creer les culture et non culture de 3 types ->  1 céréale, 2 vigne, 0 foret
  ask local_cities [
    set localCerealDemand population / 2 ;; transformer la population en champ de blé 1 champs pour 2 personnes
    set LocalVineDemand population / 3   ;; transformer la pop en parcelles de vigne 1 parcelle pour 3
    let NbplotsW population * 2 ;sachant qu'une parcelle de blé nourrit 2 personne mais qu'une personne peut cultivé deux parcelles
    let PotPlotExt NbplotsW - count patches with [patchowner = [who] of myself]
    set chomeur (PotPlotExt - population) 
  ]
  
  set listPop [population] of local_cities
  set listLocalCerealD []
  CalculH
  reset-ticks
end


to initialPatches
  ask patches [
   set  patchOwner 9999
   set pcolor alti
  ]
end

to initialLocalCities
  let conterColor 2
  create-local_cities 1 [
    if PositionSenarii = 1 [
      setxy 0 -15
    ]
    if PositionSenarii = 2 [
      setxy 0 2
    ]
    if PositionSenarii = 3 [
      setxy 0 20
    ]
    if PositionSenarii = 4 [
      setxy 0 34
    ]
    if PositionSenarii = 5 [
      setxy random-pxcor random-pycor
    ]
    set size 3
    set color conterColor
    set localtype "centre"
    set population 400
    set capital population * 10
    set localCerealDemand population / 2 ;; transformer la population en champ de blé 1 champs pour 2 personnes
    set LocalVineDemand population / 3   ;; transformer la pop en parcelles de vigne 1 parcelle pour 3
    set conterColor ifelse-value (conterColor < 140) [conterColor + 10] [conterColor - 139]    
    let NbplotsW population * 2 ;sachant qu'une parcelle de blé nourrit 2 personne mais qu'une personne peut cultivé deux parcelles
    let PotPlotExt NbplotsW - count patches with [patchowner = [who] of myself]
    set chomeur (PotPlotExt - population)
    set localCerealDemand population / 2 ;; transformer la population en champ de blé 1 champs pour 2 personnes
    set LocalVineDemand population / 3   ;; transformer la pop en parcelles de vigne 1 parcelle pour 3
  ]
  updateRI
end

to initialHamlet
  ask local_cities [
    
    let distHamlet patches with  [distance myself < 25 and distance myself > 18]
    ask n-of nbHamlet  distHamlet [
      sprout-local_cities 1 [
        set size 2
        set localtype "hamlet"
        set population 40
        set capital population * 10
        set localCerealDemand population / 2 ;; transformer la population en champ de blé 1 champs pour 2 personnes
        set LocalVineDemand population / 3   ;; transformer la pop en parcelles de vigne 1 parcelle pour 3
        let NbplotsW population * 2 ;sachant qu'une parcelle de blé nourrit 2 personne mais qu'une personne peut cultivé deux parcelles
        let PotPlotExt NbplotsW - count patches with [patchowner = [who] of myself]
        set chomeur (PotPlotExt - population)
        set localCerealDemand population / 2 ;; transformer la population en champ de blé 1 champs pour 2 personnes
        set LocalVineDemand population / 3   ;; transformer la pop en parcelles de vigne 1 parcelle pour 3
      ]
    ]
    ]
end

to initialCrop
  ;;creation de la vigne
  
  ask local_cities [
    ;;initialisation de la vigne
    set coefStrategie []
    ask min-n-of LocalVineDemand patches with [ typeCrop = 0 and patchOwner = 9999][distance myself][
      set pcolor red
      set patchOwner [who] of myself
      set typeCrop 2
      set vineAge 3
    ]
    let myPotPlot2 patches with [ patchOwner = [who] of myself and typeCrop = 2]
    set myVinplots(patch-set myPotPlot2)
    
    ;;initialisation des cereales
    ask min-n-of round localCerealDemand patches with [ typeCrop = 0 and patchOwner = 9999][distance myself][
      set pcolor yellow
      set patchOwner [who] of myself
      set typeCrop 1
    ]
    let myPotPlot1 patches with [ patchOwner = [who] of myself and typeCrop = 1]
    set mycereal(patch-set myPotPlot1)
    
  ]

 
end

to updateRI
  ask patches with [patchowner = 9999][
;   set rendementIndex (Alti + 1) * (sol * 50) + (-1 * (distance myself)
    set rendementIndex (Alti + 1) * (sol * 50 + 1)
  ]
  ; Transformation en 100%
  let maxRI max [rendementIndex] of patches
  ask patches with [patchowner = 9999][
   set  rendementIndex 100 - ((rendementIndex * 100) / maxRI)
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                             GO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  ask local_cities [
    increaseCrop
    updatecapital
    increasePop
  ]
  updateWinePrice
  visualize
  
  ask patches [
    updatecultureHistory
    updateoldtypeCrop
  ]
  set listPop []
  set oldAreaVine count patches with [typeCrop = 2]
  set oldAreaCereal count patches with [typeCrop = 1]
  
  CalculH
  updateGlobal
  updatePlot
  if not any? local_cities [
   stop 
  ]
  tick
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                      GO  PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to visualize
  if visuMode = "parcelles" [
    ask patches with [patchowner != 9999][
     if typeCrop = 1 [
      set pcolor yellow 
     ]
     if typeCrop = 2 [
      set pcolor red 
     ]
    ]
  ]
  
  if visuMode = "indexRendement" [
   ask patches with [patchowner = 9999][
    set pcolor scale-color red rendementIndex 0 100 
   ] 
  ]
  if visuMode = "altitude" [
   ask patches with [patchowner = 9999][
    set pcolor alti 
   ] 
  ]
  
  if visuMode = "cultureStory" [
    ask patches [
      set pcolor scale-color red cultureHistory 0 600
    ]
  ]
  if visuMode = "varaitionCrop"[
   ask patches [
    set pcolor scale-color green nbVariationCrop 0 50
   ] 
  ]
end

to increasePop
  ;;local_cities context
  let NbplotsW population * 2 ;sachant qu'une parcelle de blé nourrit 2 personne mais qu'une personne peut cultivé deux parcelles
  let PotPlotExt NbplotsW - count patches with [patchowner = [who] of myself]
  set chomeur (PotPlotExt - population)
  
  ifelse LogisticPop = TRUE [
    ifelse localCerealDemand > (count mycereal + 1) + importCereal [
     set population population - coefUpPop * population * (1 - population / popMAx) ;; fonction logistique d'évolution de la population
    ][
      set population population + coefUpPop * population * (1 - population / popMAx) ;; fonction logistique d'évolution de la population
    ]
    
    
   
  ][
  ifelse localCerealDemand > (count mycereal + 1) + importCereal [
    set population population - 3
    
  ][
;  set population population + random-normal 20 5
  set population population + 1
  ]
  ]
  
  
  
end

to updatecapital
  ;;local_cities context
  set supCereal count myCereal - localCerealDemand
  if supCereal < 0 [
    set  importCereal abs(supCereal)
  ]
  set supVine count myVinPlots - LocalVineDemand
  if supVine < 0 [
   set importWine abs(supVine) 
  ]
  set oldCapital capital
  set capital capital + (supCereal * cerealPriceInput) + (supVine * WinePriceInput) - (importCereal * cerealPriceInput) - (importWine * WinePriceInput) ;+ (population * 10)
  
  if  capital < -1000 [
   ask myCereal [
        set pcolor alti
        set patchOwner 9999
        set typeCrop 0
        set  vineAge 0 
     ]
   ask myVinPlots [
        set pcolor alti
        set patchOwner 9999
        set typeCrop 0
        set  vineAge 0 
   ]
   die
  ]
  
end

to increaseCrop
  ;;local_cities context
  set localCerealDemand population / 2 ;; transformer la population en champ de blé 1 champs pour 2 personnes
  set LocalVineDemand population / 3   ;; transformer la pop en parcelles de vigne 1 parcelle pour 3
  
  let NbplotsW population * 2 ;sachant qu'une parcelle de blé nourrit 2 personne mais qu'une personne peut cultivé deux parcelles
  let PotPlotExt NbplotsW - count patches with [patchowner = [who] of myself]
  set chomeur (PotPlotExt - population)

;ifelse capital > 10000 AND  capital / 10 > ((importCereal * cerealPriceInput) + (importWine * WinePriceInput)) AND capital > oldCapital + 10000[
ifelse capital > 10000 AND  capital > oldCapital[
    commerce
    set strategie "commerce"
    set coefStrategie lput 2 coefStrategie
  ][
    autoconsomation
    set strategie "autoconsomation"
    set coefStrategie lput 1 coefStrategie
  ]
  set label strategie
  
end

to autoconsomation
  ;;local_cities context
     ifelse  chomeur > 0[ ;; S'il y a de la main d'oeuvre dispo on plante du blé
       if localCerealDemand > count myCereal [
          let metaChomeur round(chomeur / 2)
          let interationBle n-values metaChomeur [1]
          foreach interationBle [
            increaseCereal
          ]
       ]
       if chomeur > 1 [;;s'il y a de la main d'oeuvre dispo +1 on plante de la vigne
         if LocalVineDemand > count myVinPlots [
           let metaChomeur round(chomeur / 2)
           let interationWine n-values metaChomeur [1]
           foreach interationWine [
             increaseVine
           ]
         ]
       ]
     ][ ; Si chomeur <= 0 s'il n'y avait plus de main d'oeuvre on pert 1 de cereal
       let terSupVine round(abs(supVine / 3))
       let interationUpcereal n-values terSupVine [1]
       foreach interationUpcereal [
         decreaseVine
       ]
       
;     decreaseCereal
;     decreaseVine
     ]
  
  
end

to commerce
  ;;local_cities context  
  ifelse WinePriceInput > cerealPriceInput [
     ifelse chomeur > 2 [
       let metaChomeur round(chomeur / 2)
       let interationWine n-values metaChomeur [1]
       foreach interationWine [
         increaseVine
       ]
     ][;sinon
;     ifelse count myCereal > round(localCerealDemand + importCereal ) OR capital > (importCereal * cerealPriceInput)[
     ifelse capital < (importCereal * cerealPriceInput)[
       let terSupBlé round(abs(supCereal / 3))
       let interationUpVine n-values terSupBlé [1]
       foreach interationUpVine [
         decreaseCereal
         increaseVine
       ]
     ][
     ;;calculer le nombre de parcelles de blé qu'on peut perdre en achetant le blé à l'exterieur 
     ;;on abandonner 10 % des parcelles qu'on peut achter par ans
     let pctAbandon round(round(capital / ((cerealPriceInput + cerealPriceInput * 0.05) + 1)) / 10)
     let plotAbandon  round((pctAbandon * count myCereal) / capital)
     let interationBleloose n-values plotAbandon [1]
     foreach interationBleloose [
       decreaseCereal
       increaseVine
      ]
     ]
    ]
  ][
  ;;ici condition cerealPriceInput >= WinePriceInput
   ifelse chomeur > 2 [
     let metaChomeur round(chomeur / 2)
     let interationBle n-values metaChomeur [1]
       foreach interationBle [
         increaseCereal
       ]
   ][
   ;;ici si chomeur <= 0
;    ifelse count myCereal > round(localCerealDemand + importCereal) OR capital > (importCereal * cerealPriceInput)[
   ifelse capital < (importCereal * cerealPriceInput)[
       let terSupVin round(count myVinPlots / 20)
       let incrementCerealup n-values terSupVin [1]
       foreach incrementCerealup [
         decreaseVine
         increaseCereal
       ]
   ][
     ;;calculer le nombre de parcelles de vigne qu'on peut perdre en achetant le vin à l'exterieur 
     ;;on abandonner 10 % des parcelles qu'on peut achter par ans
     let pctAbandon round(round(capital / (((WinePriceInput + WinePriceInput * 0.05) / 10) + 1))) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;le +1
     let plotAbandon  round((pctAbandon * count myVinPlots) / capital)
     let interationBleloose n-values plotAbandon [1]
     foreach interationBleloose [
       decreaseVine
       increaseCereal
      ]
   ]
  ]
 ]

end

;; Reporter pour trouver la valeur de rendement la plus proche
to-report min-by [metric xs]
  let pairs (map list xs (map metric xs))
  let better-pair task [ifelse-value (item 1 ?1 < item 1 ?2) [?1] [?2]]
  let best-pair reduce better-pair pairs
  report first best-pair
end

to-report closest [x xs]
  let difference task [abs (x - ?)]
  report min-by difference xs
end

to increaseVine
  ;;local_cities context

    let potPlotFinal (patch-set) ;collection de patchs pot
    let newplot (patch-set)
    ifelse any? myVinPlots [
      ask myVinPlots [
        let freePatches patches in-radius 3 with [patchOwner = 9999 or (patchOwner = [patchOwner] of myself and typeCrop = 1)] ;critère de selection, patches libre
      ;;patch-set A
        set potplotFinal (patch-set potplotfinal freePatches)
      ]
    ][
     ;;s'il n'y a plus de parcelles de vigne on peut en replanter à proximité de la ville
     set potplotFinal n-of 1 patches with-min [distance myself]
    ]
    
    ;;patch-set B
    let  potplot potplotFinal with [count patches in-radius 2 with [typeCrop = 2] > 1] ; on va chercher à installer de la vigne sur une parcelle qui a des voisine en vigne.
    let listRendement [rendementIndex] of potplot
    if not empty? listRendement [ 
      let rendementViti closest 60 listRendement
      
      
      set newplot n-of 1 potplot with [rendementIndex = rendementViti]
      ask  newplot[
        set pcolor red
        set patchOwner [who] of myself
        set typeCrop 2
        set  vineAge 0  
      ]
      set myVinPlots (patch-set myVinPlots newplot)
      set myCereal (patch-set patches with [patchOwner = [who] of myself and typeCrop = 1 ])
    ]
end

to increaseCereal 
  ;;local_cities context
  ifelse any? patches with [patchowner = 9999][
    ;;S'il y a des patches libre à proximiter des parcelles déjà en blé on va travailler dessu
   let finalpoPLot (patch-set)
    ask myCereal [
      let freePatches patches  in-radius 2 with [patchowner = 9999]
      set finalpoPLot (patch-set freePatches finalpoPLot)
    ]
    ifelse any? finalpoPLot[
           let listRendement [rendementIndex] of finalpoPLot
           let newplot min-one-of finalpoPLot with [rendementIndex = closest 95 listRendement][distance myself]
           ask  newplot[
;            set pcolor [color] of myself
             set pcolor yellow
             set patchOwner [who] of myself
             set typeCrop 1 
           ]
    set myCereal (patch-set myCereal newplot)
      
    ][
    ;;sinon on va travailler sur tout les patches libres, mais cela va prendre plus de temps
           let freePatches patches with [patchowner = 9999]
           let listRendement [rendementIndex] of freePatches
           let newplot min-one-of freePatches with [rendementIndex = closest 95 listRendement][distance myself]
           ask  newplot[
;            set pcolor [color] of myself
             set pcolor yellow
             set patchOwner [who] of myself
             set typeCrop 1 
           ]
    set myCereal (patch-set myCereal newplot)
    
    ]
  ][
;  ;;;;;ATTENTION JE NE SUIS PAS SUR QU'IL SOIT NECESAIRE D4AJOUTER CE QUI SUIE
;  ;;; s'il n'y a plus de place pour developper des cereal on va developper sur de la vigne
;    let freePatches patches with [patchowner = [who] of myself]
;    let listRendement [rendementIndex] of freePatches
;    let newplot min-one-of freePatches with [rendementIndex = closest 95 listRendement][distance myself]
;    ask  newplot[
;;            set pcolor [color] of myself
;            set pcolor yellow
;            set patchOwner [who] of myself
;            set typeCrop 1 
;          ]
;    set myCereal (patch-set myCereal newplot)
;    set myVinPLots patches with [patchowner = [who] of myself and typeCrop = 2]
;show "bong"
  ]

end

to decreaseCereal 

  if any? mycereal [
    ask  min-n-of 1 mycereal with-max[distance myself][rendementIndex][ 
      set pcolor alti
      set patchOwner 9999
      set typeCrop 0
    ]
    let regpatch patches with  [patchOwner = [who] of myself and typeCrop = 1 ]
    set  mycereal (patch-set regpatch)
  ]

end

to decreaseVine
  ;;local_cities context
    if count myVinplots > 0 [
      ask max-n-of 1 myVinplots with-max[distance myself][rendementIndex][ 
        set pcolor alti
        set patchOwner 9999
        set typeCrop 0
        set  vineAge 0
      ]
  ]
   let regpatch patches with  [patchOwner = [who] of myself and typeCrop = 2 ]
    set  myVinplots (patch-set regpatch)

end

to updatecultureHistory
  if typeCrop =  2[
    set cultureHistory cultureHistory + 1
  ]
  if typeCrop = 1 [
    set cultureHistory cultureHistory - 1
  ]
  if oldtypeCrop != typeCrop [
    set nbVariationCrop nbVariationCrop + 1
  ]
end

to updateWinePrice
  if Logist_Price = TRUE [
    ;;Si le nombre de patches viticole actuelle est sup au nombre du tour précedent diminution du prix
    ifelse oldAreaVine < count patches with [typeCrop = 2][
      let increasingAreaV (count patches with [typeCrop = 2]) - oldAreaVine
      let interationIncresinfPriceV n-values increasingAreaV [1]
      foreach interationIncresinfPriceV [
        set WinePriceInput WinePriceInput + coefdownPrice * WinePriceInput * (1 - WinePriceInput / 100)
      ]
    ][;;Sinon augmentation du prix
      let increasingAreaV (count patches with [typeCrop = 2]) - oldAreaVine ;est negatif
      let interationIncresinfPriceV n-values abs increasingAreaV [1] ;; on le repasse en positif avec abs
      foreach interationIncresinfPriceV [
        set WinePriceInput WinePriceInput - coefdownPrice * WinePriceInput * (1 - WinePriceInput / 100) ;;le coef en interface est négatif il faut donc passer en negatif ici aussi la parti coef
      ]
    ]
      ifelse oldAreaCereal < count patches with [typeCrop = 1][ ;;Si le nombre de patches céréal actuelle est sup  au nb de patch précedent -> diminution du prix
     
      let increasingAreaC (count patches with [typeCrop = 1]) - oldAreaCereal
      let interationIncresinfPriceC n-values increasingAreaC [1]
      foreach interationIncresinfPriceC [
        set cerealPriceInput cerealPriceInput + coefdownPrice * cerealPriceInput * (1 - cerealPriceInput / 100)
      ]
    ][ ; sinon augmentation du prix
      let increasingAreaC (count patches with [typeCrop = 1]) - oldAreaCereal ;est négatif
      let interationIncresinfPriceC n-values abs increasingAreaC [1] ; on le repasse en positif avec abs
      foreach interationIncresinfPriceC [
        set cerealPriceInput cerealPriceInput - coefdownPrice * cerealPriceInput * (1 - cerealPriceInput / 100)
      ]
    ]
  ]
  if afine = TRUE [
    let patchesNonViti (count patches) - (count patches with [typeCrop = 2])
    let patchesNonCereal (count patches) - (count patches with [typeCrop = 1])
    let pctPatchesNonViti patchesNonViti * 100 / count patches
    let pctPatchesNonCereal patchesNonCereal * 100 / count patches
;    let pctPatchesViti (count patches with [typeCrop = 1]) * 100 / count patches
;    set cerealPriceInput random-normal pctPatchesNonCereal 2
;    set WinePriceInput random-normal pctPatchesNonViti 2
    set cerealPriceInput pctPatchesNonCereal
    set WinePriceInput pctPatchesNonViti
    ]
  if periodicFonction = TRUE [
    set cerealPriceInput initPrice * sin(ticks * 30) + initPrice
    set WinePriceInput initPrice * cos(ticks * mvPeriode) + initPrice

  ]
end

to CalculH
  if any? patches with [patchowner != 9999][
    set listRendementIndex []
    ask patches with [patchowner != 9999] [
      set listRendementIndex lput rendementIndex listRendementIndex
    ]
    set listRendementIndex remove-duplicates listRendementIndex
    set nbRI length listRendementIndex
    set logS log nbRI 2
    
    let poI 0
    let oneH 0
    let listH []
    foreach  listRendementIndex [
      set poI (count patches with [rendementIndex = ?]) / count patches
      set oneH poI * log poI 2
      set listH lput oneH listH
    ]
    set Shannon sum listH * -1
  ]
end

to photo-view
  export-view (word "view-"ticks".png")
end

to updateGlobal
  let tpsSumCereal []
  ask local_cities [
   let countC count myCereal
   set tpsSumCereal  lput countC tpsSumCereal
  ]
  set sumCereal sum(tpsSumCereal)
  
  let tpsSumVine []
  ask local_cities [
   let countV count myVinPlots
   set tpsSumVine  lput countV tpsSumVine
  ]
  set sumVine sum(tpsSumVine)
  
  ;;creation d'un global avec population
  set populationTotal sum[population]of local_cities
  set capitalTotal sum[capital]of local_cities
  set cerealSoil count patches with [rendementIndex >= 94 AND typeCrop = 0]
  set wineSoil count patches with [rendementIndex < 94 AND typeCrop = 0]
;  set cerealOnCerealSoil (count patches with [typeCrop = 1]) - (count patches with [rendementIndex >= 94 AND typeCrop = 1] * 100 / count patches with [typeCrop = 1])
;  set wineOnWineSoil (count patches with [typeCrop = 2]) - (count patches with [rendementIndex < 90 AND typeCrop = 2] * 100 / count patches with [typeCrop = 2])
  if any? patches with [typeCrop = 1] [
    set cerealOnCerealSoil (count patches with [rendementIndex >= 90 AND typeCrop = 1] * 100 / count patches with [typeCrop = 1])
  ]
  if any? patches with [typeCrop = 2] [
  set wineOnWineSoil (count patches with [rendementIndex < 90 AND typeCrop = 2] * 100 / count patches with [typeCrop = 2])
  ]
  set villageGoodposition count local_cities with [count patches in-radius 3 with[rendementIndex < 90] > 0]
  ask local_cities [
    set modeStartegie modes coefStrategie
    ifelse modeStartegie = [1] [
      set color brown ;autoconsomation
    ][
    set color green ;commerce
    ]
    ]
end

to updateoldtypeCrop
  set oldtypeCrop typeCrop
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;PLOTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to updatePlot
  set-current-plot "plot For population"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks population
  ]
  set-current-plot "plot For chomeurs"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks chomeur
  ]
  set-current-plot "plot count myCereal"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks count myCereal
  ]
  set-current-plot "plot count myVinePlots"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks count myVinPlots
  ]
  set-current-plot "plot localCerealDemand"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks localCerealDemand
    set-plot-pen-color yellow
    plotxy ticks count myCereal
  ]
  set-current-plot "plot LocalVineDemand"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks LocalVineDemand
    set-plot-pen-color red
    plotxy ticks count myVinPlots
  ]
  set-current-plot "Show_Capital"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks capital
  ]
  
  set-current-plot "WinePrice"
  set-plot-pen-color red
  plotxy ticks WinePriceInput
  set-plot-pen-color yellow
  plotxy ticks cerealPriceInput
  
  set-current-plot "import-cereal"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks importCereal
  ]
  
  set-current-plot "import-wine"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks importWine
  ]
  
  set-current-plot "balanceProd"
  ask local_cities [
    set-plot-pen-color color
    plotxy ticks (count myCereal - count myVinPlots)
  ]
  
  set-current-plot "phase_Vine_Cereal"
  set-plot-pen-color black
  plotxy sumCereal sumVine
  
  set-current-plot "population total"
  plotxy ticks populationTotal
  
  set-current-plot "capital total"
  plotxy ticks capitalTotal
  
end
@#$#@#$#@
GRAPHICS-WINDOW
200
10
636
467
35
35
6.0
1
10
1
1
1
0
0
0
1
-35
35
-35
35
0
0
1
ticks
30.0

BUTTON
5
10
78
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
82
10
145
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

SWITCH
10
80
127
113
Isotrope
Isotrope
0
1
-1000

SLIDER
165
10
198
160
PositionSenarii
PositionSenarii
1
5
1
1
1
NIL
VERTICAL

SLIDER
10
115
127
148
nbHamlet
nbHamlet
0
10
10
1
1
NIL
HORIZONTAL

CHOOSER
640
10
807
55
visuMode
visuMode
"parcelles" "altitude" "indexRendement" "cultureStory" "varaitionCrop"
0

BUTTON
5
45
70
78
go step
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
640
80
812
113
cerealPriceInput
cerealPriceInput
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
640
125
812
158
WinePriceInput
WinePriceInput
0
100
50
1
1
NIL
HORIZONTAL

PLOT
825
535
1025
685
plot For population
time
pop
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
1025
535
1225
685
plot For chomeurs
time
nb chomeurs
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""
"pen-1" 1.0 0 -7500403 true "" "plot 0"

PLOT
825
685
1025
835
plot count myCereal
time
nb Cereal plot
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
1025
685
1225
835
plot count myVinePlots
time
nb Vine plots
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
1025
835
1225
985
plot LocalVineDemand
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
825
835
1025
985
plot localCerealDemand
time
Demande Cereal
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
825
985
1025
1135
Show_Capital
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
"pen-1" 1.0 0 -7500403 true "" "plot 1000"

MONITOR
645
275
737
312
WinePriceInput
WinePriceInput
2
1
9

PLOT
1025
985
1225
1135
WinePrice
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
640
320
817
353
coefdownPrice
coefdownPrice
-0.009
0
-0.003
0.001
1
NIL
HORIZONTAL

SWITCH
640
230
817
263
Logist_Price
Logist_Price
1
1
-1000

TEXTBOX
655
165
805
225
Si l'intérupteur est sur off le prix est gérer par le slide \"WinePriceInput\", sinon on peut regler le r de l'equ logistique
9
0.0
1

INPUTBOX
25
355
105
415
coefUpPop
0.04
1
0
Number

SWITCH
25
315
162
348
LogisticPop
LogisticPop
0
1
-1000

SLIDER
25
420
197
453
popMAx
popMAx
0
10000
1000
100
1
NIL
HORIZONTAL

PLOT
1225
535
1425
685
import-cereal
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

TEXTBOX
30
235
180
306
Si l'intérupteur \"LogisticPop\" est sur off la croissance de la population est linéraire. S'il est sur on la croissance est logistique avec un max suivant le slide popMax.
9
0.0
1

PLOT
1225
685
1425
835
import-wine
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

SWITCH
640
380
743
413
Afine
Afine
1
1
-1000

PLOT
1225
835
1425
985
phase_Vine_Cereal
cereal
vine
1600.0
3000.0
1600.0
3000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
1225
985
1425
1135
balanceProd
time
vine     Cereal
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""
"pen-1" 1.0 0 -2674135 true "" "plot 0"

TEXTBOX
870
5
1020
23
indicateurs behaviors space 
9
0.0
1

PLOT
840
30
1040
180
population total
time
population
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
1040
30
1240
180
capital total
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
"default" 1.0 0 -16777216 true "" ""

PLOT
840
180
1040
330
Sum Cereal VS SumVine
time
CerealVSWine
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sumCereal"
"pen-1" 1.0 0 -7500403 true "" "plot sumVine"

PLOT
1040
180
1240
330
Price
time
price
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot cerealPriceInput"
"pen-1" 1.0 0 -7500403 true "" "plot winePriceInput"

PLOT
1240
30
1440
180
soilCrop
time
vineORCereal Soil
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot cerealSoil"
"pen-1" 1.0 0 -7500403 true "" "plot wineSoil"

BUTTON
750
380
832
413
price50
set cerealPriceInput 50\nset winePriceInput 50
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
1242
183
1442
333
Crop on good soil
time
%cropOnBadSoil
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"cereal" 1.0 0 -16777216 true "" "plot cerealOnCerealSoil"
"wine" 1.0 0 -7500403 true "" "plot wineOnWineSoil"
"100" 1.0 0 -2674135 true "" "plot 100"

MONITOR
745
275
830
312
NIL
villageGoodposition
2
1
9

TEXTBOX
1100
10
1425
31
En gris les infos sur la vigne et en noir sur les céréales
9
0.0
1

SWITCH
645
445
785
478
periodicFonction
periodicFonction
0
1
-1000

BUTTON
75
45
152
78
go300
if ticks < 300 [go]
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
645
485
710
545
initPrice
50
1
0
Number

SLIDER
715
485
887
518
mvPeriode
mvPeriode
0
31
31
1
1
NIL
HORIZONTAL

TEXTBOX
790
435
940
481
si periodicFonction est activé il faut définir le prix median. mvPeriode permet de jouer sur la freq des periodes du vin
9
0.0
1

TEXTBOX
895
490
1045
531
6 done une periode de 12 ans\ncereal -> 30
9
0.0
1

MONITOR
840
330
897
375
H
Shannon
2
1
11

MONITOR
895
330
952
375
NIL
logS
2
1
11

PLOT
950
330
1150
480
shannon H
time
H
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Shannon"

TEXTBOX
1155
335
1260
441
The Shannon entropy quantifies the uncertainty (entropy or degree of surprise) associated with this prediction. If we are close of logS -> unpredicteble
9
0.0
1

TEXTBOX
30
160
180
210
PosotopnSenarri permet de faire changer la dispoition des villages du sud (1) au nord (4). La position 5 étant aléatoire!
8
0.0
1

MONITOR
65
505
187
550
NIL
count local_cities
17
1
11

TEXTBOX
650
65
800
83
céréal
8
0.0
1

TEXTBOX
645
115
795
133
vine\n
8
0.0
1

TEXTBOX
70
585
220
630
20000 ticks une stabilisation 
12
0.0
1

MONITOR
245
510
322
555
NIL
cerealSoil
17
1
11

MONITOR
250
565
317
610
NIL
wineSoil
17
1
11

BUTTON
455
530
562
563
NIL
photo-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

ce modèle permet d'explorer plusieur phénomènes. originalement, il a été développer pour explorer les conditions qui font passer un territoir viticole en terre a céréale et inversement. Qu'est ce qui conduit la vigne à prendre la place de la culture vivrillère, et a partir de quelle prix (valeur relative), il devient intéressant de produir dans les terre non productice.
Cela nous a conduit à introduir un prix variable auquelle les différentes production sont vendu. L'oservateur est donc en mesure d'explorer les condition de survie ou abandon d'une culture. 

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

Il est important de noté qu'il n'y a pas dans ce modèle de prise en compte d'une culture (au sens culturelle) agricole. En effet les villages vont dans cette version du modèle passer d'une agriculture céréale à une agriculture viticole sans vergogne. Il serait par la suite intéressant d'introduire cette possibilitée dans les prochaine versions. Ce qui ne manquera pas d'introduir de nouveau questionnement!

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
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment-iso-aniso" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>sumCereal</metric>
    <metric>sumVine</metric>
    <metric>populationTotal</metric>
    <metric>capitalTotal</metric>
    <metric>cerealSoil</metric>
    <metric>wineSoil</metric>
    <metric>cerealOnCerealSoil</metric>
    <metric>wineOnWineSoil</metric>
    <metric>villageGoodposition</metric>
    <metric>count local_cities</metric>
    <enumeratedValueSet variable="mvPeriode">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuMode">
      <value value="&quot;parcelles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WinePriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Isotrope">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PositionSenarii">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicFonction">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefUpPop">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="popMAx">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cerealPriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LogisticPop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbHamlet">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefdownPrice">
      <value value="-0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initPrice">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Logist_Price">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Afine">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-multiActor" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>sumCereal</metric>
    <metric>sumVine</metric>
    <metric>populationTotal</metric>
    <metric>capitalTotal</metric>
    <metric>cerealSoil</metric>
    <metric>wineSoil</metric>
    <metric>cerealOnCerealSoil</metric>
    <metric>wineOnWineSoil</metric>
    <metric>villageGoodposition</metric>
    <metric>count local_cities</metric>
    <enumeratedValueSet variable="mvPeriode">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuMode">
      <value value="&quot;parcelles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WinePriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Isotrope">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PositionSenarii">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicFonction">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefUpPop">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="popMAx">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cerealPriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LogisticPop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbHamlet">
      <value value="0"/>
      <value value="2"/>
      <value value="4"/>
      <value value="6"/>
      <value value="8"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefdownPrice">
      <value value="-0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initPrice">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Logist_Price">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Afine">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-logistic-price" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>sumCereal</metric>
    <metric>sumVine</metric>
    <metric>populationTotal</metric>
    <metric>capitalTotal</metric>
    <metric>cerealSoil</metric>
    <metric>wineSoil</metric>
    <metric>cerealOnCerealSoil</metric>
    <metric>wineOnWineSoil</metric>
    <metric>villageGoodposition</metric>
    <metric>count local_cities</metric>
    <enumeratedValueSet variable="mvPeriode">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuMode">
      <value value="&quot;parcelles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WinePriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Isotrope">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PositionSenarii">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicFonction">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefUpPop">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="popMAx">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cerealPriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LogisticPop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbHamlet">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="coefdownPrice" first="-0.005" step="0.001" last="0"/>
    <enumeratedValueSet variable="initPrice">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Logist_Price">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Afine">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-positionsenarii1234" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>sumCereal</metric>
    <metric>sumVine</metric>
    <metric>populationTotal</metric>
    <metric>capitalTotal</metric>
    <metric>cerealSoil</metric>
    <metric>wineSoil</metric>
    <metric>cerealOnCerealSoil</metric>
    <metric>wineOnWineSoil</metric>
    <metric>villageGoodposition</metric>
    <metric>count local_cities</metric>
    <enumeratedValueSet variable="PositionSenarii">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cerealPriceInput">
      <value value="93.6917278317794"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefUpPop">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuMode">
      <value value="&quot;parcelles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="popMAx">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Afine">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicFonction">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Logist_Price">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mvPeriode">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefdownPrice">
      <value value="-0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WinePriceInput">
      <value value="94.44554651854791"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbHamlet">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Isotrope">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LogisticPop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initPrice">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-Periodic" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>sumCereal</metric>
    <metric>sumVine</metric>
    <metric>populationTotal</metric>
    <metric>capitalTotal</metric>
    <metric>cerealSoil</metric>
    <metric>wineSoil</metric>
    <metric>cerealOnCerealSoil</metric>
    <metric>wineOnWineSoil</metric>
    <metric>villageGoodposition</metric>
    <metric>count local_cities</metric>
    <enumeratedValueSet variable="Logist_Price">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Afine">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefUpPop">
      <value value="0.04"/>
    </enumeratedValueSet>
    <steppedValueSet variable="mvPeriode" first="0" step="2" last="10"/>
    <enumeratedValueSet variable="PositionSenarii">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visuMode">
      <value value="&quot;parcelles&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="popMAx">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbHamlet">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="periodicFonction">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="coefdownPrice">
      <value value="-0.003"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LogisticPop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WinePriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cerealPriceInput">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initPrice">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Isotrope">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
