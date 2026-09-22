; ============================================================
; Inert Gas System Configurator
; Prototype 1
;
; Inputs:
;   nDist  - cylinders in CylinderBankDistribution
;   nStand - cylinders in CylinderBankStandAlone
;   zones  - number of protected zones
;
; 0 cylinders means that the corresponding bank does not exist.
;
; Maximum: 100 cylinders per bank.
; ============================================================


; ------------------------------------------------------------
; 0. Printer options
;
; Without these, Z3 factors repeated/large subterms into
; "let"-bound aliases (a!1, a!2, ...) once a term passes a
; size threshold, and prints those blocks out of the order
; you'd expect. Raising the threshold and the depth limit
; makes eval print bom-dist / bom-stand / bom as one plain,
; top-to-bottom term instead.
; ------------------------------------------------------------

(set-option :pp.min_alias_size 1000000)
(set-option :pp.max_depth 1000)


; ------------------------------------------------------------
; 1. Input variables
; ------------------------------------------------------------

(declare-const nDist Int)
(declare-const nStand Int)
(declare-const zones Int)


; ------------------------------------------------------------
; 2. Validation rules
; ------------------------------------------------------------

(assert (>= nDist 0))
(assert (<= nDist 100))

(assert (>= nStand 0))
(assert (<= nStand 100))

(assert (>= zones 0))


; ------------------------------------------------------------
; 3. Helper functions
; ------------------------------------------------------------

; Ceiling division:
;
;   ceil(x / d)
;
; For positive integer d.

(define-fun ceil_div ((x Int) (d Int)) Int
  (div (+ x (- d 1)) d)
)



; ------------------------------------------------------------
; BoM tree datatypes
; ------------------------------------------------------------

(declare-datatypes ((Node 0) (NodeList 0))
  (
    (
      (node
        (name String)
        (quantity Int)
        (children NodeList))
    )

    (
      (nil)
      (cons
        (head Node)
        (tail NodeList))
    )
  )
)

; ------------------------------------------------------------
; 5. List helpers
; ------------------------------------------------------------

; Empty list is already:
;
;   nil
;
; List constructor:
;
;   cons
;
; ------------------------------------------------------------


; ------------------------------------------------------------
; 6. Distribution-bank components
; ------------------------------------------------------------

(define-fun dist_cylinders () Int
  nDist)

(define-fun dist_manifolds () Int
  (ite (> nDist 0)
       (ceil_div nDist 5)
       0))

(define-fun dist_pressure_switches () Int
  (ite (> nDist 0)
       zones
       0))

(define-fun dist_discharge_valves () Int
  nDist)

(define-fun dist_hoses () Int
  nDist)

(define-fun dist_signal_cables () Int
  (ite (> nDist 0) 1 0))

(define-fun dist_solenoid_actuators () Int
  (ite (> nDist 0)
       zones
       0))

(define-fun dist_start_kits () Int
  (ite (> nDist 0)
       zones
       0))

(define-fun dist_zone_kits () Int
  (ite (> nDist 0)
       zones
       0))

(define-fun dist_test_ports () Int
  (ite (> nDist 0)
       zones
       0))

(define-fun dist_activation_kit () Int
  (ite (> nDist 0) 1 0))

(define-fun dist_end_plug () Int
  (ite (> nDist 0) 1 0))

(define-fun dist_stainless_tube_m () Int
  (ite (> nDist 0)
       (* 2 zones)
       0))

(define-fun dist_rail_m () Int
  (ite (> nDist 0)
       (* nDist 2)
       0))

(define-fun dist_brackets () Int
  nDist)

(define-fun dist_labels () Int
  nDist)


; ------------------------------------------------------------
; 7. Stand-alone-bank components
; ------------------------------------------------------------

(define-fun stand_cylinders () Int
  nStand)

(define-fun stand_manifolds () Int
  (ite (> nStand 0) 1 0))

(define-fun stand_pressure_switches () Int
  (ite (> nStand 0) 1 0))

(define-fun stand_discharge_valves () Int
  nStand)

(define-fun stand_hoses () Int
  nStand)

(define-fun stand_signal_cables () Int
  (ite (> nStand 0) 1 0))

