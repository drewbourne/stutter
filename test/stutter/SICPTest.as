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
			assertThat(eval(expression), equalTo(result));
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
	}
}