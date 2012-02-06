package stutter 
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;

	public class StutterTest
	{
		private var runtime:StutterRunTime;
		private var reader:StutterReader;

		[Before]
		public function setup():void 
		{
			runtime = new StutterRunTime();
			reader = new StutterReader();
		}

		[Test]
		public function math():void 
		{
			assertThat('+', eval('(+ 2 3)'), equalTo(5));
			assertThat('-', eval('(- 2 3)'), equalTo(-1));
			assertThat('*', eval('(* 2 3)'), equalTo(6));
			assertThat('/', eval('(/ 6 2)'), equalTo(3));
		}

		[Test]
		public function lambdas():void 
		{
			eval('(label second (quote (lambda (x) (car (cdr x)))))');

			assertThat(eval('(second (quote (1 2 3)))'), equalTo(2));
		}

		[Test]
		public function truth():void 
		{
			assertThat(eval('t'), equalTo(TRUE));
		}

		[Test]
		public function falsey():void 
		{
			assertThat(eval('nil'), equalTo(FALSE));
		}

		[Test]
		public function scoping():void 
		{
			eval(<![CDATA[
(label test (quote (lambda (a b c) 
					(+ a (* b c) 4)
				]]>.toString())

			assertThat(eval('(test 1 2 3)'), equalTo(11));
		}

		[Ignore]
		[Test]
		public function and_():void 
		{
			eval(<![CDATA[
(label and (quote (lambda (and_x and_y)
             			  (if (eq and_x t)
             			  	  (if (eq and_y t) nil)
             			  	  nil))))
				]]>.toString());
			
			assertThat('true?', eval('(and (eq 2 2) (eq 3 3))'), equalTo(TRUE));
			assertThat('false?', eval('(and (eq 2 2) (eq 3 4))'), equalTo(FALSE));
		}

		private function eval(expression:String):*
		{
			return runtime.eval(reader.read(expression));
		}
	}
}