; "Return of canis lupus in Lower Saxony"
;
; 07.12.2016 - 01.03.2017
;
; @Amélie Klöffer
; @Viktoria Sagolla
;
; Leuphana Universität Lüneburg
; module Interdisciplinary Sustainability Studies, course Ökosystemmodellierung
; Prof. Dr.-Ing. Eckhard Bollow, Dr. Carsten Lemmen
;
; @copyright CC BY-NC-SA 4.0
;------------------------------------------------------------------------------------------------------------------------------
; CONTENT:
; 1. Extentions, globals & variables
; 2. Setup-procedure
;  2.1 Setup-patches procedure
;  2.2 Setup-turtles procedure
;  2.3 Reset-calendar procedure
; 3. Go-procedure
;  3.1 Advance-calendar procedure
;  3.2 Define-forest procedure
;  3.3 Go-turtles procedure
;  3.4 Manage-system procedure
;  3.5 Die-crossing-street procedure
; 4. Move-turtle procedure
; 5. Reproduce procedure
; 6. Eat and grow forest procedure
; 7. Catch procedures
;  7.1 Normal-predation procedure
;  7.2. Predation-with-management procedure
;       7.2.1 "wooden-fence"
;       7.2.2 "electric-fence"
;       7.2.3 "shepherd-dog"
;       7.3.4 "kill-wolves"
;       7.3.5 "kill-prey"
;
;-------------------------------------------------------------------------------------------------------------------------------


;                                                                                   scale 1:2.000.000 = [ 1 patch = 500 m² ]


;---------------------------------------------------------------------------------
;                     1. Extentions, globals & variables
;---------------------------------------------------------------------------------


globals
  [ days-in-month                                                                 ; how many days every month has
    year month day                                                                ; we set a year, a month and a day
    doy                                                                           ; also the day of the year is shown
    forest-patches                                                                ; we define certain patches as forest
  ]

breed [ boars boar ]                                                              ; the different breeds are: boars,
breed [ deer a-deer ]                                                             ; deer,
breed [ wolves wolf ]                                                             ; wolves,
breed [ livestock a-livestock ]                                                   ; livestock and
breed [ hunters hunter ]                                                          ; hunters

turtles-own [ energy ]                                                            ; all turtles apart from livestock and hunters
                                                                                  ; have energy
patches-own [ countdown ]                                                         ; to let grow the eaten forest-patches,
                                                                                  ; we set a patches-own countdown


;---------------------------------------------------------------------------------
;                     2. Setup-procedure
;---------------------------------------------------------------------------------

to setup

  clear-all
  setup-patches
  setup-turtles
  reset-calendar
  reset-ticks

end


;---------------------------------------------------------------------------------
;                       2.1 Setup-patches procedure
;---------------------------------------------------------------------------------


to setup-patches
   Import-pcolors "map - Kopie.png"                                               ; import map as patch color. You have to put
end                                                                               ; it in the same folder as this model

;---------------------------------------------------------------------------------
;                       2.2 Setup-turtles procedure
;---------------------------------------------------------------------------------

to setup-turtles                                                                  ; by pressing the setup-button, the breeds shall
                                                                                  ; be created on patches with specific color
  ask n-of num-wolves patches with [ pcolor = 56 ] [ sprout-wolves 1 ]
  ask n-of num-deer patches with [ pcolor = 56 ] [ sprout-deer 1 ]
  ask n-of num-boars patches with [ pcolor = 56 ] [ sprout-boars 1 ]
  ask n-of num-livestock patches with [ pcolor = 46.7 ] [ sprout-livestock 1 ]
  ask n-of num-hunters patches with [ pcolor = 46.7 ] [ sprout-hunters 1 ]



  ask boars                                                                       ; the breed of boars shall be created
    [ set shape "wildschwein"
      set color brown
      set size 10
      set energy 1 + random 550                                                   ; their initial energy: 1-550
    ]

  ask deer                                                                        ; the breed of deer shall be created
    [ set shape "rotwild"
      set color red
      set size 10
      set energy 1 + random 550                                                   ; their initial energy: 1-550
    ]

  ask wolves                                                                      ; the breed of wolves shall be created
    [ set shape "wolf"
      set color black
      set size 10
      set energy 1 + random 600                                                   ; their initial energy: 1-600
    ]

  ask livestock                                                                   ; the breed of livestock shall be created
    [ set shape "farmtier (kuh)"
      set color white
      set size 10
    ]

  ask hunters
    [ set shape "jäger"
      set color orange
      set size 20
    ]
end

;--------------------------------------------------------------------------------
;                       2.3 Reset-calendar procedure
;--------------------------------------------------------------------------------

to reset-calendar                                                                ; by pressing the set-up button,
                                                                                 ; the calendar shall be reset on
  set year 2017                                                                  ; 01.01.2017
  set doy 1
  set day doy
  set month 1
  set days-in-month ( list 31 28 31 30 31 30 31 31 30 31 30 31 )

