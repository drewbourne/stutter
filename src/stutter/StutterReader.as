package stutter 
{
	public class StutterReader 
	{
		private var _tokens:Array;

		public function StutterReader()
		{
			super();
		}

		public function load(expression:String):void 
		{
			_tokens = expression.match(
			//	parentheses		numbers				atoms			strings			operators			flags
				/[()]| 			-?\d+(\.\d+)?|		\w+(-\w+)*|		".*?"|'.*?'|	[\+\-\*\/\<\>=]		/gx);
		}

		public function read(expression:String):Object 
		{
			load(expression);

			return parse();
		}

		public function hasTokens():Boolean
		{
			return _tokens.length > 0;
		}

		public function peek():String 
		{
			return _tokens[0];
		}

		public function nextToken():String 
		{
			return _tokens.shift();
		}

		public function parse():Object 
		{
			var token:String = nextToken();

			if (token === '(')
			{
				return parseList();
			}
			else if ((/['"].*/).test(token)) // '
			{
				return token.slice(1, -1);
			}
			else if ((/\d+(\.\d+)?/).test(token)) 
			{
				return parseFloat(token);
			}
			else
			{
				return S(token);
			}
		}

		public function parseList():Array 
		{
			var list:Array = [];
			var token:String;

			while ((token = peek()) && token != null && token !== ')')
			{
				list.push(parse());
			}

			nextToken();

			return list;	
		}
	}
}