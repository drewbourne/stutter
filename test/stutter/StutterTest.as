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

		[Before]
		public function setup():void 
		{
			runtime = new StutterRunTime();
		}

		[Test]
		public function stutter():void 
		{
			eval('(label second (quote (lambda (x) (car (cdr x)))))');

			assertThat(eval('(second (quote (1 2 3)))'), equalTo(2));
		}

		private function eval(expression:String):*
		{
			return runtime.eval((new StutterReader(expression)).parse());
		}
	}
}