end


;--------------------------------------------------------------------------------
;                     3. Go-procedure
;--------------------------------------------------------------------------------

to go                                                                            ; by pressing the go button,

  tick
  advance-calendar                                                               ; the calendar shall count forward
  define-forest                                                                  ; the forest-patches shall be defined
  if not any? turtles [ stop ]                                                   ; simulation stops when all turltes are dead

  ask boars [ go-boars ]

  ask deer [ go-deer ]

  ask wolves [ go-wolves ]

  ask livestock [ go-livestock ]

  ask hunters [ go-hunters ]

  ask patches [ grow-forest ]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;          ask patches in-radius 20       ;
  ;        [ set pcolor red ]               ;                                    ; to make visible the radius in which wolves catch
  ;                                         ;
  ;                                         ;
  ;          ask patches in-radius 5        ;
  ;        [ set pcolor green ]             ;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

;--------------------------------------------------------------------------------
;                         3.1 Advance-calendar procedure
;--------------------------------------------------------------------------------

to advance-calendar

  set day day + 1                                                                ; Update the day monitors
  set doy doy + 1                                                                ; based on the day of year

  let my-doy sum sublist days-in-month 0 month + 1                               ; sum up the days of the months already passed

  if doy > my-doy - 1                                                            ; jump to the next month and reset the day
    [ set month month + 1
      set day 1
    ]

  if doy > 59 [ set my-doy my-doy + leap-year ]                                  ; in leap years add 1
                                                                                 ; (2020 is the next leap year)
  if doy > 365 + leap-year                                                       ; jump to the next year and reset the day
    [ set year year + 1
      set month 1
      set doy 1
      set day 1
    ]

end

to-report leap-year

  if (( year mod 4 ) != 0 )  [ report 0 ]
  if (( year mod 400 ) = 0 ) [ report 1 ]
  if (( year mod 100 ) != 0 ) [ report 0 ]
  report 1

end

;--------------------------------------------------------------------------------
;                         3.2 Define-forest procedure
;--------------------------------------------------------------------------------

to define-forest
  set forest-patches patches with [ shade-of? green pcolor ]                     ; the forest patches shall be those with green color
end


;--------------------------------------------------------------------------------
;                         3.3 Go turtles procedures
;--------------------------------------------------------------------------------


to go-boars

  if ( shade-of? green pcolor ) [ eat-forest ]                                   ; if there is forest of green color, then eat it (it will turn brown)
  move-turtle 5                                                                  ; if not, move up to 10 patches

  if energy < 1 [ die ]                                                          ; die if energy is under 1
  reproduce-boars                                                                ; give birth
  if human-threats [die-crossing-streets]                                        ; if "human-threats" is active, boars die when crossing streets

end


to go-deer

  if ( shade-of? green pcolor ) [ eat-forest ]                                   ; if there is forest of green color, then eat it (it will turn brown)
  move-turtle 20                                                                 ; if not, move up to 20 patches

  if energy < 1 [ die ]                                                          ; die if energy is under 1
  reproduce-deer                                                                 ; give birth
  if human-threats [die-crossing-streets]                                        ; if "human-threats" is active, deer die when crossing streets

end


to go-livestock
  reproduce-livestock                                                            ; give birth
end


to go-wolves

  if energy < 1 [ die ]                                                          ; die if energy is under 1
  reproduce-wolves                                                               ; give birth
  if human-threats [die-crossing-streets]                                        ; if "human-threats" is active, wolves die when crossing streets

;-------------------------------------------------------------------------------
;                         3.4 Manage-system procedures                           ; precaution of the livestock ( Management strategies )
;-------------------------------------------------------------------------------


  if precaution-livestock = "no-management"                                      ; if "no-management" is aktiv
    [ ifelse energy < 200 [ catch-prey ] [ move-turtle random 50 ] ]             ; and energy < 200, catch-prey, if not move up to 50 patches

  ifelse precaution-livestock = "wooden-fence"                                   ; if "wooden-fence" is active,
    [ ifelse energy < 200 [ catch-prey1 ] [ move-turtle 50 ] ]                   ; and energy < 200, catch-prey1, if not move up to 50 patches
    [ ifelse energy < 200 [ catch-prey ] [ move-turtle 50 ] ]                    ; if not and energy < 200, catch-prey, if not move up to 50 patches

  ifelse precaution-livestock = "electric-fence"                                 ; if "electric-fence" is active,
    [ ifelse energy < 200 [ catch-prey2 ] [ move-turtle random 50 ] ]            ; and energy < 200, catch-prey2, if not move up to 50 patches
    [ ifelse energy < 200 [ catch-prey ]  [ move-turtle random 50 ] ]            ; if not and energy < 200, catch-prey if not move up to 50 patches

  ifelse precaution-livestock = "shepherd-dog"                                   ; if "shepherd-dog" is aktiv
    [ ifelse energy < 200 [catch-prey3 ] [ move-turtle random 50 ] ]             ; and energy < 200, catch-prey3, if not move up to 50 patches
    [ ifelse energy < 200 [ catch-prey ] [ move-turtle random 50 ] ]             ; if not and energy < 200, catch-prey, if not move up to 50 patches

