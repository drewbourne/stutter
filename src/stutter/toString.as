package stutter
{
	import asx.array.map;
	import flash.utils.Dictionary;

	public function toString(object:Object):String 
	{
		var out:String;

		if (object is Array) 
		{
			out = '[';
			out += map((object as Array), toString).join(', ');
			out += ']';
			return out;
		}

		if (object is Function)
		{
			return 'Function';
		}

		if (object is Dictionary)
		{
			out = '{\n\t';
			var pairs:Array = [];
			for (var key:* in object)
			{
				var value:* = object[key];
				if (!(value is Function))
				{
					pairs.push(key + ': ' + toString(value));	
				}
			}

			out += pairs.join(',\n\t');
			out += '}';
			return out;	
		}

		return String(object);
	}
}