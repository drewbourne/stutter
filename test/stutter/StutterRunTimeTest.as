package stutter
{
	import org.flexunit.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	
	public class StutterRunTimeTest
	{
		public var l:StutterRunTime;
		
		[Before]
		public function setup():void
		{
			l = new StutterRunTime();
		}
		
		[Test]
		public function label():void
		{
			l.eval([ S('label'), S('a'), 42 ]);
			assertThat(l.eval(S('a')), equalTo(42))
		}
		
		[Test]
		public function eq():void
		{
			l.eval([ S('label'), S('a'), 42 ]);
			assertThat(l.eval([ S('eq'), 42, S('a')]), isTrue());
		}
		
		[Test]
		public function quote():void
		{
			assertThat(l.eval([ S('quote'), 1, 2 ]), array(1, 2));
		}
		
		[Test]
		public function car():void
		{
			assertThat(l.eval([ S('car'), [ S('quote'), 1, 2 ]]), equalTo(1));
		}
		
		[Test]
		public function cdr():void
		{
			assertThat(l.eval([ S('cdr'), [ S('quote'), 1, 2 ]]), array(2));
		}
		
		[Test]
		public function cons():void
		{
			assertThat(l.eval([ S('cons'), 1, [ S('quote'), 2, 3 ]]), array(1, 2, 3));
		}
		
		[Test]
		public function if_():void
		{
			assertThat(l.eval([ S('if'), [ S('eq'), 1, 2 ], 42, 43 ]), equalTo(43));
		}
		
		[Test]
		public function atom():void
		{
			assertThat(l.eval([ S('atom'), [ S('quote'), [ 1, 2 ]]]), isFalse());
		}
		
		[Test]
		public function lambda():void
		{
			// (label second `(lambda (x) (car (cdr x))))
			l.eval([ S('label'), S('second'), [ S('quote'), [ S('lambda'), [ S('x')], [ S('car'), [ S('cdr'), S('x')]]]]]);
			// (second `(1 2 3))
			assertThat(l.eval([ S('second'), [ S('quote'), [ 1, 2, 3 ]]]), equalTo(2));
		}
	}
}