end

to go-hunters

  ifelse precaution-livestock = "kill-wolves"
  [ hunt-wolves ] [ hunt-prey ]

end

;--------------------------------------------------------------------------------
;                         3.5 Die-crossing-streets
;--------------------------------------------------------------------------------


to die-crossing-streets

  if one-of neighbors = shade-of? blue pcolor                                    ; if one of neighbor-patches blue (street)
   [ die ]                                                                       ; turtles here die

end


;--------------------------------------------------------------------------------
;                      4. Move-turtle procedure
;--------------------------------------------------------------------------------

                                                                                 ; turtle move procedure
to move-turtle [ maximum-speed ]                                                 ; each turtle has its own maximum speed
                                                                                 ; the overall moment is divided into maximum-speed steps
  repeat maximum-speed                                                           ; which are repeated as often as the maximum-speed value
   [ let speed random-float 1                                                    ; in each of these steps, the turtles move forward max. 1 patch
     carefully
     [ face one-of neighbors with [ shade-of? green pcolor ]                     ;in each step, preferably a forest patch is looked for
     ]
     [ rt random 360
     ]
       fd speed
   ]
  set energy energy - 1                                                          ; the turtles lose 1 energy unit as they move

end


;--------------------------------------------------------------------------------
;                      5. Reproduce procedures
;--------------------------------------------------------------------------------


to reproduce-boars                                                               ; boars procedure
  if month = 3 or month = 4                                                      ; boars give birth in march and april
   [ if random-float 100 < boar-reproduce                                        ; throw "dice" to see if you will reproduce
      [ hatch 2 + random 4                                                       ; hatch between 4 and 8 offsprings and
        move-to one-of patches with [ pcolor = 56 ]                               ; move to a green forest patch
      ]
   ]
end

to reproduce-deer                                                                ; deer procedure
  if month = 5 or month = 6                                                      ; deer give birth in may and june
   [ if random-float 100 < deer-reproduce                                        ; throw "dice" to see if you will reproduce
      [ hatch 1 + random 1                                                       ; hatch one or two offsprings and
        move-to one-of patches with [ pcolor = 56 ]                              ; move to a green forest patch
      ]
   ]
end

to reproduce-wolves                                                              ; wolf procedure
  if month = 4 or month = 5                                                      ; give birth in april and may
   [ if random-float 100 < wolf-reproduce                                        ; throw "dice" to see if you will reproduce
      [ hatch 2 + random 5                                                       ; hatch between 4 and 7 offsprings and
        move-to one-of patches with [ pcolor = 56 ]                              ; move to a green forest patch
      ]
    ]

end

to reproduce-livestock                                                           ; livestock procedure
  if random-float 100 < livestock-reproduce                                      ; throw "dice" to see if you will reproduce
    [ hatch 1                                                                    ; hatch offspring and
      [rt random-float 360 fd 1 ]                                                ; move forward 1
    ]

end

;--------------------------------------------------------------------------------
;                      6. Eat & grow forest procedure
;--------------------------------------------------------------------------------

to eat-forest                                                                    ; boar & a-deer procedure

  set  pcolor  brown                                                             ; when it eats forest, the patch turns brown
  set energy energy + 0.99                                                       ; and it gains energy

end

to grow-forest                                                                   ; patch procedure

  if pcolor = brown                                                              ; countdown on brown patches
  [ ifelse countdown <= 0                                                        ; if reach 0, grow some forest
    [ set pcolor 56
      set countdown 14                                                           ; countdown starts by 14
    ]
    [ set countdown countdown - 1                                                ; countdown goes every day (tick) one down
    ]
  ]

end


;--------------------------------------------------------------------------------
;                      7. Catch procedures
;--------------------------------------------------------------------------------
;                        7.1 Normal-predation procedure
;--------------------------------------------------------------------------------

to catch-prey                                                                    ; wolf procedure
  let prey min-one-of ( turtles with                                             ; wolve's prey is a random a-livestock, a-deer or boar
    [ breed = livestock or
      breed = deer or
      breed = boars
    ] in-radius 40 ) [ distance myself ]                                         ; in radius of 20 km

  ifelse prey != nobody                                                          ; if there is some prey
    [ ifelse distance prey > 5                                                   ; in radius > 5,
      [ face prey                                                                ; face it,
        fd 5                                                                     ; move and
        set energy energy - random-float 1                                       ; lose energy
      ]
      [ set energy energy + random wolf-gain-from-food                           ; if the prey is in radius < 5,
        ask prey [ die ]                                                         ; kill it ! and gain energy
      ]
    ]
    [ move-turtle random 50
    ]                                                                            ; if there is no prey, move

