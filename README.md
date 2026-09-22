# Z3 SMT Configurator Guide

This project contains a formal rule engine built using the **Z3 SMT Solver** and the standard **SMT-LIB2** language. It models and validates product configuration business rules (Emissions, Power Ratings, Frequencies, and Tank types).

## 🚀 Getting Started with the REPL

To start Z3 in interactive mode (Read-Eval-Print Loop) directly from your macOS terminal, run:

```bash
z3 -in
```

### Essential Interactive Shell Commands

* `(exit)` — Safely exit the interactive Z3 environment.
* `(check-sat)` — Asks Z3 if the current rules and filters can be satisfied together. Returns `sat` or `unsat`.
* `(get-model)` — Run this after `sat` to view the generated assignments for every variable.
* `(get-unsat-core)` — Run this after `unsat` to identify exactly which named rules caused the conflict.

---

## 🛠️ Executing Files Directly

Instead of pasting code into the REPL line-by-line, you can execute your `.smt2` source scripts directly:

```bash
z3 generator.smt2
```
*Note: Ensure your script has a command like `(check-sat)` at the bottom, or Z3 will execute quietly without terminal printouts.*

---

## 💡 Common Diagnostic Patterns

### 1. The Push/Pop Sandbox Pattern
To test temporary conditions without modifying or overriding your core business rules permanently, wrap your testing queries inside a `(push 1)` and `(pop 1)` block:

```smt2
(push 1)
  (assert stage5)
  (assert (not def)) ; Contradicts rule: (=> stage5 def)
  (check-sat)        ; Returns: unsat
  (get-unsat-core)   ; Returns: (def-required)
(pop 1)
; Core rules remain clean here
```

### 2. Multi-Solution Discovery (All-SAT) Pattern
SMT solvers only return one solution at a time. To find **all** possible valid combinations for a given setup, find a solution, copy its core assignments, assert their negation to block them, and check again:

```smt2
(push 1)
  (assert stage3)
  (assert kva250)
  
  (check-sat) ; Returns sat
  (get-model) ; Shows Solution A (e.g., hz50=true, hz60=false)
  
  ; Block Solution A manually
  (assert (not (and hz50 (not hz60))))
  
  (check-sat) ; Returns sat
  (get-model) ; Shows Solution B (e.g., hz50=false, hz60=true)
  
  ; Block Solution B manually
  (assert (not (and (not hz50) hz60)))
  
  (check-sat) ; Returns unsat (No more variations left!)
(pop 1)
```

### Executing Inert Gas BOM Generation in REPL

```smt2
(include "inertgas.smt2")
(assert (= nDist 40))   
(assert (= nStand 4))
(assert (= zones 20))
(check-sat)
sat
(eval bom-dist)
(eval bom-stand)
(eval bom)
```

### Pretty-Print Your BOM Tree

Делаем файл исполняемым: `chmod +x pretty-bom.sh`
Запускаете скрипт: `./pretty-bom.sh`
Используйте код с осторожностью. Вставляете ваш текст из Z3. 
Нажимаете Enter (перейти на новую пустую строку).
Нажимаете комбинацию клавиш Ctrl + D (сигнал терминалу «я закончил вставлять данные»).
Cкрипт мгновенно выдаст идеально чистое дерево.