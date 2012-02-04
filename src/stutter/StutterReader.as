package stutter 
{
	public class StutterReader 
	{
		private var _tokens:Array;

		public function StutterReader()
		{
			super();
		}

		public function read(expression:String):Object 
		{
			_tokens = expression.match(/[()]|\w+|".*?"|'.*?'/g);

			return parse();
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
			trace('parse', token);
			if (token === '(')
			{
				return parseList();
			}
			else if ((/['"].*/).test(token)) // '
			{
				return token.slice(1, -1);
			}
			else if ((/\d+/).test(token)) 
			{
				return parseInt(token);
			}
			else
			{
				return S(token);
			}
		}

		public function parseList():Array 
		{
			var list:Array = [];
			while (peek() !== ')')
			{
				list.push(parse());
			}
			nextToken();
			return list;	
		}
	}
}