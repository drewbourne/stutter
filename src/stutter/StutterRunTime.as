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
			
			_env[S('label')] = function _label(args:Array, _:*):*
			{
				var name:Symbol = args[0];
				var value:* = args[1];

				trace('label', name, value);
				return _env[name] = value;
			};
			
			_env[S('quote')] = function _quote(sexp:Array, _:*):*
			{
				trace('quote', sexp);
				return sexp[0];
			};
			
			_env[S('car')] = function _car(args:Array, _:*):*
			{
				var list:Array = args[0];
				trace('car', list);
				return list[0];
			};
			
			_env[S('cdr')] = function _cdr(args:Array, _:*):*
			{
				var list:Array = args[0];
				trace('cdr', list);
				return list.slice(1);
			};
			
			_env[S('cons')] = function _cons(args:Array, _:*):Array
			{
				var e:* = args[0]
				var cell:* = args[1];

				trace('cons', e, cell);
				return [ e ].concat(cell);
			};
			
			_env[S('eq')] = function _eq(args:Array, _:*):Boolean
			{
				var l:* = args[0];
				var r:* = args[1];

				trace('eq', l, r);
				return l === r;
			};
			
			_env[S('if')] = function _if(args:Array, ctx:*):*
			{
				var cond:* = args[0];
				var then:* = args[1]; 
				var els:* = args[2];

				trace('if', cond, then, els);
				return eval(cond, ctx) ? eval(then, ctx) : eval(els, ctx);
			};
			
			_env[S('atom')] = function _atom(args:*, _:*):Boolean
			{
				var sexp:* = args[0];
				return sexp is Symbol || sexp is Number
			};
		}
		
		public function eval(sexp:*, ctx:Object = null):Object
		{
			ctx ||= _env;
			
			if (_env[S('atom')].call(null, [sexp], ctx))
			{
				trace('eval atom', sexp);

				if (ctx[sexp])
				{
					return ctx[sexp];
				}
				return sexp;
			}
			
			var fn:* = sexp[0];
			var args:Array = sexp.slice(1);

			trace('eval fn', fn)
			trace('eval args', args);
			
			args = map(args, function(a:*):*
			{
				trace('eval arg', a);
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

			if (fn is Number)
			{
				return fn;
			}
			
			var target:* = _env[fn];

			trace('apply target', target);
			
			// the built-ins
			if (target is Function)
			{
				return (target as Function).call(null, args, ctx);
			}
			
			trace('apply target', target);

			if (target is Number)
			{
				return target;
			}
			
			trace('apply ctx target[1]', toString(target[1]));

			// create new context
			args = zip(target[1], args);
			trace('apply ctx args', toString(args));

			args = flatten(args, 1);
			trace('apply ctx args', toString(args));

			ctx = toObject(args);
			trace('apply ctx args', ctx);
			
			// custom functions
			return eval(target[2], ctx);
		}
	}
}

import asx.array.inject;
import asx.array.map;

import flash.utils.Dictionary;
	
internal function flatten(array:Array, depth:int = -1, level:int = 0):Array
{
	return inject([], array, function(memo:Array, value:Object):Array
	{
		trace('flatten', depth, level);

		level++;
		memo = memo.concat(value is Array && depth < level ? flatten(value as Array, depth, level) : value);
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
		
		trace('toObject key', key);
		trace('toObject value', value);

		result[key] = value;
	}
	
	return result;
}

internal function toString(object:Object):String 
{
	if (object is Array) 
	{
		var out:String = '[';
		out += map((object as Array), toString).join(', ');
		out += ']';
		return out;
	}	

	return String(object);
}