end

;--------------------------------------------------------------------------------
;                        7.2 Predation-with-management procedures
;--------------------------------------------------------------------------------


;                            7.2.1 "wooden-fence"
;--------------------------------------------------------------------------------

to catch-prey1                                                                   ; wolf procedure

  let prey1 min-one-of ( turtles with                                            ; prey1 is a-livestock in radius 30
    [ breed = livestock ] in-radius 20 ) [ distance myself ]

  let prey min-one-of ( turtles with                                             ; prey one of the breeds in radius 30
    [ breed = deer or
      breed = boars ] in-radius 20 ) [ distance myself ]

  ifelse prey != nobody                                                          ; if there is some prey (in radius 30):

    [ ifelse distance prey > 5                                                   ; if the prey is in radius > 5,
      [ face prey                                                                ; face it, move and lose energy
        fd 5
        set energy energy - random-float 1
      ]
      [ set energy energy + 5 + random 10                                        ; if the prey is in radius < 5,
         ask prey[ die ]                                                         ; kill it ! and gain energy
      ]
    ]
                                                                                 ; if there is no prey but prey1 (livestock)
    [ ifelse prey1 != nobody and random 100 < 0.5                                ; and just in random 1000 < 10 of cases:
      [ ifelse distance prey1 > 5                                                ; if prey1 is in radius > 5,
        [ face prey1                                                             ; face it, move and lose energy
          fd 5
          set energy energy - random-float 1
        ]
        [ set energy energy + random wolf-gain-from-food                         ; if prey1 is in radius < 5,
          ask prey1[ die ]                                                       ; kill it ! and gain energy
        ]
      ]
      [ move-turtle random 50                                                    ; if not, move
      ]
    ]

end
;                            7.2.2 "electric-fence"
;--------------------------------------------------------------------------------

to catch-prey2                                                                   ; wolf procedure


  let prey1 min-one-of ( turtles with                                            ; prey1 is a-livestock in radius 30
    [ breed = livestock ] in-radius 20 ) [ distance myself ]

  let prey min-one-of ( turtles with                                             ; prey is one of the breeds in radius 20
    [ breed = deer or
      breed = boars ] in-radius 20 ) [ distance myself ]

  ifelse prey != nobody                                                          ; if there is some prey (in radius 30):

    [ ifelse distance prey > 5                                                   ; if prey is in radius > 5,
      [ face prey                                                                ; face it, move and lose energy
        fd 5
        set energy energy - random-float 1
      ]
      [ set energy energy + 5 + random 10                                        ; if prey is radius < 5,
        ask prey [ die ]                                                         ; kill it ! and gain energy
      ]
    ]
                                                                                 ; if there is no prey but prey1 (livestock)
    [ ifelse prey1 != nobody and random 100 < 0.1                                ; and just in random 1000 < 5 of cases:
      [ ifelse distance prey1 > 5                                                ; if prey1 is in radius > 5,
        [ face prey1                                                             ; face it, move and lose energy
          fd 5
          set energy energy - random-float 1
        ]
        [ set energy energy + random wolf-gain-from-food                         ; if prey1 is in radius 5,
          ask prey1 [ die ]                                                      ; kill it ! and gain energy
        ]
      ]
      [ move-turtle random 50                                                    ; if not, move
      ]
    ]

end



;                            7.2.3 "shepherd-dog"
;--------------------------------------------------------------------------------

to catch-prey3                                                                   ; wolf procedure

  let prey1 min-one-of ( turtles with                                            ; prey1 is a-livestock in radius 30
    [ breed = livestock ] in-radius 20 ) [ distance myself ]

  let prey min-one-of ( turtles with                                             ; prey one of the breeds in radius 30
    [ breed = deer or breed = boars ] in-radius 20 ) [ distance myself ]

  ifelse prey != nobody                                                          ; if there is some prey (in radius 30)

    [ ifelse distance prey > 5                                                   ; if prey is in radius > 5,
      [ face prey                                                                ; face it, move and lose energy
        fd 5
        set energy energy - random-float 1
      ]
      [ set energy energy + 5 + random 10                                        ; if the prey is in radius < 5,
        ask prey[ die ]                                                          ; kill it ! and gain energy
      ]
    ]
                                                                                 ; if where is no prey but prey1 (livestock)
    [ ifelse prey1 != nobody and random 100 < 0.07                               ; and just in  random 1000 < 1 of cases:
      [ ifelse distance prey1 > 5                                                ; if prey1 is in radius > 5,
        [ face prey1                                                             ; face it, move and lose energy
          fd 5
          set energy energy - random-float 1
        ]
        [ set energy energy + random wolf-gain-from-food                         ; if prey1 is in radius < 5,
          ask prey1[ die ]                                                       ; kill it ! and gain energy
        ]
      ]
      [ move-turtle random 50
      ]                                                                          ; if not, move
    ]

