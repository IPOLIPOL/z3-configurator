; ============================================================
; Inert Gas System Configurator
; Prototype 1
;
; Inputs:
;   nDist  - cylinders in CylinderBankDistribution
;   nStand - cylinders in CylinderBankStandAlone
;   zones  - number of protected zones by CylinderBankDistribution
;   zones_s  - number of protected zones by CylinderBankStandAlone
;
; 0 cylinders means that the corresponding bank does not exist.
;
; Maximum: 100 cylinders per bank.
; ============================================================

; ------------------------------------------------------------
; 0. Printer options
; ------------------------------------------------------------

(set-option :pp.min_alias_size 1000000)
(set-option :pp.max_depth 1000)

; ------------------------------------------------------------
; 1. Input variables
; ------------------------------------------------------------

(declare-const nDist Int)
(declare-const nStand Int)
(declare-const zones Int)
(declare-const zones_s Int)
; ------------------------------------------------------------
; 2. Validation rules
; ------------------------------------------------------------

(assert (>= nDist 0))
(assert (<= nDist 100))

(assert (>= nStand 0))
(assert (<= nStand 100))

(assert (>= zones 0))
(assert (>= zones_s 0))

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
        (component_name String)
        (variant_name String)
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
; 6. Distribution-bank components quantities
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

(define-fun dist_activation_kit_elbow () Int
  (ite (> nDist 0) 1 0))

(define-fun dist_activation_kit_straight () Int
  (ite (> nDist 2)
       (- nDist 2)
       0))

(define-fun dist_end_plug () Int
  (ite (> nDist 0) 1 0))

(define-fun dist_stainless_tube_m () Int
  (ite (> nDist 0)
       (* 2 zones)
       0))

(define-fun dist_seal_plastic_red () Int
  nDist)

(define-fun dist_seal_wire_finess_ss () Int
  nDist)

(define-fun dist_rail_m () Int
  nDist)

(define-fun dist_rail_covers () Int
    (ite (> nDist 0)
       8
       0))

(define-fun dist_brackets () Int
  nDist)

(define-fun dist_labels () Int
  nDist)


; ------------------------------------------------------------
; 7. Stand-alone-bank components quantities
; ------------------------------------------------------------

(define-fun stand_cylinders () Int
  nStand)

(define-fun stand_manifolds () Int
    (ite (> nStand 0)
       zones_s
       0))

(define-fun stand_pressure_switches () Int
  (ite (> nStand 0) 1 0))

(define-fun ci_mt_orifice_kit () Int
  (ite (> nStand 0) 1 0))

(define-fun stand_discharge_valves () Int
  nStand)

(define-fun stand_hoses () Int
  nStand)

(define-fun stand_signal_cables () Int
  (ite (> nStand 0) 1 0))

(define-fun stand_solenoid_actuators () Int
    (ite (> nStand 0)
       zones_s
       0))

(define-fun stand_seal_plastic_red () Int
  nStand)

(define-fun stand_seal_wire_finess_ss () Int
  nStand)

(define-fun stand_rail_m () Int
  nStand)

