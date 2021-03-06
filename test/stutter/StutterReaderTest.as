package stutter 
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.collection.emptyArray;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;

	import stutter.S;

	public class StutterReaderTest
	{
		public var reader:StutterReader;

		[Before]
		public function setup():void 
		{
			reader = new StutterReader();
		}

		public function read(string:String):Object
		{
			return reader.read(string);
		}

		[Test]
		public function readTokens():void 
		{
			var examples:Array = [
				['()', emptyArray()],
				['1', equalTo(1)],
				['1.234567890', equalTo(1.234567890)],
				['(-1 -2.2 -0.33)', equalTo([-1, -2.2, -0.33])],
				["'single quoted'", equalTo('single quoted')],
				['"double quoted"', equalTo('double quoted')],
				['(1 2 3)', array(1, 2, 3)],
				['(label a 42)', array(S('label'), S('a'), 42)],
				['(label a-b-c 43)', array(S('label'), S('a-b-c'), 43)],
				['(quote (1 2 3))', array(S('quote'), array(1, 2, 3))],
				['(if (eq 1 2) 3 4)', array(S('if'), [S('eq'), 1, 2], 3, 4)],
				['(label second (quote (lambda (x) (car (cdr x)))))', equalTo([ S('label'), S('second'), [ S('quote'), [ S('lambda'), [ S('x') ], [ S('car'), [ S('cdr'), S('x')]]]]])],
				['(+ 2 3)', array( S('+'), 2, 3 )],
				['(- 2 3)', array( S('-'), 2, 3 )],
				['(* 2 3)', array( S('*'), 2, 3 )],
				['(/ 6 2)', array( S('/'), 6, 2 )]
				];

			for each (var example:Array in examples)
			{
				trace(example[0], read(example[0]));
				assertThat(read(example[0]), example[1]);
			}
		}

		[Test]
		public function readFullExpressions():void 
		{
			var expressions:String = <![CDATA[
				1
				a
				t
				()
				]]>.toString();

			var expression:String;

			reader.load(expressions);

			var results:Array = [];
			var sexp:*;

			while (reader.hasTokens() && (sexp = reader.parse()))
			{
				results.push(sexp);
			}

			assertThat(results, array(1, S('a'), TRUE, []));
		}
	}
}