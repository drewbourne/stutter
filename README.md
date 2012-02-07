# Stutter

A lisp implemented in AS3. 

Started from [Lisp in 32 lines of Ruby](http://blog.fogus.me/2012/01/25/lisp-in-40-lines-of-ruby/).

Extended while working through [SICP](http://mitpress.mit.edu/sicp/).


# Examples

```AS3
(label x 11)
x
// => 11

(quote x)
// => x

(car (1 2 3))
// => 1

(cdr (1 2 3))
// => (2 3)

(eq 2 2)
// => t

(if (= 2 3) 4 5)
// => 5

(cond ((= 3 4) 1)
	  ((> 3 4) 2)
	  (else t))
// => t

(atom x)
// => t

(atom (1 2 3))
// => nil

(and (= 2 2) (= 3 3))
// => t

(or (> 2 3) (< 3 4))
// => t

(not (< 3 4))
// => nil

(not (not (< 3 4)))
// => t

(+ 2 3)
// => 5

(- 4 5)
// => -1

(* 6 7)
// => 42

(/ 9 3)
// => 3

(< 2 3)
// => t

(> 2 3)
// => nil

(= 10 10)
// => t

// long hand for defining a named function
(label abs (quote (lambda (x) 
						  (if (< x 0)
							  (- x)
							  x))))

(abs -4)

// no shorthand yet. 

```


# See also

There is another [STUTTER](http://galaru.net/stutter/), it is also a lisp. They are unrelated projects. 