(define-fun stand_rail_covers () Int
    (ite (> nStand 0)
       4
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
    "CylinderBank" "CylinderBankDistribution"
    1

    (cons
      (node "InertGasCylinder" "Cylinder80300M25DNV" dist_cylinders nil)

      (cons
        (node "MT_Manifold" "SV22_MT_X_Manifold" dist_manifolds nil)

        (cons
          (node "SV22PipePressureSwitchKit" "SV22PipePSKit5K6IEC331" dist_pressure_switches nil)

          (cons
            (node "DischargeValve" "CiIV8300ManoswitchIEC331" dist_discharge_valves nil)

            (cons
              (node "InertGasHose" "HoseDn10400L1000Aisi316" dist_hoses nil)

              (cons
                (node "InertGasCable" "Manoswitch5K6CableIEC331_5.0m" dist_signal_cables nil)

                (cons
                  (node "SolenoidActuator" "CiIS8BSolenoidManualSemco" dist_solenoid_actuators nil)

                    (cons
                      (node "SV22ZoneKit" "SV22ZoneKitNpt1CalibrCiV" dist_zone_kits nil)

                        (cons
                          (node "PneumaticActivationKit" "SVCiNextKit070Elbow" dist_activation_kit_elbow nil)

                          (cons
                            (node "PneumaticActivationKit" "SVCiNextKit028Straight" dist_activation_kit_straight nil)

                            (cons
                                (node "SVBuildComponent" "SVCiVStartKit" dist_start_kits nil)

                                (cons
                                    (node "SVBuildComponent" "SVTestPortKit" dist_test_ports nil)

                                    (cons
                                      (node "SVBuildComponent" "SV22EndPlugKit" dist_end_plug nil)

                                        (cons
                                          (node "InertGasAccessories" "StainlessSteelTube_m" dist_stainless_tube_m nil)

                                            (cons
                                            (node "InertGasAccessories" "SealPlasticRed" dist_seal_plastic_red nil)

                                            (cons
                                                (node "InertGasAccessories" "SealWireFinessSS" dist_seal_wire_finess_ss nil)

                                                (cons
                                                    (node "CylinderRail" "CylinderRailCylRailxcylStainless_m" dist_rail_m nil)

                                                    (cons
                                                    (node "CylinderRailCover" "CylinderRailEndCover" dist_rail_covers nil)

                                                        (cons
                                                        (node "CylinderBracket" "CylBracket2x80KtAisi316" dist_brackets nil)

                                                        (cons
                                                            (node "Label" "CylinderLabel" dist_labels nil)

                                                nil))))))))))))))))))))
))


; ------------------------------------------------------------
; 9. Stand-alone-bank BoM
; ------------------------------------------------------------

(define-fun bom-stand () Node

  (node
    "CylinderBank" "CylinderBankStandAlone"
    1

    (cons
      (node "InertGasCylinder" "Cylinder80300M25DNV" stand_cylinders nil)

      (cons
        (node "MT_Manifold" "Ci_MT_Manifold" stand_manifolds nil)

        (cons
          (node "CiMTPressureSwitchKit" "CiMTPressureSwitchKit5K6IEC331" stand_pressure_switches nil)

          (cons
            (node "CiMTOrificeKit" "CiMTnptOrificeKitCalibrated" ci_mt_orifice_kit nil)

            (cons
                (node "DischargeValve" "CiIV8300ManoswitchIEC331" stand_discharge_valves nil)

                (cons
                    (node "InertGasHose" "HoseDn10400L1000Aisi316" stand_hoses nil)

                    (cons
                      (node "InertGasCable" "Manoswitch5K6CableIEC331_5.0m" stand_signal_cables nil)

                      (cons
                        (node "SolenoidActuator" "CiIS8BSolenoidManualSemco" stand_solenoid_actuators nil)

                        (cons
                          (node "InertGasAccessories" "SealPlasticRed" stand_seal_plastic_red nil)

                            (cons
                              (node "InertGasAccessories" "SealWireFinessSS" stand_seal_wire_finess_ss nil)

                                (cons
                                  (node "CylinderRail" "CylinderRailCylRailxcylStainless_m" stand_rail_m nil)

                                    (cons
                                      (node "CylinderRailCover" "CylinderRailEndCover" stand_rail_covers nil)

                                        (cons
                                          (node "CylinderBracket" "CylBracket3050LKit25Aisi316" stand_brackets nil)

                                            (cons
                                              (node "Label" "CylinderLabel" stand_labels nil)

                                                nil))))))))))))))
))


; ------------------------------------------------------------
; 10. Root system BoM
;
; A bank with zero cylinders is omitted.
; ------------------------------------------------------------

(define-fun bom () Node

  (node
    "InertGasSystem"
    "InertGasSystem"
    1

    (cons
      (ite (> nDist 0)
           bom-dist
           (node "No_CylinderBankDistribution"
                 ""
                 0
                 nil))

      (cons
        (ite (> nStand 0)
             bom-stand
             (node "No_CylinderBankStandAlone"
                   ""
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
; (assert (= zones_s 2))

; (check-sat)

; (eval bom-dist)
; (eval bom-stand)
; (eval bom)