end


;                            7.2.4 "kill-wolves"
;--------------------------------------------------------------------------------

to hunt-wolves                                                                   ; hunter procedure

  let prey min-one-of ( turtles with                                             ; if "kill-wolves" is active,
    [ breed = wolves or                                                          ; hunters prey are wolves,
      breed = deer or                                                            ; deer or
      breed = boars ] in-radius 10 ) [ distance myself ]                         ; boars. Hunters just kill wolves in radius 5 km

  ifelse prey != nobody                                                          ; if there is some,
    [ ask prey [ die ]                                                           ; kill it!
    ]
    [ carefully
      [ face one-of neighbors with
        [ shade-of? green pcolor or shade-of? yellow pcolor
        ]
      ]
      [ rt random 360
      ]                                                                          ; if not, move
      fd 1
    ]
                                                                                 ; hunter is able to kill the wolf in random-float 100 < 10 of cases
end

;                            7.2.5 "kill-prey"
;--------------------------------------------------------------------------------

to hunt-prey                                                                     ; hunter procedure

  let prey min-one-of ( turtles with                                             ; if "kill-wolves" is not active, if "kill-wolves" is not activ
    [ breed = deer or                                                            ; hunters prey are deer or boars
      breed = boars ] in-radius 10 ) [ distance myself ]                         ; hunters just kill prey in radius 5 km

  ifelse prey != nobody                                                          ; if there is some,
    [ ask prey [ die ]                                                           ; kill it!
    ]
    [ right random 50                                                            ; if not, move
      left random 50
      forward 1
    ]
                                                                                 ; hunter is able to kill the prey in random-float 100 < 10 of cases
end



;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------

;____________________________________________________________________________________________
@#$#@#$#@
GRAPHICS-WINDOW
218
10
985
582
-1
-1
1.0
1
1
1
1
1
0
1
1
1
-379
379
-281
281
1
1
1
ticks
50.0

BUTTON
9
10
72
43
setup
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
145
10
208
43
go
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

BUTTON
77
10
140
43
go
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
310
209
343
num-hunters
num-hunters
0
1000
4.0
1
1
NIL
HORIZONTAL

CHOOSER
8
56
207
101
precaution-livestock
precaution-livestock
"no-management" "wooden-fence" "electric-fence" "shepherd-dog" "kill-wolves"
0

SWITCH
7
110
208
143
human-threats
human-threats
1
1
-1000

SLIDER
8
230
208
263
num-wolves
num-wolves
0
200
4.0
1
1
NIL
HORIZONTAL

MONITOR
1006
15
1063
60
NIL
year
17
1
11

MONITOR
1075
16
1132
61
NIL
month
17
1
11

MONITOR
1006
70
1063
115
NIL
day
17
1
11

MONITOR
1075
72
1132
117
NIL
doy
17
1
11

PLOT
1006
132
1344
282
Populations
Time
Counts
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Wolves" 1.0 0 -16777216 true "" "if display-plots? [plot count wolves]"
"Boars" 1.0 0 -7500403 true "" "if display-plots? [plot count boars]"
"Deer" 1.0 0 -2674135 true "" "if display-plots? [plot count deer]"
"Livestock" 1.0 0 -955883 true "" "if display-plots? [plot count livestock]"

PLOT
1007
295
1344
445
Forest damage
Time
Count
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if display-plots? [plot count patches with [ pcolor = brown ]]"

SLIDER
8
191
210
224
num-deer
num-deer
0
3000
552.0
1
1
*250
HORIZONTAL

SLIDER
9
271
211
304
num-livestock
num-livestock
0
2300
920.0
1
1
*250
HORIZONTAL

SLIDER
7
152
209
185
num-boars
num-boars
0
1000
180.0
1
1
*250
HORIZONTAL

SWITCH
1143
20
1340
53
display-plots?
display-plots?
0
1
-1000

MONITOR
1246
73
1296
118
wolves
count wolves
17
1
11

MONITOR
1194
72
1244
117
deer
count deer
17
1
11

MONITOR
1143
72
1193
117
boars
count boars
17
1
11

MONITOR
1296
73
1346
118
livestock
count livestock
17
1
11

SLIDER
6
366
211
399
boar-reproduce
boar-reproduce
0
1.5
0.61
0.01
1
NIL
HORIZONTAL

SLIDER
6
403
210
436
deer-reproduce
deer-reproduce
0
1.5
0.58
0.01
1
NIL
HORIZONTAL

