(set-option :produce-unsat-cores true)

; ---- Configuration: 14 boolean choices ----
(declare-const stage3 Bool) (declare-const stage5 Bool) (declare-const tier4 Bool)
(declare-const kva250 Bool) (declare-const kva400 Bool) (declare-const kva560 Bool)
(declare-const hz50 Bool)   (declare-const hz60 Bool)
(declare-const def Bool)
(declare-const tank7d Bool) (declare-const tank10d Bool) (declare-const tank14d Bool)
(declare-const dnv Bool)    (declare-const boem Bool)

; ---- Helper ----
(define-fun exactlyOne ((a Bool) (b Bool) (c Bool)) Bool
  (and (or a b c) (not (and a b)) (not (and a c)) (not (and b c))))

; ---- Valid: the business rules ----
(assert (! (exactlyOne stage3 stage5 tier4)              :named emission-stage))
(assert (! (exactlyOne kva250 kva400 kva560)             :named power-rating))
(assert (! (or hz50 hz60)                                :named frequency-chosen))
(assert (! (not (and hz50 hz60))                         :named frequency-not-both))
(assert (! (=> (or stage5 tier4) def)                    :named def-required))
(assert (! (=> def (exactlyOne tank7d tank10d tank14d))  :named tank-choice))
(assert (! (=> (or stage3 stage5) dnv)                   :named dnv-required))
(assert (! (not (and tier4 dnv))                         :named no-dnv-with-tier4))
(assert (! (=> tier4 boem)                               :named boem-required))
(assert (! (not (and (or stage3 stage5) boem))           :named no-boem-with-stage5-stage3))

; ---- Example configurations (complete) ----
(declare-const config1 Bool)   ; valid
(assert (= config1 (and (not stage3) stage5 (not tier4)
                        (not kva250) kva400 (not kva560)
                        hz50 (not hz60)
                        def (not tank7d) tank10d (not tank14d)
                        dnv (not boem))))
(declare-const config2 Bool)   ; invalid: stage5 without def
(assert (= config2 (and (not stage3) stage5 (not tier4)
                        (not kva250) kva400 (not kva560)
                        hz50 (not hz60)
                        (not def) (not tank7d) (not tank10d) (not tank14d)
                        dnv (not boem))))

(check-sat)