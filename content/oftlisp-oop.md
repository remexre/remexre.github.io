+++
date = "2017-08-11"
draft = true
tags = ["OftLisp"]
title = "Object-Oriented Programming in OftLisp"
+++

TODO The whole thing

```oftlisp
(defclass dog ()
  (var breed)
  (var name))

(defmethod make-sound ((this dog))
  "Woof!")
(defmethod name ((this dog))
  (format "The {} {}" (breed this) (name this)))

(defclass cow ())

(defmethod make-sound ((this cow))
  "Moo")
(defmethod name ((this cow))
  "The Cow")

(defn main ()
  (def pupper (dog "Malamute" "Joey"))
  
  ; Prints "The Malamute Joey says Woof!"
  (println
    (name pupper)
	" says "
    (make-sound pupper)))
```
