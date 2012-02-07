package stutter 
{
	import org.flexunit.assertThat;
	import org.hamcrest.Matcher;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.number.closeTo;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;

	public class SICPTest
	{
		private var runtime:StutterRunTime;
		private var reader:StutterReader;

		[Before]
		public function setup():void 
		{
			runtime = new StutterRunTime();
			reader = new StutterReader();
		}

		private function eval(expression:String):*
		{
			reader.load(expression);

			var sexp:*;
			var result:*;

			while (reader.hasTokens() && (sexp = reader.parse()))
			{
				result = runtime.eval(sexp);
			}

			return result;
		}

		private function assert(expression:String, result:*):void 
		{
			assertThat(expression, eval(expression), result is Matcher ? result : equalTo(result));
		}

		private function ignore(expression:String):void 
		{
			trace('ignore: ', expression);
		}

		[Test(order=1)]
		public function ex1():void
		{
			var result:* = eval(<![CDATA[
				(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))
				]]>.toString());
			
			assertThat(result, equalTo(57));
		}

		[Test(order=2)]
		public function ch1_1_2_ex1():void 
		{
			eval(<![CDATA[
				(label size 2)
				]]>.toString());

			var result:* = eval(<![CDATA[
				(* 5 size)
				]]>.toString())
			
			assertThat(result, equalTo(10));
		}

		[Test(order=3)]
		public function ch1_1_2_ex2():void 
		{
			eval('(label pi 3.14159)');
			eval('(label radius 10)');
			assert('(* pi (* radius radius))', 314.159);
			eval('(label circumference (* 2 pi radius)');
			assert('(circumference)', 62.8318);
		}

		[Test(order=4)]
		public function ch1_1_4_ex1():void 
		{
			eval('(label square (quote (lambda (x) (* x x)))');
			assert('(square 21)', 441);
			assert('(square (+ 2 5))', 49);
			assert('(square (square 3))', 81);

			eval('(label sum-of-squares (quote (lambda (x y) (+ (square x) (square y)))))');
			assert('(sum-of-squares 3 4)', 25);

			eval('(label f (quote (lambda (a) (sum-of-squares (+ a 1) (* a 2)))))');
			assert('(f 5)', 136);
		}

		[Ignore]
		[Test(order=5)]
		public function ch1_1_6_ex1():void 
		{
			eval(<![CDATA[
				
				(label abs (quote (lambda (x) 
									(cond ((> x 0) x)
										  ((= x 0) 0)
										  ((< x 0) (- x))
									))))

				]]>.toString());

			assert('(abs 4)', 4);
			assert('(abs 0)', 0);
			assert('(abs -4)', 4);
		}

		[Test(order=6)]
		public function ch1_1_6_ex2():void 
		{
			eval(<![CDATA[
				
				(label abs (quote (lambda (x) 
									(if (< x 0)
										(- x)
										x))))

				]]>.toString());

			assert('(abs 4)', 4);
			assert('(abs 0)', 0);
			assert('(abs -4)', 4);
		}

		[Test(order=7)]
		public function ch1_1_6_ex3():void 
		{
			eval('(label x 6)');
			assert('(and (> x 5) (< x 10))', TRUE);
		}

		[Test(order=8)]
		public function ch1_1_6_ex4():void 
		{
			eval('(label x 6)');
			assert('(or (> x 5) (< x 3))', TRUE);
		}

		[Test(order=9)]
		public function ch1_1_6_ex5():void 
		{
			eval('(label x nil)');
			eval('(label y t)');
			assert('(not x)', TRUE);
			assert('(not y)', FALSE);
			assert('(not (not x))', FALSE);
		}

		[Test(order=10)]
		public function ch1_ex1_1():void 
		{
			assert('10', 10);
			assert('(+ 5 3 4)', 12);
			assert('(- 9 1)', 8);
			assert('(/ 6 2)', 3);
			assert('(+ (* 2 4) (- 4 6))', 6);
			eval('(label a 3)');
			eval('(label b (+ a 1)');
			assert('(+ a b (* a b))', 19);

			assert(<![CDATA[

				(if (and (> b a) (< b (* a b)))
					b
					a)
				
				]]>.toString(), eval('b'));

			// cond not yet implemented
			ignore(<![CDATA[

				(cond ((= a 4) 6)
					  ((= b 4) (+ 6 7 a))
					  (else 25))
				
				]]>.toString());

			assert('(+ 2 (if (> b a) b a))', 6);
		}

		[Ignore]
		[Test(order=11)]
		public function ch1_ex1_3():void 
		{
			eval('(label square (quote (lambda (x) (* x x)))');
			eval(<![CDATA[

				(label sum-largest-two (quote (lambda (a b c)
					(if (and (> a b) (> b c))
						(+ (square a) (square b))
						(if (and (< a b) (> b c)))
							(+ (square b) (square c))
							(+ (square a) (square c))
					))))

				]]>.toString());
			
			assert('(sum-largest-two 2 3 4)', 25);
			assert('(sum-largest-two 3 4 2)', 25);
			assert('(sum-largest-two 4 2 3)', 25);
		}

		[Test(order=12)]
		public function ch1_ex1_4():void 
		{
			eval(<![CDATA[

				(label a-plus-abs-b (quote (lambda (a b)
					((if (> b 0) (quote +) (quote -)) a b))))

				]]>.toString());

			assert('(a-plus-abs-b 1 2)', 3);
			assert('(a-plus-abs-b 1 -2)', 3);
		}

		// TODO think about this exercise some more. 
		[Ignore]
		[Test(order=13)]
		public function ch1_ex1_5():void 
		{
			eval('(label p (quote p)');
			
			eval(<![CDATA[

				(label test (quote (lambda (x y) 
					(if (= x 0)
						0
						y))))

				]]>.toString());

			assert('(test 0 (quote p))', eval('p'));
		}

		[Test(order=14)]
		public function ch1_1_7_ex1():void 
		{
			eval(<![CDATA[

				(label sqrt-iter (quote (lambda (guess x)
					(if (good-enough guess x)
						guess
						(sqrt-iter (improve guess x) x)))))

				(label improve (quote (lambda (guess x)
					(average guess (/ x guess)))))

				(label average (quote (lambda (x y)
					(/ (+ x y) 2))))

				(label good-enough (quote (lambda (guess x) 
					(< (abs (- (square guess) x)) 0.001))))

				(label abs (quote (lambda (x) 
					(if (< x 0)
						(- x)
						x))))

				(label square (quote (lambda (x) (* x x))))

				(label sqrt (quote (lambda (x)
					(sqrt-iter 1.0 x))))	

				]]>.toString());	
				
			assert('(sqrt 9)', closeTo(3, 0.001));
			assert('(sqrt (+ 100 37))', closeTo(11.704, 0.001));
			assert('(sqrt (+ (sqrt 2) (sqrt 3)))', closeTo(1.774, 0.001));
			assert('(square (sqrt 1000))', closeTo(1000, 0.001));
		}

		// nested label-quote-lambdas does not work as expected.
		[Ignore] 
		[Test(order=15)]
		public function ch1_1_8_ex1():void 
		{
			eval(<![CDATA[

				(label square (quote (lambda (x) (* x x))))

				(label average (quote (lambda (x y)
					(/ (+ x y) 2))))

				(label sqrt (quote (lambda (x) 
					(label good-enough (quote (lambda (guess)
						(< (abs (- (square guess) x)) 0.001))))
					(label improve (quote (lambda (guess)
						(average guess (/ x guess)))))
					(label sqrt-iter (quote (lambda (guess)
						(if (good-enough guess)
							guess
							(sqrt-iter (improve guess))))))
					(sqrt-iter 1.0))))
				
				]]>.toString());

			assert('(sqrt 9)', closeTo(3, 0.001));
			assert('(sqrt (+ 100 37))', closeTo(11.704, 0.001));
			assert('(sqrt (+ (sqrt 2) (sqrt 3)))', closeTo(1.774, 0.001));
			assert('(square (sqrt 1000))', closeTo(1000, 0.001));
		}
	}
}