SLIDER
7
444
210
477
wolf-reproduce
wolf-reproduce
0
1.2
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
9
484
211
517
livestock-reproduce
livestock-reproduce
0
0.1
0.03
0.01
1
NIL
HORIZONTAL

TEXTBOX
1012
452
1334
530
Note for the curve \"Forest damage\": Please consider, that the fact that the curve in the beginning goes down, is due to the procedure \"regrow-forest\": brown patches are turned into green, so some streets in the map.
9
0.0
1

SLIDER
7
541
209
574
wolf-gain-from-food
wolf-gain-from-food
0
100
56.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
# Return of _Canis lupus_ in Lower Saxony
![wolf](file:wolf-62898_1920.jpg)

## WHAT IS IT?

This model explores the impacts of the return of _Canis lupus_ in Lower Saxony on the balance of its possible future habitats in terms of predator-prey-relationship and competition to humans. The model furthermore tries to show how management strategies for monitored return of _Canis lupus_ could look like and how different they work. A successful management strategy leads to a stable system with balance between the populations of _Canis lupus_ and those of its wild living prey, as well as ensured security for residential humans and their livestock. A failured one leads to an instable system in which entire populations die.

## HOW IT WORKS

The main construction of this model is a basic predator-prey ecosystem, where wolves hunt the other animals (deer, boars and livestock). The wild animals should move mainly on the green patches, which are forests, heath, nature reserves and scrub lands. The livestock-animals should stay on the yellow patches which represents farm orchard and vineyard land. If no management is selected, and hunters are activated, they will represent the competitors of the wolves and will also hunt the wild animals.
The wild animals will randomly be sprouted on green patches and then wander randomly around on those patches. By moving forward, the wild animals lose energy. To gain energy, the hoofed game must eat forest patches. Once the forest is eaten it will only regrow after a fixed amount of time (14 ticks). The wolves must catch their prey (deer, boars or livestock) in order to replenish energy. When the animals run out of energy, they die. To allow the populations to continue, each sort of animal has a fixed probability of reproducing based on different months.
To provide the wolves from catching the livestock animals, the user can select different management strategies. Each strategy has its own probability of how often the wolves will be able to catch one of the livestock animals, except for the “kill wolves” option where the hunters just catch wolves.


## HOW TO USE IT

**1.**	Choose one management strategy.
**2.**	Adjust the slider and chooser parameters (see below), or use the default settings.
**3.**	Press the SETUP Button.
**4.**	Press the GO or the GO-forever Button to begin the simulation.
**5.**      Look at the monitors to see the current population sizes.
**6.**	Look at the plots Population and Forest damage to watch its fluctuation over time.

###PARAMETER

**Precaution-livestock:**

**1.**        No-management: Wolf catches all animals at the same level
**2.**        Wooden-fence: Wolf catches livestock on a probability of 0,5%
**3.**	  Electric-fence: Wolf catches livestock on a probability of 0,1%
**4.**	  Shepherd-dog: Wolf catches livestock on a probability of 0,07%
**5.**	  Kill-wolves: Hunters hunt wolves.

**Num-boars:** The initial size of boar population x 250. The default-setting is 180 x 250 which is the number of hunted boars in the hunt year of 2015/16.
**Num-deer:** The initial size of deer population x 250. The default-setting is 552 x 250 which is the number of hunted red and roe deer in the hunt year of 2015/16.
**Num-wolves:** The initial size of wolf population. The default-setting is 4 which is ca. 1/20 of the number of wolves probably living in Lower Saxony in 2017.
**Num-livestock:** The initial size of livestock population. The default-setting is 920 x 250 which is the number of sheep breeded in Lower Saxony.
**Num-hunters:** The initial number of hunters. The default-setting is 0.


**Boar-reproduce:** The probability of a boar reproducing at each time step in the months march and april. The default-setting is 0,75 which is the estimated probability of boars to give birth in a year divided through 60, the rounded number of 2 months.
**Deer-reproduce:** The probability of a deer reproducing at each time step. The default-setting is 0,58 which is the estimated probability of deer to give birth in a year divided through 60, the rounded number of 2 months.
**Wolf-reproduce:** The probability of a wolf reproducing at each time step. The default-setting is 0,5 which is the estimated probability of wolves to give birth in a year divided through 60, the rounded number of 2 months.
**Livestock-reproduce:** The probability of a livestock reproducing at each time step. The default-setting is 0,03, a quite low reproduction rate because the number of breeded sheep tends to stay nearly the same due to the tight chain of slaughter and man made reproduction.

**Wolf-gain-from-food:** The amount of energy which wolves gain from their food. The default-setting is 56, which is as much as they can survive 14 days without andy food.

**Human-threats:** Whether or not to include human threats in the simulation. If activated, wild animals will die when getting on blue patches, the big street in the map.
**Display-plots?:** Whether or not to show the plots.