(define-fun stand_solenoid_actuators () Int
  (ite (> nStand 0)
       zones
       0))

(define-fun stand_rail_m () Int
  (ite (> nStand 0)
       nStand
       0))

(define-fun stand_brackets () Int
  (* nStand 2))

(define-fun stand_labels () Int
  nStand)


; ------------------------------------------------------------
; 8. Distribution-bank BoM
; ------------------------------------------------------------

(define-fun bom-dist () Node

  (node
    "CylinderBankDistribution"
    1

    (cons
      (node "InertGasCylinder" dist_cylinders nil)

      (cons
        (node "MT_Manifold" dist_manifolds nil)

        (cons
          (node "SV22PipePressureSwitchKit"
                dist_pressure_switches
                nil)

          (cons
            (node "DischargeValve"
                  dist_discharge_valves
                  nil)

            (cons
              (node "InertGasHose"
                    dist_hoses
                    nil)

              (cons
                (node "Manoswitch5K6CableIEC331_5.0m"
                      dist_signal_cables
                      nil)

                (cons
                  (node "SolenoidActuator"
                        dist_solenoid_actuators
                        nil)

                  (cons
                    (node "SVCiVStartKit"
                          dist_start_kits
                          nil)

                    (cons
                      (node "SV22ZoneKit"
                            dist_zone_kits
                            nil)

                      (cons
                        (node "SVTestPortKit"
                              dist_test_ports
                              nil)

                        (cons
                          (node "SVCiNextKit070Elbow"
                                dist_activation_kit
                                nil)

                          (cons
                            (node "SVCiNextKit028Straight"
                                  (ite (> nDist 2)
                                       (- nDist 2)
                                       0)
                                  nil)

                            (cons
                              (node "SV22EndPlugKit"
                                    dist_end_plug
                                    nil)

                              (cons
                                (node "StainlessSteelTube_m"
                                      dist_stainless_tube_m
                                      nil)

                                (cons
                                  (node "CylinderRail_m"
                                        dist_rail_m
                                        nil)

                                  (cons
                                    (node "CylinderBracket"
                                          dist_brackets
                                          nil)

                                    (cons
                                      (node "CylinderLabel"
                                            dist_labels
                                            nil)

                                      nil)))))))))))))))))
))


; ------------------------------------------------------------
; 9. Stand-alone-bank BoM
; ------------------------------------------------------------

(define-fun bom-stand () Node

  (node
    "CylinderBankStandAlone"
    1

    (cons
      (node "InertGasCylinder"
            stand_cylinders
            nil)

      (cons
        (node "Ci_MT_Manifold"
              stand_manifolds
              nil)

        (cons
          (node "CiMTPressureSwitchKit5K6IEC331"
                stand_pressure_switches
                nil)

          (cons
            (node "DischargeValve"
                  stand_discharge_valves
                  nil)

            (cons
              (node "InertGasHose"
                    stand_hoses
                    nil)

              (cons
                (node "Manoswitch5K6CableIEC331_5.0m"
                      stand_signal_cables
                      nil)

                (cons
                  (node "SolenoidActuator"
                        stand_solenoid_actuators
                        nil)

                  (cons
                    (node "CylinderRail_m"
                          stand_rail_m
                          nil)

                    (cons
                      (node "CylinderBracket"
                            stand_brackets
                            nil)

                      (cons
                        (node "CylinderLabel"
                              stand_labels
                              nil)

                        nil))))))))))
))


; ------------------------------------------------------------
; 10. Root system BoM
;
; A bank with zero cylinders is omitted.
; ------------------------------------------------------------

(define-fun bom () Node

  (node
    "InertGasSystem"
    1

    (cons
      (ite (> nDist 0)
           bom-dist
           (node "No_CylinderBankDistribution"
                 0
                 nil))

      (cons
        (ite (> nStand 0)
             bom-stand
             (node "No_CylinderBankStandAlone"
                   0
                   nil))

        nil)))
)


; ------------------------------------------------------------
; 11. Example interactive session
;
; Uncomment these three assertions when testing directly.
; ------------------------------------------------------------

; (assert (= nDist 8))
; (assert (= nStand 4))
; (assert (= zones 3))

; (check-sat)

; (eval bom-dist)
; (eval bom-stand)
; (eval bom)