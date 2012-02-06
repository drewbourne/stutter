package stutter 
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
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
			return runtime.eval(reader.read(expression));
		}

		private function assert(expression:String, result:*):void 
		{
			assertThat(expression, eval(expression), equalTo(result));
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
	}
}