##THINGS TO NOTICE##

Beware that the numbers of animals are to multiply with 100 to get the realistic numbers - and those in the case of deer and boars only of the individuals hunted in the hunt year 2015/16!
Take into account the note under the plot "Forest damage".
The livestock in this model stands mainly for sheep because they are hunted more often by wolves. However they have the shape of cows because you can see better their color on the background of the map.
One unit of energy is deducted for every step a wild animal takes.


## THINGS TO TRY

What happens, if you reduce the initial number by a quotient of again 10 or 100?
How fine do the default reproduction rates then work?

Try adjusting the parameters under various settings. How sensitive is the stability of the model to the particular parameters?

Try out the different management strategies!

How dangerous are streets for wild animals trying to wander and access habitat?

Who is more effective in hunting? Wolf or human?

Which influence has the food-gain on the population dynamics?

Can you find any parameters that generate a stable ecosystem that includes only animals?


## EXTENDING THE MODEL

Try changing the reproduction rules – for example, what would happen if reproduction depended on energy rather than being determined by a fixed probability?
Furthermore you could change the time in which the animals reproduce: how do the populations perform if they reproduce only within one month whith the same rate?

Look at the move-procedure: What does change if the animals wander more/ less far?


## NETLOGO FEATURES

To be able to see the map of Lower Saxony, you need the data file "map - Kopie.png". Download it into the same folder as the model file. This is also the case for the title foto up in this info tab: "wolf-62898_1920.jpg".

## RELATED MODELS

