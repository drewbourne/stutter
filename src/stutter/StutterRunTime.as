package stutter
{
	import asx.array.map;
	import asx.array.zip;
	
	import flash.utils.Dictionary;
	
	public class StutterRunTime
	{
		private var _env:Dictionary;
		
		public function StutterRunTime()
		{
			super();
			
			_env = new Dictionary();
			
			_env[S('label')] = function(name:Symbol, val:*, _:*):*
			{
				return _env[name] = val;
			};
			
			_env[S('quote')] = function(sexpr:Array, _:*):*
			{
				return sexpr[0];
			};
			
			_env[S('car')] = function(list:Array, _:*):*
			{
				return list[0];
			};
			
			_env[S('cdr')] = function(list:Array, _:*):*
			{
				return list.slice(1);
			};
			
			_env[S('cons')] = function(e:*, cell:*, _:*):Array
			{
				return [ e ].concat(cell);
			};
			
			_env[S('eq')] = function(l:*, r:*, _:*):Boolean
			{
				return l === r;
			};
			
			_env[S('if')] = function(cond:*, then:*, els:*, ctx:*):*
			{
				return eval(cond, ctx) ? eval(then, ctx) : eval(els, ctx);
			};
			
			_env[S('atom')] = function(sexpr:*, _:*):Boolean
			{
				return sexpr is Symbol || sexpr is Number
			};
		}
		
		public function eval(sexp:*, ctx:Object = null):Object
		{
			ctx ||= _env;
			
			if (_env[S('atom')].call(null, sexp, ctx))
			{
				if (ctx[sexp])
				{
					return ctx[sexp];
				}
				return sexp;
			}
			
			var fn:Symbol = sexp[0];
			var args:Array = sexp.slice(1);
			
			args = map(args, function(a:*):*
			{
				if ([ S('quote'), S('if')].indexOf(fn) == -1)
				{
					return eval(a, ctx);
				}
				
				return a;
			});
			
			return apply(fn, args, ctx);
		}
		
		private function apply(fn:*, args:Array, ctx:Object = null):*
		{
			ctx ||= _env;
			
			trace('apply fn', fn);
			trace('apply args', args);
			
			var target:* = _env[fn];
			
			// the built-ins
			if (target is Function)
			{
				return (target as Function).apply(null, args.concat(ctx));
			}
			
			trace('apply target', target);
			
			// create new context
			ctx = toObject(flatten(zip(target[1], args), 1));
			
			// custom functions
			return eval(target[2], ctx);
		}
	}
}

import asx.array.inject;

import flash.utils.Dictionary;

internal function flatten(array:Array, depth:int = -1):Array
{
	var level:int = 0;
	
	return inject([], array, function(memo:Array, value:Object):Array
	{
		level++;
		memo = memo.concat(value is Array && depth < level ? flatten(value as Array) : [ value ]);
		level--;
		return memo;
	}) as Array;
}

internal function toObject(array:Array):Object
{
	var result:Dictionary = new Dictionary();
	
	while (array.length > 0)
	{
		var key:* = array.shift();
		var value:* = array.shift();
		
		result[key] = value;
	}
	
	return result;
}
