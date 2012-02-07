# Stutter

A lisp implemented in AS3. 

Started from [Lisp in 32 lines of Ruby](http://blog.fogus.me/2012/01/25/lisp-in-40-lines-of-ruby/).

Extended while working through [SICP](http://mitpress.mit.edu/sicp/).


# Example

```AS3
(label abs (quote (lambda (x) 
						  (if (< x 0)
							  (- x)
							  x))))

(abs -4)
```


# See also

There is another [STUTTER](http://galaru.net/stutter/), it is also a lisp. They are unrelated projects. 