There are three different versions of the classical wolf sheep predation model in the NetLogo Models Library.
The basic one named "Wolf Sheep Pradation" explores the stability of the predator-prey ecosystem of sheep and wolves. It shows the basics of the parameters influencing population dynamics. Adjusting the initial size of the two populations, the amount of energy the animals gain from their food, the ability of food and the reproduction rates, you can learn about the interdependencies between those. You can observe contiuously the development of the populations and let show the energy level of every animal for every step the model takes. A stable system here as well is includes adjustments which guarantee stable population sizes of both species and prevent extinction.
Two other wolves models you can find in the folder "System Dynamics". "Wolf Sheep Preadtion (Docked Hybrid)" explores the relationship of two different kinds of models, one agent-based and the other aggregate. You can run them "docked side-by-side" or seperately. "Wolf Sheep Predation (System Dynamics)" shows (you can't adjust any parameters) the Lotka-Volterra equations of population growth.


## CREDITS AND REFERENCES

Baumgartner, H. et al. (2008): Der Wolf. Ein Raubtier in unserer Nähe. Haupt Verlag Bern

Dröscher Vitus ( 1988): Tiere in ihrem Lebensraum. Ravensburger Buchverlag Otto Maier GmbH, S. 82

Gräber, R., Strauß, E. und S. Johanshon (2016): Wild und Jagd – Landesjagdbericht
2015 / 2016. Niedersächsisches Ministerium für Ernährung, Landwirtschaft und
Verbraucherschutz (Hrsg.), Hannover, 116 Seiten ISSN 2197-9839

Grzimek Bernhard (Hrsg) (1987): Hunde. Die Arten im Vergleich. In: Grzimeks Enzyklopädie, Band 4, Säugetiere, S. 60f., Kindler Verlag GmbH, München


Institut für Terrestrische und Aquatische Wildtierforschung. Unter: http://www.tiho-hannover.de/de/kliniken-institute/institute/institut-fuer-terrestrische-und-aquatische-wildtierforschung/

Kontaktbüro Wölfe in Sachsen: Schutzmaßnahmen. Unter: http://www.wolf-sachsen.de/schadensvorbeugung


Schafzucht Niedersachsen (2017): Über die Schafzucht in Niedersachsen. Unter: http://www.schafzucht-niedersachsen.de/Schafzucht-Verbaende-Niedersachsen/index.php?option=com_content&view=article&id=23&Itemid=680&lang=de


Sodeikat, G.: Vermehrungsraten des Schwarzwildes im östlichen Niedersachsen. In: Niedersächsischer Jäger 17/2008


Treves A., Krofel M., McManus J.: Predator control should not be a shot in the dark von. In: Frontiers in Ecology and the Environment Ausgabe 14, Issue 7. S. 380-388, September 2016.

## LICENSE

Copyright 2017 Viktoria Sagolla, Amélie Klöffer

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

Dieses Werk ist lizenziert unter einer <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz</a
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

chess knight
false
0
Line -16777216 false 75 255 225 255
Polygon -7500403 true true 90 255 60 255 60 225 75 180 75 165 60 135 45 90 60 75 60 45 90 30 120 30 135 45 240 60 255 75 255 90 255 105 240 120 225 105 180 120 210 150 225 195 225 210 210 255
Polygon -16777216 false false 210 255 60 255 60 225 75 180 75 165 60 135 45 90 60 75 60 45 90 30 120 30 135 45 240 60 255 75 255 90 255 105 240 120 225 105 180 120 210 150 225 195 225 210
Line -16777216 false 255 90 240 90
Circle -16777216 true false 134 63 24
Line -16777216 false 103 34 108 45
Line -16777216 false 80 41 88 49
Line -16777216 false 61 53 70 58
Line -16777216 false 64 75 79 75
Line -16777216 false 53 100 67 98
Line -16777216 false 63 126 69 123
Line -16777216 false 71 148 77 145
Rectangle -7500403 true true 90 255 210 300
Rectangle -16777216 false false 90 255 210 300

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

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

farmtier (kuh)
false
15
Polygon -1 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 255 60 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -1 true true 73 210 86 251 62 249 48 208
Polygon -1 true true 25 114 16 195 9 204 23 213 25 200 39 123
Polygon -16777216 true false 60 75 30 90 45 105 75 105 75 90
Polygon -16777216 true false 108 116 99 129 113 143 124 148 135 150 150 150 165 135 165 120 147 105 129 88 120 90 111 91 104 103
Polygon -16777216 true false 46 174 65 171 74 182 62 190 58 201 48 196 50 184 45 174
Polygon -16777216 true false 265 78 256 86 257 93 271 105 279 104 275 96 275 89 270 83 267 77
Polygon -16777216 true false 221 66 221 81 231 81 237 84 239 78 243 74 243 70 239 66 234 65 222 64
Polygon -16777216 true false 90 147 109 157 105 165 90 165 77 161 63 161 56 148 60 135 66 136 69 142 78 143 79 150
Polygon -16777216 true false 196 221 187 216 181 221 181 225 190 232 190 237 198 241 197 221
Polygon -16777216 true false 55 225 64 221 72 230 72 238 67 240 63 245 59 236 61 231 57 228 54 227 57 223
Polygon -16777216 true false 23 145 32 139 37 123 31 120 26 105 26 117 21 143 24 144
Polygon -16777216 true false 210 135 202 138 189 158 189 175 203 176 212 160 224 159 229 144 225 135
Polygon -16777216 true false 173 85 172 96 181 103 194 102 208 97 205 93 203 88 184 86 174 86

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

jäger
false
2
Polygon -16777216 true false 135 120 150 105 285 105 285 120 225 120 210 135 165 135 135 150 135 120
Polygon -955883 true true 75 285 75 195 135 195 150 285 120 285 105 195 105 285 75 285
Polygon -13840069 true false 135 210 135 165 165 180 210 150 195 135 165 150 135 135 135 120 120 105 90 105 75 120 75 210 135 210
Circle -1 true false 71 41 67
Polygon -1 true false 210 150 210 135 195 135 210 150
Polygon -13840069 true false 75 75 60 75 60 60 75 60 75 45 90 30 120 30 135 45 135 60 150 60 150 75 75 75
Polygon -955883 true true 75 120 75 195 135 195 135 165 105 150 105 135 105 120 120 120 135 135 135 120 120 105 90 105 75 120
Polygon -16777216 true false 75 180 135 180 135 165 75 165 75 180
Polygon -16777216 true false 75 135 105 135 105 150 75 150 75 135
Polygon -6459832 true false 120 60 120 45 105 30 105 45 105 60 120 60

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

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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

rotwild
false
1
Polygon -2674135 true true 45 120 180 120 210 75 195 60 255 60 300 90 300 105 255 105 225 180 210 195 210 300 180 300 180 195 105 195 90 225 150 300 120 300 60 225 60 210 45 240 45 300 15 300 15 240 30 210 30 180 15 195 15 135 45 120
Polygon -6459832 true false 225 60 210 45 210 30 210 15 270 15 270 30 225 30 225 45 285 45 285 60 255 60 225 60

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

wildschwein
false
3
Polygon -6459832 true true 15 255 15 150 45 150 45 255 30 255
Polygon -6459832 true true 60 255 60 195 90 195 90 255 60 255
Polygon -6459832 true true 135 255 135 210 165 210 165 255 135 255
Polygon -6459832 true true 180 255 180 195 210 195 210 255 180 255
Polygon -7500403 true false 30 135 30 120
Polygon -6459832 true true 15 165 15 135 45 105 90 105 120 105 135 90 180 90 195 105 210 120 210 210 180 225 165 225 135 225 90 225 60 210 45 195 15 165
Polygon -6459832 true true 195 225 210 210 255 210 300 180 300 165 270 150 255 135 195 120 195 225
Polygon -6459832 true true 255 135 240 105 210 90 210 135 255 135
Polygon -1 true false 255 195 270 195 285 180 270 180 255 180 255 195
Polygon -6459832 true true 15 135 0 150 15 150 15 135

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
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
