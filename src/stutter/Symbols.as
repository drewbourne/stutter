package stutter
{
	import flash.utils.Dictionary;
	
	public class Symbols
	{
		private static var _symbols:Dictionary;
		
		public static function getSymbolOf(value:String):Symbol
		{
			_symbols ||= new Dictionary();
			var symbol:Symbol = _symbols[value] ||= new Symbol(value);
			return symbol;
		}
	}
}
