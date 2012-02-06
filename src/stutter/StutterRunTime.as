package stutter
{
	import asx.array.inject;
	import asx.array.map;
	import asx.array.zip;
	import asx.number.add;
	import asx.number.sub;
	import asx.number.mul;
	import asx.number.div;
	
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
				return _env[name] = value;
			};
			
			_env[S('quote')] = function _quote(sexp:Array, _:*):*
			{
				return sexp[0];
			};
			
			_env[S('car')] = function _car(args:Array, _:*):*
			{
				var list:Array = args[0];
				return list[0];
			};
			
			_env[S('cdr')] = function _cdr(args:Array, _:*):*
			{
				var list:Array = args[0];
				return list.slice(1);
			};
			
			_env[S('cons')] = function _cons(args:Array, _:*):*
			{
				var e:* = args[0]
				var cell:* = args[1];
				return [ e ].concat(cell);
			};
			
			_env[S('eq')] = function _eq(args:Array, _:*):*
			{
				var l:* = args[0];
				var r:* = args[1];
				return l === r ? TRUE : FALSE;
			};
			
			_env[S('if')] = _env[S('cond')] = function _cond(args:Array, ctx:*):*
			{
				var cond:* = args[0];
				var then:* = args[1]; 
				var els:* = args[2];
				return eval(cond, ctx) === TRUE ? eval(then, ctx) : eval(els, ctx);
			};
			
			_env[S('atom')] = function _atom(args:*, _:*):*
			{
				var sexp:* = args[0];
				return (sexp is Symbol || sexp is Number) ? TRUE : FALSE;
			};

			// operators
			_env[S('+')] = function _plus(args:*, _:*):Number 
			{
				return inject(args.shift(), args, add) as Number;
			}

			_env[S('-')] = function _minus(args:*, _:*):Number 
			{
				return inject(args.shift(), args, sub) as Number;	
			}

			_env[S('*')] = function _multiply(args:*, _:*):Number 
			{
				return inject(args.shift(), args, mul) as Number;	
			}

			_env[S('/')] = function _divide(args:*, _:*):Number 
			{
				return inject(args.shift(), args, div) as Number;	
			}

			_env[S('<')] = function _lt(args:*, _:*):* 
			{
				return args[0] < args[1] ? TRUE : FALSE;
			}

			_env[S('>')] = function _gt(args:*, _:*):* 
			{
				return args[0] > args[1] ? TRUE : FALSE;
			}

			_env[S('=')] = _env[S('eq')];

			// symbols
			_env[S('t')] = TRUE;
			_env[S('nil')] = FALSE;
		}
		
		public function eval(sexp:*, ctx:Object = null):Object
		{
			ctx ||= _env;

			trace('eval', toString(sexp));
			// trace('eval \tctx', ctx == _env ? 'env' : toString(ctx));
			// trace('eval \tatom', _env[S('atom')].call(null, [sexp], ctx));
			
			if (_env[S('atom')].call(null, [sexp], ctx) === TRUE)
			{
				if (ctx[sexp])
				{
					return ctx[sexp];
				}

				return sexp;
			}
			
			var fn:* = sexp[0];
			var args:Array = sexp.slice(1);

			args = map(args, function(a:*):* {
				return ([ S('quote'), S('if')].indexOf(fn) == -1) ? eval(a, ctx) : a;
			});

			var result:* = apply(fn, args, ctx);

			trace('eval    ->fn', fn, '\targs', toString(args), '\n\t<-result', result);

			return result;
		}
		
		private function apply(fn:*, args:Array, ctx:Object = null):*
		{
			ctx ||= _env;

			trace('apply fn', fn);
			trace('apply args', toString(args));
			// trace('apply \tctx', ctx == _env ? 'env' : toString(ctx));

			if (fn is Number)
			{
				return fn;
			}
			
			var target:* = ctx[fn];

			if (target is Function)
			{
				return (target as Function).call(null, args, ctx);
			}

			if (target is Number)
			{
				return target;
			}

			if (!target)
			{
				throw new Error('Undefined term "' + fn + '"');
			}

			trace('apply \ttrg args', toString(target[1]));

			// clone existing context
			var evalctx:Dictionary = new Dictionary();
			var key:*;
			var value:*;

			for (key in ctx) 
			{
				evalctx[key] = ctx[key];
			}

			// create context
			args = zip(target[1], args);
			// trace('apply \tctx args', toString(args));

			args = flatten(args, 1);
			// trace('apply \tctx args', toString(args));

			// ctx = toObject(args);
			// merge args to new context
			while (args.length > 0) 
			{
				key = args.shift();
				value = args.shift();
				evalctx[key] = value;
			}

			// trace('apply \tctx args', toString(evalctx));
			
			var result:* = eval(target[2], evalctx);

			trace('apply   ->fn', fn, '\targs', toString(args), '\n\t<-result', result);

			return result;
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
		result[key] = value;
	}
	
	return result;
}

internal function toString(object:Object):String 
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
		out = '{';
		var pairs:Array = [];
		for (var key:* in object)
		{
			pairs.push(key + ': ' + toString(object[key]));
		}

		out += pairs.join(', ');
		out += '}';
		return out;	
	}

	return String(object);
}

