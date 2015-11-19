; #!r6rs
; (import (rnrs base (6)) (rnrs eval (6)))


; shorthand for creating a 4-element list
; specifically used for the format `'if 'expr 'expr1 'expr2`
(define make4list
  (lambda (a b c d)
    (cons a (cons b (cons c (cons d '()))))))

; check for built-in functions on either side of the
; comparision if the comparison has the same length
(define (check-function a b)
  (or (equal? (car a) 'if)      (equal? (car b) 'if)
      (equal? (car a) 'let)     (equal? (car b) 'let)
      (equal? (car a) 'lambda)  (equal? (car b) 'lambda)
      (equal? (car a) 'quote)   (equal? (car b) 'quote)))

; check variables of 'let' recursively
; if equal, return true, otherwise false
(define (check-let-variables a b)
  (if (and (equal? a '()) (equal? b '()))
    #t
    (if (equal? (car (car a)) (car (car b)))
      (check-let-variables (cdr a) (cdr b))
      #f)))


(define compare-expr-const
  (lambda (a b)
    (if (equal? a b)
      a
      (if (and (equal? a #t) (equal? b #f))
        'TCP
        (if (and (equal? a #f) (equal? b #t))
          '(not TCP)
          (make4list 'if 'TCP a b))))))

; return empty list if either 'a' or 'b' is empty
; otherwise recursively compare each element in the list
(define compare-expr-list
  (lambda (a b)
    (if (or (equal? a '()) (equal? b '()))
        '()
        (cons (compare-expr (car a) (car b)) 
              (compare-expr-list (cdr a) (cdr b))))))

; check if arguments in lambda are equal
; if yes, then compare the body as a list
; otherwise compare it as a constant for any differences
(define (compare-expr-lambda a b)
  (if (equal? (car (cdr a)) (car (cdr b)))
    (compare-expr-list a b)
    (compare-expr-const a b)))

; if the 'let' expression binds the same variables
; compare the body as a list
; otherwise compare it as a constant for any differences
(define (compare-expr-let a b)
  (if (check-let-variables (car (cdr a)) (car (cdr b)))
    (compare-expr-list a b)
    (compare-expr-const a b)))

; check if 'a' and 'b' are lists
; if yes, then check if they have the same length
;   if yes, then check if their first elements are the same
;     if they are the same, then we match then with
;       'quote'  --> compare-expr-const (quote)
;       'lambda' --> compare-expr-lambda (lambda expression)
;       'let'    --> compare-expr-let (let expression)
;       '_'      --> compare-expr-list (normal list)
;     if not, then we check if either side has a built-in function
;       if yes --> compare-expr-const
;       if no  --> compare-expr-list (normal list)
;   if no --> compare-expr-const
; if no --> compare-expr-const
(define (compare-expr a b)
  (if (and (list? a) (list? b))
    (if (equal? (length a) (length b))
      (if (equal? (car a) (car b))
        (match (car a)
          ['quote (compare-expr-const a b)]
          ['lambda (compare-expr-lambda a b)]
          ['let (compare-expr-let a b)]
          [_ (compare-expr-list a b)])
        (if (check-function a b)
          (compare-expr-const a b)
          (compare-expr-list a b)))
      (compare-expr-const a b))
    (compare-expr-const a b)))


; test-compare-expr
(define (test-compare-expr x y)
  (let ((compare-res (compare-expr x y)))
    (and (equal? (eval x)
                 (eval (cons 'let (cons '((TCP #t)) (cons compare-res '())))))
         (equal? (eval y)
                 (eval (cons 'let (cons '((TCP #f)) (cons compare-res '()))))))))


; test-x
(define test-x
  '(cons
    ; same bindings for 'let'
    (let ((a 5) (b 6))
      ; different formals for 'lambda'
      ; same bodies for 'lambda'
      ((lambda (d c) (* c d)) a b))
    (cons
      ; different bindings for 'let'
      (let ((c #t) (d 11) (e 12))
        ; same formals for 'lambda'
        ; different bodies for 'lambda'
        ((lambda (x y z) (if x y z)) c d e)) 
      (cons
        ; procedures
        ; constants
        ; boolean constants
        (if (equal? (+ 3 5) 8) #t #f)
        (cons
          ; same lists
          '(if #t 5 6)
          ; different lists
          '(if #t 5 6))))))

; test-y
(define test-y
  '(cons
    (let ((a 5) (b 6))
      ((lambda (c d) (* c d)) a b))
    (cons
      (let ((a #t) (b 11) (c 12))
        ((lambda (x y z) (if x z y)) a b c))
      (cons
        (if (equal? (- 12 5) 7) #f #t)
        (cons
          '(if #t 5 6)
          '(if #f 5 7))))))


(compare-expr test-x test-y)
(test-compare-expr test-x test-y)

; other tests

; (test-compare-expr 12 20)
; (test-compare-expr 12 12)
; (test-compare-expr 12 20)
; (test-compare-expr #t #t)
; (test-compare-expr #f #f)
; (test-compare-expr #t #f)
; (test-compare-expr #f #t)

; (define a 3)
; (define b 4)
; (define c 5)

; (test-compare-expr 'a '(cons a b))
; (test-compare-expr '(cons a b)
;                    '(cons a b))
; (test-compare-expr '(cons a b)
;                    '(cons a c))
; (test-compare-expr '(cons (cons a b) (cons b c)) 
;                    '(cons (cons a c) (cons a c)))
; (test-compare-expr '(cons a b)
;                    '(list a b))
; (test-compare-expr '(list)
;                    '(list a))
; (test-compare-expr ''(a b)
;                    ''(a c))
; (test-compare-expr '(quote (a b))
;                    '(quote (a c)))
; (test-compare-expr '(quoth (a b))
;                    '(quoth (a c)))

; (define x #t)
; (define y 6)
; (define z 7)

; (test-compare-expr '(if x y z)
;                    '(if x z z))
; (test-compare-expr '(if x y z)
;                    '(if x y))
; (test-compare-expr '(if x y z)
;                    '(g x y z))
; (test-compare-expr '(let ((a 1)) (f a))
;                    '(let ((a 2)) (g a)))
; (test-compare-expr '(+ #f (let ((a 1) (b 2)) (f a b)))
;                    '(+ #t (let ((a 1) (c 2)) (f a c))))
; (test-compare-expr '((lambda (a) (f a)) 1)
;                    '((lambda (a) (g a)) 2))
; (test-compare-expr '((lambda (a b) (f a b)) 1 2)
;                    '((lambda (a b) (f b a)) 1 2))
; (test-compare-expr '((lambda (a b) (f a b)) 1 2)
;                    '((lambda (a c) (f c a)) 1 2))


(compare-expr 12 20)
(compare-expr 12 12)
(compare-expr 12 20)
(compare-expr #t #t)
(compare-expr #f #f)
(compare-expr #t #f)
(compare-expr #f #t)
(compare-expr 'a '(cons a b))
(compare-expr '(cons a b)
              '(cons a b))
(compare-expr '(cons a b)
              '(cons a c))
(compare-expr '(cons (cons a b) (cons b c)) 
              '(cons (cons a c) (cons a c)))
(compare-expr '(cons a b)
              '(list a b))
(compare-expr '(list)
              '(list a))
(compare-expr ''(a b)
              ''(a c))
(compare-expr '(quote (a b))
              '(quote (a c)))
(compare-expr '(quoth (a b))
              '(quoth (a c)))
(compare-expr '(if x y z)
              '(if x z z))
(compare-expr '(if x y z)
              '(if x y))
(compare-expr '(if x y z)
              '(g x y z))
(compare-expr '(let ((a 1)) (f a))
              '(let ((a 2)) (g a)))
(compare-expr '(+ #f (let ((a 1) (b 2)) (f a b)))
              '(+ #t (let ((a 1) (c 2)) (f a c))))
(compare-expr '((lambda (a) (f a)) 1)
              '((lambda (a) (g a)) 2))
(compare-expr '((lambda (a b) (f a b)) 1 2)
              '((lambda (a b) (f b a)) 1 2))
(compare-expr '((lambda (a b) (f a b)) 1 2)
              '((lambda (a c) (f c a)) 1 2))
