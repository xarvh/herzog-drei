(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

console.warn('Compiled in DEV mode. Follow the advice at https://elm-lang.org/0.19.1/optimize for better performance and smaller assets.');


var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log_UNUSED = F2(function(tag, value)
{
	return value;
});

var _Debug_log = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString_UNUSED(value)
{
	return '<internals>';
}

function _Debug_toString(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[94m' + string + '\x1b[0m' : string;
}



// CRASH


function _Debug_crash_UNUSED(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.start.line === region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'on lines ' + region.start.line + ' through ' + region.end.line;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	/**/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**_UNUSED/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**_UNUSED/
	if (!x.$)
	//*/
	/**/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0_UNUSED = 0;
var _Utils_Tuple0 = { $: '#0' };

function _Utils_Tuple2_UNUSED(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3_UNUSED(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr_UNUSED(c) { return c; }
function _Utils_chr(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil_UNUSED = { $: 0 };
var _List_Nil = { $: '[]' };

function _List_Cons_UNUSED(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return word
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800)
			+
			String.fromCharCode(code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

var _Json_decodeInt = { $: 2 };
var _Json_decodeBool = { $: 3 };
var _Json_decodeFloat = { $: 4 };
var _Json_decodeValue = { $: 5 };
var _Json_decodeString = { $: 6 };

function _Json_decodeList(decoder) { return { $: 7, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 8, b: decoder }; }

function _Json_decodeNull(value) { return { $: 9, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 10,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 11,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 12,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 13,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 14,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 15,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 3:
			return (typeof value === 'boolean')
				? $elm$core$Result$Ok(value)
				: _Json_expecting('a BOOL', value);

		case 2:
			if (typeof value !== 'number') {
				return _Json_expecting('an INT', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return $elm$core$Result$Ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return $elm$core$Result$Ok(value);
			}

			return _Json_expecting('an INT', value);

		case 4:
			return (typeof value === 'number')
				? $elm$core$Result$Ok(value)
				: _Json_expecting('a FLOAT', value);

		case 6:
			return (typeof value === 'string')
				? $elm$core$Result$Ok(value)
				: (value instanceof String)
					? $elm$core$Result$Ok(value + '')
					: _Json_expecting('a STRING', value);

		case 9:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 5:
			return $elm$core$Result$Ok(_Json_wrap(value));

		case 7:
			if (!Array.isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 8:
			if (!Array.isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 10:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 11:
			var index = decoder.e;
			if (!Array.isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 12:
			if (typeof value !== 'object' || value === null || Array.isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 13:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 14:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 15:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 3:
		case 2:
		case 4:
		case 6:
		case 5:
			return true;

		case 9:
			return x.c === y.c;

		case 7:
		case 8:
		case 12:
			return _Json_equality(x.b, y.b);

		case 10:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 11:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 13:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 14:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 15:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap(value) { return { $: 0, a: value }; }
function _Json_unwrap(value) { return value.a; }

function _Json_wrap_UNUSED(value) { return value; }
function _Json_unwrap_UNUSED(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**/, _Json_errorToString(result.a) /**/);
	var managers = {};
	result = init(result.a);
	var model = result.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		result = A2(update, msg, model);
		stepper(model = result.a, viewMetadata);
		_Platform_dispatchEffects(managers, result.b, subscriptions(model));
	}

	_Platform_dispatchEffects(managers, result.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				p: bag.n,
				q: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.q)
		{
			x = temp.p(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		r: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		r: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].r;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**_UNUSED/
	var node = args['node'];
	//*/
	/**/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS


function _VirtualDom_noScript(tag)
{
	return tag == 'script' ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return /^(on|formAction$)/i.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri_UNUSED(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,'')) ? '' : value;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return /^javascript:/i.test(value.replace(/\s/g,''))
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri_UNUSED(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value) ? '' : value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return /^\s*(javascript:|data:text\/html)/i.test(value)
		? 'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'
		: value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		message: func(record.message),
		stopPropagation: record.stopPropagation,
		preventDefault: record.preventDefault
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		(key !== 'value' || key !== 'checked' || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		value
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		value
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.message;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.stopPropagation;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.preventDefault) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			var oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			var newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}



// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var view = impl.view;
			/**_UNUSED/
			var domNode = args['node'];
			//*/
			/**/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.init,
		impl.update,
		impl.subscriptions,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.setup && impl.setup(sendToApp)
			var view = impl.view;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.title) && (_VirtualDom_doc.title = title = doc.title);
			});
		}
	);
});



// ANIMATION


var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.onUrlChange;
	var onUrlRequest = impl.onUrlRequest;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		setup: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.download)
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.protocol === next.protocol
							&& curr.host === next.host
							&& curr.port_.a === next.port_.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		init: function(flags)
		{
			return A3(impl.init, flags, _Browser_getUrl(), key);
		},
		view: impl.view,
		update: impl.update,
		subscriptions: impl.subscriptions
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { hidden: 'hidden', change: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { hidden: 'mozHidden', change: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { hidden: 'msHidden', change: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { hidden: 'webkitHidden', change: 'webkitvisibilitychange' }
		: { hidden: 'hidden', change: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		scene: _Browser_getScene(),
		viewport: {
			x: _Browser_window.pageXOffset,
			y: _Browser_window.pageYOffset,
			width: _Browser_doc.documentElement.clientWidth,
			height: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		width: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		height: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			scene: {
				width: node.scrollWidth,
				height: node.scrollHeight
			},
			viewport: {
				x: node.scrollLeft,
				y: node.scrollTop,
				width: node.clientWidth,
				height: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			scene: _Browser_getScene(),
			viewport: {
				x: x,
				y: y,
				width: _Browser_doc.documentElement.clientWidth,
				height: _Browser_doc.documentElement.clientHeight
			},
			element: {
				x: x + rect.left,
				y: y + rect.top,
				width: rect.width,
				height: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});


/*
 * Copyright (c) 2010 Mozilla Corporation
 * Copyright (c) 2010 Vladimir Vukicevic
 * Copyright (c) 2013 John Mayer
 * Copyright (c) 2018 Andrey Kuzmin
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

// Vector2

var _MJS_v2 = F2(function(x, y) {
    return new Float64Array([x, y]);
});

var _MJS_v2getX = function(a) {
    return a[0];
};

var _MJS_v2getY = function(a) {
    return a[1];
};

var _MJS_v2setX = F2(function(x, a) {
    return new Float64Array([x, a[1]]);
});

var _MJS_v2setY = F2(function(y, a) {
    return new Float64Array([a[0], y]);
});

var _MJS_v2toRecord = function(a) {
    return { x: a[0], y: a[1] };
};

var _MJS_v2fromRecord = function(r) {
    return new Float64Array([r.x, r.y]);
};

var _MJS_v2add = F2(function(a, b) {
    var r = new Float64Array(2);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    return r;
});

var _MJS_v2sub = F2(function(a, b) {
    var r = new Float64Array(2);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    return r;
});

var _MJS_v2negate = function(a) {
    var r = new Float64Array(2);
    r[0] = -a[0];
    r[1] = -a[1];
    return r;
};

var _MJS_v2direction = F2(function(a, b) {
    var r = new Float64Array(2);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    var im = 1.0 / _MJS_v2lengthLocal(r);
    r[0] = r[0] * im;
    r[1] = r[1] * im;
    return r;
});

function _MJS_v2lengthLocal(a) {
    return Math.sqrt(a[0] * a[0] + a[1] * a[1]);
}
var _MJS_v2length = _MJS_v2lengthLocal;

var _MJS_v2lengthSquared = function(a) {
    return a[0] * a[0] + a[1] * a[1];
};

var _MJS_v2distance = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    return Math.sqrt(dx * dx + dy * dy);
});

var _MJS_v2distanceSquared = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    return dx * dx + dy * dy;
});

var _MJS_v2normalize = function(a) {
    var r = new Float64Array(2);
    var im = 1.0 / _MJS_v2lengthLocal(a);
    r[0] = a[0] * im;
    r[1] = a[1] * im;
    return r;
};

var _MJS_v2scale = F2(function(k, a) {
    var r = new Float64Array(2);
    r[0] = a[0] * k;
    r[1] = a[1] * k;
    return r;
});

var _MJS_v2dot = F2(function(a, b) {
    return a[0] * b[0] + a[1] * b[1];
});

// Vector3

var _MJS_v3temp1Local = new Float64Array(3);
var _MJS_v3temp2Local = new Float64Array(3);
var _MJS_v3temp3Local = new Float64Array(3);

var _MJS_v3 = F3(function(x, y, z) {
    return new Float64Array([x, y, z]);
});

var _MJS_v3getX = function(a) {
    return a[0];
};

var _MJS_v3getY = function(a) {
    return a[1];
};

var _MJS_v3getZ = function(a) {
    return a[2];
};

var _MJS_v3setX = F2(function(x, a) {
    return new Float64Array([x, a[1], a[2]]);
});

var _MJS_v3setY = F2(function(y, a) {
    return new Float64Array([a[0], y, a[2]]);
});

var _MJS_v3setZ = F2(function(z, a) {
    return new Float64Array([a[0], a[1], z]);
});

var _MJS_v3toRecord = function(a) {
    return { x: a[0], y: a[1], z: a[2] };
};

var _MJS_v3fromRecord3 = function(r) {
    return new Float64Array([r.x, r.y, r.z]);
};

var _MJS_v3add = F2(function(a, b) {
    var r = new Float64Array(3);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    r[2] = a[2] + b[2];
    return r;
});

function _MJS_v3subLocal(a, b, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
    return r;
}
var _MJS_v3sub = F2(_MJS_v3subLocal);

var _MJS_v3negate = function(a) {
    var r = new Float64Array(3);
    r[0] = -a[0];
    r[1] = -a[1];
    r[2] = -a[2];
    return r;
};

function _MJS_v3directionLocal(a, b, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    return _MJS_v3normalizeLocal(_MJS_v3subLocal(a, b, r), r);
}
var _MJS_v3direction = F2(_MJS_v3directionLocal);

function _MJS_v3lengthLocal(a) {
    return Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
}
var _MJS_v3length = _MJS_v3lengthLocal;

var _MJS_v3lengthSquared = function(a) {
    return a[0] * a[0] + a[1] * a[1] + a[2] * a[2];
};

var _MJS_v3distance = function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
};

var _MJS_v3distanceSquared = function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    return dx * dx + dy * dy + dz * dz;
};

function _MJS_v3normalizeLocal(a, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    var im = 1.0 / _MJS_v3lengthLocal(a);
    r[0] = a[0] * im;
    r[1] = a[1] * im;
    r[2] = a[2] * im;
    return r;
}
var _MJS_v3normalize = _MJS_v3normalizeLocal;

var _MJS_v3scale = F2(function(k, a) {
    return new Float64Array([a[0] * k, a[1] * k, a[2] * k]);
});

var _MJS_v3dotLocal = function(a, b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
};
var _MJS_v3dot = F2(_MJS_v3dotLocal);

function _MJS_v3crossLocal(a, b, r) {
    if (r === undefined) {
        r = new Float64Array(3);
    }
    r[0] = a[1] * b[2] - a[2] * b[1];
    r[1] = a[2] * b[0] - a[0] * b[2];
    r[2] = a[0] * b[1] - a[1] * b[0];
    return r;
}
var _MJS_v3cross = F2(_MJS_v3crossLocal);

var _MJS_v3mul4x4 = F2(function(m, v) {
    var w;
    var tmp = _MJS_v3temp1Local;
    var r = new Float64Array(3);

    tmp[0] = m[3];
    tmp[1] = m[7];
    tmp[2] = m[11];
    w = _MJS_v3dotLocal(v, tmp) + m[15];
    tmp[0] = m[0];
    tmp[1] = m[4];
    tmp[2] = m[8];
    r[0] = (_MJS_v3dotLocal(v, tmp) + m[12]) / w;
    tmp[0] = m[1];
    tmp[1] = m[5];
    tmp[2] = m[9];
    r[1] = (_MJS_v3dotLocal(v, tmp) + m[13]) / w;
    tmp[0] = m[2];
    tmp[1] = m[6];
    tmp[2] = m[10];
    r[2] = (_MJS_v3dotLocal(v, tmp) + m[14]) / w;
    return r;
});

// Vector4

var _MJS_v4 = F4(function(x, y, z, w) {
    return new Float64Array([x, y, z, w]);
});

var _MJS_v4getX = function(a) {
    return a[0];
};

var _MJS_v4getY = function(a) {
    return a[1];
};

var _MJS_v4getZ = function(a) {
    return a[2];
};

var _MJS_v4getW = function(a) {
    return a[3];
};

var _MJS_v4setX = F2(function(x, a) {
    return new Float64Array([x, a[1], a[2], a[3]]);
});

var _MJS_v4setY = F2(function(y, a) {
    return new Float64Array([a[0], y, a[2], a[3]]);
});

var _MJS_v4setZ = F2(function(z, a) {
    return new Float64Array([a[0], a[1], z, a[3]]);
});

var _MJS_v4setW = F2(function(w, a) {
    return new Float64Array([a[0], a[1], a[2], w]);
});

var _MJS_v4toRecord = function(a) {
    return { x: a[0], y: a[1], z: a[2], w: a[3] };
};

var _MJS_v4fromRecord = function(r) {
    return new Float64Array([r.x, r.y, r.z, r.w]);
};

var _MJS_v4add = F2(function(a, b) {
    var r = new Float64Array(4);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    r[2] = a[2] + b[2];
    r[3] = a[3] + b[3];
    return r;
});

var _MJS_v4sub = F2(function(a, b) {
    var r = new Float64Array(4);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
    r[3] = a[3] - b[3];
    return r;
});

var _MJS_v4negate = function(a) {
    var r = new Float64Array(4);
    r[0] = -a[0];
    r[1] = -a[1];
    r[2] = -a[2];
    r[3] = -a[3];
    return r;
};

var _MJS_v4direction = F2(function(a, b) {
    var r = new Float64Array(4);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
    r[3] = a[3] - b[3];
    var im = 1.0 / _MJS_v4lengthLocal(r);
    r[0] = r[0] * im;
    r[1] = r[1] * im;
    r[2] = r[2] * im;
    r[3] = r[3] * im;
    return r;
});

function _MJS_v4lengthLocal(a) {
    return Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2] + a[3] * a[3]);
}
var _MJS_v4length = _MJS_v4lengthLocal;

var _MJS_v4lengthSquared = function(a) {
    return a[0] * a[0] + a[1] * a[1] + a[2] * a[2] + a[3] * a[3];
};

var _MJS_v4distance = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    var dw = a[3] - b[3];
    return Math.sqrt(dx * dx + dy * dy + dz * dz + dw * dw);
});

var _MJS_v4distanceSquared = F2(function(a, b) {
    var dx = a[0] - b[0];
    var dy = a[1] - b[1];
    var dz = a[2] - b[2];
    var dw = a[3] - b[3];
    return dx * dx + dy * dy + dz * dz + dw * dw;
});

var _MJS_v4normalize = function(a) {
    var r = new Float64Array(4);
    var im = 1.0 / _MJS_v4lengthLocal(a);
    r[0] = a[0] * im;
    r[1] = a[1] * im;
    r[2] = a[2] * im;
    r[3] = a[3] * im;
    return r;
};

var _MJS_v4scale = F2(function(k, a) {
    var r = new Float64Array(4);
    r[0] = a[0] * k;
    r[1] = a[1] * k;
    r[2] = a[2] * k;
    r[3] = a[3] * k;
    return r;
});

var _MJS_v4dot = F2(function(a, b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3];
});

// Matrix4

var _MJS_m4x4temp1Local = new Float64Array(16);
var _MJS_m4x4temp2Local = new Float64Array(16);

var _MJS_m4x4identity = new Float64Array([
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
]);

var _MJS_m4x4fromRecord = function(r) {
    var m = new Float64Array(16);
    m[0] = r.m11;
    m[1] = r.m21;
    m[2] = r.m31;
    m[3] = r.m41;
    m[4] = r.m12;
    m[5] = r.m22;
    m[6] = r.m32;
    m[7] = r.m42;
    m[8] = r.m13;
    m[9] = r.m23;
    m[10] = r.m33;
    m[11] = r.m43;
    m[12] = r.m14;
    m[13] = r.m24;
    m[14] = r.m34;
    m[15] = r.m44;
    return m;
};

var _MJS_m4x4toRecord = function(m) {
    return {
        m11: m[0], m21: m[1], m31: m[2], m41: m[3],
        m12: m[4], m22: m[5], m32: m[6], m42: m[7],
        m13: m[8], m23: m[9], m33: m[10], m43: m[11],
        m14: m[12], m24: m[13], m34: m[14], m44: m[15]
    };
};

var _MJS_m4x4inverse = function(m) {
    var r = new Float64Array(16);

    r[0] = m[5] * m[10] * m[15] - m[5] * m[11] * m[14] - m[9] * m[6] * m[15] +
        m[9] * m[7] * m[14] + m[13] * m[6] * m[11] - m[13] * m[7] * m[10];
    r[4] = -m[4] * m[10] * m[15] + m[4] * m[11] * m[14] + m[8] * m[6] * m[15] -
        m[8] * m[7] * m[14] - m[12] * m[6] * m[11] + m[12] * m[7] * m[10];
    r[8] = m[4] * m[9] * m[15] - m[4] * m[11] * m[13] - m[8] * m[5] * m[15] +
        m[8] * m[7] * m[13] + m[12] * m[5] * m[11] - m[12] * m[7] * m[9];
    r[12] = -m[4] * m[9] * m[14] + m[4] * m[10] * m[13] + m[8] * m[5] * m[14] -
        m[8] * m[6] * m[13] - m[12] * m[5] * m[10] + m[12] * m[6] * m[9];
    r[1] = -m[1] * m[10] * m[15] + m[1] * m[11] * m[14] + m[9] * m[2] * m[15] -
        m[9] * m[3] * m[14] - m[13] * m[2] * m[11] + m[13] * m[3] * m[10];
    r[5] = m[0] * m[10] * m[15] - m[0] * m[11] * m[14] - m[8] * m[2] * m[15] +
        m[8] * m[3] * m[14] + m[12] * m[2] * m[11] - m[12] * m[3] * m[10];
    r[9] = -m[0] * m[9] * m[15] + m[0] * m[11] * m[13] + m[8] * m[1] * m[15] -
        m[8] * m[3] * m[13] - m[12] * m[1] * m[11] + m[12] * m[3] * m[9];
    r[13] = m[0] * m[9] * m[14] - m[0] * m[10] * m[13] - m[8] * m[1] * m[14] +
        m[8] * m[2] * m[13] + m[12] * m[1] * m[10] - m[12] * m[2] * m[9];
    r[2] = m[1] * m[6] * m[15] - m[1] * m[7] * m[14] - m[5] * m[2] * m[15] +
        m[5] * m[3] * m[14] + m[13] * m[2] * m[7] - m[13] * m[3] * m[6];
    r[6] = -m[0] * m[6] * m[15] + m[0] * m[7] * m[14] + m[4] * m[2] * m[15] -
        m[4] * m[3] * m[14] - m[12] * m[2] * m[7] + m[12] * m[3] * m[6];
    r[10] = m[0] * m[5] * m[15] - m[0] * m[7] * m[13] - m[4] * m[1] * m[15] +
        m[4] * m[3] * m[13] + m[12] * m[1] * m[7] - m[12] * m[3] * m[5];
    r[14] = -m[0] * m[5] * m[14] + m[0] * m[6] * m[13] + m[4] * m[1] * m[14] -
        m[4] * m[2] * m[13] - m[12] * m[1] * m[6] + m[12] * m[2] * m[5];
    r[3] = -m[1] * m[6] * m[11] + m[1] * m[7] * m[10] + m[5] * m[2] * m[11] -
        m[5] * m[3] * m[10] - m[9] * m[2] * m[7] + m[9] * m[3] * m[6];
    r[7] = m[0] * m[6] * m[11] - m[0] * m[7] * m[10] - m[4] * m[2] * m[11] +
        m[4] * m[3] * m[10] + m[8] * m[2] * m[7] - m[8] * m[3] * m[6];
    r[11] = -m[0] * m[5] * m[11] + m[0] * m[7] * m[9] + m[4] * m[1] * m[11] -
        m[4] * m[3] * m[9] - m[8] * m[1] * m[7] + m[8] * m[3] * m[5];
    r[15] = m[0] * m[5] * m[10] - m[0] * m[6] * m[9] - m[4] * m[1] * m[10] +
        m[4] * m[2] * m[9] + m[8] * m[1] * m[6] - m[8] * m[2] * m[5];

    var det = m[0] * r[0] + m[1] * r[4] + m[2] * r[8] + m[3] * r[12];

    if (det === 0) {
        return $elm$core$Maybe$Nothing;
    }

    det = 1.0 / det;

    for (var i = 0; i < 16; i = i + 1) {
        r[i] = r[i] * det;
    }

    return $elm$core$Maybe$Just(r);
};

var _MJS_m4x4inverseOrthonormal = function(m) {
    var r = new Float64Array(16);
    _MJS_m4x4transposeLocal(m, r);
    var t = [m[12], m[13], m[14]];
    r[3] = r[7] = r[11] = 0;
    r[12] = -_MJS_v3dotLocal([r[0], r[4], r[8]], t);
    r[13] = -_MJS_v3dotLocal([r[1], r[5], r[9]], t);
    r[14] = -_MJS_v3dotLocal([r[2], r[6], r[10]], t);
    return r;
};

function _MJS_m4x4makeFrustumLocal(left, right, bottom, top, znear, zfar) {
    var r = new Float64Array(16);

    r[0] = 2 * znear / (right - left);
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = 2 * znear / (top - bottom);
    r[6] = 0;
    r[7] = 0;
    r[8] = (right + left) / (right - left);
    r[9] = (top + bottom) / (top - bottom);
    r[10] = -(zfar + znear) / (zfar - znear);
    r[11] = -1;
    r[12] = 0;
    r[13] = 0;
    r[14] = -2 * zfar * znear / (zfar - znear);
    r[15] = 0;

    return r;
}
var _MJS_m4x4makeFrustum = F6(_MJS_m4x4makeFrustumLocal);

var _MJS_m4x4makePerspective = F4(function(fovy, aspect, znear, zfar) {
    var ymax = znear * Math.tan(fovy * Math.PI / 360.0);
    var ymin = -ymax;
    var xmin = ymin * aspect;
    var xmax = ymax * aspect;

    return _MJS_m4x4makeFrustumLocal(xmin, xmax, ymin, ymax, znear, zfar);
});

function _MJS_m4x4makeOrthoLocal(left, right, bottom, top, znear, zfar) {
    var r = new Float64Array(16);

    r[0] = 2 / (right - left);
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = 2 / (top - bottom);
    r[6] = 0;
    r[7] = 0;
    r[8] = 0;
    r[9] = 0;
    r[10] = -2 / (zfar - znear);
    r[11] = 0;
    r[12] = -(right + left) / (right - left);
    r[13] = -(top + bottom) / (top - bottom);
    r[14] = -(zfar + znear) / (zfar - znear);
    r[15] = 1;

    return r;
}
var _MJS_m4x4makeOrtho = F6(_MJS_m4x4makeOrthoLocal);

var _MJS_m4x4makeOrtho2D = F4(function(left, right, bottom, top) {
    return _MJS_m4x4makeOrthoLocal(left, right, bottom, top, -1, 1);
});

function _MJS_m4x4mulLocal(a, b) {
    var r = new Float64Array(16);
    var a11 = a[0];
    var a21 = a[1];
    var a31 = a[2];
    var a41 = a[3];
    var a12 = a[4];
    var a22 = a[5];
    var a32 = a[6];
    var a42 = a[7];
    var a13 = a[8];
    var a23 = a[9];
    var a33 = a[10];
    var a43 = a[11];
    var a14 = a[12];
    var a24 = a[13];
    var a34 = a[14];
    var a44 = a[15];
    var b11 = b[0];
    var b21 = b[1];
    var b31 = b[2];
    var b41 = b[3];
    var b12 = b[4];
    var b22 = b[5];
    var b32 = b[6];
    var b42 = b[7];
    var b13 = b[8];
    var b23 = b[9];
    var b33 = b[10];
    var b43 = b[11];
    var b14 = b[12];
    var b24 = b[13];
    var b34 = b[14];
    var b44 = b[15];

    r[0] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41;
    r[1] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41;
    r[2] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41;
    r[3] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41;
    r[4] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42;
    r[5] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42;
    r[6] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42;
    r[7] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42;
    r[8] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43;
    r[9] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43;
    r[10] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43;
    r[11] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43;
    r[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44;
    r[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44;
    r[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44;
    r[15] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44;

    return r;
}
var _MJS_m4x4mul = F2(_MJS_m4x4mulLocal);

var _MJS_m4x4mulAffine = F2(function(a, b) {
    var r = new Float64Array(16);
    var a11 = a[0];
    var a21 = a[1];
    var a31 = a[2];
    var a12 = a[4];
    var a22 = a[5];
    var a32 = a[6];
    var a13 = a[8];
    var a23 = a[9];
    var a33 = a[10];
    var a14 = a[12];
    var a24 = a[13];
    var a34 = a[14];

    var b11 = b[0];
    var b21 = b[1];
    var b31 = b[2];
    var b12 = b[4];
    var b22 = b[5];
    var b32 = b[6];
    var b13 = b[8];
    var b23 = b[9];
    var b33 = b[10];
    var b14 = b[12];
    var b24 = b[13];
    var b34 = b[14];

    r[0] = a11 * b11 + a12 * b21 + a13 * b31;
    r[1] = a21 * b11 + a22 * b21 + a23 * b31;
    r[2] = a31 * b11 + a32 * b21 + a33 * b31;
    r[3] = 0;
    r[4] = a11 * b12 + a12 * b22 + a13 * b32;
    r[5] = a21 * b12 + a22 * b22 + a23 * b32;
    r[6] = a31 * b12 + a32 * b22 + a33 * b32;
    r[7] = 0;
    r[8] = a11 * b13 + a12 * b23 + a13 * b33;
    r[9] = a21 * b13 + a22 * b23 + a23 * b33;
    r[10] = a31 * b13 + a32 * b23 + a33 * b33;
    r[11] = 0;
    r[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14;
    r[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24;
    r[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34;
    r[15] = 1;

    return r;
});

var _MJS_m4x4makeRotate = F2(function(angle, axis) {
    var r = new Float64Array(16);
    axis = _MJS_v3normalizeLocal(axis, _MJS_v3temp1Local);
    var x = axis[0];
    var y = axis[1];
    var z = axis[2];
    var c = Math.cos(angle);
    var c1 = 1 - c;
    var s = Math.sin(angle);

    r[0] = x * x * c1 + c;
    r[1] = y * x * c1 + z * s;
    r[2] = z * x * c1 - y * s;
    r[3] = 0;
    r[4] = x * y * c1 - z * s;
    r[5] = y * y * c1 + c;
    r[6] = y * z * c1 + x * s;
    r[7] = 0;
    r[8] = x * z * c1 + y * s;
    r[9] = y * z * c1 - x * s;
    r[10] = z * z * c1 + c;
    r[11] = 0;
    r[12] = 0;
    r[13] = 0;
    r[14] = 0;
    r[15] = 1;

    return r;
});

var _MJS_m4x4rotate = F3(function(angle, axis, m) {
    var r = new Float64Array(16);
    var im = 1.0 / _MJS_v3lengthLocal(axis);
    var x = axis[0] * im;
    var y = axis[1] * im;
    var z = axis[2] * im;
    var c = Math.cos(angle);
    var c1 = 1 - c;
    var s = Math.sin(angle);
    var xs = x * s;
    var ys = y * s;
    var zs = z * s;
    var xyc1 = x * y * c1;
    var xzc1 = x * z * c1;
    var yzc1 = y * z * c1;
    var t11 = x * x * c1 + c;
    var t21 = xyc1 + zs;
    var t31 = xzc1 - ys;
    var t12 = xyc1 - zs;
    var t22 = y * y * c1 + c;
    var t32 = yzc1 + xs;
    var t13 = xzc1 + ys;
    var t23 = yzc1 - xs;
    var t33 = z * z * c1 + c;
    var m11 = m[0], m21 = m[1], m31 = m[2], m41 = m[3];
    var m12 = m[4], m22 = m[5], m32 = m[6], m42 = m[7];
    var m13 = m[8], m23 = m[9], m33 = m[10], m43 = m[11];
    var m14 = m[12], m24 = m[13], m34 = m[14], m44 = m[15];

    r[0] = m11 * t11 + m12 * t21 + m13 * t31;
    r[1] = m21 * t11 + m22 * t21 + m23 * t31;
    r[2] = m31 * t11 + m32 * t21 + m33 * t31;
    r[3] = m41 * t11 + m42 * t21 + m43 * t31;
    r[4] = m11 * t12 + m12 * t22 + m13 * t32;
    r[5] = m21 * t12 + m22 * t22 + m23 * t32;
    r[6] = m31 * t12 + m32 * t22 + m33 * t32;
    r[7] = m41 * t12 + m42 * t22 + m43 * t32;
    r[8] = m11 * t13 + m12 * t23 + m13 * t33;
    r[9] = m21 * t13 + m22 * t23 + m23 * t33;
    r[10] = m31 * t13 + m32 * t23 + m33 * t33;
    r[11] = m41 * t13 + m42 * t23 + m43 * t33;
    r[12] = m14,
    r[13] = m24;
    r[14] = m34;
    r[15] = m44;

    return r;
});

function _MJS_m4x4makeScale3Local(x, y, z) {
    var r = new Float64Array(16);

    r[0] = x;
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = y;
    r[6] = 0;
    r[7] = 0;
    r[8] = 0;
    r[9] = 0;
    r[10] = z;
    r[11] = 0;
    r[12] = 0;
    r[13] = 0;
    r[14] = 0;
    r[15] = 1;

    return r;
}
var _MJS_m4x4makeScale3 = F3(_MJS_m4x4makeScale3Local);

var _MJS_m4x4makeScale = function(v) {
    return _MJS_m4x4makeScale3Local(v[0], v[1], v[2]);
};

var _MJS_m4x4scale3 = F4(function(x, y, z, m) {
    var r = new Float64Array(16);

    r[0] = m[0] * x;
    r[1] = m[1] * x;
    r[2] = m[2] * x;
    r[3] = m[3] * x;
    r[4] = m[4] * y;
    r[5] = m[5] * y;
    r[6] = m[6] * y;
    r[7] = m[7] * y;
    r[8] = m[8] * z;
    r[9] = m[9] * z;
    r[10] = m[10] * z;
    r[11] = m[11] * z;
    r[12] = m[12];
    r[13] = m[13];
    r[14] = m[14];
    r[15] = m[15];

    return r;
});

var _MJS_m4x4scale = F2(function(v, m) {
    var r = new Float64Array(16);
    var x = v[0];
    var y = v[1];
    var z = v[2];

    r[0] = m[0] * x;
    r[1] = m[1] * x;
    r[2] = m[2] * x;
    r[3] = m[3] * x;
    r[4] = m[4] * y;
    r[5] = m[5] * y;
    r[6] = m[6] * y;
    r[7] = m[7] * y;
    r[8] = m[8] * z;
    r[9] = m[9] * z;
    r[10] = m[10] * z;
    r[11] = m[11] * z;
    r[12] = m[12];
    r[13] = m[13];
    r[14] = m[14];
    r[15] = m[15];

    return r;
});

function _MJS_m4x4makeTranslate3Local(x, y, z) {
    var r = new Float64Array(16);

    r[0] = 1;
    r[1] = 0;
    r[2] = 0;
    r[3] = 0;
    r[4] = 0;
    r[5] = 1;
    r[6] = 0;
    r[7] = 0;
    r[8] = 0;
    r[9] = 0;
    r[10] = 1;
    r[11] = 0;
    r[12] = x;
    r[13] = y;
    r[14] = z;
    r[15] = 1;

    return r;
}
var _MJS_m4x4makeTranslate3 = F3(_MJS_m4x4makeTranslate3Local);

var _MJS_m4x4makeTranslate = function(v) {
    return _MJS_m4x4makeTranslate3Local(v[0], v[1], v[2]);
};

var _MJS_m4x4translate3 = F4(function(x, y, z, m) {
    var r = new Float64Array(16);
    var m11 = m[0];
    var m21 = m[1];
    var m31 = m[2];
    var m41 = m[3];
    var m12 = m[4];
    var m22 = m[5];
    var m32 = m[6];
    var m42 = m[7];
    var m13 = m[8];
    var m23 = m[9];
    var m33 = m[10];
    var m43 = m[11];

    r[0] = m11;
    r[1] = m21;
    r[2] = m31;
    r[3] = m41;
    r[4] = m12;
    r[5] = m22;
    r[6] = m32;
    r[7] = m42;
    r[8] = m13;
    r[9] = m23;
    r[10] = m33;
    r[11] = m43;
    r[12] = m11 * x + m12 * y + m13 * z + m[12];
    r[13] = m21 * x + m22 * y + m23 * z + m[13];
    r[14] = m31 * x + m32 * y + m33 * z + m[14];
    r[15] = m41 * x + m42 * y + m43 * z + m[15];

    return r;
});

var _MJS_m4x4translate = F2(function(v, m) {
    var r = new Float64Array(16);
    var x = v[0];
    var y = v[1];
    var z = v[2];
    var m11 = m[0];
    var m21 = m[1];
    var m31 = m[2];
    var m41 = m[3];
    var m12 = m[4];
    var m22 = m[5];
    var m32 = m[6];
    var m42 = m[7];
    var m13 = m[8];
    var m23 = m[9];
    var m33 = m[10];
    var m43 = m[11];

    r[0] = m11;
    r[1] = m21;
    r[2] = m31;
    r[3] = m41;
    r[4] = m12;
    r[5] = m22;
    r[6] = m32;
    r[7] = m42;
    r[8] = m13;
    r[9] = m23;
    r[10] = m33;
    r[11] = m43;
    r[12] = m11 * x + m12 * y + m13 * z + m[12];
    r[13] = m21 * x + m22 * y + m23 * z + m[13];
    r[14] = m31 * x + m32 * y + m33 * z + m[14];
    r[15] = m41 * x + m42 * y + m43 * z + m[15];

    return r;
});

var _MJS_m4x4makeLookAt = F3(function(eye, center, up) {
    var z = _MJS_v3directionLocal(eye, center, _MJS_v3temp1Local);
    var x = _MJS_v3normalizeLocal(_MJS_v3crossLocal(up, z, _MJS_v3temp2Local), _MJS_v3temp2Local);
    var y = _MJS_v3normalizeLocal(_MJS_v3crossLocal(z, x, _MJS_v3temp3Local), _MJS_v3temp3Local);
    var tm1 = _MJS_m4x4temp1Local;
    var tm2 = _MJS_m4x4temp2Local;

    tm1[0] = x[0];
    tm1[1] = y[0];
    tm1[2] = z[0];
    tm1[3] = 0;
    tm1[4] = x[1];
    tm1[5] = y[1];
    tm1[6] = z[1];
    tm1[7] = 0;
    tm1[8] = x[2];
    tm1[9] = y[2];
    tm1[10] = z[2];
    tm1[11] = 0;
    tm1[12] = 0;
    tm1[13] = 0;
    tm1[14] = 0;
    tm1[15] = 1;

    tm2[0] = 1; tm2[1] = 0; tm2[2] = 0; tm2[3] = 0;
    tm2[4] = 0; tm2[5] = 1; tm2[6] = 0; tm2[7] = 0;
    tm2[8] = 0; tm2[9] = 0; tm2[10] = 1; tm2[11] = 0;
    tm2[12] = -eye[0]; tm2[13] = -eye[1]; tm2[14] = -eye[2]; tm2[15] = 1;

    return _MJS_m4x4mulLocal(tm1, tm2);
});


function _MJS_m4x4transposeLocal(m) {
    var r = new Float64Array(16);

    r[0] = m[0]; r[1] = m[4]; r[2] = m[8]; r[3] = m[12];
    r[4] = m[1]; r[5] = m[5]; r[6] = m[9]; r[7] = m[13];
    r[8] = m[2]; r[9] = m[6]; r[10] = m[10]; r[11] = m[14];
    r[12] = m[3]; r[13] = m[7]; r[14] = m[11]; r[15] = m[15];

    return r;
}
var _MJS_m4x4transpose = _MJS_m4x4transposeLocal;

var _MJS_m4x4makeBasis = F3(function(vx, vy, vz) {
    var r = new Float64Array(16);

    r[0] = vx[0];
    r[1] = vx[1];
    r[2] = vx[2];
    r[3] = 0;
    r[4] = vy[0];
    r[5] = vy[1];
    r[6] = vy[2];
    r[7] = 0;
    r[8] = vz[0];
    r[9] = vz[1];
    r[10] = vz[2];
    r[11] = 0;
    r[12] = 0;
    r[13] = 0;
    r[14] = 0;
    r[15] = 1;

    return r;
});


function _WebGL_log(/* msg */) {
  // console.log(msg);
}

var _WebGL_guid = 0;

function _WebGL_listEach(fn, list) {
  for (; list.b; list = list.b) {
    fn(list.a);
  }
}

function _WebGL_listLength(list) {
  var length = 0;
  for (; list.b; list = list.b) {
    length++;
  }
  return length;
}

var _WebGL_rAF = typeof requestAnimationFrame !== 'undefined' ?
  requestAnimationFrame :
  function (cb) { setTimeout(cb, 1000 / 60); };

// eslint-disable-next-line no-unused-vars
var _WebGL_entity = F5(function (settings, vert, frag, mesh, uniforms) {

  if (!mesh.id) {
    mesh.id = _WebGL_guid++;
  }

  return {
    $: 0,
    a: settings,
    b: vert,
    c: frag,
    d: mesh,
    e: uniforms
  };

});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableBlend = F2(function (gl, setting) {
  gl.enable(gl.BLEND);
  // a   b   c   d   e   f   g h i j
  // eq1 f11 f12 eq2 f21 f22 r g b a
  gl.blendEquationSeparate(setting.a, setting.d);
  gl.blendFuncSeparate(setting.b, setting.c, setting.e, setting.f);
  gl.blendColor(setting.g, setting.h, setting.i, setting.j);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableDepthTest = F2(function (gl, setting) {
  gl.enable(gl.DEPTH_TEST);
  // a    b    c    d
  // func mask near far
  gl.depthFunc(setting.a);
  gl.depthMask(setting.b);
  gl.depthRange(setting.c, setting.d);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableStencilTest = F2(function (gl, setting) {
  gl.enable(gl.STENCIL_TEST);
  // a   b    c         d     e     f      g      h     i     j      k
  // ref mask writeMask test1 fail1 zfail1 zpass1 test2 fail2 zfail2 zpass2
  gl.stencilFuncSeparate(gl.FRONT, setting.d, setting.a, setting.b);
  gl.stencilOpSeparate(gl.FRONT, setting.e, setting.f, setting.g);
  gl.stencilMaskSeparate(gl.FRONT, setting.c);
  gl.stencilFuncSeparate(gl.BACK, setting.h, setting.a, setting.b);
  gl.stencilOpSeparate(gl.BACK, setting.i, setting.j, setting.k);
  gl.stencilMaskSeparate(gl.BACK, setting.c);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableScissor = F2(function (gl, setting) {
  gl.enable(gl.SCISSOR_TEST);
  gl.scissor(setting.a, setting.b, setting.c, setting.d);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableColorMask = F2(function (gl, setting) {
  gl.colorMask(setting.a, setting.b, setting.c, setting.d);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableCullFace = F2(function (gl, setting) {
  gl.enable(gl.CULL_FACE);
  gl.cullFace(setting.a);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enablePolygonOffset = F2(function (gl, setting) {
  gl.enable(gl.POLYGON_OFFSET_FILL);
  gl.polygonOffset(setting.a, setting.b);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableSampleCoverage = F2(function (gl, setting) {
  gl.enable(gl.SAMPLE_COVERAGE);
  gl.sampleCoverage(setting.a, setting.b);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableSampleAlphaToCoverage = F2(function (gl, setting) {
  gl.enable(gl.SAMPLE_ALPHA_TO_COVERAGE);
});

// eslint-disable-next-line no-unused-vars
var _WebGL_disableBlend = function (gl) {
  gl.disable(gl.BLEND);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableDepthTest = function (gl) {
  gl.disable(gl.DEPTH_TEST);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableStencilTest = function (gl) {
  gl.disable(gl.STENCIL_TEST);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableScissor = function (gl) {
  gl.disable(gl.SCISSOR_TEST);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableColorMask = function (gl) {
  gl.colorMask(true, true, true, true);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableCullFace = function (gl) {
  gl.disable(gl.CULL_FACE);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disablePolygonOffset = function (gl) {
  gl.disable(gl.POLYGON_OFFSET_FILL);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableSampleCoverage = function (gl) {
  gl.disable(gl.SAMPLE_COVERAGE);
};

// eslint-disable-next-line no-unused-vars
var _WebGL_disableSampleAlphaToCoverage = function (gl) {
  gl.disable(gl.SAMPLE_ALPHA_TO_COVERAGE);
};

function _WebGL_doCompile(gl, src, type) {

  var shader = gl.createShader(type);
  _WebGL_log('Created shader');

  gl.shaderSource(shader, src);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    throw gl.getShaderInfoLog(shader);
  }

  return shader;

}

function _WebGL_doLink(gl, vshader, fshader) {

  var program = gl.createProgram();
  _WebGL_log('Created program');

  gl.attachShader(program, vshader);
  gl.attachShader(program, fshader);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    throw gl.getProgramInfoLog(program);
  }

  return program;

}

function _WebGL_getAttributeInfo(gl, type) {
  switch (type) {
    case gl.FLOAT:
      return { size: 1, type: Float32Array, baseType: gl.FLOAT };
    case gl.FLOAT_VEC2:
      return { size: 2, type: Float32Array, baseType: gl.FLOAT };
    case gl.FLOAT_VEC3:
      return { size: 3, type: Float32Array, baseType: gl.FLOAT };
    case gl.FLOAT_VEC4:
      return { size: 4, type: Float32Array, baseType: gl.FLOAT };
    case gl.INT:
      return { size: 1, type: Int32Array, baseType: gl.INT };
    case gl.INT_VEC2:
      return { size: 2, type: Int32Array, baseType: gl.INT };
    case gl.INT_VEC3:
      return { size: 3, type: Int32Array, baseType: gl.INT };
    case gl.INT_VEC4:
      return { size: 4, type: Int32Array, baseType: gl.INT };
  }
}

/**
 *  Form the buffer for a given attribute.
 *
 *  @param {WebGLRenderingContext} gl context
 *  @param {WebGLActiveInfo} attribute the attribute to bind to.
 *         We use its name to grab the record by name and also to know
 *         how many elements we need to grab.
 *  @param {Mesh} mesh The mesh coming in from Elm.
 *  @param {Object} attributes The mapping between the attribute names and Elm fields
 *  @return {WebGLBuffer}
 */
function _WebGL_doBindAttribute(gl, attribute, mesh, attributes) {
  // The length of the number of vertices that
  // complete one 'thing' based on the drawing mode.
  // ie, 2 for Lines, 3 for Triangles, etc.
  var elemSize = mesh.a.elemSize;

  var idxKeys = [];
  for (var i = 0; i < elemSize; i++) {
    idxKeys.push(String.fromCharCode(97 + i));
  }

  function dataFill(data, cnt, fillOffset, elem, key) {
    var i;
    if (elemSize === 1) {
      for (i = 0; i < cnt; i++) {
        data[fillOffset++] = cnt === 1 ? elem[key] : elem[key][i];
      }
    } else {
      idxKeys.forEach(function (idx) {
        for (i = 0; i < cnt; i++) {
          data[fillOffset++] = cnt === 1 ? elem[idx][key] : elem[idx][key][i];
        }
      });
    }
  }

  var attributeInfo = _WebGL_getAttributeInfo(gl, attribute.type);

  if (attributeInfo === undefined) {
    throw new Error('No info available for: ' + attribute.type);
  }

  var dataIdx = 0;
  var array = new attributeInfo.type(_WebGL_listLength(mesh.b) * attributeInfo.size * elemSize);

  _WebGL_listEach(function (elem) {
    dataFill(array, attributeInfo.size, dataIdx, elem, attributes[attribute.name] || attribute.name);
    dataIdx += attributeInfo.size * elemSize;
  }, mesh.b);

  var buffer = gl.createBuffer();
  _WebGL_log('Created attribute buffer ' + attribute.name);

  gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
  gl.bufferData(gl.ARRAY_BUFFER, array, gl.STATIC_DRAW);
  return buffer;
}

/**
 *  This sets up the binding caching buffers.
 *
 *  We don't actually bind any buffers now except for the indices buffer.
 *  The problem with filling the buffers here is that it is possible to
 *  have a buffer shared between two webgl shaders;
 *  which could have different active attributes. If we bind it here against
 *  a particular program, we might not bind them all. That final bind is now
 *  done right before drawing.
 *
 *  @param {WebGLRenderingContext} gl context
 *  @param {Mesh} mesh a mesh object from Elm
 *  @return {Object} buffer - an object with the following properties
 *  @return {Number} buffer.numIndices
 *  @return {WebGLBuffer} buffer.indexBuffer
 *  @return {Object} buffer.buffers - will be used to buffer attributes
 */
function _WebGL_doBindSetup(gl, mesh) {
  _WebGL_log('Created index buffer');
  var indexBuffer = gl.createBuffer();
  var indices = (mesh.a.indexSize === 0)
    ? _WebGL_makeSequentialBuffer(mesh.a.elemSize * _WebGL_listLength(mesh.b))
    : _WebGL_makeIndexedBuffer(mesh.c, mesh.a.indexSize);

  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);

  return {
    numIndices: indices.length,
    indexBuffer: indexBuffer,
    buffers: {}
  };
}

/**
 *  Create an indices array and fill it with 0..n
 *
 *  @param {Number} numIndices The number of indices
 *  @return {Uint16Array} indices
 */
function _WebGL_makeSequentialBuffer(numIndices) {
  var indices = new Uint16Array(numIndices);
  for (var i = 0; i < numIndices; i++) {
    indices[i] = i;
  }
  return indices;
}

/**
 *  Create an indices array and fill it from indices
 *  based on the size of the index
 *
 *  @param {List} indicesList the list of indices
 *  @param {Number} indexSize the size of the index
 *  @return {Uint16Array} indices
 */
function _WebGL_makeIndexedBuffer(indicesList, indexSize) {
  var indices = new Uint16Array(_WebGL_listLength(indicesList) * indexSize);
  var fillOffset = 0;
  var i;
  _WebGL_listEach(function (elem) {
    if (indexSize === 1) {
      indices[fillOffset++] = elem;
    } else {
      for (i = 0; i < indexSize; i++) {
        indices[fillOffset++] = elem[String.fromCharCode(97 + i)];
      }
    }
  }, indicesList);
  return indices;
}

function _WebGL_getProgID(vertID, fragID) {
  return vertID + '#' + fragID;
}

var _WebGL_drawGL = F2(function (model, domNode) {

  var gl = model.f.gl;

  if (!gl) {
    return domNode;
  }

  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT);
  _WebGL_log('Drawing');

  function drawEntity(entity) {
    if (!entity.d.b.b) {
      return; // Empty list
    }

    var progid;
    var program;
    if (entity.b.id && entity.c.id) {
      progid = _WebGL_getProgID(entity.b.id, entity.c.id);
      program = model.f.programs[progid];
    }

    if (!program) {

      var vshader;
      if (entity.b.id) {
        vshader = model.f.shaders[entity.b.id];
      } else {
        entity.b.id = _WebGL_guid++;
      }

      if (!vshader) {
        vshader = _WebGL_doCompile(gl, entity.b.src, gl.VERTEX_SHADER);
        model.f.shaders[entity.b.id] = vshader;
      }

      var fshader;
      if (entity.c.id) {
        fshader = model.f.shaders[entity.c.id];
      } else {
        entity.c.id = _WebGL_guid++;
      }

      if (!fshader) {
        fshader = _WebGL_doCompile(gl, entity.c.src, gl.FRAGMENT_SHADER);
        model.f.shaders[entity.c.id] = fshader;
      }

      var glProgram = _WebGL_doLink(gl, vshader, fshader);

      program = {
        glProgram: glProgram,
        attributes: Object.assign({}, entity.b.attributes, entity.c.attributes),
        uniformSetters: _WebGL_createUniformSetters(
          gl,
          model,
          glProgram,
          Object.assign({}, entity.b.uniforms, entity.c.uniforms)
        )
      };

      progid = _WebGL_getProgID(entity.b.id, entity.c.id);
      model.f.programs[progid] = program;

    }

    gl.useProgram(program.glProgram);

    _WebGL_setUniforms(program.uniformSetters, entity.e);

    var buffer = model.f.buffers[entity.d.id];

    if (!buffer) {
      buffer = _WebGL_doBindSetup(gl, entity.d);
      model.f.buffers[entity.d.id] = buffer;
    }

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer.indexBuffer);

    var numAttributes = gl.getProgramParameter(program.glProgram, gl.ACTIVE_ATTRIBUTES);

    for (var i = 0; i < numAttributes; i++) {
      var attribute = gl.getActiveAttrib(program.glProgram, i);

      var attribLocation = gl.getAttribLocation(program.glProgram, attribute.name);
      gl.enableVertexAttribArray(attribLocation);

      if (buffer.buffers[attribute.name] === undefined) {
        buffer.buffers[attribute.name] = _WebGL_doBindAttribute(gl, attribute, entity.d, program.attributes);
      }
      var attributeBuffer = buffer.buffers[attribute.name];
      var attributeInfo = _WebGL_getAttributeInfo(gl, attribute.type);

      gl.bindBuffer(gl.ARRAY_BUFFER, attributeBuffer);
      gl.vertexAttribPointer(attribLocation, attributeInfo.size, attributeInfo.baseType, false, 0, 0);
    }

    _WebGL_listEach(function (setting) {
      A2($elm_explorations$webgl$WebGL$Internal$enableSetting, gl, setting);
    }, entity.a);

    gl.drawElements(entity.d.a.mode, buffer.numIndices, gl.UNSIGNED_SHORT, 0);

    _WebGL_listEach(function (setting) {
      A2($elm_explorations$webgl$WebGL$Internal$disableSetting, gl, setting);
    }, entity.a);

  }

  _WebGL_listEach(drawEntity, model.g);
  return domNode;
});

function _WebGL_createUniformSetters(gl, model, program, uniformsMap) {
  var textureCounter = 0;
  function createUniformSetter(program, uniform) {
    var uniformLocation = gl.getUniformLocation(program, uniform.name);
    switch (uniform.type) {
      case gl.INT:
        return function (value) {
          gl.uniform1i(uniformLocation, value);
        };
      case gl.FLOAT:
        return function (value) {
          gl.uniform1f(uniformLocation, value);
        };
      case gl.FLOAT_VEC2:
        return function (value) {
          gl.uniform2fv(uniformLocation, new Float32Array(value));
        };
      case gl.FLOAT_VEC3:
        return function (value) {
          gl.uniform3fv(uniformLocation, new Float32Array(value));
        };
      case gl.FLOAT_VEC4:
        return function (value) {
          gl.uniform4fv(uniformLocation, new Float32Array(value));
        };
      case gl.FLOAT_MAT4:
        return function (value) {
          gl.uniformMatrix4fv(uniformLocation, false, new Float32Array(value));
        };
      case gl.SAMPLER_2D:
        var currentTexture = textureCounter++;
        return function (texture) {
          gl.activeTexture(gl.TEXTURE0 + currentTexture);
          var tex = model.f.textures[texture.id];
          if (!tex) {
            _WebGL_log('Created texture');
            tex = texture.createTexture(gl);
            model.f.textures[texture.id] = tex;
          }
          gl.bindTexture(gl.TEXTURE_2D, tex);
          gl.uniform1i(uniformLocation, currentTexture);
        };
      case gl.BOOL:
        return function (value) {
          gl.uniform1i(uniformLocation, value);
        };
      default:
        _WebGL_log('Unsupported uniform type: ' + uniform.type);
        return function () {};
    }
  }

  var uniformSetters = {};
  var numUniforms = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
  for (var i = 0; i < numUniforms; i++) {
    var uniform = gl.getActiveUniform(program, i);
    uniformSetters[uniformsMap[uniform.name] || uniform.name] = createUniformSetter(program, uniform);
  }

  return uniformSetters;
}

function _WebGL_setUniforms(setters, values) {
  Object.keys(values).forEach(function (name) {
    var setter = setters[name];
    if (setter) {
      setter(values[name]);
    }
  });
}

// VIRTUAL-DOM WIDGET

// eslint-disable-next-line no-unused-vars
var _WebGL_toHtml = F3(function (options, factList, entities) {
  return _VirtualDom_custom(
    factList,
    {
      g: entities,
      f: {},
      h: options
    },
    _WebGL_render,
    _WebGL_diff
  );
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableAlpha = F2(function (options, option) {
  options.contextAttributes.alpha = true;
  options.contextAttributes.premultipliedAlpha = option.a;
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableDepth = F2(function (options, option) {
  options.contextAttributes.depth = true;
  options.sceneSettings.push(function (gl) {
    gl.clearDepth(option.a);
  });
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableStencil = F2(function (options, option) {
  options.contextAttributes.stencil = true;
  options.sceneSettings.push(function (gl) {
    gl.clearStencil(option.a);
  });
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableAntialias = F2(function (options, option) {
  options.contextAttributes.antialias = true;
});

// eslint-disable-next-line no-unused-vars
var _WebGL_enableClearColor = F2(function (options, option) {
  options.sceneSettings.push(function (gl) {
    gl.clearColor(option.a, option.b, option.c, option.d);
  });
});

/**
 *  Creates canvas and schedules initial _WebGL_drawGL
 *  @param {Object} model
 *  @param {Object} model.f that may contain the following properties:
           gl, shaders, programs, buffers, textures
 *  @param {List<Option>} model.h list of options coming from Elm
 *  @param {List<Entity>} model.g list of entities coming from Elm
 *  @return {HTMLElement} <canvas> if WebGL is supported, otherwise a <div>
 */
function _WebGL_render(model) {
  var options = {
    contextAttributes: {
      alpha: false,
      depth: false,
      stencil: false,
      antialias: false,
      premultipliedAlpha: false
    },
    sceneSettings: []
  };

  _WebGL_listEach(function (option) {
    A2($elm_explorations$webgl$WebGL$Internal$enableOption, options, option);
  }, model.h);

  _WebGL_log('Render canvas');
  var canvas = _VirtualDom_doc.createElement('canvas');
  var gl = canvas.getContext && (
    canvas.getContext('webgl', options.contextAttributes) ||
    canvas.getContext('experimental-webgl', options.contextAttributes)
  );

  if (gl) {
    options.sceneSettings.forEach(function (sceneSetting) {
      sceneSetting(gl);
    });
  } else {
    canvas = _VirtualDom_doc.createElement('div');
    canvas.innerHTML = '<a href="https://get.webgl.org/">Enable WebGL</a> to see this content!';
  }

  model.f.gl = gl;
  model.f.shaders = [];
  model.f.programs = {};
  model.f.buffers = [];
  model.f.textures = [];

  // Render for the first time.
  // This has to be done in animation frame,
  // because the canvas is not in the DOM yet
  _WebGL_rAF(function () {
    A2(_WebGL_drawGL, model, canvas);
  });

  return canvas;
}

function _WebGL_diff(oldModel, newModel) {
  newModel.f = oldModel.f;
  return _WebGL_drawGL(newModel);
}
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$EQ = {$: 'EQ'};
var $elm$core$Basics$GT = {$: 'GT'};
var $elm$core$Basics$LT = {$: 'LT'};
var $elm$core$Result$Err = function (a) {
	return {$: 'Err', a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 'Failure', a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 'Field', a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 'Index', a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 'Ok', a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 'OneOf', a: a};
};
var $elm$core$Basics$False = {$: 'False'};
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 'Just', a: a};
};
var $elm$core$Maybe$Nothing = {$: 'Nothing'};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 'Field':
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 'Nothing') {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'Index':
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 'OneOf':
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 'Array_elm_builtin', a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 'Leaf', a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 'SubTree', a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.nodeListSize) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.tail);
		} else {
			var treeLen = builder.nodeListSize * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.nodeList) : builder.nodeList;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.nodeListSize);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.tail) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.tail);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{nodeList: nodeList, nodeListSize: (len / $elm$core$Array$branchFactor) | 0, tail: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = {$: 'True'};
var $elm$core$Result$isOk = function (result) {
	if (result.$ === 'Ok') {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 'Normal':
			return 0;
		case 'MayStopPropagation':
			return 1;
		case 'MayPreventDefault':
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 'External', a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 'Internal', a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = function (a) {
	return {$: 'NotFound', a: a};
};
var $elm$url$Url$Http = {$: 'Http'};
var $elm$url$Url$Https = {$: 'Https'};
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {fragment: fragment, host: host, path: path, port_: port_, protocol: protocol, query: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 'Nothing') {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Http,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		$elm$url$Url$Https,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0.a;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = function (a) {
	return {$: 'Perform', a: a};
};
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(_Utils_Tuple0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0.a;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return _Utils_Tuple0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(_Utils_Tuple0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0.a;
		return $elm$core$Task$Perform(
			A2($elm$core$Task$map, tagger, task));
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			$elm$core$Task$Perform(
				A2($elm$core$Task$map, toMessage, task)));
	});
var $elm$browser$Browser$document = _Browser_document;
var $elm$json$Json$Decode$field = _Json_decodeField;
var $author$project$App$MenuMain = {$: 'MenuMain'};
var $author$project$App$SelectedButton = function (a) {
	return {$: 'SelectedButton', a: a};
};
var $author$project$App$SceneMain = F2(
	function (a, b) {
		return {$: 'SceneMain', a: a, b: b};
	});
var $author$project$App$SubSceneDemo = {$: 'SubSceneDemo'};
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$random$Random$Generator = function (a) {
	return {$: 'Generator', a: a};
};
var $elm$random$Random$constant = function (value) {
	return $elm$random$Random$Generator(
		function (seed) {
			return _Utils_Tuple2(value, seed);
		});
};
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Random$List$get = F2(
	function (index, list) {
		return $elm$core$List$head(
			A2($elm$core$List$drop, index, list));
	});
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$random$Random$Seed = F2(
	function (a, b) {
		return {$: 'Seed', a: a, b: b};
	});
var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
var $elm$random$Random$next = function (_v0) {
	var state0 = _v0.a;
	var incr = _v0.b;
	return A2($elm$random$Random$Seed, ((state0 * 1664525) + incr) >>> 0, incr);
};
var $elm$core$Bitwise$xor = _Bitwise_xor;
var $elm$random$Random$peel = function (_v0) {
	var state = _v0.a;
	var word = (state ^ (state >>> ((state >>> 28) + 4))) * 277803737;
	return ((word >>> 22) ^ word) >>> 0;
};
var $elm$random$Random$int = F2(
	function (a, b) {
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v0 = (_Utils_cmp(a, b) < 0) ? _Utils_Tuple2(a, b) : _Utils_Tuple2(b, a);
				var lo = _v0.a;
				var hi = _v0.b;
				var range = (hi - lo) + 1;
				if (!((range - 1) & range)) {
					return _Utils_Tuple2(
						(((range - 1) & $elm$random$Random$peel(seed0)) >>> 0) + lo,
						$elm$random$Random$next(seed0));
				} else {
					var threshhold = (((-range) >>> 0) % range) >>> 0;
					var accountForBias = function (seed) {
						accountForBias:
						while (true) {
							var x = $elm$random$Random$peel(seed);
							var seedN = $elm$random$Random$next(seed);
							if (_Utils_cmp(x, threshhold) < 0) {
								var $temp$seed = seedN;
								seed = $temp$seed;
								continue accountForBias;
							} else {
								return _Utils_Tuple2((x % range) + lo, seedN);
							}
						}
					};
					return accountForBias(seed0);
				}
			});
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $elm$random$Random$map = F2(
	function (func, _v0) {
		var genA = _v0.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v1 = genA(seed0);
				var a = _v1.a;
				var seed1 = _v1.b;
				return _Utils_Tuple2(
					func(a),
					seed1);
			});
	});
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $author$project$Random$List$choose = function (list) {
	if ($elm$core$List$isEmpty(list)) {
		return $elm$random$Random$constant(
			_Utils_Tuple2($elm$core$Maybe$Nothing, list));
	} else {
		var lastIndex = $elm$core$List$length(list) - 1;
		var gen = A2($elm$random$Random$int, 0, lastIndex);
		var front = function (i) {
			return A2($elm$core$List$take, i, list);
		};
		var back = function (i) {
			return A2($elm$core$List$drop, i + 1, list);
		};
		return A2(
			$elm$random$Random$map,
			function (index) {
				return _Utils_Tuple2(
					A2($author$project$Random$List$get, index, list),
					A2(
						$elm$core$List$append,
						front(index),
						back(index)));
			},
			gen);
	}
};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $elm$core$Set$Set_elm_builtin = function (a) {
	return {$: 'Set_elm_builtin', a: a};
};
var $elm$core$Dict$RBEmpty_elm_builtin = {$: 'RBEmpty_elm_builtin'};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Set$empty = $elm$core$Set$Set_elm_builtin($elm$core$Dict$empty);
var $elm$core$Dict$Black = {$: 'Black'};
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: 'RBNode_elm_builtin', a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = {$: 'Red'};
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Red')) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) && (left.d.$ === 'RBNode_elm_builtin')) && (left.d.a.$ === 'Red')) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Red,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1.$) {
				case 'LT':
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 'EQ':
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return $elm$core$Set$Set_elm_builtin(
			A3($elm$core$Dict$insert, key, _Utils_Tuple0, dict));
	});
var $elm$core$Set$fromList = function (list) {
	return A3($elm$core$List$foldl, $elm$core$Set$insert, $elm$core$Set$empty, list);
};
var $author$project$OfficialMaps$default = {
	author: '',
	halfHeight: 10,
	halfWidth: 20,
	leftBase: _Utils_Tuple2(-15, 0),
	name: 'Default map',
	rightBase: _Utils_Tuple2(15, 0),
	smallBases: $elm$core$Set$fromList(
		_List_fromArray(
			[
				_Utils_Tuple2(0, -7),
				_Utils_Tuple2(0, 7)
			])),
	wallTiles: $elm$core$Set$empty
};
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $elm$random$Random$initialSeed = function (x) {
	var _v0 = $elm$random$Random$next(
		A2($elm$random$Random$Seed, 0, 1013904223));
	var state1 = _v0.a;
	var incr = _v0.b;
	var state2 = (state1 + x) >>> 0;
	return $elm$random$Random$next(
		A2($elm$random$Random$Seed, state2, incr));
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$List$sortBy = _List_sortBy;
var $author$project$Game$BaseMain = {$: 'BaseMain'};
var $elm_community$list_extra$List$Extra$find = F2(
	function (predicate, list) {
		find:
		while (true) {
			if (!list.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var first = list.a;
				var rest = list.b;
				if (predicate(first)) {
					return $elm$core$Maybe$Just(first);
				} else {
					var $temp$predicate = predicate,
						$temp$list = rest;
					predicate = $temp$predicate;
					list = $temp$list;
					continue find;
				}
			}
		}
	});
var $author$project$Base$isOccupiedBy = F2(
	function (maybeTeamId, base) {
		var _v0 = base.maybeOccupied;
		if (_v0.$ === 'Nothing') {
			return false;
		} else {
			var occupied = _v0.a;
			return _Utils_eq(occupied.maybeTeamId, maybeTeamId);
		}
	});
var $elm$core$Dict$values = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return A2($elm$core$List$cons, value, valueList);
			}),
		_List_Nil,
		dict);
};
var $author$project$Base$teamMainBase = F2(
	function (game, maybeTeamId) {
		return A2(
			$elm_community$list_extra$List$Extra$find,
			function (b) {
				return _Utils_eq(b.type_, $author$project$Game$BaseMain) && A2($author$project$Base$isOccupiedBy, maybeTeamId, b);
			},
			$elm$core$Dict$values(game.baseById));
	});
var $elm_explorations$linear_algebra$Math$Vector2$vec2 = _MJS_v2;
var $elm$core$Basics$abs = function (n) {
	return (n < 0) ? (-n) : n;
};
var $elm_explorations$linear_algebra$Math$Vector2$toRecord = _MJS_v2toRecord;
var $author$project$Game$vectorDistance = F2(
	function (v1, v2) {
		var b = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v2);
		var a = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v1);
		return $elm$core$Basics$abs(a.x - b.x) + $elm$core$Basics$abs(a.y - b.y);
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (maybe.$ === 'Just') {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Bot$Dummy$init = F5(
	function (inputKey, teamId, hasHumanAlly, randomInteger, game) {
		var mainBasePosition = A2(
			$elm$core$Maybe$withDefault,
			A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
			A2(
				$elm$core$Maybe$map,
				function ($) {
					return $.position;
				},
				A2(
					$author$project$Base$teamMainBase,
					game,
					$elm$core$Maybe$Just(teamId))));
		var basesSortedByPriority = A2(
			$elm$core$List$map,
			function ($) {
				return $.id;
			},
			A2(
				$elm$core$List$sortBy,
				function (base) {
					return A2($author$project$Game$vectorDistance, base.position, mainBasePosition);
				},
				$elm$core$Dict$values(game.baseById)));
		return {
			basesSortedByPriority: basesSortedByPriority,
			hasHumanAlly: hasHumanAlly,
			inputKey: inputKey,
			lastChange: game.time,
			randomSeed: $elm$random$Random$initialSeed(randomInteger),
			speedAroundBase: 1,
			teamId: teamId
		};
	});
var $author$project$MainScene$inputIsBot = function (key) {
	return A2($elm$core$String$startsWith, 'bot ', key);
};
var $elm$core$Basics$neq = _Utils_notEqual;
var $elm$core$Basics$not = _Basics_not;
var $elm$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var left = dict.d;
				var right = dict.e;
				var $temp$n = A2($elm$core$Dict$sizeHelp, n + 1, right),
					$temp$dict = left;
				n = $temp$n;
				dict = $temp$dict;
				continue sizeHelp;
			}
		}
	});
var $elm$core$Dict$size = function (dict) {
	return A2($elm$core$Dict$sizeHelp, 0, dict);
};
var $elm$core$Dict$foldl = F3(
	function (func, acc, dict) {
		foldl:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldl, func, acc, left)),
					$temp$dict = right;
				func = $temp$func;
				acc = $temp$acc;
				dict = $temp$dict;
				continue foldl;
			}
		}
	});
var $elm$core$Dict$union = F2(
	function (t1, t2) {
		return A3($elm$core$Dict$foldl, $elm$core$Dict$insert, t2, t1);
	});
var $author$project$MainScene$initBots = function (model) {
	var humanInputs = function (team) {
		return A2(
			$elm$core$List$filter,
			A2($elm$core$Basics$composeR, $author$project$MainScene$inputIsBot, $elm$core$Basics$not),
			$elm$core$Dict$keys(team.mechClassByInputKey));
	};
	var initBot = F4(
		function (inputKey, team, n, game) {
			return A5(
				$author$project$Bot$Dummy$init,
				inputKey,
				team.id,
				!_Utils_eq(
					humanInputs(team),
					_List_Nil),
				n,
				game);
		});
	var addBot = F3(
		function (team, inputKey, botStatesByKey) {
			return A3(
				$elm$core$Dict$insert,
				inputKey,
				A4(
					initBot,
					inputKey,
					team,
					$elm$core$Dict$size(botStatesByKey),
					model.game),
				botStatesByKey);
		});
	var teamBots = function (team) {
		return A3(
			$elm$core$List$foldl,
			addBot(team),
			$elm$core$Dict$empty,
			A2(
				$elm$core$List$filter,
				$author$project$MainScene$inputIsBot,
				$elm$core$Dict$keys(team.mechClassByInputKey)));
	};
	return _Utils_update(
		model,
		{
			botStatesByKey: A2(
				$elm$core$Dict$union,
				teamBots(model.game.leftTeam),
				teamBots(model.game.rightTeam))
		});
};
var $author$project$Game$TeamLeft = {$: 'TeamLeft'};
var $author$project$Game$TeamRight = {$: 'TeamRight'};
var $elm$random$Random$andThen = F2(
	function (callback, _v0) {
		var genA = _v0.a;
		return $elm$random$Random$Generator(
			function (seed) {
				var _v1 = genA(seed);
				var result = _v1.a;
				var newSeed = _v1.b;
				var _v2 = callback(result);
				var genB = _v2.a;
				return genB(newSeed);
			});
	});
var $author$project$Game$GameFadeIn = {$: 'GameFadeIn'};
var $author$project$Game$GameModeVersus = {$: 'GameModeVersus'};
var $elm$core$Set$union = F2(
	function (_v0, _v1) {
		var dict1 = _v0.a;
		var dict2 = _v1.a;
		return $elm$core$Set$Set_elm_builtin(
			A2($elm$core$Dict$union, dict1, dict2));
	});
var $author$project$Game$addStaticObstacles = F2(
	function (tiles, game) {
		return _Utils_update(
			game,
			{
				staticObstacles: A2(
					$elm$core$Set$union,
					$elm$core$Set$fromList(tiles),
					game.staticObstacles)
			});
	});
var $author$project$Game$tile2Vec = function (_v0) {
	var x = _v0.a;
	var y = _v0.b;
	return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, x, y);
};
var $author$project$Base$size = function (baseType) {
	if (baseType.$ === 'BaseSmall') {
		return 2;
	} else {
		return 4;
	}
};
var $author$project$Game$centeredTileInterval = function (length) {
	return A2($elm$core$List$range, ((-length) / 2) | 0, ((length - 1) / 2) | 0);
};
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $author$project$Game$squareArea = F2(
	function (sideLength, _v0) {
		var centerX = _v0.a;
		var centerY = _v0.b;
		var range = $author$project$Game$centeredTileInterval(sideLength);
		return $elm$core$List$concat(
			A2(
				$elm$core$List$map,
				function (x) {
					return A2(
						$elm$core$List$map,
						function (y) {
							return _Utils_Tuple2(centerX + x, centerY + y);
						},
						range);
				},
				range));
	});
var $author$project$Base$tiles = F2(
	function (baseType, tile) {
		return A2(
			$author$project$Game$squareArea,
			$author$project$Base$size(baseType),
			tile);
	});
var $author$project$Base$add = F3(
	function (type_, tile, game) {
		var id = game.lastId + 1;
		var base = {
			id: id,
			maybeOccupied: $elm$core$Maybe$Nothing,
			position: $author$project$Game$tile2Vec(tile),
			tile: tile,
			type_: type_
		};
		return _Utils_Tuple2(
			A2(
				$author$project$Game$addStaticObstacles,
				A2($author$project$Base$tiles, type_, tile),
				_Utils_update(
					game,
					{
						baseById: A3($elm$core$Dict$insert, id, base, game.baseById),
						lastId: id
					})),
			base);
	});
var $author$project$Game$UnitModeFree = {$: 'UnitModeFree'};
var $author$project$Game$UnitSub = function (a) {
	return {$: 'UnitSub', a: a};
};
var $elm_explorations$linear_algebra$Math$Vector2$negate = _MJS_v2negate;
var $elm$core$Basics$atan2 = _Basics_atan2;
var $author$project$Game$vecToAngle = function (v) {
	var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v);
	var x = _v0.x;
	var y = _v0.y;
	return A2($elm$core$Basics$atan2, x, y);
};
var $author$project$Game$addUnit = F5(
	function (component, maybeTeamId, position, startAngle, game) {
		var id = game.lastId + 1;
		var unit = {component: component, fireAngle: startAngle, id: id, integrity: 1, isLeavingBase: true, lastDamaged: -99, lookAngle: startAngle, maybeCharge: $elm$core$Maybe$Nothing, maybeTeamId: maybeTeamId, moveAngle: startAngle, position: position, reloadEndTime: game.time};
		var unitById = A3($elm$core$Dict$insert, id, unit, game.unitById);
		var faceCenterOfMap = $author$project$Game$vecToAngle(
			$elm_explorations$linear_algebra$Math$Vector2$negate(position));
		return _Utils_Tuple2(
			_Utils_update(
				game,
				{lastId: id, unitById: unitById}),
			unit);
	});
var $elm$core$Basics$pi = _Basics_pi;
var $author$project$Game$addSub = F4(
	function (maybeTeamId, position, isBig, game) {
		var subComponent = $author$project$Game$UnitSub(
			{isBig: isBig, mode: $author$project$Game$UnitModeFree, targetId: -1});
		var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(position);
		var x = _v0.x;
		var y = _v0.y;
		var startAngle = function () {
			var _v1 = _Utils_Tuple2(
				_Utils_cmp(y, x) > 0,
				_Utils_cmp(y, -x) > 0);
			if (!_v1.a) {
				if (_v1.b) {
					return (-$elm$core$Basics$pi) / 2;
				} else {
					return 0;
				}
			} else {
				if (_v1.b) {
					return $elm$core$Basics$pi;
				} else {
					return $elm$core$Basics$pi / 2;
				}
			}
		}();
		return A5($author$project$Game$addUnit, subComponent, maybeTeamId, position, startAngle, game);
	});
var $author$project$Game$UnitModeBase = function (a) {
	return {$: 'UnitModeBase', a: a};
};
var $author$project$Base$corners = function (base) {
	var r = (($author$project$Base$size(base.type_) / 2) | 0) - 0.2;
	var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(base.position);
	var x = _v0.x;
	var y = _v0.y;
	return _List_fromArray(
		[
			A2($elm_explorations$linear_algebra$Math$Vector2$vec2, x + r, y + r),
			A2($elm_explorations$linear_algebra$Math$Vector2$vec2, x - r, y + r),
			A2($elm_explorations$linear_algebra$Math$Vector2$vec2, x - r, y - r),
			A2($elm_explorations$linear_algebra$Math$Vector2$vec2, x + r, y - r)
		]);
};
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (_v0.$ === 'Just') {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$core$Basics$ge = _Utils_ge;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === 'RBEmpty_elm_builtin') {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1.$) {
					case 'LT':
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 'EQ':
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $author$project$Base$maxContainedUnits = 4;
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $elm$core$List$member = F2(
	function (x, xs) {
		return A2(
			$elm$core$List$any,
			function (a) {
				return _Utils_eq(a, x);
			},
			xs);
	});
var $elm$core$Set$size = function (_v0) {
	var dict = _v0.a;
	return $elm$core$Dict$size(dict);
};
var $elm_explorations$linear_algebra$Math$Vector2$sub = _MJS_v2sub;
var $author$project$Game$updateBase = F2(
	function (base, game) {
		return _Utils_update(
			game,
			{
				baseById: A3($elm$core$Dict$insert, base.id, base, game.baseById)
			});
	});
var $author$project$Game$updateSub = F3(
	function (update, game, unit) {
		var _v0 = unit.component;
		if (_v0.$ === 'UnitSub') {
			var subRecord = _v0.a;
			return _Utils_update(
				unit,
				{
					component: $author$project$Game$UnitSub(
						update(subRecord))
				});
		} else {
			return unit;
		}
	});
var $author$project$Game$updateUnit = F2(
	function (unit, game) {
		return _Utils_update(
			game,
			{
				unitById: A3($elm$core$Dict$insert, unit.id, unit, game.unitById)
			});
	});
var $author$project$SubThink$updateUnitEntersBase = F3(
	function (unit, base, game) {
		var originalOccupied = function () {
			var _v1 = base.maybeOccupied;
			if (_v1.$ === 'Nothing') {
				return {isActive: false, maybeTeamId: unit.maybeTeamId, mechBuildCompletions: _List_Nil, subBuildCompletion: 0, unitIds: $elm$core$Set$empty};
			} else {
				var occupied = _v1.a;
				return occupied;
			}
		}();
		var unitsInBase = A2(
			$elm$core$List$filterMap,
			function (id) {
				return A2($elm$core$Dict$get, id, game.unitById);
			},
			$elm$core$Set$toList(originalOccupied.unitIds));
		var takenCorners = A2(
			$elm$core$List$map,
			function ($) {
				return $.position;
			},
			unitsInBase);
		var baseCorners = $author$project$Base$corners(base);
		var _v0 = A2(
			$elm_community$list_extra$List$Extra$find,
			function (corner) {
				return !A2($elm$core$List$member, corner, takenCorners);
			},
			baseCorners);
		if (_v0.$ === 'Nothing') {
			return game;
		} else {
			var corner = _v0.a;
			var unitIds = A2($elm$core$Set$insert, unit.id, originalOccupied.unitIds);
			var occupied = _Utils_update(
				originalOccupied,
				{
					isActive: originalOccupied.isActive || (_Utils_cmp(
						$elm$core$Set$size(unitIds),
						$author$project$Base$maxContainedUnits) > -1),
					unitIds: unitIds
				});
			var updatedBase = _Utils_update(
				base,
				{
					maybeOccupied: $elm$core$Maybe$Just(occupied)
				});
			var angle = $author$project$Game$vecToAngle(
				A2($elm_explorations$linear_algebra$Math$Vector2$sub, corner, base.position));
			var updatedUnit = function (u) {
				return _Utils_update(
					u,
					{moveAngle: angle, position: corner});
			}(
				A3(
					$author$project$Game$updateSub,
					function (s) {
						return _Utils_update(
							s,
							{
								mode: $author$project$Game$UnitModeBase(base.id)
							});
					},
					game,
					unit));
			return A2(
				$author$project$Game$updateBase,
				updatedBase,
				A2($author$project$Game$updateUnit, updatedUnit, game));
		}
	});
var $author$project$Game$with = F4(
	function (getter, game, id, fn) {
		var _v0 = A2(
			$elm$core$Dict$get,
			id,
			getter(game));
		if (_v0.$ === 'Nothing') {
			return game;
		} else {
			var item = _v0.a;
			return fn(item);
		}
	});
var $author$project$Game$withBase = $author$project$Game$with(
	function ($) {
		return $.baseById;
	});
var $author$project$Init$addEmbeddedSub = F3(
	function (maybeTeamId, baseId, game) {
		return A3(
			$author$project$Game$withBase,
			game,
			baseId,
			function (base) {
				var _v0 = A4(
					$author$project$Game$addSub,
					maybeTeamId,
					A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
					false,
					game);
				var game_ = _v0.a;
				var unit = _v0.b;
				return A3($author$project$SubThink$updateUnitEntersBase, unit, base, game_);
			});
	});
var $author$project$Init$addMainBase = F3(
	function (maybeTeamId, tile, game) {
		var _v0 = A3($author$project$Base$add, $author$project$Game$BaseMain, tile, game);
		var game_ = _v0.a;
		var base = _v0.b;
		return A3(
			$author$project$Init$addEmbeddedSub,
			maybeTeamId,
			base.id,
			A3(
				$author$project$Init$addEmbeddedSub,
				maybeTeamId,
				base.id,
				A3(
					$author$project$Init$addEmbeddedSub,
					maybeTeamId,
					base.id,
					A3($author$project$Init$addEmbeddedSub, maybeTeamId, base.id, game_))));
	});
var $author$project$Game$ToFlyer = {$: 'ToFlyer'};
var $author$project$Game$UnitMech = function (a) {
	return {$: 'UnitMech', a: a};
};
var $author$project$Game$addMech = F5(
	function (_class, inputKey, maybeTeamId, position, game) {
		var startAngle = 0;
		var mechComponent = $author$project$Game$UnitMech(
			{_class: _class, inputKey: inputKey, transformState: 1, transformingTo: $author$project$Game$ToFlyer});
		return A5($author$project$Game$addUnit, mechComponent, maybeTeamId, position, startAngle, game);
	});
var $author$project$Init$addMechsForTeam = F2(
	function (team, game) {
		var _v0 = A2(
			$author$project$Base$teamMainBase,
			game,
			$elm$core$Maybe$Just(team.id));
		if (_v0.$ === 'Nothing') {
			return game;
		} else {
			var base = _v0.a;
			return A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, _class, g) {
						return A5(
							$author$project$Game$addMech,
							_class,
							key,
							$elm$core$Maybe$Just(team.id),
							base.position,
							g).a;
					}),
				game,
				team.mechClassByInputKey);
		}
	});
var $author$project$Init$addMechForEveryPlayer = function (game) {
	return A2(
		$author$project$Init$addMechsForTeam,
		game.rightTeam,
		A2($author$project$Init$addMechsForTeam, game.leftTeam, game));
};
var $author$project$Game$BaseSmall = {$: 'BaseSmall'};
var $author$project$Init$addSmallBase = F2(
	function (tile, game) {
		var _v0 = A3($author$project$Base$add, $author$project$Game$BaseSmall, tile, game);
		var game_ = _v0.a;
		var base = _v0.b;
		return A3(
			$author$project$Init$addEmbeddedSub,
			$elm$core$Maybe$Nothing,
			base.id,
			A3(
				$author$project$Init$addEmbeddedSub,
				$elm$core$Maybe$Nothing,
				base.id,
				A3(
					$author$project$Init$addEmbeddedSub,
					$elm$core$Maybe$Nothing,
					base.id,
					A3($author$project$Init$addEmbeddedSub, $elm$core$Maybe$Nothing, base.id, game_))));
	});
var $elm_explorations$linear_algebra$Math$Vector3$toRecord = _MJS_v3toRecord;
var $author$project$ColorPattern$vecToRgb = function (v) {
	var f2s = function (f) {
		return $elm$core$String$fromInt(
			$elm$core$Basics$ceiling(f * 255));
	};
	var _v0 = $elm_explorations$linear_algebra$Math$Vector3$toRecord(v);
	var x = _v0.x;
	var y = _v0.y;
	var z = _v0.z;
	return 'rgb(' + (f2s(x) + (',' + (f2s(y) + (',' + (f2s(z) + ')')))));
};
var $author$project$ColorPattern$pattern = F3(
	function (bright, dark, key) {
		return {
			bright: $author$project$ColorPattern$vecToRgb(bright),
			brightV: bright,
			dark: $author$project$ColorPattern$vecToRgb(dark),
			darkV: dark,
			key: key
		};
	});
var $elm_explorations$linear_algebra$Math$Vector3$vec3 = _MJS_v3;
var $author$project$ColorPattern$neutral = A3(
	$author$project$ColorPattern$pattern,
	A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0.73, 0.73, 0.73),
	A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0.5, 0.5, 0.5),
	'grey');
var $author$project$Game$newTeam = F3(
	function (id, colorPattern, mechs) {
		return {
			bigSubsToSpawn: 0,
			colorPattern: colorPattern,
			id: id,
			markerPosition: A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
			markerTime: 0,
			mechClassByInputKey: mechs,
			pathing: $elm$core$Dict$empty
		};
	});
var $author$project$Game$defaultGame = {
	baseById: $elm$core$Dict$empty,
	cosmetics: _List_Nil,
	dynamicObstacles: $elm$core$Set$empty,
	halfHeight: 10,
	halfWidth: 20,
	lastId: 0,
	laters: _List_Nil,
	leftTeam: A3($author$project$Game$newTeam, $author$project$Game$TeamLeft, $author$project$ColorPattern$neutral, $elm$core$Dict$empty),
	maybeTransition: $elm$core$Maybe$Nothing,
	maybeVictory: $elm$core$Maybe$Nothing,
	mode: $author$project$Game$GameModeVersus,
	projectileById: $elm$core$Dict$empty,
	rightTeam: A3($author$project$Game$newTeam, $author$project$Game$TeamRight, $author$project$ColorPattern$neutral, $elm$core$Dict$empty),
	seed: $elm$random$Random$initialSeed(0),
	shake: 0,
	shakeVector: A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
	slowMotionEnd: 0,
	staticObstacles: $elm$core$Set$empty,
	subBuildMultiplier: 2,
	time: 0,
	timeMultiplier: 1,
	unitById: $elm$core$Dict$empty,
	wallTiles: $elm$core$Set$empty
};
var $elm$core$Set$foldl = F3(
	function (func, initialState, _v0) {
		var dict = _v0.a;
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (key, _v1, state) {
					return A2(func, key, state);
				}),
			initialState,
			dict);
	});
var $elm_explorations$linear_algebra$Math$Vector2$add = _MJS_v2add;
var $author$project$Game$getTeam = F2(
	function (game, teamId) {
		if (teamId.$ === 'TeamLeft') {
			return game.leftTeam;
		} else {
			return game.rightTeam;
		}
	});
var $elm_explorations$linear_algebra$Math$Vector2$normalize = _MJS_v2normalize;
var $elm_explorations$linear_algebra$Math$Vector2$scale = _MJS_v2scale;
var $author$project$Game$updateTeam = F2(
	function (team, game) {
		var _v0 = team.id;
		if (_v0.$ === 'TeamLeft') {
			return _Utils_update(
				game,
				{leftTeam: team});
		} else {
			return _Utils_update(
				game,
				{rightTeam: team});
		}
	});
var $author$project$Init$initMarkerPosition = F2(
	function (id, game) {
		var _v0 = A2(
			$author$project$Base$teamMainBase,
			game,
			$elm$core$Maybe$Just(id));
		if (_v0.$ === 'Nothing') {
			return game;
		} else {
			var base = _v0.a;
			var team = A2($author$project$Game$getTeam, game, id);
			var markerPosition = A2(
				$elm_explorations$linear_algebra$Math$Vector2$add,
				base.position,
				A2(
					$elm_explorations$linear_algebra$Math$Vector2$scale,
					5,
					$elm_explorations$linear_algebra$Math$Vector2$normalize(
						$elm_explorations$linear_algebra$Math$Vector2$negate(base.position))));
			return A2(
				$author$project$Game$updateTeam,
				_Utils_update(
					team,
					{markerPosition: markerPosition}),
				game);
		}
	});
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (_v0.$ === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return A2($elm$core$Dict$member, key, dict);
	});
var $author$project$Pathfinding$availableMoves = F2(
	function (_v0, _v1) {
		var halfWidth = _v0.halfWidth;
		var halfHeight = _v0.halfHeight;
		var staticObstacles = _v0.staticObstacles;
		var x = _v1.a;
		var y = _v1.b;
		var add = F4(
			function (xx, yy, cost, set) {
				return (true && ((_Utils_cmp(xx, -halfWidth) > -1) && ((_Utils_cmp(xx, halfWidth) < 0) && ((_Utils_cmp(yy, -halfHeight) > -1) && ((_Utils_cmp(yy, halfHeight) < 0) && (!A2(
					$elm$core$Set$member,
					_Utils_Tuple2(xx, yy),
					staticObstacles))))))) ? A2(
					$elm$core$Set$insert,
					_Utils_Tuple2(
						_Utils_Tuple2(xx, yy),
						cost),
					set) : set;
			});
		return A4(
			add,
			x + 1,
			y - 1,
			1.5,
			A4(
				add,
				x - 1,
				y - 1,
				1.5,
				A4(
					add,
					x - 1,
					y + 1,
					1.5,
					A4(
						add,
						x + 1,
						y + 1,
						1.5,
						A4(
							add,
							x,
							y + 1,
							1,
							A4(
								add,
								x,
								y - 1,
								1,
								A4(
									add,
									x + 1,
									y,
									1,
									A4(add, x - 1, y, 1, $elm$core$Set$empty))))))));
	});
var $author$project$Pathfinding$cartesianToNodeId = F2(
	function (_v0, _v1) {
		var halfWidth = _v0.halfWidth;
		var halfHeight = _v0.halfHeight;
		var x = _v1.a;
		var y = _v1.b;
		var w = halfWidth * 2;
		return (x + halfWidth) + ((y + halfHeight) * w);
	});
var $elm$core$Dict$fromList = function (assocs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, dict) {
				var key = _v0.a;
				var value = _v0.b;
				return A3($elm$core$Dict$insert, key, value, dict);
			}),
		$elm$core$Dict$empty,
		assocs);
};
var $author$project$Pathfinding$listRemove = F2(
	function (nodeId, openNodes) {
		var rm = F2(
			function (_v0, accumulator) {
				var id = _v0.a;
				var distance = _v0.b;
				return _Utils_eq(id, nodeId) ? accumulator : A2(
					$elm$core$List$cons,
					_Utils_Tuple2(id, distance),
					accumulator);
			});
		return A3($elm$core$List$foldl, rm, _List_Nil, openNodes);
	});
var $elm_community$list_extra$List$Extra$minimumBy = F2(
	function (f, ls) {
		var minBy = F2(
			function (x, _v1) {
				var y = _v1.a;
				var fy = _v1.b;
				var fx = f(x);
				return (_Utils_cmp(fx, fy) < 0) ? _Utils_Tuple2(x, fx) : _Utils_Tuple2(y, fy);
			});
		if (ls.b) {
			if (!ls.b.b) {
				var l_ = ls.a;
				return $elm$core$Maybe$Just(l_);
			} else {
				var l_ = ls.a;
				var ls_ = ls.b;
				return $elm$core$Maybe$Just(
					A3(
						$elm$core$List$foldl,
						minBy,
						_Utils_Tuple2(
							l_,
							f(l_)),
						ls_).a);
			}
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $author$project$Pathfinding$dijkstra = F2(
	function (getAdjacent, startIds) {
		var initialOpenNodes = A2(
			$elm$core$List$map,
			function (id) {
				return _Utils_Tuple2(id, 0);
			},
			startIds);
		var initialDistances = $elm$core$Dict$fromList(initialOpenNodes);
		var addNode = F3(
			function (bestDistance, _v4, _v5) {
				var nodeId = _v4.a;
				var cost = _v4.b;
				var openNodes = _v5.a;
				var distancesById = _v5.b;
				var distance = cost + bestDistance;
				var _v3 = A2($elm$core$Dict$get, nodeId, distancesById);
				if (_v3.$ === 'Nothing') {
					return _Utils_Tuple2(
						A2(
							$elm$core$List$cons,
							_Utils_Tuple2(nodeId, distance),
							openNodes),
						A3($elm$core$Dict$insert, nodeId, distance, distancesById));
				} else {
					var oldDistance = _v3.a;
					return (_Utils_cmp(distance, oldDistance) < 0) ? _Utils_Tuple2(
						openNodes,
						A3($elm$core$Dict$insert, nodeId, distance, distancesById)) : _Utils_Tuple2(openNodes, distancesById);
				}
			});
		var iteration = F2(
			function (openNodes, distancesById) {
				iteration:
				while (true) {
					var _v0 = A2($elm_community$list_extra$List$Extra$minimumBy, $elm$core$Tuple$second, openNodes);
					if (_v0.$ === 'Nothing') {
						return distancesById;
					} else {
						var _v1 = _v0.a;
						var bestNode = _v1.a;
						var bestDistance = _v1.b;
						var _v2 = A3(
							$elm$core$Set$foldl,
							addNode(bestDistance),
							_Utils_Tuple2(openNodes, distancesById),
							getAdjacent(bestNode));
						var newOpenNode = _v2.a;
						var newDistances = _v2.b;
						var $temp$openNodes = A2($author$project$Pathfinding$listRemove, bestNode, newOpenNode),
							$temp$distancesById = newDistances;
						openNodes = $temp$openNodes;
						distancesById = $temp$distancesById;
						continue iteration;
					}
				}
			});
		return A2(iteration, initialOpenNodes, initialDistances);
	});
var $elm$core$Set$map = F2(
	function (func, set) {
		return $elm$core$Set$fromList(
			A3(
				$elm$core$Set$foldl,
				F2(
					function (x, xs) {
						return A2(
							$elm$core$List$cons,
							func(x),
							xs);
					}),
				_List_Nil,
				set));
	});
var $elm$core$Tuple$mapFirst = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			func(x),
			y);
	});
var $author$project$Pathfinding$maybeFind = F3(
	function (transform, condition, list) {
		maybeFind:
		while (true) {
			if (!list.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var a = list.a;
				var xs = list.b;
				var b = transform(a);
				if (condition(b)) {
					return $elm$core$Maybe$Just(b);
				} else {
					var $temp$transform = transform,
						$temp$condition = condition,
						$temp$list = xs;
					transform = $temp$transform;
					condition = $temp$condition;
					list = $temp$list;
					continue maybeFind;
				}
			}
		}
	});
var $author$project$Pathfinding$maybeBaseAt = F2(
	function (game, target) {
		return A3(
			$author$project$Pathfinding$maybeFind,
			function (b) {
				return A2($author$project$Base$tiles, b.type_, b.tile);
			},
			$elm$core$List$member(target),
			$elm$core$Dict$values(game.baseById));
	});
var $elm$core$Basics$modBy = _Basics_modBy;
var $author$project$Pathfinding$nodeIdToCartesian = F2(
	function (_v0, id) {
		var halfWidth = _v0.halfWidth;
		var halfHeight = _v0.halfHeight;
		var w = halfWidth * 2;
		return _Utils_Tuple2(
			A2($elm$core$Basics$modBy, w, id) - halfWidth,
			((id / w) | 0) - halfHeight);
	});
var $author$project$Pathfinding$makePaths = F2(
	function (game, target) {
		var xyToId = $author$project$Pathfinding$cartesianToNodeId(game);
		var targetTiles = function () {
			var _v0 = A2($author$project$Pathfinding$maybeBaseAt, game, target);
			if (_v0.$ === 'Nothing') {
				return _List_fromArray(
					[target]);
			} else {
				var tiles = _v0.a;
				return tiles;
			}
		}();
		var idToXy = $author$project$Pathfinding$nodeIdToCartesian(game);
		var keyNodeIdToKeyCartesian = F3(
			function (nodeId, distance, d) {
				return A3(
					$elm$core$Dict$insert,
					idToXy(nodeId),
					distance,
					d);
			});
		var availableMovesNode = function (nodeId) {
			return A2(
				$elm$core$Set$map,
				$elm$core$Tuple$mapFirst(xyToId),
				A2(
					$author$project$Pathfinding$availableMoves,
					game,
					idToXy(nodeId)));
		};
		return A3(
			$elm$core$Dict$foldl,
			keyNodeIdToKeyCartesian,
			$elm$core$Dict$empty,
			A2(
				$author$project$Pathfinding$dijkstra,
				availableMovesNode,
				A2($elm$core$List$map, xyToId, targetTiles)));
	});
var $author$project$Game$vec2Tile = function (v) {
	var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v);
	var x = _v0.x;
	var y = _v0.y;
	return _Utils_Tuple2(
		$elm$core$Basics$floor(x),
		$elm$core$Basics$floor(y));
};
var $author$project$Init$initPathing = function (game) {
	var addPathing = function (team) {
		return _Utils_update(
			team,
			{
				pathing: A2(
					$author$project$Pathfinding$makePaths,
					game,
					$author$project$Game$vec2Tile(team.markerPosition))
			});
	};
	return A2(
		$author$project$Game$updateTeam,
		addPathing(game.rightTeam),
		A2(
			$author$project$Game$updateTeam,
			addPathing(game.leftTeam),
			game));
};
var $author$project$Init$asVersus = F5(
	function (randomSeed, time, leftTeam, rightTeam, map) {
		var team = F2(
			function (id, teamSeed) {
				return A3($author$project$Game$newTeam, id, teamSeed.colorPattern, teamSeed.mechClassByInputKey);
			});
		return $author$project$Init$addMechForEveryPlayer(
			$author$project$Init$initPathing(
				A2(
					$author$project$Init$initMarkerPosition,
					$author$project$Game$TeamRight,
					A2(
						$author$project$Init$initMarkerPosition,
						$author$project$Game$TeamLeft,
						A3(
							$author$project$Init$addMainBase,
							$elm$core$Maybe$Just($author$project$Game$TeamRight),
							map.rightBase,
							A3(
								$author$project$Init$addMainBase,
								$elm$core$Maybe$Just($author$project$Game$TeamLeft),
								map.leftBase,
								function (g) {
									return A3($elm$core$Set$foldl, $author$project$Init$addSmallBase, g, map.smallBases);
								}(
									_Utils_update(
										$author$project$Game$defaultGame,
										{
											halfHeight: map.halfHeight,
											halfWidth: map.halfWidth,
											leftTeam: A2(team, $author$project$Game$TeamLeft, leftTeam),
											maybeTransition: $elm$core$Maybe$Just(
												{fade: $author$project$Game$GameFadeIn, start: time}),
											mode: $author$project$Game$GameModeVersus,
											rightTeam: A2(team, $author$project$Game$TeamRight, rightTeam),
											seed: randomSeed,
											staticObstacles: map.wallTiles,
											time: time,
											wallTiles: map.wallTiles
										}))))))));
	});
var $author$project$Game$Blimp = {$: 'Blimp'};
var $author$project$Game$Heli = {$: 'Heli'};
var $author$project$Game$Plane = {$: 'Plane'};
var $author$project$Mech$intToClass = function (n) {
	switch (n) {
		case 0:
			return $author$project$Game$Plane;
		case 1:
			return $author$project$Game$Heli;
		default:
			return $author$project$Game$Blimp;
	}
};
var $author$project$Mech$classGenerator = A2(
	$elm$random$Random$map,
	$author$project$Mech$intToClass,
	A2($elm$random$Random$int, 0, 2));
var $author$project$MainScene$inputBot = F2(
	function (teamId, n) {
		var t = function () {
			if (teamId.$ === 'TeamLeft') {
				return 'L';
			} else {
				return 'R';
			}
		}();
		return 'bot ' + (t + $elm$core$String$fromInt(n));
	});
var $elm$random$Random$listHelp = F4(
	function (revList, n, gen, seed) {
		listHelp:
		while (true) {
			if (n < 1) {
				return _Utils_Tuple2(revList, seed);
			} else {
				var _v0 = gen(seed);
				var value = _v0.a;
				var newSeed = _v0.b;
				var $temp$revList = A2($elm$core$List$cons, value, revList),
					$temp$n = n - 1,
					$temp$gen = gen,
					$temp$seed = newSeed;
				revList = $temp$revList;
				n = $temp$n;
				gen = $temp$gen;
				seed = $temp$seed;
				continue listHelp;
			}
		}
	});
var $elm$random$Random$list = F2(
	function (n, _v0) {
		var gen = _v0.a;
		return $elm$random$Random$Generator(
			function (seed) {
				return A4($elm$random$Random$listHelp, _List_Nil, n, gen, seed);
			});
	});
var $elm$random$Random$map2 = F3(
	function (func, _v0, _v1) {
		var genA = _v0.a;
		var genB = _v1.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v2 = genA(seed0);
				var a = _v2.a;
				var seed1 = _v2.b;
				var _v3 = genB(seed1);
				var b = _v3.a;
				var seed2 = _v3.b;
				return _Utils_Tuple2(
					A2(func, a, b),
					seed2);
			});
	});
var $elm$random$Random$pair = F2(
	function (genA, genB) {
		return A3(
			$elm$random$Random$map2,
			F2(
				function (a, b) {
					return _Utils_Tuple2(a, b);
				}),
			genA,
			genB);
	});
var $elm$random$Random$step = F2(
	function (_v0, seed) {
		var generator = _v0.a;
		return generator(seed);
	});
var $author$project$ColorPattern$patterns = function () {
	var n = $elm_explorations$linear_algebra$Math$Vector3$vec3;
	var b = F3(
		function (r, g, bb) {
			return A3($elm_explorations$linear_algebra$Math$Vector3$vec3, r / 255, g / 255, bb / 255);
		});
	return _List_fromArray(
		[
			A3(
			$author$project$ColorPattern$pattern,
			A3(n, 1, 0, 0),
			A3(n, 0.5, 0, 0),
			'red'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(b, 255, 165, 0),
			A3(n, 0, 0, 1),
			'sol'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(n, 0, 1, 0),
			A3(n, 0, 0.5, 0),
			'green'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(n, 0, 0, 1),
			A3(n, 0, 0, 0.5),
			'blue'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(b, 0, 238, 238),
			A3(n, 0, 0.5, 0.5),
			'cyan'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(n, 1, 0, 1),
			A3(n, 0.5, 0, 0.5),
			'purple'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(b, 238, 238, 0),
			A3(n, 0.5, 0.5, 0),
			'yellow'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(b, 0, 238, 238),
			A3(n, 0.5, 0, 0.5),
			'octarine'),
			A3(
			$author$project$ColorPattern$pattern,
			A3(b, 50, 50, 50),
			A3(b, 224, 156, 31),
			'brass')
		]);
}();
var $author$project$Random$List$shuffle = function (list) {
	if ($elm$core$List$isEmpty(list)) {
		return $elm$random$Random$constant(list);
	} else {
		var helper = function (_v0) {
			var done = _v0.a;
			var remaining = _v0.b;
			return A2(
				$elm$random$Random$andThen,
				function (_v1) {
					var m_val = _v1.a;
					var shorter = _v1.b;
					if (m_val.$ === 'Nothing') {
						return $elm$random$Random$constant(
							_Utils_Tuple2(done, shorter));
					} else {
						var val = m_val.a;
						return helper(
							_Utils_Tuple2(
								A2($elm$core$List$cons, val, done),
								shorter));
					}
				},
				$author$project$Random$List$choose(remaining));
		};
		return A2(
			$elm$random$Random$map,
			$elm$core$Tuple$first,
			helper(
				_Utils_Tuple2(_List_Nil, list)));
	}
};
var $author$project$ColorPattern$twoDifferent = function () {
	var takeTwo = function (list) {
		if (list.b && list.b.b) {
			var a = list.a;
			var _v1 = list.b;
			var b = _v1.a;
			return _Utils_Tuple2(a, b);
		} else {
			return _Utils_Tuple2($author$project$ColorPattern$neutral, $author$project$ColorPattern$neutral);
		}
	};
	return A2(
		$elm$random$Random$map,
		takeTwo,
		$author$project$Random$List$shuffle($author$project$ColorPattern$patterns));
}();
var $author$project$MainScene$makeAiGame = F2(
	function (seed, map) {
		var makeTeam = F3(
			function (id, colorPattern, classes) {
				return {
					colorPattern: colorPattern,
					mechClassByInputKey: $elm$core$Dict$fromList(
						A2(
							$elm$core$List$indexedMap,
							F2(
								function (index, _class) {
									return _Utils_Tuple2(
										A2($author$project$MainScene$inputBot, id, index),
										_class);
								}),
							classes))
				};
			});
		var tuplesToTeam = F2(
			function (_v2, _v3) {
				var color1 = _v2.a;
				var color2 = _v2.b;
				var classes1 = _v3.a;
				var classes2 = _v3.b;
				return _Utils_Tuple2(
					A3(makeTeam, $author$project$Game$TeamLeft, color1, classes1),
					A3(makeTeam, $author$project$Game$TeamRight, color2, classes2));
			});
		var generateMechClasses = function (playersPerTeam) {
			return A2(
				$elm$random$Random$pair,
				A2($elm$random$Random$list, playersPerTeam, $author$project$Mech$classGenerator),
				A2($elm$random$Random$list, playersPerTeam, $author$project$Mech$classGenerator));
		};
		var generateTeams = A3(
			$elm$random$Random$map2,
			tuplesToTeam,
			$author$project$ColorPattern$twoDifferent,
			A2(
				$elm$random$Random$andThen,
				generateMechClasses,
				A2($elm$random$Random$int, 1, 4)));
		var _v0 = A2($elm$random$Random$step, generateTeams, seed);
		var _v1 = _v0.a;
		var leftTeam = _v1.a;
		var rightTeam = _v1.b;
		var newSeed = _v0.b;
		return A5($author$project$Init$asVersus, newSeed, 0, leftTeam, rightTeam, map);
	});
var $author$project$MainScene$initDemo = F2(
	function (seed, map) {
		var game = A2($author$project$MainScene$makeAiGame, seed, map);
		return $author$project$MainScene$initBots(
			{
				botStatesByKey: $elm$core$Dict$empty,
				fps: _List_fromArray(
					[1]),
				game: game,
				previousInputStatesByKey: $elm$core$Dict$empty
			});
	});
var $author$project$OfficialMaps$maps = _List_fromArray(
	[
		{
		author: 'xa',
		halfHeight: 10,
		halfWidth: 20,
		leftBase: _Utils_Tuple2(-17, 7),
		name: 'Loveledge',
		rightBase: _Utils_Tuple2(17, -7),
		smallBases: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(5, 3),
					_Utils_Tuple2(-5, -3)
				])),
		wallTiles: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-16, -8),
					_Utils_Tuple2(-16, -7),
					_Utils_Tuple2(-16, -6),
					_Utils_Tuple2(-16, -5),
					_Utils_Tuple2(-16, -4),
					_Utils_Tuple2(-15, -8),
					_Utils_Tuple2(-15, -7),
					_Utils_Tuple2(-14, 3),
					_Utils_Tuple2(-14, 4),
					_Utils_Tuple2(-12, 0),
					_Utils_Tuple2(-11, 1),
					_Utils_Tuple2(-11, 2),
					_Utils_Tuple2(-11, 3),
					_Utils_Tuple2(-10, -2),
					_Utils_Tuple2(-10, -1),
					_Utils_Tuple2(-10, 3),
					_Utils_Tuple2(-10, 4),
					_Utils_Tuple2(-10, 5),
					_Utils_Tuple2(-10, 6),
					_Utils_Tuple2(-10, 7),
					_Utils_Tuple2(-6, 2),
					_Utils_Tuple2(-5, -7),
					_Utils_Tuple2(-5, -6),
					_Utils_Tuple2(-2, 0),
					_Utils_Tuple2(-1, 5),
					_Utils_Tuple2(0, -6),
					_Utils_Tuple2(1, -1),
					_Utils_Tuple2(4, 5),
					_Utils_Tuple2(4, 6),
					_Utils_Tuple2(5, -3),
					_Utils_Tuple2(9, -8),
					_Utils_Tuple2(9, -7),
					_Utils_Tuple2(9, -6),
					_Utils_Tuple2(9, -5),
					_Utils_Tuple2(9, -4),
					_Utils_Tuple2(9, 0),
					_Utils_Tuple2(9, 1),
					_Utils_Tuple2(10, -4),
					_Utils_Tuple2(10, -3),
					_Utils_Tuple2(10, -2),
					_Utils_Tuple2(11, -1),
					_Utils_Tuple2(13, -5),
					_Utils_Tuple2(13, -4),
					_Utils_Tuple2(14, 6),
					_Utils_Tuple2(14, 7),
					_Utils_Tuple2(15, 3),
					_Utils_Tuple2(15, 4),
					_Utils_Tuple2(15, 5),
					_Utils_Tuple2(15, 6),
					_Utils_Tuple2(15, 7)
				]))
	},
		{
		author: 'dd',
		halfHeight: 10,
		halfWidth: 20,
		leftBase: _Utils_Tuple2(-15, 1),
		name: 'Eight Shells',
		rightBase: _Utils_Tuple2(15, -1),
		smallBases: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-8, -7),
					_Utils_Tuple2(-7, 7),
					_Utils_Tuple2(-1, -8),
					_Utils_Tuple2(1, 8),
					_Utils_Tuple2(7, -7),
					_Utils_Tuple2(8, 7)
				])),
		wallTiles: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-20, -10),
					_Utils_Tuple2(-20, -6),
					_Utils_Tuple2(-20, -4),
					_Utils_Tuple2(-20, -3),
					_Utils_Tuple2(-20, -2),
					_Utils_Tuple2(-20, -1),
					_Utils_Tuple2(-20, 0),
					_Utils_Tuple2(-20, 1),
					_Utils_Tuple2(-20, 2),
					_Utils_Tuple2(-20, 3),
					_Utils_Tuple2(-20, 4),
					_Utils_Tuple2(-20, 7),
					_Utils_Tuple2(-20, 9),
					_Utils_Tuple2(-19, -8),
					_Utils_Tuple2(-19, -4),
					_Utils_Tuple2(-19, -3),
					_Utils_Tuple2(-19, 4),
					_Utils_Tuple2(-19, 6),
					_Utils_Tuple2(-18, -10),
					_Utils_Tuple2(-18, -7),
					_Utils_Tuple2(-18, -5),
					_Utils_Tuple2(-18, -4),
					_Utils_Tuple2(-18, -3),
					_Utils_Tuple2(-18, 4),
					_Utils_Tuple2(-18, 5),
					_Utils_Tuple2(-18, 7),
					_Utils_Tuple2(-18, 9),
					_Utils_Tuple2(-17, -10),
					_Utils_Tuple2(-17, -8),
					_Utils_Tuple2(-17, -5),
					_Utils_Tuple2(-17, -4),
					_Utils_Tuple2(-17, -3),
					_Utils_Tuple2(-17, 4),
					_Utils_Tuple2(-17, 5),
					_Utils_Tuple2(-16, 5),
					_Utils_Tuple2(-15, -10),
					_Utils_Tuple2(-14, -10),
					_Utils_Tuple2(-14, -9),
					_Utils_Tuple2(-14, -5),
					_Utils_Tuple2(-14, -4),
					_Utils_Tuple2(-13, -10),
					_Utils_Tuple2(-13, -9),
					_Utils_Tuple2(-13, -5),
					_Utils_Tuple2(-13, -4),
					_Utils_Tuple2(-13, 5),
					_Utils_Tuple2(-13, 8),
					_Utils_Tuple2(-13, 9),
					_Utils_Tuple2(-12, -10),
					_Utils_Tuple2(-12, -9),
					_Utils_Tuple2(-12, -5),
					_Utils_Tuple2(-12, -4),
					_Utils_Tuple2(-12, -3),
					_Utils_Tuple2(-12, 4),
					_Utils_Tuple2(-12, 5),
					_Utils_Tuple2(-12, 8),
					_Utils_Tuple2(-12, 9),
					_Utils_Tuple2(-11, -4),
					_Utils_Tuple2(-11, -3),
					_Utils_Tuple2(-11, -2),
					_Utils_Tuple2(-11, 2),
					_Utils_Tuple2(-11, 3),
					_Utils_Tuple2(-11, 4),
					_Utils_Tuple2(-11, 5),
					_Utils_Tuple2(-11, 8),
					_Utils_Tuple2(-11, 9),
					_Utils_Tuple2(-10, -3),
					_Utils_Tuple2(-10, -2),
					_Utils_Tuple2(-10, 2),
					_Utils_Tuple2(-10, 3),
					_Utils_Tuple2(-9, -3),
					_Utils_Tuple2(-9, -2),
					_Utils_Tuple2(-8, 2),
					_Utils_Tuple2(-8, 3),
					_Utils_Tuple2(-7, 2),
					_Utils_Tuple2(-7, 3),
					_Utils_Tuple2(-6, -3),
					_Utils_Tuple2(-6, -2),
					_Utils_Tuple2(-5, -10),
					_Utils_Tuple2(-5, -9),
					_Utils_Tuple2(-5, -8),
					_Utils_Tuple2(-5, -7),
					_Utils_Tuple2(-5, -6),
					_Utils_Tuple2(-5, -3),
					_Utils_Tuple2(-5, -2),
					_Utils_Tuple2(-5, 2),
					_Utils_Tuple2(-5, 3),
					_Utils_Tuple2(-4, -10),
					_Utils_Tuple2(-4, -9),
					_Utils_Tuple2(-4, -8),
					_Utils_Tuple2(-4, -7),
					_Utils_Tuple2(-4, -6),
					_Utils_Tuple2(-4, -3),
					_Utils_Tuple2(-4, -2),
					_Utils_Tuple2(-4, 2),
					_Utils_Tuple2(-4, 3),
					_Utils_Tuple2(-4, 4),
					_Utils_Tuple2(-4, 5),
					_Utils_Tuple2(-4, 6),
					_Utils_Tuple2(-4, 7),
					_Utils_Tuple2(-4, 8),
					_Utils_Tuple2(-4, 9),
					_Utils_Tuple2(-3, 2),
					_Utils_Tuple2(-3, 3),
					_Utils_Tuple2(-3, 4),
					_Utils_Tuple2(-3, 5),
					_Utils_Tuple2(-3, 6),
					_Utils_Tuple2(-3, 7),
					_Utils_Tuple2(-3, 8),
					_Utils_Tuple2(-3, 9),
					_Utils_Tuple2(2, -10),
					_Utils_Tuple2(2, -9),
					_Utils_Tuple2(2, -8),
					_Utils_Tuple2(2, -7),
					_Utils_Tuple2(2, -6),
					_Utils_Tuple2(2, -5),
					_Utils_Tuple2(2, -4),
					_Utils_Tuple2(2, -3),
					_Utils_Tuple2(3, -10),
					_Utils_Tuple2(3, -9),
					_Utils_Tuple2(3, -8),
					_Utils_Tuple2(3, -7),
					_Utils_Tuple2(3, -6),
					_Utils_Tuple2(3, -5),
					_Utils_Tuple2(3, -4),
					_Utils_Tuple2(3, -3),
					_Utils_Tuple2(3, 1),
					_Utils_Tuple2(3, 2),
					_Utils_Tuple2(3, 5),
					_Utils_Tuple2(3, 6),
					_Utils_Tuple2(3, 7),
					_Utils_Tuple2(3, 8),
					_Utils_Tuple2(3, 9),
					_Utils_Tuple2(4, -4),
					_Utils_Tuple2(4, -3),
					_Utils_Tuple2(4, 1),
					_Utils_Tuple2(4, 2),
					_Utils_Tuple2(4, 5),
					_Utils_Tuple2(4, 6),
					_Utils_Tuple2(4, 7),
					_Utils_Tuple2(4, 8),
					_Utils_Tuple2(4, 9),
					_Utils_Tuple2(5, 1),
					_Utils_Tuple2(5, 2),
					_Utils_Tuple2(6, -4),
					_Utils_Tuple2(6, -3),
					_Utils_Tuple2(7, -4),
					_Utils_Tuple2(7, -3),
					_Utils_Tuple2(8, 1),
					_Utils_Tuple2(8, 2),
					_Utils_Tuple2(9, -4),
					_Utils_Tuple2(9, -3),
					_Utils_Tuple2(9, 1),
					_Utils_Tuple2(9, 2),
					_Utils_Tuple2(10, -10),
					_Utils_Tuple2(10, -9),
					_Utils_Tuple2(10, -6),
					_Utils_Tuple2(10, -5),
					_Utils_Tuple2(10, -4),
					_Utils_Tuple2(10, -3),
					_Utils_Tuple2(10, 1),
					_Utils_Tuple2(10, 2),
					_Utils_Tuple2(10, 3),
					_Utils_Tuple2(11, -10),
					_Utils_Tuple2(11, -9),
					_Utils_Tuple2(11, -6),
					_Utils_Tuple2(11, -5),
					_Utils_Tuple2(11, 2),
					_Utils_Tuple2(11, 3),
					_Utils_Tuple2(11, 4),
					_Utils_Tuple2(11, 8),
					_Utils_Tuple2(11, 9),
					_Utils_Tuple2(12, -10),
					_Utils_Tuple2(12, -9),
					_Utils_Tuple2(12, -6),
					_Utils_Tuple2(12, 3),
					_Utils_Tuple2(12, 4),
					_Utils_Tuple2(12, 8),
					_Utils_Tuple2(12, 9),
					_Utils_Tuple2(13, 3),
					_Utils_Tuple2(13, 4),
					_Utils_Tuple2(13, 8),
					_Utils_Tuple2(13, 9),
					_Utils_Tuple2(14, 9),
					_Utils_Tuple2(15, -6),
					_Utils_Tuple2(16, -6),
					_Utils_Tuple2(16, -5),
					_Utils_Tuple2(16, 2),
					_Utils_Tuple2(16, 3),
					_Utils_Tuple2(16, 4),
					_Utils_Tuple2(16, 7),
					_Utils_Tuple2(16, 9),
					_Utils_Tuple2(17, -10),
					_Utils_Tuple2(17, -8),
					_Utils_Tuple2(17, -6),
					_Utils_Tuple2(17, -5),
					_Utils_Tuple2(17, 2),
					_Utils_Tuple2(17, 3),
					_Utils_Tuple2(17, 4),
					_Utils_Tuple2(17, 6),
					_Utils_Tuple2(17, 9),
					_Utils_Tuple2(18, -7),
					_Utils_Tuple2(18, -5),
					_Utils_Tuple2(18, 2),
					_Utils_Tuple2(18, 3),
					_Utils_Tuple2(18, 7),
					_Utils_Tuple2(19, -10),
					_Utils_Tuple2(19, -8),
					_Utils_Tuple2(19, -5),
					_Utils_Tuple2(19, -4),
					_Utils_Tuple2(19, -3),
					_Utils_Tuple2(19, -2),
					_Utils_Tuple2(19, -1),
					_Utils_Tuple2(19, 0),
					_Utils_Tuple2(19, 1),
					_Utils_Tuple2(19, 2),
					_Utils_Tuple2(19, 3),
					_Utils_Tuple2(19, 5),
					_Utils_Tuple2(19, 9)
				]))
	},
		{
		author: 'JT',
		halfHeight: 10,
		halfWidth: 20,
		leftBase: _Utils_Tuple2(-15, -7),
		name: 'Doubt Thyself',
		rightBase: _Utils_Tuple2(15, 7),
		smallBases: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-16, -2),
					_Utils_Tuple2(-16, 6),
					_Utils_Tuple2(-8, -3),
					_Utils_Tuple2(-8, 3),
					_Utils_Tuple2(-5, -8),
					_Utils_Tuple2(5, 8),
					_Utils_Tuple2(8, -3),
					_Utils_Tuple2(8, 3),
					_Utils_Tuple2(16, -6),
					_Utils_Tuple2(16, 2)
				])),
		wallTiles: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-20, -10),
					_Utils_Tuple2(-20, -8),
					_Utils_Tuple2(-20, -5),
					_Utils_Tuple2(-19, -10),
					_Utils_Tuple2(-19, -9),
					_Utils_Tuple2(-19, -7),
					_Utils_Tuple2(-13, -5),
					_Utils_Tuple2(-11, -5),
					_Utils_Tuple2(-7, 7),
					_Utils_Tuple2(-7, 8),
					_Utils_Tuple2(-6, 7),
					_Utils_Tuple2(-6, 9),
					_Utils_Tuple2(-5, -2),
					_Utils_Tuple2(-3, -4),
					_Utils_Tuple2(-3, -2),
					_Utils_Tuple2(-3, -1),
					_Utils_Tuple2(-3, 0),
					_Utils_Tuple2(-2, 0),
					_Utils_Tuple2(-2, 1),
					_Utils_Tuple2(-1, -5),
					_Utils_Tuple2(-1, -2),
					_Utils_Tuple2(-1, 0),
					_Utils_Tuple2(-1, 2),
					_Utils_Tuple2(0, -3),
					_Utils_Tuple2(0, -1),
					_Utils_Tuple2(0, 1),
					_Utils_Tuple2(0, 4),
					_Utils_Tuple2(1, -2),
					_Utils_Tuple2(1, -1),
					_Utils_Tuple2(2, -4),
					_Utils_Tuple2(2, -1),
					_Utils_Tuple2(2, 1),
					_Utils_Tuple2(4, 1),
					_Utils_Tuple2(5, -10),
					_Utils_Tuple2(5, -8),
					_Utils_Tuple2(6, -9),
					_Utils_Tuple2(6, -8),
					_Utils_Tuple2(10, 4),
					_Utils_Tuple2(12, 4),
					_Utils_Tuple2(18, 6),
					_Utils_Tuple2(18, 8),
					_Utils_Tuple2(18, 9),
					_Utils_Tuple2(19, 4),
					_Utils_Tuple2(19, 7),
					_Utils_Tuple2(19, 9)
				]))
	},
		{
		author: 'NA',
		halfHeight: 15,
		halfWidth: 24,
		leftBase: _Utils_Tuple2(-21, 9),
		name: 'Dikjistra\'s Spiral',
		rightBase: _Utils_Tuple2(21, -9),
		smallBases: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-19, -11),
					_Utils_Tuple2(-10, -3),
					_Utils_Tuple2(-2, 6),
					_Utils_Tuple2(0, 0),
					_Utils_Tuple2(2, -6),
					_Utils_Tuple2(10, 3),
					_Utils_Tuple2(19, 11)
				])),
		wallTiles: $elm$core$Set$fromList(
			_List_fromArray(
				[
					_Utils_Tuple2(-25, 1),
					_Utils_Tuple2(-24, -14),
					_Utils_Tuple2(-24, -13),
					_Utils_Tuple2(-24, -12),
					_Utils_Tuple2(-24, -11),
					_Utils_Tuple2(-24, -10),
					_Utils_Tuple2(-24, -7),
					_Utils_Tuple2(-24, -6),
					_Utils_Tuple2(-24, -5),
					_Utils_Tuple2(-24, -4),
					_Utils_Tuple2(-24, -3),
					_Utils_Tuple2(-24, -2),
					_Utils_Tuple2(-24, -1),
					_Utils_Tuple2(-24, 0),
					_Utils_Tuple2(-24, 1),
					_Utils_Tuple2(-24, 2),
					_Utils_Tuple2(-24, 3),
					_Utils_Tuple2(-24, 14),
					_Utils_Tuple2(-23, -12),
					_Utils_Tuple2(-23, -11),
					_Utils_Tuple2(-23, -10),
					_Utils_Tuple2(-23, -9),
					_Utils_Tuple2(-23, -6),
					_Utils_Tuple2(-23, -5),
					_Utils_Tuple2(-23, -4),
					_Utils_Tuple2(-23, -3),
					_Utils_Tuple2(-23, -1),
					_Utils_Tuple2(-23, 0),
					_Utils_Tuple2(-23, 1),
					_Utils_Tuple2(-23, 2),
					_Utils_Tuple2(-23, 3),
					_Utils_Tuple2(-23, 13),
					_Utils_Tuple2(-23, 14),
					_Utils_Tuple2(-22, -10),
					_Utils_Tuple2(-22, -9),
					_Utils_Tuple2(-22, -5),
					_Utils_Tuple2(-22, 0),
					_Utils_Tuple2(-22, 1),
					_Utils_Tuple2(-22, 2),
					_Utils_Tuple2(-22, 13),
					_Utils_Tuple2(-22, 14),
					_Utils_Tuple2(-21, -9),
					_Utils_Tuple2(-21, -8),
					_Utils_Tuple2(-21, -2),
					_Utils_Tuple2(-21, -1),
					_Utils_Tuple2(-21, 0),
					_Utils_Tuple2(-21, 1),
					_Utils_Tuple2(-21, 2),
					_Utils_Tuple2(-21, 14),
					_Utils_Tuple2(-20, -9),
					_Utils_Tuple2(-20, -8),
					_Utils_Tuple2(-20, -6),
					_Utils_Tuple2(-20, -3),
					_Utils_Tuple2(-20, -2),
					_Utils_Tuple2(-20, -1),
					_Utils_Tuple2(-20, 0),
					_Utils_Tuple2(-20, 2),
					_Utils_Tuple2(-20, 3),
					_Utils_Tuple2(-20, 13),
					_Utils_Tuple2(-20, 14),
					_Utils_Tuple2(-19, -9),
					_Utils_Tuple2(-19, -8),
					_Utils_Tuple2(-19, -7),
					_Utils_Tuple2(-19, -6),
					_Utils_Tuple2(-19, -3),
					_Utils_Tuple2(-19, -2),
					_Utils_Tuple2(-19, 3),
					_Utils_Tuple2(-19, 13),
					_Utils_Tuple2(-19, 14),
					_Utils_Tuple2(-18, -9),
					_Utils_Tuple2(-18, -8),
					_Utils_Tuple2(-18, 14),
					_Utils_Tuple2(-17, -9),
					_Utils_Tuple2(-17, -8),
					_Utils_Tuple2(-17, -7),
					_Utils_Tuple2(-17, 9),
					_Utils_Tuple2(-17, 10),
					_Utils_Tuple2(-16, -10),
					_Utils_Tuple2(-16, -9),
					_Utils_Tuple2(-16, 8),
					_Utils_Tuple2(-16, 9),
					_Utils_Tuple2(-16, 10),
					_Utils_Tuple2(-15, -11),
					_Utils_Tuple2(-15, -10),
					_Utils_Tuple2(-15, -9),
					_Utils_Tuple2(-14, -10),
					_Utils_Tuple2(-14, 4),
					_Utils_Tuple2(-14, 14),
					_Utils_Tuple2(-13, 3),
					_Utils_Tuple2(-13, 4),
					_Utils_Tuple2(-13, 14),
					_Utils_Tuple2(-12, -15),
					_Utils_Tuple2(-12, 3),
					_Utils_Tuple2(-12, 13),
					_Utils_Tuple2(-12, 14),
					_Utils_Tuple2(-11, -15),
					_Utils_Tuple2(-11, -14),
					_Utils_Tuple2(-11, 12),
					_Utils_Tuple2(-11, 13),
					_Utils_Tuple2(-11, 14),
					_Utils_Tuple2(-10, -15),
					_Utils_Tuple2(-10, -7),
					_Utils_Tuple2(-10, -6),
					_Utils_Tuple2(-10, -5),
					_Utils_Tuple2(-10, 9),
					_Utils_Tuple2(-10, 10),
					_Utils_Tuple2(-10, 11),
					_Utils_Tuple2(-10, 12),
					_Utils_Tuple2(-10, 13),
					_Utils_Tuple2(-10, 14),
					_Utils_Tuple2(-9, -15),
					_Utils_Tuple2(-9, -6),
					_Utils_Tuple2(-9, -5),
					_Utils_Tuple2(-9, -4),
					_Utils_Tuple2(-9, -3),
					_Utils_Tuple2(-9, 10),
					_Utils_Tuple2(-9, 11),
					_Utils_Tuple2(-9, 12),
					_Utils_Tuple2(-9, 13),
					_Utils_Tuple2(-9, 14),
					_Utils_Tuple2(-8, -5),
					_Utils_Tuple2(-8, -4),
					_Utils_Tuple2(-8, -3),
					_Utils_Tuple2(-8, -2),
					_Utils_Tuple2(-8, 11),
					_Utils_Tuple2(-8, 12),
					_Utils_Tuple2(-8, 13),
					_Utils_Tuple2(-8, 14),
					_Utils_Tuple2(-7, -4),
					_Utils_Tuple2(-7, -3),
					_Utils_Tuple2(-7, -2),
					_Utils_Tuple2(-7, -1),
					_Utils_Tuple2(-7, 5),
					_Utils_Tuple2(-7, 12),
					_Utils_Tuple2(-7, 13),
					_Utils_Tuple2(-7, 14),
					_Utils_Tuple2(-6, -13),
					_Utils_Tuple2(-6, -12),
					_Utils_Tuple2(-6, -11),
					_Utils_Tuple2(-6, 4),
					_Utils_Tuple2(-6, 5),
					_Utils_Tuple2(-6, 6),
					_Utils_Tuple2(-6, 13),
					_Utils_Tuple2(-6, 14),
					_Utils_Tuple2(-5, -14),
					_Utils_Tuple2(-5, -13),
					_Utils_Tuple2(-5, -12),
					_Utils_Tuple2(-5, -11),
					_Utils_Tuple2(-5, -10),
					_Utils_Tuple2(-5, 4),
					_Utils_Tuple2(-5, 5),
					_Utils_Tuple2(-5, 13),
					_Utils_Tuple2(-5, 14),
					_Utils_Tuple2(-4, -14),
					_Utils_Tuple2(-4, -13),
					_Utils_Tuple2(-4, -12),
					_Utils_Tuple2(-4, -11),
					_Utils_Tuple2(-4, 2),
					_Utils_Tuple2(-4, 3),
					_Utils_Tuple2(-4, 4),
					_Utils_Tuple2(-4, 5),
					_Utils_Tuple2(-4, 12),
					_Utils_Tuple2(-4, 13),
					_Utils_Tuple2(-4, 14),
					_Utils_Tuple2(-3, -13),
					_Utils_Tuple2(-3, -12),
					_Utils_Tuple2(-3, 2),
					_Utils_Tuple2(-3, 3),
					_Utils_Tuple2(-3, 4),
					_Utils_Tuple2(-3, 11),
					_Utils_Tuple2(-3, 12),
					_Utils_Tuple2(-3, 13),
					_Utils_Tuple2(-3, 14),
					_Utils_Tuple2(-2, -13),
					_Utils_Tuple2(-2, -12),
					_Utils_Tuple2(-2, 3),
					_Utils_Tuple2(-2, 4),
					_Utils_Tuple2(-2, 11),
					_Utils_Tuple2(-2, 12),
					_Utils_Tuple2(-2, 13),
					_Utils_Tuple2(-2, 14),
					_Utils_Tuple2(-1, -15),
					_Utils_Tuple2(-1, -12),
					_Utils_Tuple2(-1, -6),
					_Utils_Tuple2(-1, -5),
					_Utils_Tuple2(-1, -4),
					_Utils_Tuple2(-1, 4),
					_Utils_Tuple2(-1, 5),
					_Utils_Tuple2(-1, 11),
					_Utils_Tuple2(-1, 12),
					_Utils_Tuple2(-1, 13),
					_Utils_Tuple2(-1, 14),
					_Utils_Tuple2(0, -15),
					_Utils_Tuple2(0, -14),
					_Utils_Tuple2(0, -13),
					_Utils_Tuple2(0, -12),
					_Utils_Tuple2(0, -6),
					_Utils_Tuple2(0, -5),
					_Utils_Tuple2(0, 3),
					_Utils_Tuple2(0, 4),
					_Utils_Tuple2(0, 5),
					_Utils_Tuple2(0, 11),
					_Utils_Tuple2(0, 14),
					_Utils_Tuple2(1, -15),
					_Utils_Tuple2(1, -14),
					_Utils_Tuple2(1, -13),
					_Utils_Tuple2(1, -12),
					_Utils_Tuple2(1, -5),
					_Utils_Tuple2(1, -4),
					_Utils_Tuple2(1, 11),
					_Utils_Tuple2(1, 12),
					_Utils_Tuple2(2, -15),
					_Utils_Tuple2(2, -14),
					_Utils_Tuple2(2, -13),
					_Utils_Tuple2(2, -12),
					_Utils_Tuple2(2, -5),
					_Utils_Tuple2(2, -4),
					_Utils_Tuple2(2, -3),
					_Utils_Tuple2(2, 11),
					_Utils_Tuple2(2, 12),
					_Utils_Tuple2(3, -15),
					_Utils_Tuple2(3, -14),
					_Utils_Tuple2(3, -13),
					_Utils_Tuple2(3, -6),
					_Utils_Tuple2(3, -5),
					_Utils_Tuple2(3, -4),
					_Utils_Tuple2(3, -3),
					_Utils_Tuple2(3, 10),
					_Utils_Tuple2(3, 11),
					_Utils_Tuple2(3, 12),
					_Utils_Tuple2(3, 13),
					_Utils_Tuple2(4, -15),
					_Utils_Tuple2(4, -14),
					_Utils_Tuple2(4, -6),
					_Utils_Tuple2(4, -5),
					_Utils_Tuple2(4, 9),
					_Utils_Tuple2(4, 10),
					_Utils_Tuple2(4, 11),
					_Utils_Tuple2(4, 12),
					_Utils_Tuple2(4, 13),
					_Utils_Tuple2(5, -15),
					_Utils_Tuple2(5, -14),
					_Utils_Tuple2(5, -7),
					_Utils_Tuple2(5, -6),
					_Utils_Tuple2(5, -5),
					_Utils_Tuple2(5, 10),
					_Utils_Tuple2(5, 11),
					_Utils_Tuple2(5, 12),
					_Utils_Tuple2(6, -15),
					_Utils_Tuple2(6, -14),
					_Utils_Tuple2(6, -13),
					_Utils_Tuple2(6, -6),
					_Utils_Tuple2(6, 0),
					_Utils_Tuple2(6, 1),
					_Utils_Tuple2(6, 2),
					_Utils_Tuple2(6, 3),
					_Utils_Tuple2(7, -15),
					_Utils_Tuple2(7, -14),
					_Utils_Tuple2(7, -13),
					_Utils_Tuple2(7, -12),
					_Utils_Tuple2(7, 1),
					_Utils_Tuple2(7, 2),
					_Utils_Tuple2(7, 3),
					_Utils_Tuple2(7, 4),
					_Utils_Tuple2(8, -15),
					_Utils_Tuple2(8, -14),
					_Utils_Tuple2(8, -13),
					_Utils_Tuple2(8, -12),
					_Utils_Tuple2(8, -11),
					_Utils_Tuple2(8, 2),
					_Utils_Tuple2(8, 3),
					_Utils_Tuple2(8, 4),
					_Utils_Tuple2(8, 5),
					_Utils_Tuple2(8, 14),
					_Utils_Tuple2(9, -15),
					_Utils_Tuple2(9, -14),
					_Utils_Tuple2(9, -13),
					_Utils_Tuple2(9, -12),
					_Utils_Tuple2(9, -11),
					_Utils_Tuple2(9, -10),
					_Utils_Tuple2(9, 4),
					_Utils_Tuple2(9, 5),
					_Utils_Tuple2(9, 6),
					_Utils_Tuple2(9, 14),
					_Utils_Tuple2(10, -15),
					_Utils_Tuple2(10, -14),
					_Utils_Tuple2(10, -13),
					_Utils_Tuple2(10, 13),
					_Utils_Tuple2(10, 14),
					_Utils_Tuple2(11, -15),
					_Utils_Tuple2(11, -14),
					_Utils_Tuple2(11, -4),
					_Utils_Tuple2(11, 14),
					_Utils_Tuple2(12, -15),
					_Utils_Tuple2(12, -5),
					_Utils_Tuple2(12, -4),
					_Utils_Tuple2(13, -15),
					_Utils_Tuple2(13, -5),
					_Utils_Tuple2(13, 9),
					_Utils_Tuple2(14, 8),
					_Utils_Tuple2(14, 9),
					_Utils_Tuple2(14, 10),
					_Utils_Tuple2(15, -11),
					_Utils_Tuple2(15, -10),
					_Utils_Tuple2(15, -9),
					_Utils_Tuple2(15, 8),
					_Utils_Tuple2(15, 9),
					_Utils_Tuple2(16, -11),
					_Utils_Tuple2(16, -10),
					_Utils_Tuple2(16, 6),
					_Utils_Tuple2(16, 7),
					_Utils_Tuple2(16, 8),
					_Utils_Tuple2(17, -15),
					_Utils_Tuple2(17, 7),
					_Utils_Tuple2(17, 8),
					_Utils_Tuple2(18, -15),
					_Utils_Tuple2(18, -14),
					_Utils_Tuple2(18, -4),
					_Utils_Tuple2(18, 1),
					_Utils_Tuple2(18, 2),
					_Utils_Tuple2(18, 5),
					_Utils_Tuple2(18, 6),
					_Utils_Tuple2(18, 7),
					_Utils_Tuple2(18, 8),
					_Utils_Tuple2(19, -15),
					_Utils_Tuple2(19, -14),
					_Utils_Tuple2(19, -4),
					_Utils_Tuple2(19, -3),
					_Utils_Tuple2(19, -1),
					_Utils_Tuple2(19, 0),
					_Utils_Tuple2(19, 1),
					_Utils_Tuple2(19, 2),
					_Utils_Tuple2(19, 5),
					_Utils_Tuple2(19, 7),
					_Utils_Tuple2(19, 8),
					_Utils_Tuple2(20, -15),
					_Utils_Tuple2(20, -3),
					_Utils_Tuple2(20, -2),
					_Utils_Tuple2(20, -1),
					_Utils_Tuple2(20, 0),
					_Utils_Tuple2(20, 1),
					_Utils_Tuple2(20, 7),
					_Utils_Tuple2(20, 8),
					_Utils_Tuple2(21, -15),
					_Utils_Tuple2(21, -14),
					_Utils_Tuple2(21, -3),
					_Utils_Tuple2(21, -2),
					_Utils_Tuple2(21, -1),
					_Utils_Tuple2(21, 4),
					_Utils_Tuple2(21, 8),
					_Utils_Tuple2(21, 9),
					_Utils_Tuple2(22, -15),
					_Utils_Tuple2(22, -14),
					_Utils_Tuple2(22, -4),
					_Utils_Tuple2(22, -3),
					_Utils_Tuple2(22, -2),
					_Utils_Tuple2(22, -1),
					_Utils_Tuple2(22, 0),
					_Utils_Tuple2(22, 2),
					_Utils_Tuple2(22, 3),
					_Utils_Tuple2(22, 4),
					_Utils_Tuple2(22, 5),
					_Utils_Tuple2(22, 8),
					_Utils_Tuple2(22, 9),
					_Utils_Tuple2(22, 10),
					_Utils_Tuple2(22, 11),
					_Utils_Tuple2(23, -15),
					_Utils_Tuple2(23, -4),
					_Utils_Tuple2(23, -3),
					_Utils_Tuple2(23, -2),
					_Utils_Tuple2(23, -1),
					_Utils_Tuple2(23, 0),
					_Utils_Tuple2(23, 1),
					_Utils_Tuple2(23, 2),
					_Utils_Tuple2(23, 3),
					_Utils_Tuple2(23, 4),
					_Utils_Tuple2(23, 5),
					_Utils_Tuple2(23, 6),
					_Utils_Tuple2(23, 9),
					_Utils_Tuple2(23, 10),
					_Utils_Tuple2(23, 11),
					_Utils_Tuple2(23, 12),
					_Utils_Tuple2(23, 13),
					_Utils_Tuple2(24, -2)
				]))
	}
	]);
var $author$project$App$demoScene = function (oldSeed) {
	var mapGenerator = A2(
		$elm$random$Random$map,
		A2(
			$elm$core$Basics$composeR,
			$elm$core$Tuple$first,
			$elm$core$Maybe$withDefault($author$project$OfficialMaps$default)),
		$author$project$Random$List$choose($author$project$OfficialMaps$maps));
	var _v0 = A2($elm$random$Random$step, mapGenerator, oldSeed);
	var map = _v0.a;
	var newSeed = _v0.b;
	return _Utils_Tuple2(
		A2(
			$author$project$App$SceneMain,
			$author$project$App$SubSceneDemo,
			A2($author$project$MainScene$initDemo, newSeed, map)),
		newSeed);
};
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $author$project$Config$Config = F3(
	function (gamepadDatabase, useKeyboardAndMouse, showFps) {
		return {gamepadDatabase: gamepadDatabase, showFps: showFps, useKeyboardAndMouse: useKeyboardAndMouse};
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $xarvh$elm_gamepad$Gamepad$UserMappings = function (a) {
	return {$: 'UserMappings', a: a};
};
var $xarvh$elm_gamepad$Gamepad$emptyUserMappings = $xarvh$elm_gamepad$Gamepad$UserMappings(
	{byId: $elm$core$Dict$empty, byIndexAndId: $elm$core$Dict$empty});
var $author$project$Config$default = {gamepadDatabase: $xarvh$elm_gamepad$Gamepad$emptyUserMappings, showFps: false, useKeyboardAndMouse: true};
var $elm$json$Json$Decode$map3 = _Json_map3;
var $xarvh$elm_gamepad$Gamepad$Axis = {$: 'Axis'};
var $xarvh$elm_gamepad$Gamepad$Button = {$: 'Button'};
var $xarvh$elm_gamepad$Gamepad$Origin = F3(
	function (a, b, c) {
		return {$: 'Origin', a: a, b: b, c: c};
	});
var $elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
var $elm$json$Json$Decode$dict = function (decoder) {
	return A2(
		$elm$json$Json$Decode$map,
		$elm$core$Dict$fromList,
		$elm$json$Json$Decode$keyValuePairs(decoder));
};
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var $elm$json$Json$Decode$string = _Json_decodeString;
var $xarvh$elm_gamepad$Gamepad$userMappingsDecoder = function () {
	var stringToOriginType = function (s) {
		switch (s) {
			case 'axis':
				return $elm$json$Json$Decode$succeed($xarvh$elm_gamepad$Gamepad$Axis);
			case 'button':
				return $elm$json$Json$Decode$succeed($xarvh$elm_gamepad$Gamepad$Button);
			default:
				return $elm$json$Json$Decode$fail('unrecognised Origin Type');
		}
	};
	var originDecoder = A4(
		$elm$json$Json$Decode$map3,
		$xarvh$elm_gamepad$Gamepad$Origin,
		A2($elm$json$Json$Decode$field, 'isReverse', $elm$json$Json$Decode$bool),
		A2(
			$elm$json$Json$Decode$field,
			'type',
			A2($elm$json$Json$Decode$andThen, stringToOriginType, $elm$json$Json$Decode$string)),
		A2($elm$json$Json$Decode$field, 'index', $elm$json$Json$Decode$int));
	var listToUserMappings = function (listByIndexAndId) {
		return $xarvh$elm_gamepad$Gamepad$UserMappings(
			{
				byId: $elm$core$Dict$fromList(
					A2(
						$elm$core$List$map,
						$elm$core$Tuple$mapFirst($elm$core$Tuple$second),
						listByIndexAndId)),
				byIndexAndId: $elm$core$Dict$fromList(listByIndexAndId)
			});
	};
	var keyDecoder = A3(
		$elm$json$Json$Decode$map2,
		$elm$core$Tuple$pair,
		A2($elm$json$Json$Decode$field, 'index', $elm$json$Json$Decode$int),
		A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string));
	var tuplesDecoder = A3(
		$elm$json$Json$Decode$map2,
		$elm$core$Tuple$pair,
		keyDecoder,
		A2(
			$elm$json$Json$Decode$field,
			'mapping',
			$elm$json$Json$Decode$dict(originDecoder)));
	return A2(
		$elm$json$Json$Decode$map,
		listToUserMappings,
		$elm$json$Json$Decode$list(tuplesDecoder));
}();
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$maybe = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder),
				$elm$json$Json$Decode$succeed($elm$core$Maybe$Nothing)
			]));
};
var $author$project$Config$withDefault = F2(
	function (value, dec) {
		return A2(
			$elm$json$Json$Decode$map,
			$elm$core$Maybe$withDefault(value),
			$elm$json$Json$Decode$maybe(dec));
	});
var $author$project$Config$decoder = A4(
	$elm$json$Json$Decode$map3,
	$author$project$Config$Config,
	A2(
		$author$project$Config$withDefault,
		$author$project$Config$default.gamepadDatabase,
		A2($elm$json$Json$Decode$field, 'gamepadDatabase', $xarvh$elm_gamepad$Gamepad$userMappingsDecoder)),
	A2(
		$author$project$Config$withDefault,
		$author$project$Config$default.useKeyboardAndMouse,
		A2($elm$json$Json$Decode$field, 'useKeyboardAndMouse', $elm$json$Json$Decode$bool)),
	A2(
		$author$project$Config$withDefault,
		$author$project$Config$default.showFps,
		A2($elm$json$Json$Decode$field, 'showFps', $elm$json$Json$Decode$bool)));
var $author$project$Config$fromString = function (s) {
	var _v0 = A2($elm$json$Json$Decode$decodeString, $author$project$Config$decoder, s);
	if (_v0.$ === 'Ok') {
		var config = _v0.a;
		return config;
	} else {
		var message = _v0.a;
		return $author$project$Config$default;
	}
};
var $author$project$SplitScreen$defaultViewport = {h: 480, w: 640, x: 0, y: 0};
var $author$project$SplitScreen$cellToViewport = F2(
	function (window, _v0) {
		var x = _v0.x;
		var y = _v0.y;
		var w = _v0.w;
		var h = _v0.h;
		return {
			h: $elm$core$Basics$floor(h * window.height),
			w: $elm$core$Basics$floor(w * window.width),
			x: $elm$core$Basics$floor(x * window.width),
			y: $elm$core$Basics$floor(y * window.height)
		};
	});
var $author$project$SplitScreen$makeRowCells = F3(
	function (rowHeight, rowIndex, numberOfColumns) {
		var y = rowIndex * rowHeight;
		var columnWidth = 1.0 / numberOfColumns;
		var columnIndexToCell = function (index) {
			return {h: rowHeight, w: columnWidth, x: index * columnWidth, y: y};
		};
		return A2(
			$elm$core$List$map,
			columnIndexToCell,
			A2($elm$core$List$range, 0, numberOfColumns - 1));
	});
var $author$project$SplitScreen$makeViewports = F2(
	function (windowSize, numberOfPlayers) {
		var rows = function () {
			switch (numberOfPlayers) {
				case 0:
					return _List_fromArray(
						[1]);
				case 1:
					return _List_fromArray(
						[1]);
				case 2:
					return _List_fromArray(
						[2]);
				case 3:
					return _List_fromArray(
						[3]);
				case 4:
					return _List_fromArray(
						[2, 2]);
				case 5:
					return _List_fromArray(
						[3, 2]);
				case 6:
					return _List_fromArray(
						[3, 3]);
				case 7:
					return _List_fromArray(
						[4, 3]);
				default:
					return _List_fromArray(
						[4, 4]);
			}
		}();
		var numberOfRows = $elm$core$List$length(rows);
		var rowHeight = 1.0 / numberOfRows;
		return A2(
			$elm$core$List$map,
			$author$project$SplitScreen$cellToViewport(windowSize),
			$elm$core$List$concat(
				A2(
					$elm$core$List$indexedMap,
					$author$project$SplitScreen$makeRowCells(rowHeight),
					rows)));
	});
var $author$project$App$makeViewport = function (windowSize) {
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$SplitScreen$defaultViewport,
		$elm$core$List$head(
			A2($author$project$SplitScreen$makeViewports, windowSize, 1)));
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$App$noCmd = function (model) {
	return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
};
var $author$project$App$init = function (flags) {
	var windowSize = {height: flags.windowHeight, width: flags.windowWidth};
	var config = $author$project$Config$fromString(flags.config);
	var _v0 = $author$project$App$demoScene(
		$elm$random$Random$initialSeed(flags.dateNow));
	var scene = _v0.a;
	var seed = _v0.b;
	return $author$project$App$noCmd(
		{
			config: config,
			flags: flags,
			maybeMenu: $elm$core$Maybe$Just($author$project$App$MenuMain),
			mouseIsPressed: false,
			mousePosition: {x: 0, y: 0},
			pressedKeys: $elm$core$Set$empty,
			scene: scene,
			seed: seed,
			selectedButton: $author$project$App$SelectedButton(''),
			viewport: $author$project$App$makeViewport(windowSize),
			windowSize: windowSize
		});
};
var $author$project$App$OnGamepad = function (a) {
	return {$: 'OnGamepad', a: a};
};
var $author$project$App$OnKeyDown = function (a) {
	return {$: 'OnKeyDown', a: a};
};
var $author$project$App$OnKeyUp = function (a) {
	return {$: 'OnKeyUp', a: a};
};
var $author$project$App$OnMapEditorMsg = function (a) {
	return {$: 'OnMapEditorMsg', a: a};
};
var $author$project$App$OnMouseButton = function (a) {
	return {$: 'OnMouseButton', a: a};
};
var $author$project$App$OnMouseMoves = F2(
	function (a, b) {
		return {$: 'OnMouseMoves', a: a, b: b};
	});
var $author$project$App$OnRemapMsg = function (a) {
	return {$: 'OnRemapMsg', a: a};
};
var $author$project$App$OnVisibilityChange = function (a) {
	return {$: 'OnVisibilityChange', a: a};
};
var $author$project$App$OnWindowResizes = F2(
	function (a, b) {
		return {$: 'OnWindowResizes', a: a, b: b};
	});
var $author$project$Input$always = $elm$json$Json$Decode$succeed;
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$json$Json$Decode$array = _Json_decodeArray;
var $elm$json$Json$Decode$float = _Json_decodeFloat;
var $elm$json$Json$Decode$index = _Json_decodeIndex;
var $author$project$GamepadPort$gamepad = _Platform_incomingPort(
	'gamepad',
	A2(
		$elm$json$Json$Decode$andThen,
		function (_v0) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (_v1) {
					return $elm$json$Json$Decode$succeed(
						_Utils_Tuple2(_v0, _v1));
				},
				A2(
					$elm$json$Json$Decode$index,
					1,
					A2(
						$elm$json$Json$Decode$andThen,
						function (timestamp) {
							return A2(
								$elm$json$Json$Decode$andThen,
								function (gamepads) {
									return $elm$json$Json$Decode$succeed(
										{gamepads: gamepads, timestamp: timestamp});
								},
								A2(
									$elm$json$Json$Decode$field,
									'gamepads',
									$elm$json$Json$Decode$list(
										A2(
											$elm$json$Json$Decode$andThen,
											function (mapping) {
												return A2(
													$elm$json$Json$Decode$andThen,
													function (index) {
														return A2(
															$elm$json$Json$Decode$andThen,
															function (id) {
																return A2(
																	$elm$json$Json$Decode$andThen,
																	function (buttons) {
																		return A2(
																			$elm$json$Json$Decode$andThen,
																			function (axes) {
																				return $elm$json$Json$Decode$succeed(
																					{axes: axes, buttons: buttons, id: id, index: index, mapping: mapping});
																			},
																			A2(
																				$elm$json$Json$Decode$field,
																				'axes',
																				$elm$json$Json$Decode$array($elm$json$Json$Decode$float)));
																	},
																	A2(
																		$elm$json$Json$Decode$field,
																		'buttons',
																		$elm$json$Json$Decode$array(
																			A2(
																				$elm$json$Json$Decode$andThen,
																				function (_v0) {
																					return A2(
																						$elm$json$Json$Decode$andThen,
																						function (_v1) {
																							return $elm$json$Json$Decode$succeed(
																								_Utils_Tuple2(_v0, _v1));
																						},
																						A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$float));
																				},
																				A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$bool)))));
															},
															A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string));
													},
													A2($elm$json$Json$Decode$field, 'index', $elm$json$Json$Decode$int));
											},
											A2($elm$json$Json$Decode$field, 'mapping', $elm$json$Json$Decode$string)))));
						},
						A2($elm$json$Json$Decode$field, 'timestamp', $elm$json$Json$Decode$float))));
		},
		A2(
			$elm$json$Json$Decode$index,
			0,
			A2(
				$elm$json$Json$Decode$andThen,
				function (timestamp) {
					return A2(
						$elm$json$Json$Decode$andThen,
						function (gamepads) {
							return $elm$json$Json$Decode$succeed(
								{gamepads: gamepads, timestamp: timestamp});
						},
						A2(
							$elm$json$Json$Decode$field,
							'gamepads',
							$elm$json$Json$Decode$list(
								A2(
									$elm$json$Json$Decode$andThen,
									function (mapping) {
										return A2(
											$elm$json$Json$Decode$andThen,
											function (index) {
												return A2(
													$elm$json$Json$Decode$andThen,
													function (id) {
														return A2(
															$elm$json$Json$Decode$andThen,
															function (buttons) {
																return A2(
																	$elm$json$Json$Decode$andThen,
																	function (axes) {
																		return $elm$json$Json$Decode$succeed(
																			{axes: axes, buttons: buttons, id: id, index: index, mapping: mapping});
																	},
																	A2(
																		$elm$json$Json$Decode$field,
																		'axes',
																		$elm$json$Json$Decode$array($elm$json$Json$Decode$float)));
															},
															A2(
																$elm$json$Json$Decode$field,
																'buttons',
																$elm$json$Json$Decode$array(
																	A2(
																		$elm$json$Json$Decode$andThen,
																		function (_v0) {
																			return A2(
																				$elm$json$Json$Decode$andThen,
																				function (_v1) {
																					return $elm$json$Json$Decode$succeed(
																						_Utils_Tuple2(_v0, _v1));
																				},
																				A2($elm$json$Json$Decode$index, 1, $elm$json$Json$Decode$float));
																		},
																		A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$bool)))));
													},
													A2($elm$json$Json$Decode$field, 'id', $elm$json$Json$Decode$string));
											},
											A2($elm$json$Json$Decode$field, 'index', $elm$json$Json$Decode$int));
									},
									A2($elm$json$Json$Decode$field, 'mapping', $elm$json$Json$Decode$string)))));
				},
				A2($elm$json$Json$Decode$field, 'timestamp', $elm$json$Json$Decode$float)))));
var $xarvh$elm_gamepad$Gamepad$isRemapping = function (_v0) {
	var model = _v0.a;
	return !_Utils_eq(model.maybeRemapping, $elm$core$Maybe$Nothing);
};
var $elm$core$String$toUpper = _String_toUpper;
var $author$project$Input$singleToUpper = function (s) {
	return ($elm$core$String$length(s) !== 1) ? s : $elm$core$String$toUpper(s);
};
var $author$project$Input$keyboardDecoder = function (msg) {
	return A2(
		$elm$json$Json$Decode$map,
		A2($elm$core$Basics$composeR, $author$project$Input$singleToUpper, msg),
		A2($elm$json$Json$Decode$field, 'key', $elm$json$Json$Decode$string));
};
var $elm$core$Platform$Sub$map = _Platform_map;
var $author$project$Input$mouseMoveDecoder = function (msg) {
	return A3(
		$elm$json$Json$Decode$map2,
		msg,
		A2($elm$json$Json$Decode$field, 'clientX', $elm$json$Json$Decode$int),
		A2($elm$json$Json$Decode$field, 'clientY', $elm$json$Json$Decode$int));
};
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $elm$browser$Browser$Events$Document = {$: 'Document'};
var $elm$browser$Browser$Events$MySub = F3(
	function (a, b, c) {
		return {$: 'MySub', a: a, b: b, c: c};
	});
var $elm$browser$Browser$Events$State = F2(
	function (subs, pids) {
		return {pids: pids, subs: subs};
	});
var $elm$browser$Browser$Events$init = $elm$core$Task$succeed(
	A2($elm$browser$Browser$Events$State, _List_Nil, $elm$core$Dict$empty));
var $elm$browser$Browser$Events$nodeToKey = function (node) {
	if (node.$ === 'Document') {
		return 'd_';
	} else {
		return 'w_';
	}
};
var $elm$browser$Browser$Events$addKey = function (sub) {
	var node = sub.a;
	var name = sub.b;
	return _Utils_Tuple2(
		_Utils_ap(
			$elm$browser$Browser$Events$nodeToKey(node),
			name),
		sub);
};
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _v0) {
				stepState:
				while (true) {
					var list = _v0.a;
					var result = _v0.b;
					if (!list.b) {
						return _Utils_Tuple2(
							list,
							A3(rightStep, rKey, rValue, result));
					} else {
						var _v2 = list.a;
						var lKey = _v2.a;
						var lValue = _v2.b;
						var rest = list.b;
						if (_Utils_cmp(lKey, rKey) < 0) {
							var $temp$rKey = rKey,
								$temp$rValue = rValue,
								$temp$_v0 = _Utils_Tuple2(
								rest,
								A3(leftStep, lKey, lValue, result));
							rKey = $temp$rKey;
							rValue = $temp$rValue;
							_v0 = $temp$_v0;
							continue stepState;
						} else {
							if (_Utils_cmp(lKey, rKey) > 0) {
								return _Utils_Tuple2(
									list,
									A3(rightStep, rKey, rValue, result));
							} else {
								return _Utils_Tuple2(
									rest,
									A4(bothStep, lKey, lValue, rValue, result));
							}
						}
					}
				}
			});
		var _v3 = A3(
			$elm$core$Dict$foldl,
			stepState,
			_Utils_Tuple2(
				$elm$core$Dict$toList(leftDict),
				initialResult),
			rightDict);
		var leftovers = _v3.a;
		var intermediateResult = _v3.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (_v4, result) {
					var k = _v4.a;
					var v = _v4.b;
					return A3(leftStep, k, v, result);
				}),
			intermediateResult,
			leftovers);
	});
var $elm$browser$Browser$Events$Event = F2(
	function (key, event) {
		return {event: event, key: key};
	});
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$browser$Browser$Events$spawn = F3(
	function (router, key, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var actualNode = function () {
			if (node.$ === 'Document') {
				return _Browser_doc;
			} else {
				return _Browser_window;
			}
		}();
		return A2(
			$elm$core$Task$map,
			function (value) {
				return _Utils_Tuple2(key, value);
			},
			A3(
				_Browser_on,
				actualNode,
				name,
				function (event) {
					return A2(
						$elm$core$Platform$sendToSelf,
						router,
						A2($elm$browser$Browser$Events$Event, key, event));
				}));
	});
var $elm$browser$Browser$Events$onEffects = F3(
	function (router, subs, state) {
		var stepRight = F3(
			function (key, sub, _v6) {
				var deads = _v6.a;
				var lives = _v6.b;
				var news = _v6.c;
				return _Utils_Tuple3(
					deads,
					lives,
					A2(
						$elm$core$List$cons,
						A3($elm$browser$Browser$Events$spawn, router, key, sub),
						news));
			});
		var stepLeft = F3(
			function (_v4, pid, _v5) {
				var deads = _v5.a;
				var lives = _v5.b;
				var news = _v5.c;
				return _Utils_Tuple3(
					A2($elm$core$List$cons, pid, deads),
					lives,
					news);
			});
		var stepBoth = F4(
			function (key, pid, _v2, _v3) {
				var deads = _v3.a;
				var lives = _v3.b;
				var news = _v3.c;
				return _Utils_Tuple3(
					deads,
					A3($elm$core$Dict$insert, key, pid, lives),
					news);
			});
		var newSubs = A2($elm$core$List$map, $elm$browser$Browser$Events$addKey, subs);
		var _v0 = A6(
			$elm$core$Dict$merge,
			stepLeft,
			stepBoth,
			stepRight,
			state.pids,
			$elm$core$Dict$fromList(newSubs),
			_Utils_Tuple3(_List_Nil, $elm$core$Dict$empty, _List_Nil));
		var deadPids = _v0.a;
		var livePids = _v0.b;
		var makeNewPids = _v0.c;
		return A2(
			$elm$core$Task$andThen,
			function (pids) {
				return $elm$core$Task$succeed(
					A2(
						$elm$browser$Browser$Events$State,
						newSubs,
						A2(
							$elm$core$Dict$union,
							livePids,
							$elm$core$Dict$fromList(pids))));
			},
			A2(
				$elm$core$Task$andThen,
				function (_v1) {
					return $elm$core$Task$sequence(makeNewPids);
				},
				$elm$core$Task$sequence(
					A2($elm$core$List$map, $elm$core$Process$kill, deadPids))));
	});
var $elm$browser$Browser$Events$onSelfMsg = F3(
	function (router, _v0, state) {
		var key = _v0.key;
		var event = _v0.event;
		var toMessage = function (_v2) {
			var subKey = _v2.a;
			var _v3 = _v2.b;
			var node = _v3.a;
			var name = _v3.b;
			var decoder = _v3.c;
			return _Utils_eq(subKey, key) ? A2(_Browser_decodeEvent, decoder, event) : $elm$core$Maybe$Nothing;
		};
		var messages = A2($elm$core$List$filterMap, toMessage, state.subs);
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Platform$sendToApp(router),
					messages)));
	});
var $elm$browser$Browser$Events$subMap = F2(
	function (func, _v0) {
		var node = _v0.a;
		var name = _v0.b;
		var decoder = _v0.c;
		return A3(
			$elm$browser$Browser$Events$MySub,
			node,
			name,
			A2($elm$json$Json$Decode$map, func, decoder));
	});
_Platform_effectManagers['Browser.Events'] = _Platform_createManager($elm$browser$Browser$Events$init, $elm$browser$Browser$Events$onEffects, $elm$browser$Browser$Events$onSelfMsg, 0, $elm$browser$Browser$Events$subMap);
var $elm$browser$Browser$Events$subscription = _Platform_leaf('Browser.Events');
var $elm$browser$Browser$Events$on = F3(
	function (node, name, decoder) {
		return $elm$browser$Browser$Events$subscription(
			A3($elm$browser$Browser$Events$MySub, node, name, decoder));
	});
var $elm$browser$Browser$Events$onKeyDown = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'keydown');
var $elm$browser$Browser$Events$onKeyUp = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'keyup');
var $elm$browser$Browser$Events$onMouseDown = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mousedown');
var $elm$browser$Browser$Events$onMouseMove = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mousemove');
var $elm$browser$Browser$Events$onMouseUp = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'mouseup');
var $elm$browser$Browser$Events$Window = {$: 'Window'};
var $elm$browser$Browser$Events$onResize = function (func) {
	return A3(
		$elm$browser$Browser$Events$on,
		$elm$browser$Browser$Events$Window,
		'resize',
		A2(
			$elm$json$Json$Decode$field,
			'target',
			A3(
				$elm$json$Json$Decode$map2,
				func,
				A2($elm$json$Json$Decode$field, 'innerWidth', $elm$json$Json$Decode$int),
				A2($elm$json$Json$Decode$field, 'innerHeight', $elm$json$Json$Decode$int))));
};
var $elm$browser$Browser$Events$Hidden = {$: 'Hidden'};
var $elm$browser$Browser$Events$Visible = {$: 'Visible'};
var $elm$browser$Browser$Events$withHidden = F2(
	function (func, isHidden) {
		return func(
			isHidden ? $elm$browser$Browser$Events$Hidden : $elm$browser$Browser$Events$Visible);
	});
var $elm$browser$Browser$Events$onVisibilityChange = function (func) {
	var info = _Browser_visibilityInfo(_Utils_Tuple0);
	return A3(
		$elm$browser$Browser$Events$on,
		$elm$browser$Browser$Events$Document,
		info.changes,
		A2(
			$elm$json$Json$Decode$map,
			$elm$browser$Browser$Events$withHidden(func),
			A2(
				$elm$json$Json$Decode$field,
				'target',
				A2($elm$json$Json$Decode$field, info.hidden, $elm$json$Json$Decode$bool))));
};
var $xarvh$elm_gamepad$Gamepad$OnGamepad = function (a) {
	return {$: 'OnGamepad', a: a};
};
var $xarvh$elm_gamepad$Gamepad$remapSubscriptions = function (gamepadPort) {
	return gamepadPort($xarvh$elm_gamepad$Gamepad$OnGamepad);
};
var $author$project$MapEditor$OnKeyPress = function (a) {
	return {$: 'OnKeyPress', a: a};
};
var $author$project$MapEditor$OnMouseButton = function (a) {
	return {$: 'OnMouseButton', a: a};
};
var $author$project$MapEditor$OnMouseClick = {$: 'OnMouseClick'};
var $author$project$MapEditor$OnMouseMoves = F2(
	function (a, b) {
		return {$: 'OnMouseMoves', a: a, b: b};
	});
var $elm$browser$Browser$Events$onClick = A2($elm$browser$Browser$Events$on, $elm$browser$Browser$Events$Document, 'click');
var $author$project$MapEditor$subscriptions = function (model) {
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				$elm$browser$Browser$Events$onClick(
				$author$project$Input$always($author$project$MapEditor$OnMouseClick)),
				$elm$browser$Browser$Events$onMouseDown(
				$author$project$Input$always(
					$author$project$MapEditor$OnMouseButton(true))),
				$elm$browser$Browser$Events$onMouseUp(
				$author$project$Input$always(
					$author$project$MapEditor$OnMouseButton(false))),
				$elm$browser$Browser$Events$onMouseMove(
				$author$project$Input$mouseMoveDecoder($author$project$MapEditor$OnMouseMoves)),
				$elm$browser$Browser$Events$onKeyUp(
				$author$project$Input$keyboardDecoder($author$project$MapEditor$OnKeyPress))
			]));
};
var $author$project$App$subscriptions = function (model) {
	var remapGamepadSub = A2(
		$elm$core$Platform$Sub$map,
		$author$project$App$OnRemapMsg,
		$xarvh$elm_gamepad$Gamepad$remapSubscriptions($author$project$GamepadPort$gamepad));
	var appGamepadSub = $author$project$GamepadPort$gamepad($author$project$App$OnGamepad);
	var gamepad = function () {
		var _v1 = model.maybeMenu;
		if ((_v1.$ === 'Just') && (_v1.a.$ === 'MenuGamepads')) {
			var remap = _v1.a.a;
			return $xarvh$elm_gamepad$Gamepad$isRemapping(remap) ? remapGamepadSub : $elm$core$Platform$Sub$batch(
				_List_fromArray(
					[appGamepadSub, remapGamepadSub]));
		} else {
			return appGamepadSub;
		}
	}();
	return $elm$core$Platform$Sub$batch(
		_List_fromArray(
			[
				$elm$browser$Browser$Events$onKeyDown(
				$author$project$Input$keyboardDecoder($author$project$App$OnKeyDown)),
				$elm$browser$Browser$Events$onKeyUp(
				$author$project$Input$keyboardDecoder($author$project$App$OnKeyUp)),
				$elm$browser$Browser$Events$onVisibilityChange($author$project$App$OnVisibilityChange),
				$elm$browser$Browser$Events$onMouseDown(
				$author$project$Input$always(
					$author$project$App$OnMouseButton(true))),
				$elm$browser$Browser$Events$onMouseUp(
				$author$project$Input$always(
					$author$project$App$OnMouseButton(false))),
				$elm$browser$Browser$Events$onMouseMove(
				$author$project$Input$mouseMoveDecoder($author$project$App$OnMouseMoves)),
				$elm$browser$Browser$Events$onResize($author$project$App$OnWindowResizes),
				gamepad,
				function () {
				var _v0 = model.scene;
				if (_v0.$ === 'SceneMapEditor') {
					var mapEditor = _v0.a;
					return A2(
						$elm$core$Platform$Sub$map,
						$author$project$App$OnMapEditorMsg,
						$author$project$MapEditor$subscriptions(mapEditor));
				} else {
					return $elm$core$Platform$Sub$none;
				}
			}()
			]));
};
var $author$project$App$SceneMapEditor = function (a) {
	return {$: 'SceneMapEditor', a: a};
};
var $xarvh$elm_gamepad$Gamepad$A = {$: 'A'};
var $xarvh$elm_gamepad$Gamepad$B = {$: 'B'};
var $xarvh$elm_gamepad$Gamepad$LeftStickDown = {$: 'LeftStickDown'};
var $xarvh$elm_gamepad$Gamepad$LeftStickLeft = {$: 'LeftStickLeft'};
var $xarvh$elm_gamepad$Gamepad$LeftStickRight = {$: 'LeftStickRight'};
var $xarvh$elm_gamepad$Gamepad$LeftStickUp = {$: 'LeftStickUp'};
var $xarvh$elm_gamepad$Gamepad$RightBumper = {$: 'RightBumper'};
var $xarvh$elm_gamepad$Gamepad$RightStickDown = {$: 'RightStickDown'};
var $xarvh$elm_gamepad$Gamepad$RightStickLeft = {$: 'RightStickLeft'};
var $xarvh$elm_gamepad$Gamepad$RightStickRight = {$: 'RightStickRight'};
var $xarvh$elm_gamepad$Gamepad$RightStickUp = {$: 'RightStickUp'};
var $xarvh$elm_gamepad$Gamepad$RightTrigger = {$: 'RightTrigger'};
var $xarvh$elm_gamepad$Gamepad$Start = {$: 'Start'};
var $author$project$App$gamepadButtonMap = A2(
	$elm$core$List$map,
	function (_v0) {
		var a = _v0.a;
		var b = _v0.b;
		return _Utils_Tuple2(b, a);
	},
	_List_fromArray(
		[
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickLeft, 'Move LEFT'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickRight, 'Move RIGHT'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickUp, 'Move UP'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickDown, 'Move DOWN'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightStickLeft, 'Aim LEFT'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightStickRight, 'Aim RIGHT'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightStickUp, 'Aim UP'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightStickDown, 'Aim DOWN'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightTrigger, 'FIRE'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightBumper, 'Alt FIRE'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$A, 'Transform'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$B, 'Rally'),
			_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$Start, 'Menu')
		]));
var $elm$core$Platform$Cmd$map = _Platform_map;
var $elm$core$Tuple$mapSecond = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var $xarvh$elm_gamepad$Gamepad$RemapModel = function (a) {
	return {$: 'RemapModel', a: a};
};
var $xarvh$elm_gamepad$Gamepad$AllButtonsUp = {$: 'AllButtonsUp'};
var $xarvh$elm_gamepad$Gamepad$initRemap = F2(
	function (id, index) {
		return {id: id, index: index, pairs: _List_Nil, skipped: _List_Nil, waitingFor: $xarvh$elm_gamepad$Gamepad$AllButtonsUp};
	});
var $xarvh$elm_gamepad$Gamepad$noCmd = function (model) {
	return _Utils_Tuple2(model, $elm$core$Maybe$Nothing);
};
var $xarvh$elm_gamepad$Gamepad$SomeButtonDown = {$: 'SomeButtonDown'};
var $elm$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		if (maybeValue.$ === 'Just') {
			var value = maybeValue.a;
			return callback(value);
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $elm$core$Elm$JsArray$appendN = _JsArray_appendN;
var $elm$core$Elm$JsArray$slice = _JsArray_slice;
var $elm$core$Array$appendHelpBuilder = F2(
	function (tail, builder) {
		var tailLen = $elm$core$Elm$JsArray$length(tail);
		var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(builder.tail)) - tailLen;
		var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, builder.tail, tail);
		return (notAppended < 0) ? {
			nodeList: A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(appended),
				builder.nodeList),
			nodeListSize: builder.nodeListSize + 1,
			tail: A3($elm$core$Elm$JsArray$slice, notAppended, tailLen, tail)
		} : ((!notAppended) ? {
			nodeList: A2(
				$elm$core$List$cons,
				$elm$core$Array$Leaf(appended),
				builder.nodeList),
			nodeListSize: builder.nodeListSize + 1,
			tail: $elm$core$Elm$JsArray$empty
		} : {nodeList: builder.nodeList, nodeListSize: builder.nodeListSize, tail: appended});
	});
var $elm$core$Array$bitMask = 4294967295 >>> (32 - $elm$core$Array$shiftStep);
var $elm$core$Elm$JsArray$push = _JsArray_push;
var $elm$core$Elm$JsArray$singleton = _JsArray_singleton;
var $elm$core$Elm$JsArray$unsafeGet = _JsArray_unsafeGet;
var $elm$core$Elm$JsArray$unsafeSet = _JsArray_unsafeSet;
var $elm$core$Array$insertTailInTree = F4(
	function (shift, index, tail, tree) {
		var pos = $elm$core$Array$bitMask & (index >>> shift);
		if (_Utils_cmp(
			pos,
			$elm$core$Elm$JsArray$length(tree)) > -1) {
			if (shift === 5) {
				return A2(
					$elm$core$Elm$JsArray$push,
					$elm$core$Array$Leaf(tail),
					tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, $elm$core$Elm$JsArray$empty));
				return A2($elm$core$Elm$JsArray$push, newSub, tree);
			}
		} else {
			var value = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (value.$ === 'SubTree') {
				var subTree = value.a;
				var newSub = $elm$core$Array$SubTree(
					A4($elm$core$Array$insertTailInTree, shift - $elm$core$Array$shiftStep, index, tail, subTree));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			} else {
				var newSub = $elm$core$Array$SubTree(
					A4(
						$elm$core$Array$insertTailInTree,
						shift - $elm$core$Array$shiftStep,
						index,
						tail,
						$elm$core$Elm$JsArray$singleton(value)));
				return A3($elm$core$Elm$JsArray$unsafeSet, pos, newSub, tree);
			}
		}
	});
var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
var $elm$core$Array$unsafeReplaceTail = F2(
	function (newTail, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		var originalTailLen = $elm$core$Elm$JsArray$length(tail);
		var newTailLen = $elm$core$Elm$JsArray$length(newTail);
		var newArrayLen = len + (newTailLen - originalTailLen);
		if (_Utils_eq(newTailLen, $elm$core$Array$branchFactor)) {
			var overflow = _Utils_cmp(newArrayLen >>> $elm$core$Array$shiftStep, 1 << startShift) > 0;
			if (overflow) {
				var newShift = startShift + $elm$core$Array$shiftStep;
				var newTree = A4(
					$elm$core$Array$insertTailInTree,
					newShift,
					len,
					newTail,
					$elm$core$Elm$JsArray$singleton(
						$elm$core$Array$SubTree(tree)));
				return A4($elm$core$Array$Array_elm_builtin, newArrayLen, newShift, newTree, $elm$core$Elm$JsArray$empty);
			} else {
				return A4(
					$elm$core$Array$Array_elm_builtin,
					newArrayLen,
					startShift,
					A4($elm$core$Array$insertTailInTree, startShift, len, newTail, tree),
					$elm$core$Elm$JsArray$empty);
			}
		} else {
			return A4($elm$core$Array$Array_elm_builtin, newArrayLen, startShift, tree, newTail);
		}
	});
var $elm$core$Array$appendHelpTree = F2(
	function (toAppend, array) {
		var len = array.a;
		var tree = array.c;
		var tail = array.d;
		var itemsToAppend = $elm$core$Elm$JsArray$length(toAppend);
		var notAppended = ($elm$core$Array$branchFactor - $elm$core$Elm$JsArray$length(tail)) - itemsToAppend;
		var appended = A3($elm$core$Elm$JsArray$appendN, $elm$core$Array$branchFactor, tail, toAppend);
		var newArray = A2($elm$core$Array$unsafeReplaceTail, appended, array);
		if (notAppended < 0) {
			var nextTail = A3($elm$core$Elm$JsArray$slice, notAppended, itemsToAppend, toAppend);
			return A2($elm$core$Array$unsafeReplaceTail, nextTail, newArray);
		} else {
			return newArray;
		}
	});
var $elm$core$Elm$JsArray$foldl = _JsArray_foldl;
var $elm$core$Array$builderFromArray = function (_v0) {
	var len = _v0.a;
	var tree = _v0.c;
	var tail = _v0.d;
	var helper = F2(
		function (node, acc) {
			if (node.$ === 'SubTree') {
				var subTree = node.a;
				return A3($elm$core$Elm$JsArray$foldl, helper, acc, subTree);
			} else {
				return A2($elm$core$List$cons, node, acc);
			}
		});
	return {
		nodeList: A3($elm$core$Elm$JsArray$foldl, helper, _List_Nil, tree),
		nodeListSize: (len / $elm$core$Array$branchFactor) | 0,
		tail: tail
	};
};
var $elm$core$Array$append = F2(
	function (a, _v0) {
		var aTail = a.d;
		var bLen = _v0.a;
		var bTree = _v0.c;
		var bTail = _v0.d;
		if (_Utils_cmp(bLen, $elm$core$Array$branchFactor * 4) < 1) {
			var foldHelper = F2(
				function (node, array) {
					if (node.$ === 'SubTree') {
						var tree = node.a;
						return A3($elm$core$Elm$JsArray$foldl, foldHelper, array, tree);
					} else {
						var leaf = node.a;
						return A2($elm$core$Array$appendHelpTree, leaf, array);
					}
				});
			return A2(
				$elm$core$Array$appendHelpTree,
				bTail,
				A3($elm$core$Elm$JsArray$foldl, foldHelper, a, bTree));
		} else {
			var foldHelper = F2(
				function (node, builder) {
					if (node.$ === 'SubTree') {
						var tree = node.a;
						return A3($elm$core$Elm$JsArray$foldl, foldHelper, builder, tree);
					} else {
						var leaf = node.a;
						return A2($elm$core$Array$appendHelpBuilder, leaf, builder);
					}
				});
			return A2(
				$elm$core$Array$builderToArray,
				true,
				A2(
					$elm$core$Array$appendHelpBuilder,
					bTail,
					A3(
						$elm$core$Elm$JsArray$foldl,
						foldHelper,
						$elm$core$Array$builderFromArray(a),
						bTree)));
		}
	});
var $xarvh$elm_gamepad$Gamepad$axisToEstimate = F2(
	function (originIndex, v) {
		return _Utils_Tuple2(
			A3($xarvh$elm_gamepad$Gamepad$Origin, v < 0, $xarvh$elm_gamepad$Gamepad$Axis, originIndex),
			$elm$core$Basics$abs(v));
	});
var $xarvh$elm_gamepad$Gamepad$boolToNumber = function (bool) {
	return bool ? 1 : 0;
};
var $xarvh$elm_gamepad$Gamepad$buttonToEstimate = F2(
	function (originIndex, _v0) {
		var pressed = _v0.a;
		var v = _v0.b;
		return _Utils_Tuple2(
			A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, originIndex),
			$xarvh$elm_gamepad$Gamepad$boolToNumber(pressed));
	});
var $xarvh$elm_gamepad$Gamepad$estimateThreshold = function (_v0) {
	var origin = _v0.a;
	var confidence = _v0.b;
	return (confidence < 0.5) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(origin);
};
var $elm$core$Elm$JsArray$indexedMap = _JsArray_indexedMap;
var $elm$core$Array$tailIndex = function (len) {
	return (len >>> 5) << 5;
};
var $elm$core$Array$indexedMap = F2(
	function (func, _v0) {
		var len = _v0.a;
		var tree = _v0.c;
		var tail = _v0.d;
		var initialBuilder = {
			nodeList: _List_Nil,
			nodeListSize: 0,
			tail: A3(
				$elm$core$Elm$JsArray$indexedMap,
				func,
				$elm$core$Array$tailIndex(len),
				tail)
		};
		var helper = F2(
			function (node, builder) {
				if (node.$ === 'SubTree') {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldl, helper, builder, subTree);
				} else {
					var leaf = node.a;
					var offset = builder.nodeListSize * $elm$core$Array$branchFactor;
					var mappedLeaf = $elm$core$Array$Leaf(
						A3($elm$core$Elm$JsArray$indexedMap, func, offset, leaf));
					return {
						nodeList: A2($elm$core$List$cons, mappedLeaf, builder.nodeList),
						nodeListSize: builder.nodeListSize + 1,
						tail: builder.tail
					};
				}
			});
		return A2(
			$elm$core$Array$builderToArray,
			true,
			A3($elm$core$Elm$JsArray$foldl, helper, initialBuilder, tree));
	});
var $xarvh$elm_gamepad$Gamepad$estimateOriginInFrame = function (frame) {
	var buttonsEstimates = A2($elm$core$Array$indexedMap, $xarvh$elm_gamepad$Gamepad$buttonToEstimate, frame.buttons);
	var axesEstimates = A2($elm$core$Array$indexedMap, $xarvh$elm_gamepad$Gamepad$axisToEstimate, frame.axes);
	return A2(
		$elm$core$Maybe$andThen,
		$xarvh$elm_gamepad$Gamepad$estimateThreshold,
		$elm$core$List$head(
			$elm$core$List$reverse(
				A2(
					$elm$core$List$sortBy,
					$elm$core$Tuple$second,
					$elm$core$Array$toList(
						A2($elm$core$Array$append, axesEstimates, buttonsEstimates))))));
};
var $xarvh$elm_gamepad$Gamepad$estimateOrigin = F2(
	function (_v0, index) {
		var currentBlobFrame = _v0.a;
		var previousBlobFrame = _v0.b;
		return A2(
			$elm$core$Maybe$andThen,
			$xarvh$elm_gamepad$Gamepad$estimateOriginInFrame,
			A2(
				$elm_community$list_extra$List$Extra$find,
				function (pad) {
					return _Utils_eq(pad.index, index);
				},
				currentBlobFrame.gamepads));
	});
var $xarvh$elm_gamepad$Gamepad$insertPair = F3(
	function (origin, destination, remapping) {
		return _Utils_update(
			remapping,
			{
				pairs: A2(
					$elm$core$List$cons,
					_Utils_Tuple2(origin, destination),
					remapping.pairs)
			});
	});
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			$elm$core$List$any,
			A2($elm$core$Basics$composeL, $elm$core$Basics$not, isOkay),
			list);
	});
var $xarvh$elm_gamepad$Gamepad$nextUnmappedAction = F2(
	function (actions, remapping) {
		var mapped = _Utils_ap(
			A2($elm$core$List$map, $elm$core$Tuple$second, remapping.pairs),
			remapping.skipped);
		var needsMapping = function (_v0) {
			var name = _v0.a;
			var destination = _v0.b;
			return A2(
				$elm$core$List$all,
				$elm$core$Basics$neq(destination),
				mapped);
		};
		return A2($elm_community$list_extra$List$Extra$find, needsMapping, actions);
	});
var $xarvh$elm_gamepad$Gamepad$destinationToString = function (destination) {
	switch (destination.$) {
		case 'A':
			return 'a';
		case 'B':
			return 'b';
		case 'X':
			return 'x';
		case 'Y':
			return 'y';
		case 'Start':
			return 'start';
		case 'Back':
			return 'back';
		case 'Home':
			return 'home';
		case 'LeftStickLeft':
			return 'leftleft';
		case 'LeftStickRight':
			return 'leftright';
		case 'LeftStickUp':
			return 'leftup';
		case 'LeftStickDown':
			return 'leftdown';
		case 'LeftStickPress':
			return 'leftstick';
		case 'LeftBumper':
			return 'leftbumper';
		case 'LeftTrigger':
			return 'lefttrigger';
		case 'RightStickLeft':
			return 'rightleft';
		case 'RightStickRight':
			return 'rightright';
		case 'RightStickUp':
			return 'rightup';
		case 'RightStickDown':
			return 'rightdown';
		case 'RightStickPress':
			return 'rightstick';
		case 'RightBumper':
			return 'rightbumper';
		case 'RightTrigger':
			return 'righttrigger';
		case 'DpadUp':
			return 'dpadup';
		case 'DpadDown':
			return 'dpaddown';
		case 'DpadLeft':
			return 'dpadleft';
		default:
			return 'dpadright';
	}
};
var $xarvh$elm_gamepad$Gamepad$pairsToMapping = function (pairs) {
	return $elm$core$Dict$fromList(
		A2(
			$elm$core$List$map,
			function (_v0) {
				var origin = _v0.a;
				var digital = _v0.b;
				return _Utils_Tuple2(
					$xarvh$elm_gamepad$Gamepad$destinationToString(digital),
					origin);
			},
			pairs));
};
var $xarvh$elm_gamepad$Gamepad$pairsToUpdateUserMappings = F4(
	function (id, index, pairs, _v0) {
		var database = _v0.a;
		var mapping = $xarvh$elm_gamepad$Gamepad$pairsToMapping(pairs);
		return $xarvh$elm_gamepad$Gamepad$UserMappings(
			{
				byId: A3($elm$core$Dict$insert, id, mapping, database.byId),
				byIndexAndId: A3(
					$elm$core$Dict$insert,
					_Utils_Tuple2(index, id),
					mapping,
					database.byIndexAndId)
			});
	});
var $xarvh$elm_gamepad$Gamepad$updateRemapping = F3(
	function (actions, remapping, model) {
		var _v0 = _Utils_Tuple2(
			remapping.waitingFor,
			A2($xarvh$elm_gamepad$Gamepad$estimateOrigin, model.blob, remapping.index));
		_v0$2:
		while (true) {
			if (_v0.a.$ === 'AllButtonsUp') {
				if (_v0.b.$ === 'Nothing') {
					var _v1 = _v0.a;
					var _v2 = _v0.b;
					return $xarvh$elm_gamepad$Gamepad$noCmd(
						$elm$core$Maybe$Just(
							_Utils_update(
								remapping,
								{waitingFor: $xarvh$elm_gamepad$Gamepad$SomeButtonDown})));
				} else {
					break _v0$2;
				}
			} else {
				if (_v0.b.$ === 'Just') {
					var _v3 = _v0.a;
					var origin = _v0.b.a;
					var _v4 = A2($xarvh$elm_gamepad$Gamepad$nextUnmappedAction, actions, remapping);
					if (_v4.$ === 'Nothing') {
						return _Utils_Tuple2(
							$elm$core$Maybe$Nothing,
							$elm$core$Maybe$Just(
								A3($xarvh$elm_gamepad$Gamepad$pairsToUpdateUserMappings, remapping.id, remapping.index, remapping.pairs)));
					} else {
						var _v5 = _v4.a;
						var name = _v5.a;
						var destination = _v5.b;
						return $xarvh$elm_gamepad$Gamepad$noCmd(
							$elm$core$Maybe$Just(
								A3(
									$xarvh$elm_gamepad$Gamepad$insertPair,
									origin,
									destination,
									_Utils_update(
										remapping,
										{waitingFor: $xarvh$elm_gamepad$Gamepad$AllButtonsUp}))));
					}
				} else {
					break _v0$2;
				}
			}
		}
		return $xarvh$elm_gamepad$Gamepad$noCmd(
			$elm$core$Maybe$Just(remapping));
	});
var $xarvh$elm_gamepad$Gamepad$updateOnGamepad = F2(
	function (actions, model) {
		var _v0 = model.maybeRemapping;
		if (_v0.$ === 'Nothing') {
			return $xarvh$elm_gamepad$Gamepad$noCmd(model);
		} else {
			var remapping = _v0.a;
			return A2(
				$elm$core$Tuple$mapFirst,
				function (r) {
					return _Utils_update(
						model,
						{maybeRemapping: r});
				},
				A3($xarvh$elm_gamepad$Gamepad$updateRemapping, actions, remapping, model));
		}
	});
var $xarvh$elm_gamepad$Gamepad$remapUpdate = F3(
	function (actions, msg, _v0) {
		var model = _v0.a;
		return A2(
			$elm$core$Tuple$mapFirst,
			$xarvh$elm_gamepad$Gamepad$RemapModel,
			function () {
				switch (msg.$) {
					case 'Noop':
						return $xarvh$elm_gamepad$Gamepad$noCmd(model);
					case 'OnGamepad':
						var blob = msg.a;
						return A2(
							$xarvh$elm_gamepad$Gamepad$updateOnGamepad,
							actions,
							_Utils_update(
								model,
								{blob: blob}));
					case 'OnStartRemapping':
						var id = msg.a;
						var index = msg.b;
						return $xarvh$elm_gamepad$Gamepad$noCmd(
							_Utils_update(
								model,
								{
									maybeRemapping: $elm$core$Maybe$Just(
										A2($xarvh$elm_gamepad$Gamepad$initRemap, id, index))
								}));
					case 'OnCancel':
						return $xarvh$elm_gamepad$Gamepad$noCmd(
							_Utils_update(
								model,
								{maybeRemapping: $elm$core$Maybe$Nothing}));
					default:
						var digital = msg.a;
						var _v2 = model.maybeRemapping;
						if (_v2.$ === 'Nothing') {
							return $xarvh$elm_gamepad$Gamepad$noCmd(model);
						} else {
							var remapping = _v2.a;
							return $xarvh$elm_gamepad$Gamepad$noCmd(
								_Utils_update(
									model,
									{
										maybeRemapping: $elm$core$Maybe$Just(
											_Utils_update(
												remapping,
												{
													skipped: A2($elm$core$List$cons, digital, remapping.skipped)
												}))
									}));
						}
				}
			}());
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.e.d.$ === 'RBNode_elm_builtin') && (dict.e.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) && (dict.e.$ === 'RBNode_elm_builtin')) {
		if ((dict.d.d.$ === 'RBNode_elm_builtin') && (dict.d.d.a.$ === 'Red')) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				$elm$core$Dict$Red,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr.$ === 'Black') {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					$elm$core$Dict$Black,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Red')) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Red, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === 'RBNode_elm_builtin') && (right.a.$ === 'Black')) {
					if (right.d.$ === 'RBNode_elm_builtin') {
						if (right.d.a.$ === 'Black') {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === 'RBNode_elm_builtin') && (dict.d.$ === 'RBNode_elm_builtin')) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor.$ === 'Black') {
			if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === 'RBNode_elm_builtin') {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === 'RBNode_elm_builtin') && (left.a.$ === 'Black')) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === 'RBNode_elm_builtin') && (lLeft.a.$ === 'Red')) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === 'RBNode_elm_builtin') {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === 'RBNode_elm_builtin') {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === 'RBNode_elm_builtin') {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === 'RBNode_elm_builtin') && (_v0.a.$ === 'Red')) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Set$remove = F2(
	function (key, _v0) {
		var dict = _v0.a;
		return $elm$core$Set$Set_elm_builtin(
			A2($elm$core$Dict$remove, key, dict));
	});
var $author$project$App$selectButtonByName = F2(
	function (name, model) {
		return _Utils_update(
			model,
			{
				selectedButton: $author$project$App$SelectedButton(name)
			});
	});
var $author$project$App$shell = function (model) {
	return {
		config: model.config,
		flags: model.flags,
		gameIsPaused: function () {
			var _v0 = model.scene;
			if ((_v0.$ === 'SceneMain') && (_v0.a.$ === 'SubSceneDemo')) {
				var _v1 = _v0.a;
				return false;
			} else {
				return !_Utils_eq(model.maybeMenu, $elm$core$Maybe$Nothing);
			}
		}(),
		mouseIsPressed: model.mouseIsPressed,
		mousePosition: model.mousePosition,
		pressedKeys: model.pressedKeys,
		viewport: model.viewport,
		windowSize: model.windowSize
	};
};
var $author$project$MapEditor$EditMainBase = {$: 'EditMainBase'};
var $author$project$MapEditor$EditSmallBases = {$: 'EditSmallBases'};
var $author$project$MapEditor$EditWalls = function (a) {
	return {$: 'EditWalls', a: a};
};
var $author$project$MapEditor$WallPlace = {$: 'WallPlace'};
var $author$project$MapEditor$WallRemove = {$: 'WallRemove'};
var $elm$core$Basics$clamp = F3(
	function (low, high, number) {
		return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
	});
var $author$project$MapEditor$isEditWalls = function (editMode) {
	if (editMode.$ === 'EditWalls') {
		return true;
	} else {
		return false;
	}
};
var $author$project$MapEditor$isWithinMap = F2(
	function (map, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return true && ((_Utils_cmp(x, -map.halfWidth) > -1) && ((_Utils_cmp(x, map.halfWidth) < 0) && ((_Utils_cmp(y, -map.halfHeight) > -1) && (_Utils_cmp(y, map.halfHeight) < 0))));
	});
var $author$project$Map$maxSize = 30;
var $author$project$MapEditor$maxSize = $author$project$Map$maxSize;
var $author$project$Map$minSize = 8;
var $author$project$MapEditor$minSize = $author$project$Map$minSize;
var $author$project$MapEditor$noCmd = function (model) {
	return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
};
var $author$project$MapEditor$setDimension = F3(
	function (dimension, magnitude, map) {
		if (dimension.$ === 'DimensionWidth') {
			return _Utils_update(
				map,
				{halfWidth: magnitude});
		} else {
			return _Utils_update(
				map,
				{halfHeight: magnitude});
		}
	});
var $elm$core$Dict$filter = F2(
	function (isGood, dict) {
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (k, v, d) {
					return A2(isGood, k, v) ? A3($elm$core$Dict$insert, k, v, d) : d;
				}),
			$elm$core$Dict$empty,
			dict);
	});
var $author$project$MapEditor$findBasesAt = F2(
	function (map, tile) {
		var onTile = F2(
			function (base, baseType) {
				return A2(
					$elm$core$List$member,
					tile,
					A2($author$project$Base$tiles, baseType, base));
			});
		return $elm$core$Dict$keys(
			A2($elm$core$Dict$filter, onTile, map.bases));
	});
var $author$project$MapEditor$removeBase = F2(
	function (base, map) {
		return _Utils_update(
			map,
			{
				bases: A2($elm$core$Dict$remove, base, map.bases)
			});
	});
var $author$project$MapEditor$SymmetryCentral = {$: 'SymmetryCentral'};
var $author$project$MapEditor$SymmetryHorizontal = {$: 'SymmetryHorizontal'};
var $author$project$MapEditor$SymmetryVertical = {$: 'SymmetryVertical'};
var $author$project$MapEditor$shiftForward = function (v) {
	return (v >= 0) ? (v + 1) : v;
};
var $author$project$MapEditor$shiftTile = F2(
	function (symmetry, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			(_Utils_eq(symmetry, $author$project$MapEditor$SymmetryCentral) || _Utils_eq(symmetry, $author$project$MapEditor$SymmetryVertical)) ? $author$project$MapEditor$shiftForward(x) : x,
			(_Utils_eq(symmetry, $author$project$MapEditor$SymmetryCentral) || _Utils_eq(symmetry, $author$project$MapEditor$SymmetryHorizontal)) ? $author$project$MapEditor$shiftForward(y) : y);
	});
var $author$project$MapEditor$addBase = F4(
	function (symmetry, baseType, targetTile, map) {
		var shiftedTile = A2($author$project$MapEditor$shiftTile, symmetry, targetTile);
		var tiles = A2($author$project$Base$tiles, baseType, shiftedTile);
		return A2(
			$elm$core$List$all,
			$author$project$MapEditor$isWithinMap(map),
			tiles) ? function (m) {
			return _Utils_update(
				m,
				{
					bases: A3($elm$core$Dict$insert, shiftedTile, baseType, m.bases)
				});
		}(
			A3(
				$elm$core$List$foldl,
				$author$project$MapEditor$removeBase,
				map,
				$elm$core$List$concat(
					A2(
						$elm$core$List$map,
						$author$project$MapEditor$findBasesAt(map),
						tiles)))) : map;
	});
var $author$project$MapEditor$mirrorTile = F2(
	function (symmetry, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		var invert = function (v) {
			return (-v) - 1;
		};
		switch (symmetry.$) {
			case 'SymmetryCentral':
				return _Utils_Tuple2(
					invert(x),
					invert(y));
			case 'SymmetryVertical':
				return _Utils_Tuple2(
					invert(x),
					y);
			case 'SymmetryHorizontal':
				return _Utils_Tuple2(
					x,
					invert(y));
			default:
				return _Utils_Tuple2(x, y);
		}
	});
var $author$project$MapEditor$updateBase = F2(
	function (baseType, model) {
		return _Utils_update(
			model,
			{
				map: function () {
					var _v0 = A2($author$project$MapEditor$findBasesAt, model.map, model.mouseTile);
					if (!_v0.b) {
						return A4(
							$author$project$MapEditor$addBase,
							model.symmetry,
							baseType,
							model.mouseTile,
							A4(
								$author$project$MapEditor$addBase,
								model.symmetry,
								baseType,
								A2($author$project$MapEditor$mirrorTile, model.symmetry, model.mouseTile),
								model.map));
					} else {
						var base = _v0.a;
						return A2(
							$author$project$MapEditor$removeBase,
							A2($author$project$MapEditor$mirrorTile, model.symmetry, base),
							A2($author$project$MapEditor$removeBase, base, model.map));
					}
				}()
			});
	});
var $elm$core$Basics$min = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) < 0) ? x : y;
	});
var $author$project$SplitScreen$fitWidthAndHeight = F3(
	function (width, height, viewport) {
		var minSize = A2($elm$core$Basics$min, viewport.w, viewport.h);
		var xScale = width / (viewport.w / minSize);
		var yScale = height / (viewport.h / minSize);
		return A2($elm$core$Basics$max, xScale, yScale);
	});
var $author$project$SplitScreen$mouseScreenToViewport = F2(
	function (mouse, viewport) {
		var pixelY = ((1 - mouse.y) + viewport.y) + ((viewport.h / 2) | 0);
		var pixelX = (mouse.x - viewport.x) - ((viewport.w / 2) | 0);
		var minSize = A2($elm$core$Basics$min, viewport.w, viewport.h);
		return _Utils_Tuple2(pixelX / minSize, pixelY / minSize);
	});
var $author$project$MapEditor$updateWallAtMouseTile = function (model) {
	var _v0 = model.editMode;
	if ((_v0.$ === 'EditWalls') && (_v0.a.$ === 'Just')) {
		var mode = _v0.a.a;
		var operation = function () {
			if (mode.$ === 'WallRemove') {
				return $elm$core$Set$remove;
			} else {
				return $elm$core$Set$insert;
			}
		}();
		var one = model.mouseTile;
		var two = A2($author$project$MapEditor$mirrorTile, model.symmetry, one);
		var map = model.map;
		var tiles = A2(
			$elm$core$List$filter,
			$author$project$MapEditor$isWithinMap(map),
			_List_fromArray(
				[one, two]));
		var _v1 = one;
		var x = _v1.a;
		var y = _v1.b;
		return _Utils_update(
			model,
			{
				map: _Utils_update(
					map,
					{
						wallTiles: A3($elm$core$List$foldl, operation, map.wallTiles, tiles)
					})
			});
	} else {
		return model;
	}
};
var $author$project$MapEditor$toolbarHeightInPixels = 100;
var $author$project$MapEditor$viewport = function (model) {
	var size = {height: model.windowSize.height - $author$project$MapEditor$toolbarHeightInPixels, width: model.windowSize.width};
	return A2(
		$elm$core$Maybe$withDefault,
		$author$project$SplitScreen$defaultViewport,
		$elm$core$List$head(
			A2($author$project$SplitScreen$makeViewports, size, 1)));
};
var $author$project$MapEditor$updateOnMouseMove = F3(
	function (mousePositionInPixels, shell, model) {
		var vp = $author$project$MapEditor$viewport(shell);
		var scale = A3($author$project$SplitScreen$fitWidthAndHeight, model.map.halfWidth * 2, model.map.halfHeight * 2, vp);
		var toTile = function (v) {
			return $elm$core$Basics$floor(v * scale);
		};
		var mousePositionInTiles = A2(
			$elm$core$Tuple$mapSecond,
			toTile,
			A2(
				$elm$core$Tuple$mapFirst,
				toTile,
				A2($author$project$SplitScreen$mouseScreenToViewport, mousePositionInPixels, vp)));
		return $author$project$MapEditor$updateWallAtMouseTile(
			_Utils_update(
				model,
				{mouseTile: mousePositionInTiles}));
	});
var $author$project$MapEditor$updateOnSymmetry = F2(
	function (sym, model) {
		return _Utils_update(
			model,
			{symmetry: sym});
	});
var $author$project$Map$tileDecoder = A2(
	$elm$json$Json$Decode$andThen,
	function (list) {
		if ((list.b && list.b.b) && (!list.b.b.b)) {
			var x = list.a;
			var _v1 = list.b;
			var y = _v1.a;
			return $elm$json$Json$Decode$succeed(
				_Utils_Tuple2(x, y));
		} else {
			return $elm$json$Json$Decode$fail('Tile2 must be of length 2');
		}
	},
	$elm$json$Json$Decode$list($elm$json$Json$Decode$int));
var $author$project$Map$setOfTilesDecoder = A2(
	$elm$json$Json$Decode$map,
	$elm$core$Set$fromList,
	$elm$json$Json$Decode$list($author$project$Map$tileDecoder));
var $author$project$Map$mapDecoder = A2(
	$elm$json$Json$Decode$andThen,
	function (name) {
		return A2(
			$elm$json$Json$Decode$andThen,
			function (author) {
				return A2(
					$elm$json$Json$Decode$andThen,
					function (halfWidth) {
						return A2(
							$elm$json$Json$Decode$andThen,
							function (halfHeight) {
								return A2(
									$elm$json$Json$Decode$andThen,
									function (mainBases) {
										return A2(
											$elm$json$Json$Decode$andThen,
											function (smallBases) {
												return A2(
													$elm$json$Json$Decode$andThen,
													function (wallTiles) {
														return $elm$json$Json$Decode$succeed(
															{
																author: author,
																bases: $elm$core$Dict$fromList(
																	$elm$core$List$concat(
																		_List_fromArray(
																			[
																				A2(
																				$elm$core$List$map,
																				function (tile) {
																					return _Utils_Tuple2(tile, $author$project$Game$BaseMain);
																				},
																				mainBases),
																				A2(
																				$elm$core$List$map,
																				function (tile) {
																					return _Utils_Tuple2(tile, $author$project$Game$BaseSmall);
																				},
																				smallBases)
																			]))),
																halfHeight: halfHeight,
																halfWidth: halfWidth,
																name: name,
																wallTiles: wallTiles
															});
													},
													A2($elm$json$Json$Decode$field, 'wallTiles', $author$project$Map$setOfTilesDecoder));
											},
											A2(
												$elm$json$Json$Decode$field,
												'smallBases',
												$elm$json$Json$Decode$list($author$project$Map$tileDecoder)));
									},
									A2(
										$elm$json$Json$Decode$field,
										'mainBases',
										$elm$json$Json$Decode$list($author$project$Map$tileDecoder)));
							},
							A2($elm$json$Json$Decode$field, 'halfHeight', $elm$json$Json$Decode$int));
					},
					A2($elm$json$Json$Decode$field, 'halfWidth', $elm$json$Json$Decode$int));
			},
			A2($elm$json$Json$Decode$field, 'author', $elm$json$Json$Decode$string));
	},
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string));
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (result.$ === 'Ok') {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $author$project$Map$fromString = function (json) {
	return A2(
		$elm$core$Result$mapError,
		$elm$json$Json$Decode$errorToString,
		A2($elm$json$Json$Decode$decodeString, $author$project$Map$mapDecoder, json));
};
var $author$project$MapEditor$updateOnTextInput = F3(
	function (inputField, string, model) {
		var _v1 = $author$project$Map$fromString(string);
		if (_v1.$ === 'Err') {
			var message = _v1.a;
			return _Utils_update(
				model,
				{error: message});
		} else {
			var map = _v1.a;
			return _Utils_update(
				model,
				{error: ''});
		}
	});
var $author$project$MapEditor$update = F3(
	function (msg, shell, model) {
		switch (msg.$) {
			case 'Noop':
				return $author$project$MapEditor$noCmd(model);
			case 'OnMapClick':
				return $author$project$MapEditor$noCmd(model);
			case 'OnMouseMoves':
				var x = msg.a;
				var y = msg.b;
				return $author$project$MapEditor$noCmd(
					A3(
						$author$project$MapEditor$updateOnMouseMove,
						{x: x, y: y},
						shell,
						model));
			case 'OnMouseClick':
				var _v1 = model.editMode;
				switch (_v1.$) {
					case 'EditWalls':
						return $author$project$MapEditor$noCmd(model);
					case 'EditMainBase':
						return $author$project$MapEditor$noCmd(
							A2($author$project$MapEditor$updateBase, $author$project$Game$BaseMain, model));
					default:
						return $author$project$MapEditor$noCmd(
							A2($author$project$MapEditor$updateBase, $author$project$Game$BaseSmall, model));
				}
			case 'OnMouseButton':
				var isPressed = msg.a;
				return (!$author$project$MapEditor$isEditWalls(model.editMode)) ? $author$project$MapEditor$noCmd(model) : ((!isPressed) ? $author$project$MapEditor$noCmd(
					_Utils_update(
						model,
						{
							editMode: $author$project$MapEditor$EditWalls($elm$core$Maybe$Nothing)
						})) : (A2($author$project$MapEditor$isWithinMap, model.map, model.mouseTile) ? $author$project$MapEditor$noCmd(
					$author$project$MapEditor$updateWallAtMouseTile(
						_Utils_update(
							model,
							{
								editMode: $author$project$MapEditor$EditWalls(
									A2($elm$core$Set$member, model.mouseTile, model.map.wallTiles) ? $elm$core$Maybe$Just($author$project$MapEditor$WallRemove) : $elm$core$Maybe$Just($author$project$MapEditor$WallPlace))
							}))) : $author$project$MapEditor$noCmd(model)));
			case 'OnSwitchSymmetry':
				var symmetry = msg.a;
				return $author$project$MapEditor$noCmd(
					A2($author$project$MapEditor$updateOnSymmetry, symmetry, model));
			case 'OnChangeSize':
				var dimension = msg.a;
				var magnitudeAsString = msg.b;
				var _v2 = $elm$core$String$toInt(magnitudeAsString);
				if (_v2.$ === 'Nothing') {
					return $author$project$MapEditor$noCmd(model);
				} else {
					var n = _v2.a;
					return $author$project$MapEditor$noCmd(
						_Utils_update(
							model,
							{
								map: A3(
									$author$project$MapEditor$setDimension,
									dimension,
									A3($elm$core$Basics$clamp, $author$project$MapEditor$minSize, $author$project$MapEditor$maxSize, n),
									model.map)
							}));
				}
			case 'OnSwitchMode':
				var mode = msg.a;
				return $author$project$MapEditor$noCmd(
					_Utils_update(
						model,
						{editMode: mode}));
			case 'OnKeyPress':
				var keyName = msg.a;
				if (keyName === 'Escape') {
					return $author$project$MapEditor$noCmd(
						_Utils_update(
							model,
							{
								editMode: function () {
									var _v4 = model.editMode;
									switch (_v4.$) {
										case 'EditWalls':
											return $author$project$MapEditor$EditMainBase;
										case 'EditMainBase':
											return $author$project$MapEditor$EditSmallBases;
										default:
											return $author$project$MapEditor$EditWalls($elm$core$Maybe$Nothing);
									}
								}()
							}));
				} else {
					return $author$project$MapEditor$noCmd(model);
				}
			case 'OnTextInput':
				var inputField = msg.a;
				var string = msg.b;
				return $author$project$MapEditor$noCmd(
					A3(
						$author$project$MapEditor$updateOnTextInput,
						inputField,
						string,
						_Utils_update(
							model,
							{
								maybeFocus: $elm$core$Maybe$Just(
									_Utils_Tuple2(string, inputField))
							})));
			default:
				return $author$project$MapEditor$noCmd(
					_Utils_update(
						model,
						{maybeFocus: $elm$core$Maybe$Nothing}));
		}
	});
var $author$project$App$MenuButtonLabel = {$: 'MenuButtonLabel'};
var $author$project$App$MenuGamepads = function (a) {
	return {$: 'MenuGamepads', a: a};
};
var $author$project$App$MenuHowToPlay = {$: 'MenuHowToPlay'};
var $author$project$App$MenuMapSelection = {$: 'MenuMapSelection'};
var $author$project$App$MenuSettings = {$: 'MenuSettings'};
var $author$project$App$SubSceneGameplay = {$: 'SubSceneGameplay'};
var $author$project$App$menuNav = F2(
	function (menu, oldModel) {
		return $author$project$App$noCmd(
			_Utils_update(
				oldModel,
				{
					maybeMenu: $elm$core$Maybe$Just(menu)
				}));
	});
var $author$project$App$menuBack = function (model) {
	var _v0 = model.maybeMenu;
	_v0$2:
	while (true) {
		if (_v0.$ === 'Just') {
			switch (_v0.a.$) {
				case 'MenuMain':
					var _v1 = _v0.a;
					return $author$project$App$noCmd(
						_Utils_update(
							model,
							{maybeMenu: $elm$core$Maybe$Nothing}));
				case 'MenuImportMap':
					return A2($author$project$App$menuNav, $author$project$App$MenuMapSelection, model);
				default:
					break _v0$2;
			}
		} else {
			break _v0$2;
		}
	}
	return A2($author$project$App$menuNav, $author$project$App$MenuMain, model);
};
var $author$project$App$menuDemo = function (model) {
	var _v0 = $author$project$App$demoScene(model.seed);
	var scene = _v0.a;
	var seed = _v0.b;
	return $author$project$App$noCmd(
		_Utils_update(
			model,
			{scene: scene, seed: seed}));
};
var $author$project$MapEditor$init = function () {
	var map = {author: '', bases: $elm$core$Dict$empty, halfHeight: 10, halfWidth: 20, name: '', wallTiles: $elm$core$Set$empty};
	return {
		editMode: $author$project$MapEditor$EditWalls($elm$core$Maybe$Nothing),
		error: '',
		map: map,
		maybeFocus: $elm$core$Maybe$Nothing,
		mouseTile: _Utils_Tuple2(0, 0),
		symmetry: $author$project$MapEditor$SymmetryCentral
	};
}();
var $author$project$App$menuOpenMapEditor = function (model) {
	return $author$project$App$noCmd(
		_Utils_update(
			model,
			{
				maybeMenu: $elm$core$Maybe$Nothing,
				scene: $author$project$App$SceneMapEditor($author$project$MapEditor$init)
			}));
};
var $xarvh$elm_gamepad$Gamepad$Blob$emptyBlobFrame = {gamepads: _List_Nil, timestamp: 0};
var $xarvh$elm_gamepad$Gamepad$Blob$emptyBlob = _Utils_Tuple2($xarvh$elm_gamepad$Gamepad$Blob$emptyBlobFrame, $xarvh$elm_gamepad$Gamepad$Blob$emptyBlobFrame);
var $xarvh$elm_gamepad$Gamepad$remapInit = $xarvh$elm_gamepad$Gamepad$RemapModel(
	{blob: $xarvh$elm_gamepad$Gamepad$Blob$emptyBlob, maybeRemapping: $elm$core$Maybe$Nothing});
var $author$project$App$mainMenuButtons = function (model) {
	var isMapEditor = function () {
		var _v4 = model.scene;
		if (_v4.$ === 'SceneMapEditor') {
			return true;
		} else {
			return false;
		}
	}();
	var isDemo = function () {
		var _v2 = model.scene;
		if ((_v2.$ === 'SceneMain') && (_v2.a.$ === 'SubSceneDemo')) {
			var _v3 = _v2.a;
			return true;
		} else {
			return false;
		}
	}();
	var _v0 = function () {
		var _v1 = model.scene;
		if (_v1.$ === 'SceneMain') {
			var subScene = _v1.a;
			var scene = _v1.b;
			return _Utils_Tuple2(
				_Utils_eq(subScene, $author$project$App$SubSceneGameplay),
				!_Utils_eq(scene.game.maybeVictory, $elm$core$Maybe$Nothing));
		} else {
			return _Utils_Tuple2(false, false);
		}
	}();
	var isPlaying = _v0.a;
	var isFinished = _v0.b;
	return _List_fromArray(
		[
			{
			isVisible: isDemo,
			name: 'Play',
			update: $author$project$App$menuNav($author$project$App$MenuMapSelection),
			view: $author$project$App$MenuButtonLabel
		},
			{
			isVisible: isPlaying && isFinished,
			name: 'Play again',
			update: $author$project$App$menuNav($author$project$App$MenuMapSelection),
			view: $author$project$App$MenuButtonLabel
		},
			{isVisible: isPlaying && (!isFinished), name: 'Resume', update: $author$project$App$menuBack, view: $author$project$App$MenuButtonLabel},
			{
			isVisible: true,
			name: 'How to play',
			update: $author$project$App$menuNav($author$project$App$MenuHowToPlay),
			view: $author$project$App$MenuButtonLabel
		},
			{isVisible: isDemo, name: 'Map Editor', update: $author$project$App$menuOpenMapEditor, view: $author$project$App$MenuButtonLabel},
			{
			isVisible: true,
			name: 'Settings',
			update: $author$project$App$menuNav($author$project$App$MenuSettings),
			view: $author$project$App$MenuButtonLabel
		},
			{
			isVisible: true,
			name: 'Gamepads',
			update: $author$project$App$menuNav(
				$author$project$App$MenuGamepads($xarvh$elm_gamepad$Gamepad$remapInit)),
			view: $author$project$App$MenuButtonLabel
		},
			{isVisible: isPlaying || isMapEditor, name: 'Quit', update: $author$project$App$menuDemo, view: $author$project$App$MenuButtonLabel}
		]);
};
var $author$project$App$MenuButtonMap = function (a) {
	return {$: 'MenuButtonMap', a: a};
};
var $author$project$App$MenuImportMap = function (a) {
	return {$: 'MenuImportMap', a: a};
};
var $author$project$Game$GameModeTeamSelection = function (a) {
	return {$: 'GameModeTeamSelection', a: a};
};
var $author$project$Init$asTeamSelection = F2(
	function (seed, map) {
		var time = 0;
		var _v0 = A2($elm$random$Random$step, $author$project$ColorPattern$twoDifferent, seed).a;
		var leftTeamColor = _v0.a;
		var rightTeamColor = _v0.b;
		return _Utils_update(
			$author$project$Game$defaultGame,
			{
				halfHeight: map.halfHeight,
				halfWidth: map.halfWidth,
				leftTeam: A3($author$project$Game$newTeam, $author$project$Game$TeamLeft, leftTeamColor, $elm$core$Dict$empty),
				maybeTransition: $elm$core$Maybe$Just(
					{fade: $author$project$Game$GameFadeIn, start: time}),
				mode: $author$project$Game$GameModeTeamSelection(map),
				rightTeam: A3($author$project$Game$newTeam, $author$project$Game$TeamRight, rightTeamColor, $elm$core$Dict$empty),
				seed: seed,
				time: time
			});
	});
var $author$project$MainScene$initTeamSelection = F2(
	function (seed, map) {
		return {
			botStatesByKey: $elm$core$Dict$empty,
			fps: _List_fromArray(
				[1]),
			game: A2($author$project$Init$asTeamSelection, seed, map),
			previousInputStatesByKey: $elm$core$Dict$empty
		};
	});
var $author$project$App$updateStartGame = F2(
	function (map, model) {
		return $author$project$App$noCmd(
			_Utils_update(
				model,
				{
					maybeMenu: $elm$core$Maybe$Nothing,
					scene: A2(
						$author$project$App$SceneMain,
						$author$project$App$SubSceneGameplay,
						A2($author$project$MainScene$initTeamSelection, model.seed, map))
				}));
	});
var $author$project$App$mapSelectionMenuButtons = function (model) {
	var mapToButton = F2(
		function (index, map) {
			return {
				isVisible: true,
				name: 'map ' + $elm$core$String$fromInt(index),
				update: $author$project$App$updateStartGame(map),
				view: $author$project$App$MenuButtonMap(map)
			};
		});
	var maps = A2($elm$core$List$indexedMap, mapToButton, $author$project$OfficialMaps$maps);
	var importButton = {
		isVisible: true,
		name: 'Import...',
		update: $author$project$App$menuNav(
			$author$project$App$MenuImportMap(
				{
					importString: '',
					mapResult: $elm$core$Result$Err('')
				})),
		view: $author$project$App$MenuButtonLabel
	};
	return _Utils_ap(
		maps,
		_List_fromArray(
			[importButton]));
};
var $author$project$App$MenuButtonToggle = function (a) {
	return {$: 'MenuButtonToggle', a: a};
};
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(_Utils_Tuple0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$LocalStoragePort$localStorageSet = _Platform_outgoingPort(
	'localStorageSet',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'key',
					$elm$json$Json$Encode$string($.key)),
					_Utils_Tuple2(
					'value',
					$elm$json$Json$Encode$string($.value))
				]));
	});
var $author$project$LocalStoragePort$set = F2(
	function (key, value) {
		return $author$project$LocalStoragePort$localStorageSet(
			{key: key, value: value});
	});
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$json$Json$Encode$dict = F3(
	function (toKey, toValue, dictionary) {
		return _Json_wrap(
			A3(
				$elm$core$Dict$foldl,
				F3(
					function (key, value, obj) {
						return A3(
							_Json_addField,
							toKey(key),
							toValue(value),
							obj);
					}),
				_Json_emptyObject(_Utils_Tuple0),
				dictionary));
	});
var $elm$json$Json$Encode$int = _Json_wrap;
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $xarvh$elm_gamepad$Gamepad$encodeUserMappings = function (_v0) {
	var database = _v0.a;
	var encodeOriginType = function (t) {
		return $elm$json$Json$Encode$string(
			function () {
				if (t.$ === 'Axis') {
					return 'axis';
				} else {
					return 'button';
				}
			}());
	};
	var encodeOrigin = function (_v3) {
		var isReverse = _v3.a;
		var type_ = _v3.b;
		var index = _v3.c;
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'isReverse',
					$elm$json$Json$Encode$bool(isReverse)),
					_Utils_Tuple2(
					'type',
					encodeOriginType(type_)),
					_Utils_Tuple2(
					'index',
					$elm$json$Json$Encode$int(index))
				]));
	};
	var encodeMapping = function (mapping) {
		return A3($elm$json$Json$Encode$dict, $elm$core$Basics$identity, encodeOrigin, mapping);
	};
	var encodeTuples = function (_v1) {
		var _v2 = _v1.a;
		var index = _v2.a;
		var id = _v2.b;
		var mapping = _v1.b;
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'index',
					$elm$json$Json$Encode$int(index)),
					_Utils_Tuple2(
					'id',
					$elm$json$Json$Encode$string(id)),
					_Utils_Tuple2(
					'mapping',
					encodeMapping(mapping))
				]));
	};
	return A2(
		$elm$json$Json$Encode$list,
		encodeTuples,
		$elm$core$Dict$toList(database.byIndexAndId));
};
var $author$project$Config$encoder = function (config) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'gamepadDatabase',
				$xarvh$elm_gamepad$Gamepad$encodeUserMappings(config.gamepadDatabase)),
				_Utils_Tuple2(
				'useKeyboardAndMouse',
				$elm$json$Json$Encode$bool(config.useKeyboardAndMouse)),
				_Utils_Tuple2(
				'showFps',
				$elm$json$Json$Encode$bool(config.showFps))
			]));
};
var $author$project$Config$toString = function (config) {
	return A2(
		$elm$json$Json$Encode$encode,
		0,
		$author$project$Config$encoder(config));
};
var $author$project$App$updateConfig = F2(
	function (updater, model) {
		var oldConfig = model.config;
		var newConfig = updater(oldConfig);
		var cmd = _Utils_eq(newConfig, oldConfig) ? $elm$core$Platform$Cmd$none : A2(
			$author$project$LocalStoragePort$set,
			'config',
			$author$project$Config$toString(newConfig));
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{config: newConfig}),
			cmd);
	});
var $author$project$App$updateConfigFlag = F3(
	function (getter, setter, model) {
		return A2(
			$author$project$App$updateConfig,
			function (config) {
				return A2(
					setter,
					!getter(config),
					config);
			},
			model);
	});
var $author$project$App$menuSettingsButtons = function (model) {
	return _List_fromArray(
		[
			{
			isVisible: true,
			name: 'Use Keyboard & Mouse',
			update: A2(
				$author$project$App$updateConfigFlag,
				function ($) {
					return $.useKeyboardAndMouse;
				},
				F2(
					function (v, c) {
						return _Utils_update(
							c,
							{useKeyboardAndMouse: v});
					})),
			view: $author$project$App$MenuButtonToggle(
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.config;
					},
					function ($) {
						return $.useKeyboardAndMouse;
					}))
		},
			{
			isVisible: true,
			name: 'Show Frames per Second',
			update: A2(
				$author$project$App$updateConfigFlag,
				function ($) {
					return $.showFps;
				},
				F2(
					function (v, c) {
						return _Utils_update(
							c,
							{showFps: v});
					})),
			view: $author$project$App$MenuButtonToggle(
				A2(
					$elm$core$Basics$composeR,
					function ($) {
						return $.config;
					},
					function ($) {
						return $.showFps;
					}))
		}
		]);
};
var $author$project$App$menuButtons = function (model) {
	return A2(
		$elm$core$List$filter,
		function ($) {
			return $.isVisible;
		},
		function () {
			var _v0 = model.maybeMenu;
			_v0$4:
			while (true) {
				if (_v0.$ === 'Just') {
					switch (_v0.a.$) {
						case 'MenuMain':
							var _v1 = _v0.a;
							return $author$project$App$mainMenuButtons(model);
						case 'MenuMapSelection':
							var _v2 = _v0.a;
							return $author$project$App$mapSelectionMenuButtons(model);
						case 'MenuHowToPlay':
							var _v3 = _v0.a;
							return _List_fromArray(
								[
									{isVisible: true, name: 'Ok', update: $author$project$App$menuBack, view: $author$project$App$MenuButtonLabel}
								]);
						case 'MenuSettings':
							var _v4 = _v0.a;
							return $author$project$App$menuSettingsButtons(model);
						default:
							break _v0$4;
					}
				} else {
					break _v0$4;
				}
			}
			return _List_Nil;
		}());
};
var $author$project$App$findButton = F2(
	function (buttonName, model) {
		return A2(
			$elm_community$list_extra$List$Extra$find,
			function (button) {
				return _Utils_eq(button.name, buttonName);
			},
			$author$project$App$menuButtons(model));
	});
var $author$project$App$updateOnButton = F2(
	function (buttonName, model) {
		var _v0 = A2($author$project$App$findButton, buttonName, model);
		if (_v0.$ === 'Nothing') {
			return $author$project$App$noCmd(model);
		} else {
			var button = _v0.a;
			return button.update(model);
		}
	});
var $author$project$Unit$findMech = F2(
	function (inputKey, units) {
		findMech:
		while (true) {
			if (!units.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var u = units.a;
				var us = units.b;
				var _v1 = u.component;
				if (_v1.$ === 'UnitMech') {
					var mech = _v1.a;
					if (_Utils_eq(mech.inputKey, inputKey)) {
						return $elm$core$Maybe$Just(
							_Utils_Tuple2(u, mech));
					} else {
						var $temp$inputKey = inputKey,
							$temp$units = us;
						inputKey = $temp$inputKey;
						units = $temp$units;
						continue findMech;
					}
				} else {
					var $temp$inputKey = inputKey,
						$temp$units = us;
					inputKey = $temp$inputKey;
					units = $temp$units;
					continue findMech;
				}
			}
		}
	});
var $author$project$Game$AimAbsolute = function (a) {
	return {$: 'AimAbsolute', a: a};
};
var $author$project$Game$inputStateNeutral = {
	aim: $author$project$Game$AimAbsolute(
		A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0)),
	fire: false,
	move: A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
	rally: false,
	switchUnit: false,
	transform: false
};
var $author$project$Game$ToMech = {$: 'ToMech'};
var $author$project$Bot$Dummy$directionFromUnitToBase = F2(
	function (playerUnit, base) {
		return $elm_explorations$linear_algebra$Math$Vector2$normalize(
			_Utils_eq(base.position, playerUnit.position) ? $elm_explorations$linear_algebra$Math$Vector2$negate(base.position) : A2($elm_explorations$linear_algebra$Math$Vector2$sub, base.position, playerUnit.position));
	});
var $elm$random$Random$float = F2(
	function (a, b) {
		return $elm$random$Random$Generator(
			function (seed0) {
				var seed1 = $elm$random$Random$next(seed0);
				var range = $elm$core$Basics$abs(b - a);
				var n1 = $elm$random$Random$peel(seed1);
				var n0 = $elm$random$Random$peel(seed0);
				var lo = (134217727 & n1) * 1.0;
				var hi = (67108863 & n0) * 1.0;
				var val = ((hi * 134217728.0) + lo) / 9007199254740992.0;
				var scaled = (val * range) + a;
				return _Utils_Tuple2(
					scaled,
					$elm$random$Random$next(seed1));
			});
	});
var $elm$core$Basics$cos = _Basics_cos;
var $elm$core$Basics$sin = _Basics_sin;
var $author$project$Game$rotateVector = F2(
	function (angle, v) {
		var sinA = $elm$core$Basics$sin(-angle);
		var cosA = $elm$core$Basics$cos(angle);
		var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v);
		var x = _v0.x;
		var y = _v0.y;
		return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, (x * cosA) - (y * sinA), (x * sinA) + (y * cosA));
	});
var $elm$core$Basics$sqrt = _Basics_sqrt;
var $author$project$Bot$Dummy$moveToTargetBase = F5(
	function (playerUnit, playerMech, state, game, base) {
		var safeDistance = 4 + $elm$core$Basics$sqrt(
			$elm$core$List$length(
				A2(
					$elm$core$List$filter,
					function (u) {
						return (!_Utils_eq(u.maybeTeamId, playerUnit.maybeTeamId)) && (A2($author$project$Game$vectorDistance, u.position, base.position) < 6);
					},
					$elm$core$Dict$values(game.unitById))));
		if (_Utils_cmp(
			A2($author$project$Game$vectorDistance, playerUnit.position, base.position),
			safeDistance) > 0) {
			return _Utils_Tuple2(
				state,
				{
					move: A2($author$project$Bot$Dummy$directionFromUnitToBase, playerUnit, base),
					rally: false,
					transform: !_Utils_eq(playerMech.transformingTo, $author$project$Game$ToFlyer)
				});
		} else {
			var _v0 = ((game.time - state.lastChange) < 0.2) ? _Utils_Tuple2(false, state.randomSeed) : A2(
				$elm$random$Random$step,
				A2(
					$elm$random$Random$map,
					function (n) {
						return n < 0.03;
					},
					A2($elm$random$Random$float, 0, 1)),
				state.randomSeed);
			var doChangeDirection = _v0.a;
			var seed = _v0.b;
			var _v1 = doChangeDirection ? _Utils_Tuple2(-state.speedAroundBase, game.time) : _Utils_Tuple2(state.speedAroundBase, state.lastChange);
			var speedAroundBase = _v1.a;
			var lastChange = _v1.b;
			return _Utils_Tuple2(
				_Utils_update(
					state,
					{lastChange: lastChange, randomSeed: seed, speedAroundBase: speedAroundBase}),
				{
					move: A2(
						$author$project$Game$rotateVector,
						(state.speedAroundBase * $elm$core$Basics$pi) / 2,
						A2($author$project$Bot$Dummy$directionFromUnitToBase, playerUnit, base)),
					rally: true,
					transform: !_Utils_eq(playerMech.transformingTo, $author$project$Game$ToMech)
				});
		}
	});
var $author$project$Bot$Dummy$shootEnemies = F2(
	function (playerUnit, game) {
		var closeEnough = function (unit) {
			var distance = A2($author$project$Game$vectorDistance, unit.position, playerUnit.position);
			return (distance <= 8) ? $elm$core$Maybe$Just(
				_Utils_Tuple2(unit, distance)) : $elm$core$Maybe$Nothing;
		};
		var maybeUnitAndDistance = A2(
			$elm_community$list_extra$List$Extra$minimumBy,
			$elm$core$Tuple$second,
			A2(
				$elm$core$List$filterMap,
				closeEnough,
				A2(
					$elm$core$List$filter,
					function (u) {
						return !_Utils_eq(u.maybeTeamId, playerUnit.maybeTeamId);
					},
					$elm$core$Dict$values(game.unitById))));
		if (maybeUnitAndDistance.$ === 'Nothing') {
			return _Utils_Tuple2(
				$author$project$Game$AimAbsolute(
					A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0)),
				false);
		} else {
			var _v1 = maybeUnitAndDistance.a;
			var targetUnit = _v1.a;
			var distance = _v1.b;
			return _Utils_Tuple2(
				$author$project$Game$AimAbsolute(
					$elm_explorations$linear_algebra$Math$Vector2$normalize(
						A2($elm_explorations$linear_algebra$Math$Vector2$sub, targetUnit.position, playerUnit.position))),
				true);
		}
	});
var $author$project$Bot$Dummy$attackBase = F3(
	function (state, game, targetBase) {
		var _v0 = A2(
			$author$project$Unit$findMech,
			state.inputKey,
			$elm$core$Dict$values(game.unitById));
		if (_v0.$ === 'Nothing') {
			return _Utils_Tuple2(state, $author$project$Game$inputStateNeutral);
		} else {
			var _v1 = _v0.a;
			var playerUnit = _v1.a;
			var playerMech = _v1.b;
			var _v2 = A5($author$project$Bot$Dummy$moveToTargetBase, playerUnit, playerMech, state, game, targetBase);
			var newState = _v2.a;
			var transform = _v2.b.transform;
			var rally = _v2.b.rally;
			var move = _v2.b.move;
			var _v3 = A2($author$project$Bot$Dummy$shootEnemies, playerUnit, game);
			var aim = _v3.a;
			var fire = _v3.b;
			return _Utils_Tuple2(
				newState,
				{aim: aim, fire: fire, move: move, rally: rally && (!state.hasHumanAlly), switchUnit: false, transform: transform});
		}
	});
var $author$project$Game$angleToVector = function (angle) {
	return A2(
		$elm_explorations$linear_algebra$Math$Vector2$vec2,
		$elm$core$Basics$sin(angle),
		$elm$core$Basics$cos(angle));
};
var $author$project$Bot$Dummy$gloat = F2(
	function (game, state) {
		return _Utils_Tuple2(
			((game.time - state.lastChange) < 0.01) ? state : _Utils_update(
				state,
				{lastChange: game.time, speedAroundBase: state.speedAroundBase + 0.1}),
			_Utils_update(
				$author$project$Game$inputStateNeutral,
				{
					aim: $author$project$Game$AimAbsolute(
						$author$project$Game$angleToVector(state.speedAroundBase)),
					fire: true,
					transform: true
				}));
	});
var $author$project$Bot$Dummy$unitsNotHealthy = F2(
	function (ids, game) {
		return A2(
			$elm$core$List$any,
			function (u) {
				return u.integrity < 1;
			},
			A2(
				$elm$core$List$filterMap,
				function (id) {
					return A2($elm$core$Dict$get, id, game.unitById);
				},
				$elm$core$Set$toList(ids)));
	});
var $author$project$Bot$Dummy$pickTargetBase = F3(
	function (game, state, baseIds) {
		pickTargetBase:
		while (true) {
			if (!baseIds.b) {
				return $elm$core$Maybe$Nothing;
			} else {
				var baseId = baseIds.a;
				var bs = baseIds.b;
				var _v1 = A2($elm$core$Dict$get, baseId, game.baseById);
				if (_v1.$ === 'Nothing') {
					var $temp$game = game,
						$temp$state = state,
						$temp$baseIds = bs;
					game = $temp$game;
					state = $temp$state;
					baseIds = $temp$baseIds;
					continue pickTargetBase;
				} else {
					var base = _v1.a;
					var _v2 = base.maybeOccupied;
					if (_v2.$ === 'Nothing') {
						return $elm$core$Maybe$Just(base);
					} else {
						var occupied = _v2.a;
						if (!_Utils_eq(
							occupied.maybeTeamId,
							$elm$core$Maybe$Just(state.teamId))) {
							return $elm$core$Maybe$Just(base);
						} else {
							if (!occupied.isActive) {
								return $elm$core$Maybe$Just(base);
							} else {
								if (A2($author$project$Bot$Dummy$unitsNotHealthy, occupied.unitIds, game)) {
									return $elm$core$Maybe$Just(base);
								} else {
									var $temp$game = game,
										$temp$state = state,
										$temp$baseIds = bs;
									game = $temp$game;
									state = $temp$state;
									baseIds = $temp$baseIds;
									continue pickTargetBase;
								}
							}
						}
					}
				}
			}
		}
	});
var $author$project$Bot$Dummy$update = F2(
	function (game, state) {
		var _v0 = A3($author$project$Bot$Dummy$pickTargetBase, game, state, state.basesSortedByPriority);
		if (_v0.$ === 'Nothing') {
			return A2($author$project$Bot$Dummy$gloat, game, state);
		} else {
			var targetBase = _v0.a;
			return A3($author$project$Bot$Dummy$attackBase, state, game, targetBase);
		}
	});
var $author$project$MainScene$allBotsThink = function (model) {
	var foldBot = F3(
		function (inputSourceKey, oldState, _v1) {
			var statesByKey = _v1.a;
			var inputsByKey = _v1.b;
			var _v0 = A2($author$project$Bot$Dummy$update, model.game, oldState);
			var newState = _v0.a;
			var input = _v0.b;
			return _Utils_Tuple2(
				A3($elm$core$Dict$insert, inputSourceKey, newState, statesByKey),
				A3($elm$core$Dict$insert, inputSourceKey, input, inputsByKey));
		});
	return A3(
		$elm$core$Dict$foldl,
		foldBot,
		_Utils_Tuple2($elm$core$Dict$empty, $elm$core$Dict$empty),
		model.botStatesByKey);
};
var $xarvh$elm_gamepad$Gamepad$animationFrameDelta = function (_v0) {
	var currentFrame = _v0.a;
	var previousFrame = _v0.b;
	return currentFrame.timestamp - previousFrame.timestamp;
};
var $author$project$MainScene$addPlayers = F2(
	function (botClasses, team) {
		var bots = $elm$core$Dict$fromList(
			A2(
				$elm$core$List$indexedMap,
				F2(
					function (index, mechClass) {
						return _Utils_Tuple2(
							A2($author$project$MainScene$inputBot, team.id, index),
							mechClass);
					}),
				botClasses));
		return _Utils_update(
			team,
			{
				mechClassByInputKey: A2($elm$core$Dict$union, team.mechClassByInputKey, bots)
			});
	});
var $author$project$MainScene$addBots = function (model) {
	var right = model.game.rightTeam.mechClassByInputKey;
	var left = model.game.leftTeam.mechClassByInputKey;
	var teamsSize = A2(
		$elm$core$Basics$max,
		$elm$core$Dict$size(left),
		$elm$core$Dict$size(right));
	var _v0 = function (generator) {
		return A2($elm$random$Random$step, generator, model.game.seed);
	}(
		A2(
			$elm$random$Random$pair,
			A2(
				$elm$random$Random$list,
				teamsSize - $elm$core$Dict$size(left),
				$author$project$Mech$classGenerator),
			A2(
				$elm$random$Random$list,
				teamsSize - $elm$core$Dict$size(right),
				$author$project$Mech$classGenerator)));
	var _v1 = _v0.a;
	var leftBots = _v1.a;
	var rightBots = _v1.b;
	var seed = _v0.b;
	var game = function (g) {
		return _Utils_update(
			g,
			{seed: seed});
	}(
		A2(
			$author$project$Game$updateTeam,
			A2($author$project$MainScene$addPlayers, rightBots, model.game.rightTeam),
			A2(
				$author$project$Game$updateTeam,
				A2($author$project$MainScene$addPlayers, leftBots, model.game.leftTeam),
				model.game)));
	return _Utils_update(
		model,
		{game: game});
};
var $author$project$MainScene$applyOutcome = F2(
	function (outcome, _v0) {
		var model = _v0.a;
		var cmds = _v0.b;
		if (outcome.$ === 'OutcomeCanAddBots') {
			return _Utils_Tuple2(
				$author$project$MainScene$addBots(model),
				cmds);
		} else {
			return _Utils_Tuple2(
				$author$project$MainScene$initBots(model),
				cmds);
		}
	});
var $xarvh$elm_gamepad$Gamepad$RightStickPress = {$: 'RightStickPress'};
var $elm_explorations$linear_algebra$Math$Vector2$fromRecord = _MJS_v2fromRecord;
var $xarvh$elm_gamepad$Gamepad$getIndex = function (_v0) {
	var mapping = _v0.a;
	var currentFrame = _v0.b;
	var previousFrame = _v0.c;
	return currentFrame.index;
};
var $xarvh$elm_gamepad$Gamepad$axisToButton = function (n) {
	return n > 0.6;
};
var $elm$core$Array$getHelp = F3(
	function (shift, index, tree) {
		getHelp:
		while (true) {
			var pos = $elm$core$Array$bitMask & (index >>> shift);
			var _v0 = A2($elm$core$Elm$JsArray$unsafeGet, pos, tree);
			if (_v0.$ === 'SubTree') {
				var subTree = _v0.a;
				var $temp$shift = shift - $elm$core$Array$shiftStep,
					$temp$index = index,
					$temp$tree = subTree;
				shift = $temp$shift;
				index = $temp$index;
				tree = $temp$tree;
				continue getHelp;
			} else {
				var values = _v0.a;
				return A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, values);
			}
		}
	});
var $elm$core$Array$get = F2(
	function (index, _v0) {
		var len = _v0.a;
		var startShift = _v0.b;
		var tree = _v0.c;
		var tail = _v0.d;
		return ((index < 0) || (_Utils_cmp(index, len) > -1)) ? $elm$core$Maybe$Nothing : ((_Utils_cmp(
			index,
			$elm$core$Array$tailIndex(len)) > -1) ? $elm$core$Maybe$Just(
			A2($elm$core$Elm$JsArray$unsafeGet, $elm$core$Array$bitMask & index, tail)) : $elm$core$Maybe$Just(
			A3($elm$core$Array$getHelp, startShift, index, tree)));
	});
var $xarvh$elm_gamepad$Gamepad$mappingToOrigin = F2(
	function (destination, mapping) {
		return A2(
			$elm$core$Dict$get,
			$xarvh$elm_gamepad$Gamepad$destinationToString(destination),
			mapping);
	});
var $xarvh$elm_gamepad$Gamepad$reverseAxis = F2(
	function (isReverse, n) {
		return isReverse ? (-n) : n;
	});
var $xarvh$elm_gamepad$Gamepad$getAsBool = F3(
	function (destination, mapping, frame) {
		var _v0 = A2($xarvh$elm_gamepad$Gamepad$mappingToOrigin, destination, mapping);
		if (_v0.$ === 'Nothing') {
			return false;
		} else {
			if (_v0.a.b.$ === 'Axis') {
				var _v1 = _v0.a;
				var isReverse = _v1.a;
				var _v2 = _v1.b;
				var index = _v1.c;
				return $xarvh$elm_gamepad$Gamepad$axisToButton(
					A2(
						$xarvh$elm_gamepad$Gamepad$reverseAxis,
						isReverse,
						A2(
							$elm$core$Maybe$withDefault,
							0,
							A2($elm$core$Array$get, index, frame.axes))));
			} else {
				var _v3 = _v0.a;
				var isReverse = _v3.a;
				var _v4 = _v3.b;
				var index = _v3.c;
				return A2(
					$elm$core$Maybe$withDefault,
					false,
					A2(
						$elm$core$Maybe$map,
						$elm$core$Tuple$first,
						A2($elm$core$Array$get, index, frame.buttons)));
			}
		}
	});
var $xarvh$elm_gamepad$Gamepad$isPressed = F2(
	function (_v0, digital) {
		var mapping = _v0.a;
		var currentFrame = _v0.b;
		var previousFrame = _v0.c;
		return A3($xarvh$elm_gamepad$Gamepad$getAsBool, digital, mapping, currentFrame);
	});
var $xarvh$elm_gamepad$Gamepad$LeftX = {$: 'LeftX'};
var $xarvh$elm_gamepad$Gamepad$LeftY = {$: 'LeftY'};
var $xarvh$elm_gamepad$Gamepad$LeftTrigger = {$: 'LeftTrigger'};
var $xarvh$elm_gamepad$Gamepad$One = function (a) {
	return {$: 'One', a: a};
};
var $xarvh$elm_gamepad$Gamepad$Two = F2(
	function (a, b) {
		return {$: 'Two', a: a, b: b};
	});
var $xarvh$elm_gamepad$Gamepad$analogToDestination = function (analog) {
	switch (analog.$) {
		case 'LeftX':
			return A2($xarvh$elm_gamepad$Gamepad$Two, $xarvh$elm_gamepad$Gamepad$LeftStickLeft, $xarvh$elm_gamepad$Gamepad$LeftStickRight);
		case 'LeftY':
			return A2($xarvh$elm_gamepad$Gamepad$Two, $xarvh$elm_gamepad$Gamepad$LeftStickDown, $xarvh$elm_gamepad$Gamepad$LeftStickUp);
		case 'LeftTriggerAnalog':
			return $xarvh$elm_gamepad$Gamepad$One($xarvh$elm_gamepad$Gamepad$LeftTrigger);
		case 'RightX':
			return A2($xarvh$elm_gamepad$Gamepad$Two, $xarvh$elm_gamepad$Gamepad$RightStickLeft, $xarvh$elm_gamepad$Gamepad$RightStickRight);
		case 'RightY':
			return A2($xarvh$elm_gamepad$Gamepad$Two, $xarvh$elm_gamepad$Gamepad$RightStickDown, $xarvh$elm_gamepad$Gamepad$RightStickUp);
		default:
			return $xarvh$elm_gamepad$Gamepad$One($xarvh$elm_gamepad$Gamepad$RightTrigger);
	}
};
var $xarvh$elm_gamepad$Gamepad$getAsFloat = F3(
	function (destination, mapping, frame) {
		var _v0 = A2($xarvh$elm_gamepad$Gamepad$mappingToOrigin, destination, mapping);
		if (_v0.$ === 'Nothing') {
			return 0;
		} else {
			if (_v0.a.b.$ === 'Axis') {
				var _v1 = _v0.a;
				var isReverse = _v1.a;
				var _v2 = _v1.b;
				var index = _v1.c;
				return A2(
					$xarvh$elm_gamepad$Gamepad$reverseAxis,
					isReverse,
					A2(
						$elm$core$Maybe$withDefault,
						0,
						A2($elm$core$Array$get, index, frame.axes)));
			} else {
				var _v3 = _v0.a;
				var isReverse = _v3.a;
				var _v4 = _v3.b;
				var index = _v3.c;
				return A2(
					$elm$core$Maybe$withDefault,
					0,
					A2(
						$elm$core$Maybe$map,
						$elm$core$Tuple$second,
						A2($elm$core$Array$get, index, frame.buttons)));
			}
		}
	});
var $xarvh$elm_gamepad$Gamepad$getAxis = F4(
	function (negativeDestination, positiveDestination, mapping, frame) {
		var positive = A3($xarvh$elm_gamepad$Gamepad$getAsFloat, positiveDestination, mapping, frame);
		var negative = A3($xarvh$elm_gamepad$Gamepad$getAsFloat, negativeDestination, mapping, frame);
		return _Utils_eq(positive, -negative) ? positive : (positive - negative);
	});
var $xarvh$elm_gamepad$Gamepad$value = F2(
	function (_v0, analog) {
		var mapping = _v0.a;
		var currentFrame = _v0.b;
		var previousFrame = _v0.c;
		var _v1 = $xarvh$elm_gamepad$Gamepad$analogToDestination(analog);
		if (_v1.$ === 'One') {
			var positive = _v1.a;
			return A3($xarvh$elm_gamepad$Gamepad$getAsFloat, positive, mapping, currentFrame);
		} else {
			var negative = _v1.a;
			var positive = _v1.b;
			return A4($xarvh$elm_gamepad$Gamepad$getAxis, negative, positive, mapping, currentFrame);
		}
	});
var $xarvh$elm_gamepad$Gamepad$leftStickPosition = function (pad) {
	return {
		x: A2($xarvh$elm_gamepad$Gamepad$value, pad, $xarvh$elm_gamepad$Gamepad$LeftX),
		y: A2($xarvh$elm_gamepad$Gamepad$value, pad, $xarvh$elm_gamepad$Gamepad$LeftY)
	};
};
var $xarvh$elm_gamepad$Gamepad$RightX = {$: 'RightX'};
var $xarvh$elm_gamepad$Gamepad$RightY = {$: 'RightY'};
var $xarvh$elm_gamepad$Gamepad$rightStickPosition = function (pad) {
	return {
		x: A2($xarvh$elm_gamepad$Gamepad$value, pad, $xarvh$elm_gamepad$Gamepad$RightX),
		y: A2($xarvh$elm_gamepad$Gamepad$value, pad, $xarvh$elm_gamepad$Gamepad$RightY)
	};
};
var $elm_explorations$linear_algebra$Math$Vector2$length = _MJS_v2length;
var $author$project$MainScene$threshold = function (v) {
	return ($elm_explorations$linear_algebra$Math$Vector2$length(v) > 0.1) ? v : A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0);
};
var $author$project$MainScene$gamepadToInput = function (gamepad) {
	var isPressed = $xarvh$elm_gamepad$Gamepad$isPressed(gamepad);
	return _Utils_Tuple2(
		'gamepad ' + $elm$core$String$fromInt(
			$xarvh$elm_gamepad$Gamepad$getIndex(gamepad)),
		{
			aim: $author$project$Game$AimAbsolute(
				$author$project$MainScene$threshold(
					$elm_explorations$linear_algebra$Math$Vector2$fromRecord(
						$xarvh$elm_gamepad$Gamepad$rightStickPosition(gamepad)))),
			fire: isPressed($xarvh$elm_gamepad$Gamepad$RightBumper) || (isPressed($xarvh$elm_gamepad$Gamepad$RightTrigger) || isPressed($xarvh$elm_gamepad$Gamepad$RightStickPress)),
			move: $author$project$MainScene$threshold(
				$elm_explorations$linear_algebra$Math$Vector2$fromRecord(
					$xarvh$elm_gamepad$Gamepad$leftStickPosition(gamepad))),
			rally: isPressed($xarvh$elm_gamepad$Gamepad$B),
			switchUnit: false,
			transform: isPressed($xarvh$elm_gamepad$Gamepad$A)
		});
};
var $xarvh$elm_gamepad$Gamepad$Gamepad = F3(
	function (a, b, c) {
		return {$: 'Gamepad', a: a, b: b, c: c};
	});
var $xarvh$elm_gamepad$Gamepad$Back = {$: 'Back'};
var $xarvh$elm_gamepad$Gamepad$DpadDown = {$: 'DpadDown'};
var $xarvh$elm_gamepad$Gamepad$DpadLeft = {$: 'DpadLeft'};
var $xarvh$elm_gamepad$Gamepad$DpadRight = {$: 'DpadRight'};
var $xarvh$elm_gamepad$Gamepad$DpadUp = {$: 'DpadUp'};
var $xarvh$elm_gamepad$Gamepad$Home = {$: 'Home'};
var $xarvh$elm_gamepad$Gamepad$LeftBumper = {$: 'LeftBumper'};
var $xarvh$elm_gamepad$Gamepad$LeftStickPress = {$: 'LeftStickPress'};
var $xarvh$elm_gamepad$Gamepad$X = {$: 'X'};
var $xarvh$elm_gamepad$Gamepad$Y = {$: 'Y'};
var $xarvh$elm_gamepad$Gamepad$standardGamepadMapping = $xarvh$elm_gamepad$Gamepad$pairsToMapping(
	A2(
		$elm$core$List$map,
		function (_v0) {
			var a = _v0.a;
			var b = _v0.b;
			return _Utils_Tuple2(b, a);
		},
		_List_fromArray(
			[
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$A,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 0)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$B,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 1)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$X,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 2)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$Y,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 3)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$Start,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 9)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$Back,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 8)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$Home,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 16)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftStickLeft,
				A3($xarvh$elm_gamepad$Gamepad$Origin, true, $xarvh$elm_gamepad$Gamepad$Axis, 0)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftStickRight,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Axis, 0)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftStickUp,
				A3($xarvh$elm_gamepad$Gamepad$Origin, true, $xarvh$elm_gamepad$Gamepad$Axis, 1)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftStickDown,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Axis, 1)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftStickPress,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 10)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftBumper,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 4)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$LeftTrigger,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 6)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightStickLeft,
				A3($xarvh$elm_gamepad$Gamepad$Origin, true, $xarvh$elm_gamepad$Gamepad$Axis, 2)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightStickRight,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Axis, 2)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightStickUp,
				A3($xarvh$elm_gamepad$Gamepad$Origin, true, $xarvh$elm_gamepad$Gamepad$Axis, 3)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightStickDown,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Axis, 3)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightStickPress,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 11)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightBumper,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 5)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$RightTrigger,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 7)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$DpadUp,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 12)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$DpadDown,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 13)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$DpadLeft,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 14)),
				_Utils_Tuple2(
				$xarvh$elm_gamepad$Gamepad$DpadRight,
				A3($xarvh$elm_gamepad$Gamepad$Origin, false, $xarvh$elm_gamepad$Gamepad$Button, 15))
			])));
var $xarvh$elm_gamepad$Gamepad$getGamepadMapping = F2(
	function (_v0, frame) {
		var database = _v0.a;
		var _v1 = A2(
			$elm$core$Dict$get,
			_Utils_Tuple2(frame.index, frame.id),
			database.byIndexAndId);
		if (_v1.$ === 'Just') {
			var mapping = _v1.a;
			return $elm$core$Maybe$Just(mapping);
		} else {
			return (frame.mapping === 'standard') ? $elm$core$Maybe$Just($xarvh$elm_gamepad$Gamepad$standardGamepadMapping) : A2($elm$core$Dict$get, frame.id, database.byId);
		}
	});
var $elm$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		if (ma.$ === 'Nothing') {
			return $elm$core$Maybe$Nothing;
		} else {
			var a = ma.a;
			if (mb.$ === 'Nothing') {
				return $elm$core$Maybe$Nothing;
			} else {
				var b = mb.a;
				return $elm$core$Maybe$Just(
					A2(func, a, b));
			}
		}
	});
var $xarvh$elm_gamepad$Gamepad$getGamepads = F2(
	function (userMappings, _v0) {
		var currentBlobFrame = _v0.a;
		var previousBlobFrame = _v0.b;
		var getGamepad = function (currentGamepadFrame) {
			return A3(
				$elm$core$Maybe$map2,
				F2(
					function (previousGamepadFrame, mapping) {
						return A3($xarvh$elm_gamepad$Gamepad$Gamepad, mapping, currentGamepadFrame, previousGamepadFrame);
					}),
				A2(
					$elm_community$list_extra$List$Extra$find,
					function (prev) {
						return _Utils_eq(prev.index, currentGamepadFrame.index);
					},
					previousBlobFrame.gamepads),
				A2($xarvh$elm_gamepad$Gamepad$getGamepadMapping, userMappings, currentGamepadFrame));
		};
		return A2($elm$core$List$filterMap, getGamepad, currentBlobFrame.gamepads);
	});
var $author$project$Game$AimRelative = function (a) {
	return {$: 'AimRelative', a: a};
};
var $author$project$Input$arrowsAndWasd = function (pressedKeys) {
	var fold = F2(
		function (_v0, accum) {
			var v = _v0.a;
			var names = _v0.b;
			return A2(
				$elm$core$List$any,
				function (n) {
					return A2($elm$core$Set$member, n, pressedKeys);
				},
				names) ? A2($elm_explorations$linear_algebra$Math$Vector2$add, v, accum) : accum;
		});
	return A3(
		$elm$core$List$foldl,
		fold,
		A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0),
		_List_fromArray(
			[
				_Utils_Tuple2(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 1),
				_List_fromArray(
					['W', 'ArrowUp'])),
				_Utils_Tuple2(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, -1),
				_List_fromArray(
					['S', 'ArrowDown'])),
				_Utils_Tuple2(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 0),
				_List_fromArray(
					['D', 'ArrowRight'])),
				_Utils_Tuple2(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -1, 0),
				_List_fromArray(
					['A', 'ArrowLeft']))
			]));
};
var $author$project$View$Game$tilesToViewport = F2(
	function (_v0, viewport) {
		var halfWidth = _v0.halfWidth;
		var halfHeight = _v0.halfHeight;
		return A3($author$project$SplitScreen$fitWidthAndHeight, halfWidth * 2, halfHeight * 2, viewport);
	});
var $author$project$MainScene$getKeyboardAndMouseInputState = F2(
	function (shell, model) {
		var move = $author$project$Input$arrowsAndWasd(shell.pressedKeys);
		var mouseAim = $author$project$Game$AimRelative(
			A2(
				$elm_explorations$linear_algebra$Math$Vector2$scale,
				A2($author$project$View$Game$tilesToViewport, model.game, shell.viewport),
				function (_v0) {
					var xx = _v0.a;
					var yy = _v0.b;
					return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, xx, yy);
				}(
					A2($author$project$SplitScreen$mouseScreenToViewport, shell.mousePosition, shell.viewport))));
		var isPressed = function (key) {
			return A2($elm$core$Set$member, key, shell.pressedKeys);
		};
		return {
			aim: mouseAim,
			fire: shell.mouseIsPressed,
			move: move,
			rally: isPressed('Q'),
			switchUnit: isPressed(' '),
			transform: isPressed('E')
		};
	});
var $author$project$MainScene$inputKeyboardAndMouseKey = 'keyboard+mouse';
var $elm$core$Dict$map = F2(
	function (func, dict) {
		if (dict.$ === 'RBEmpty_elm_builtin') {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				A2(func, key, value),
				A2($elm$core$Dict$map, func, left),
				A2($elm$core$Dict$map, func, right));
		}
	});
var $elm$core$Basics$isNaN = _Basics_isNaN;
var $elm$core$Debug$log = _Debug_log;
var $author$project$MainScene$sanitizeInputState = F2(
	function (inputKey, inputState) {
		var vecNoNaN = function (v) {
			var _v1 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v);
			var x = _v1.x;
			var y = _v1.y;
			if ($elm$core$Basics$isNaN(x) || $elm$core$Basics$isNaN(y)) {
				var unused = A2(
					$elm$core$Debug$log,
					'input is NaN',
					_Utils_Tuple2(inputKey, inputState));
				return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0);
			} else {
				return v;
			}
		};
		var aim = function () {
			var _v0 = inputState.aim;
			if (_v0.$ === 'AimAbsolute') {
				var v = _v0.a;
				return $author$project$Game$AimAbsolute(
					vecNoNaN(v));
			} else {
				var v = _v0.a;
				return $author$project$Game$AimRelative(
					vecNoNaN(v));
			}
		}();
		return _Utils_update(
			inputState,
			{
				aim: aim,
				move: vecNoNaN(inputState.move)
			});
	});
var $elm$core$Dict$singleton = F2(
	function (key, value) {
		return A5($elm$core$Dict$RBNode_elm_builtin, $elm$core$Dict$Black, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
	});
var $author$project$Update$applyDelta = F2(
	function (delta, _v0) {
		applyDelta:
		while (true) {
			var game = _v0.a;
			var outcomes = _v0.b;
			switch (delta.$) {
				case 'DeltaNone':
					return _Utils_Tuple2(game, outcomes);
				case 'DeltaList':
					var list = delta.a;
					return A3(
						$elm$core$List$foldl,
						$author$project$Update$applyDelta,
						_Utils_Tuple2(game, outcomes),
						list);
				case 'DeltaGame':
					var f = delta.a;
					return _Utils_Tuple2(
						f(game),
						outcomes);
				case 'DeltaOutcome':
					var o = delta.a;
					return _Utils_Tuple2(
						game,
						A2($elm$core$List$cons, o, outcomes));
				case 'DeltaLater':
					var delay = delta.a;
					var later = delta.b;
					var laters = A2(
						$elm$core$List$cons,
						_Utils_Tuple2(game.time + delay, later),
						game.laters);
					return _Utils_Tuple2(
						_Utils_update(
							game,
							{laters: laters}),
						outcomes);
				case 'DeltaRandom':
					var deltaGenerator = delta.a;
					var _v2 = A2($elm$random$Random$step, deltaGenerator, game.seed);
					var d = _v2.a;
					var seed = _v2.b;
					var $temp$delta = d,
						$temp$_v0 = _Utils_Tuple2(
						_Utils_update(
							game,
							{seed: seed}),
						outcomes);
					delta = $temp$delta;
					_v0 = $temp$_v0;
					continue applyDelta;
				default:
					var gameToDelta = delta.a;
					var $temp$delta = gameToDelta(game),
						$temp$_v0 = _Utils_Tuple2(game, outcomes);
					delta = $temp$delta;
					_v0 = $temp$_v0;
					continue applyDelta;
			}
		}
	});
var $author$project$Update$applyGameDeltas = F2(
	function (game, deltas) {
		return A3(
			$elm$core$List$foldl,
			$author$project$Update$applyDelta,
			_Utils_Tuple2(game, _List_Nil),
			deltas);
	});
var $author$project$Game$DeltaGame = function (a) {
	return {$: 'DeltaGame', a: a};
};
var $author$project$Game$deltaGame = $author$project$Game$DeltaGame;
var $author$project$Game$DeltaList = function (a) {
	return {$: 'DeltaList', a: a};
};
var $author$project$Game$deltaList = $author$project$Game$DeltaList;
var $author$project$Game$DeltaNone = {$: 'DeltaNone'};
var $author$project$Game$deltaNone = $author$project$Game$DeltaNone;
var $elm$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _v0) {
				var trues = _v0.a;
				var falses = _v0.b;
				return pred(x) ? _Utils_Tuple2(
					A2($elm$core$List$cons, x, trues),
					falses) : _Utils_Tuple2(
					trues,
					A2($elm$core$List$cons, x, falses));
			});
		return A3(
			$elm$core$List$foldr,
			step,
			_Utils_Tuple2(_List_Nil, _List_Nil),
			list);
	});
var $elm$core$Basics$pow = _Basics_pow;
var $author$project$Update$screenShake = F2(
	function (dt, game) {
		var removeDecimals = function (n) {
			return (n < 0.0001) ? 0 : n;
		};
		var shake = A2(
			$elm$core$Basics$min,
			5,
			removeDecimals(
				game.shake * A2($elm$core$Basics$pow, 0.2, dt)));
		var _float = A2($elm$random$Random$float, -shake, shake);
		var vecgen = A3($elm$random$Random$map2, $elm_explorations$linear_algebra$Math$Vector2$vec2, _float, _float);
		var _v0 = A2($elm$random$Random$step, vecgen, game.seed);
		var v = _v0.a;
		var seed = _v0.b;
		return _Utils_update(
			game,
			{seed: seed, shake: shake, shakeVector: v});
	});
var $author$project$Update$slowMotion = F2(
	function (dt, game) {
		var timeToReachTarget = 0.3;
		var targetMultiplier = 0.2;
		var dm = ((1 - targetMultiplier) * dt) / timeToReachTarget;
		var timeMultiplier = (_Utils_cmp(game.time, game.slowMotionEnd) > 0) ? A2($elm$core$Basics$min, game.timeMultiplier + dm, 1) : A2($elm$core$Basics$max, game.timeMultiplier - dm, targetMultiplier);
		return _Utils_update(
			game,
			{timeMultiplier: timeMultiplier});
	});
var $author$project$BaseThink$addFreshlyBuiltMech = F4(
	function (mech, teamId, position, game) {
		return A5(
			$author$project$Game$addMech,
			mech._class,
			mech.inputKey,
			$elm$core$Maybe$Just(teamId),
			position,
			game).a;
	});
var $author$project$Game$deltaEntity = F4(
	function (getter, setter, entityId, updateEntity) {
		var updateGame = function (game) {
			var _v0 = A2(
				$elm$core$Dict$get,
				entityId,
				getter(game));
			if (_v0.$ === 'Nothing') {
				return game;
			} else {
				var entity = _v0.a;
				return A2(
					setter,
					A2(updateEntity, game, entity),
					game);
			}
		};
		return $author$project$Game$DeltaGame(updateGame);
	});
var $author$project$Game$deltaBase = A2(
	$author$project$Game$deltaEntity,
	function ($) {
		return $.baseById;
	},
	$author$project$Game$updateBase);
var $author$project$BaseThink$markMechProductionComplete = F2(
	function (mech, occupied) {
		return _Utils_update(
			occupied,
			{
				mechBuildCompletions: A2(
					$elm$core$List$filter,
					function (_v0) {
						var m = _v0.a;
						var completion = _v0.b;
						return !_Utils_eq(m, mech);
					},
					occupied.mechBuildCompletions)
			});
	});
var $author$project$Base$updateOccupied = F3(
	function (update, game, base) {
		return _Utils_update(
			base,
			{
				maybeOccupied: A2($elm$core$Maybe$map, update, base.maybeOccupied)
			});
	});
var $author$project$BaseThink$deltaBuildMech = F4(
	function (completionIncrease, base, occupied, _v0) {
		var mech = _v0.a;
		var completionAtThink = _v0.b;
		var _v1 = occupied.maybeTeamId;
		if (_v1.$ === 'Nothing') {
			return $author$project$Game$deltaNone;
		} else {
			var teamId = _v1.a;
			if ((completionAtThink + completionIncrease) < 1) {
				var increaseCompletion = function (_v2) {
					var m = _v2.a;
					var completionAtUpdate = _v2.b;
					return _Utils_eq(m, mech) ? _Utils_Tuple2(m, completionAtUpdate + completionIncrease) : _Utils_Tuple2(m, completionAtUpdate);
				};
				return A2(
					$author$project$Game$deltaBase,
					base.id,
					$author$project$Base$updateOccupied(
						function (o) {
							return _Utils_update(
								o,
								{
									mechBuildCompletions: A2($elm$core$List$map, increaseCompletion, o.mechBuildCompletions)
								});
						}));
			} else {
				return $author$project$Game$deltaList(
					_List_fromArray(
						[
							$author$project$Game$deltaGame(
							A3($author$project$BaseThink$addFreshlyBuiltMech, mech, teamId, base.position)),
							A2(
							$author$project$Game$deltaBase,
							base.id,
							$author$project$Base$updateOccupied(
								$author$project$BaseThink$markMechProductionComplete(mech)))
						]));
			}
		}
	});
var $author$project$BaseThink$mechBuildSpeed = 0.5;
var $author$project$BaseThink$deltaBuildAllMechs = F4(
	function (dt, game, base, occupied) {
		var completionIncrease = dt * $author$project$BaseThink$mechBuildSpeed;
		return $author$project$Game$deltaList(
			A2(
				$elm$core$List$map,
				A3($author$project$BaseThink$deltaBuildMech, completionIncrease, base, occupied),
				occupied.mechBuildCompletions));
	});
var $author$project$BaseThink$subBuildSpeed = 0.2;
var $author$project$BaseThink$maxSubsPerTeam = 30;
var $author$project$BaseThink$unitDoesCountTowardsCap = function (unit) {
	var _v0 = unit.component;
	if (_v0.$ === 'UnitMech') {
		return false;
	} else {
		var sub = _v0.a;
		return _Utils_eq(sub.mode, $author$project$Game$UnitModeFree);
	}
};
var $author$project$BaseThink$teamHasReachedUnitCap = F2(
	function (game, teamId) {
		return function (unitsCount) {
			return _Utils_cmp(unitsCount, $author$project$BaseThink$maxSubsPerTeam) > -1;
		}(
			$elm$core$Dict$size(
				A2(
					$elm$core$Dict$filter,
					F2(
						function (id, u) {
							return _Utils_eq(
								u.maybeTeamId,
								$elm$core$Maybe$Just(teamId)) && $author$project$BaseThink$unitDoesCountTowardsCap(u);
						}),
					game.unitById)));
	});
var $author$project$BaseThink$updateAddSub = F3(
	function (maybeTeamId, position, game) {
		if (maybeTeamId.$ === 'Nothing') {
			return game;
		} else {
			var teamId = maybeTeamId.a;
			var team = A2($author$project$Game$getTeam, game, teamId);
			var spawnBigSub = team.bigSubsToSpawn > 0;
			return A2(
				$author$project$Game$updateTeam,
				_Utils_update(
					team,
					{
						bigSubsToSpawn: A2($elm$core$Basics$max, 0, team.bigSubsToSpawn - 1)
					}),
				A4($author$project$Game$addSub, maybeTeamId, position, spawnBigSub, game).a);
		}
	});
var $author$project$BaseThink$deltaBuildSub = F4(
	function (dt, game, base, occupied) {
		var _v0 = occupied.maybeTeamId;
		if (_v0.$ === 'Nothing') {
			return $author$project$Game$deltaNone;
		} else {
			var teamId = _v0.a;
			var completionIncrease = (dt * $author$project$BaseThink$subBuildSpeed) * game.subBuildMultiplier;
			return (((occupied.subBuildCompletion + completionIncrease) < 1) || A2($author$project$BaseThink$teamHasReachedUnitCap, game, teamId)) ? A2(
				$author$project$Game$deltaBase,
				base.id,
				$author$project$Base$updateOccupied(
					function (o) {
						return _Utils_update(
							o,
							{
								subBuildCompletion: A2($elm$core$Basics$min, 1, o.subBuildCompletion + completionIncrease)
							});
					})) : $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2(
						$author$project$Game$deltaBase,
						base.id,
						$author$project$Base$updateOccupied(
							function (o) {
								return _Utils_update(
									o,
									{subBuildCompletion: 0});
							})),
						$author$project$Game$deltaGame(
						A2($author$project$BaseThink$updateAddSub, occupied.maybeTeamId, base.position))
					]));
		}
	});
var $author$project$Game$GfxRepairBubble = function (a) {
	return {$: 'GfxRepairBubble', a: a};
};
var $author$project$View$Gfx$addGfx = F2(
	function (_v0, game) {
		var duration = _v0.duration;
		var render = _v0.render;
		var gfx = {removeTime: game.time + duration, render: render, spawnTime: game.time};
		return _Utils_update(
			game,
			{
				cosmetics: A2($elm$core$List$cons, gfx, game.cosmetics)
			});
	});
var $author$project$View$Gfx$deltaAddGfx = function (seed) {
	return $author$project$Game$deltaGame(
		$author$project$View$Gfx$addGfx(seed));
};
var $author$project$Game$DeltaRandom = function (a) {
	return {$: 'DeltaRandom', a: a};
};
var $author$project$Game$deltaRandom = F2(
	function (_function, generator) {
		return $author$project$Game$DeltaRandom(
			A2($elm$random$Random$map, _function, generator));
	});
var $author$project$Game$deltaWithChance = F2(
	function (chance, delta) {
		var rollToDelta = function (roll) {
			return (_Utils_cmp(roll, chance) > 0) ? $author$project$Game$deltaNone : delta;
		};
		return A2(
			$author$project$Game$deltaRandom,
			rollToDelta,
			A2($elm$random$Random$float, 0, 1));
	});
var $author$project$View$Gfx$deltaAddRepairBubbles = F3(
	function (bubblesPerSecond, dt, position) {
		var displacementToGfx = function (randomDx) {
			return {
				duration: 1,
				render: $author$project$Game$GfxRepairBubble(
					A2(
						$elm_explorations$linear_algebra$Math$Vector2$add,
						position,
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, randomDx, 0)))
			};
		};
		return A2(
			$author$project$Game$deltaWithChance,
			dt * bubblesPerSecond,
			A2(
				$author$project$Game$deltaRandom,
				A2($elm$core$Basics$composeR, displacementToGfx, $author$project$View$Gfx$deltaAddGfx),
				A2($elm$random$Random$float, -0.5, 0.5)));
	});
var $author$project$Game$withUnit = $author$project$Game$with(
	function ($) {
		return $.unitById;
	});
var $author$project$Base$deltaRepairUnit = F3(
	function (dt, baseId, unitId) {
		return $author$project$Game$deltaGame(
			function (game) {
				return A3(
					$author$project$Game$withBase,
					game,
					baseId,
					function (base) {
						var _v0 = base.maybeOccupied;
						if (_v0.$ === 'Nothing') {
							return game;
						} else {
							var occupied = _v0.a;
							return A3(
								$author$project$Game$withUnit,
								game,
								unitId,
								function (unit) {
									var requirementLimit = 1 - unit.integrity;
									var _v1 = function () {
										var _v2 = unit.component;
										if (_v2.$ === 'UnitMech') {
											return _Utils_Tuple2(0.3, 0.3);
										} else {
											return _Utils_Tuple2(0.2, 1.0);
										}
									}();
									var repairRate = _v1.a;
									var productionToIntegrityRatio = _v1.b;
									var baseLimit = occupied.subBuildCompletion * productionToIntegrityRatio;
									var timeLimit = repairRate * dt;
									var actualRepair = A2(
										$elm$core$Basics$min,
										baseLimit,
										A2(
											$elm$core$Basics$min,
											timeLimit,
											A2($elm$core$Basics$min, requirementLimit, 1.0)));
									var updatedBase = _Utils_update(
										base,
										{
											maybeOccupied: $elm$core$Maybe$Just(
												_Utils_update(
													occupied,
													{subBuildCompletion: occupied.subBuildCompletion - (actualRepair / productionToIntegrityRatio)}))
										});
									var updatedUnit = _Utils_update(
										unit,
										{integrity: unit.integrity + actualRepair});
									return A2(
										$author$project$Game$updateUnit,
										updatedUnit,
										A2($author$project$Game$updateBase, updatedBase, game));
								});
						}
					});
			});
	});
var $author$project$BaseThink$deltaRepairEmbeddedSubs = F4(
	function (dt, game, base, occupied) {
		return (occupied.subBuildCompletion <= 0) ? $author$project$Game$deltaNone : $author$project$Game$deltaList(
			A2(
				$elm$core$List$map,
				function (u) {
					return $author$project$Game$deltaList(
						_List_fromArray(
							[
								A3($author$project$Base$deltaRepairUnit, dt, base.id, u.id),
								A3($author$project$View$Gfx$deltaAddRepairBubbles, 0.5, dt, u.position)
							]));
				},
				A2(
					$elm$core$List$filter,
					function (u) {
						return u.integrity < 1;
					},
					A2(
						$elm$core$List$filterMap,
						function (id) {
							return A2($elm$core$Dict$get, id, game.unitById);
						},
						$elm$core$Set$toList(occupied.unitIds)))));
	});
var $author$project$BaseThink$think = F3(
	function (dt, game, base) {
		var _v0 = base.maybeOccupied;
		if (_v0.$ === 'Nothing') {
			return $author$project$Game$deltaNone;
		} else {
			var occupied = _v0.a;
			return (!occupied.isActive) ? $author$project$Game$deltaNone : $author$project$Game$deltaList(
				_List_fromArray(
					[
						A4($author$project$BaseThink$deltaBuildSub, dt, game, base, occupied),
						A4($author$project$BaseThink$deltaBuildAllMechs, dt, game, base, occupied),
						A4($author$project$BaseThink$deltaRepairEmbeddedSubs, dt, game, base, occupied)
					]));
		}
	});
var $author$project$Game$updateProjectile = F2(
	function (projectile, game) {
		return _Utils_update(
			game,
			{
				projectileById: A3($elm$core$Dict$insert, projectile.id, projectile, game.projectileById)
			});
	});
var $author$project$Game$deltaProjectile = A2(
	$author$project$Game$deltaEntity,
	function ($) {
		return $.projectileById;
	},
	$author$project$Game$updateProjectile);
var $author$project$Game$GfxTrail = F3(
	function (a, b, c) {
		return {$: 'GfxTrail', a: a, b: b, c: c};
	});
var $author$project$View$Gfx$deltaAddTrail = function (_v0) {
	var position = _v0.position;
	var angle = _v0.angle;
	var stretch = _v0.stretch;
	return $author$project$View$Gfx$deltaAddGfx(
		{
			duration: 1,
			render: A3($author$project$Game$GfxTrail, position, angle, stretch)
		});
};
var $author$project$Projectile$perspective = function (age) {
	return 1;
};
var $author$project$ProjectileThink$deltaTrail = F4(
	function (dt, _class, age, projectile) {
		if (!_class.trail) {
			return $author$project$Game$deltaNone;
		} else {
			var sizeMultiplier = _class.travelsAlongZ ? $author$project$Projectile$perspective(age) : 1;
			return $author$project$View$Gfx$deltaAddTrail(
				{angle: projectile.angle, position: projectile.position, stretch: (sizeMultiplier * (_class.speed + (_class.acceleration * age))) * dt});
		}
	});
var $elm_explorations$linear_algebra$Math$Vector2$distanceSquared = _MJS_v2distanceSquared;
var $author$project$Game$ProjectileDamage = function (a) {
	return {$: 'ProjectileDamage', a: a};
};
var $author$project$Stats$bullet = {
	acceleration: 0,
	effect: $author$project$Game$ProjectileDamage(4),
	range: 8,
	speed: 30,
	trail: false,
	travelsAlongZ: false
};
var $author$project$Game$ProjectileSplashDamage = function (a) {
	return {$: 'ProjectileSplashDamage', a: a};
};
var $author$project$Stats$downwardSalvo = {
	acceleration: 30,
	effect: $author$project$Game$ProjectileSplashDamage(
		{damage: 25, radius: 5}),
	range: 20,
	speed: 20,
	trail: true,
	travelsAlongZ: true
};
var $author$project$Stats$missile = {
	acceleration: 0,
	effect: $author$project$Game$ProjectileSplashDamage(
		{damage: 30, radius: 2}),
	range: 8,
	speed: 10,
	trail: true,
	travelsAlongZ: false
};
var $author$project$Stats$rocket = {
	acceleration: 30,
	effect: $author$project$Game$ProjectileSplashDamage(
		{damage: 12, radius: 3}),
	range: 8,
	speed: 0,
	trail: true,
	travelsAlongZ: false
};
var $author$project$Stats$upwardSalvo = {
	acceleration: 30,
	effect: $author$project$Game$ProjectileDamage(0),
	range: 40,
	speed: 40,
	trail: true,
	travelsAlongZ: true
};
var $author$project$Projectile$idToClass = function (id) {
	switch (id.$) {
		case 'PlaneBullet':
			return $author$project$Stats$bullet;
		case 'BigSubBullet':
			return $author$project$Stats$bullet;
		case 'HeliRocket':
			return $author$project$Stats$rocket;
		case 'HeliMissile':
			return $author$project$Stats$missile;
		case 'UpwardSalvo':
			return $author$project$Stats$upwardSalvo;
		default:
			return $author$project$Stats$downwardSalvo;
	}
};
var $author$project$Game$GfxExplosion = F3(
	function (a, b, c) {
		return {$: 'GfxExplosion', a: a, b: b, c: c};
	});
var $author$project$View$Gfx$deltaAddExplosion = F2(
	function (position, size) {
		var angleToDelta = function (a) {
			return $author$project$View$Gfx$deltaAddGfx(
				{
					duration: 1.0,
					render: A3($author$project$Game$GfxExplosion, position, size, a)
				});
		};
		return A2(
			$author$project$Game$deltaRandom,
			angleToDelta,
			A2($elm$random$Random$float, -$elm$core$Basics$pi, $elm$core$Basics$pi));
	});
var $author$project$Projectile$remove = F2(
	function (id, game) {
		return _Utils_update(
			game,
			{
				projectileById: A2($elm$core$Dict$remove, id, game.projectileById)
			});
	});
var $author$project$Projectile$deltaRemove = function (id) {
	return $author$project$Game$deltaGame(
		$author$project$Projectile$remove(id));
};
var $author$project$Game$deltaShake = function (shake) {
	return $author$project$Game$deltaGame(
		function (g) {
			return _Utils_update(
				g,
				{
					shake: A2($elm$core$Basics$max, g.shake, shake)
				});
		});
};
var $author$project$Game$deltaUnit = A2(
	$author$project$Game$deltaEntity,
	function ($) {
		return $.unitById;
	},
	$author$project$Game$updateUnit);
var $author$project$Unit$hitPointsAndArmor = function (unit) {
	var _v0 = unit.component;
	if (_v0.$ === 'UnitMech') {
		var mech = _v0.a;
		var _v1 = mech._class;
		if (_v1.$ === 'Blimp') {
			return _Utils_Tuple2(280, 0);
		} else {
			return _Utils_Tuple2(160, 2);
		}
	} else {
		var sub = _v0.a;
		var _v2 = sub.mode;
		if (_v2.$ === 'UnitModeFree') {
			return sub.isBig ? _Utils_Tuple2(160, 0) : _Utils_Tuple2(40, 0);
		} else {
			var baseId = _v2.a;
			return _Utils_Tuple2(70, 2);
		}
	}
};
var $author$project$Unit$removeIntegrity = F3(
	function (integrityLoss, game, unit) {
		var _v0 = game.mode;
		if (_v0.$ === 'GameModeTeamSelection') {
			return unit;
		} else {
			return _Utils_update(
				unit,
				{integrity: unit.integrity - integrityLoss, lastDamaged: game.time});
		}
	});
var $author$project$Unit$takeDamage = F3(
	function (rawDamage, game, unit) {
		var _v0 = $author$project$Unit$hitPointsAndArmor(unit);
		var healthPoints = _v0.a;
		var armor = _v0.b;
		var damage = A2($elm$core$Basics$max, 0, (rawDamage - armor) / healthPoints);
		return A3($author$project$Unit$removeIntegrity, damage, game, unit);
	});
var $author$project$Unit$splashDamage = F5(
	function (game, maybeTeamId, position, damage, radius) {
		return $author$project$Game$deltaList(
			A2(
				$elm$core$List$map,
				function (u) {
					return A2(
						$author$project$Game$deltaUnit,
						u.id,
						$author$project$Unit$takeDamage(damage));
				},
				A2(
					$elm$core$List$filter,
					function (u) {
						return (!_Utils_eq(u.maybeTeamId, maybeTeamId)) && (_Utils_cmp(
							A2($elm_explorations$linear_algebra$Math$Vector2$distanceSquared, u.position, position),
							radius) < 0);
					},
					$elm$core$Dict$values(game.unitById))));
	});
var $author$project$ProjectileThink$thinkExplode = F4(
	function (game, _class, projectile, position) {
		return $author$project$Game$deltaList(
			_List_fromArray(
				[
					$author$project$Projectile$deltaRemove(projectile.id),
					function () {
					var _v0 = _class.effect;
					if (_v0.$ === 'ProjectileSplashDamage') {
						var radius = _v0.a.radius;
						var damage = _v0.a.damage;
						return $author$project$Game$deltaList(
							_List_fromArray(
								[
									A2($author$project$View$Gfx$deltaAddExplosion, position, radius),
									A5($author$project$Unit$splashDamage, game, projectile.maybeTeamId, position, damage, radius),
									$author$project$Game$deltaShake(0.05)
								]));
					} else {
						return $author$project$Game$deltaNone;
					}
				}()
				]));
	});
var $author$project$Game$normalizeAngle = function (angle) {
	var n = $elm$core$Basics$floor((angle + $elm$core$Basics$pi) / (2 * $elm$core$Basics$pi));
	return angle - ((n * 2) * $elm$core$Basics$pi);
};
var $author$project$Game$turnTo = F3(
	function (maxTurn, targetAngle, currentAngle) {
		return $author$project$Game$normalizeAngle(
			currentAngle + A3(
				$elm$core$Basics$clamp,
				-maxTurn,
				maxTurn,
				$author$project$Game$normalizeAngle(targetAngle - currentAngle)));
	});
var $elm$core$Basics$turns = function (angleInTurns) {
	return (2 * $elm$core$Basics$pi) * angleInTurns;
};
var $author$project$ProjectileThink$thinkSeeker = F4(
	function (dt, game, targetId, projectile) {
		var _class = $author$project$Projectile$idToClass(projectile.classId);
		var newPosition = A2(
			$elm_explorations$linear_algebra$Math$Vector2$add,
			projectile.position,
			A2(
				$elm_explorations$linear_algebra$Math$Vector2$scale,
				_class.speed * dt,
				$author$project$Game$angleToVector(projectile.angle)));
		if ((game.time - projectile.spawnTime) > 5) {
			return A4($author$project$ProjectileThink$thinkExplode, game, _class, projectile, newPosition);
		} else {
			var _v0 = A2($elm$core$Dict$get, targetId, game.unitById);
			if (_v0.$ === 'Nothing') {
				return A4($author$project$ProjectileThink$thinkExplode, game, _class, projectile, newPosition);
			} else {
				var target = _v0.a;
				if (A2($elm_explorations$linear_algebra$Math$Vector2$distanceSquared, target.position, newPosition) < 1) {
					return A4($author$project$ProjectileThink$thinkExplode, game, _class, projectile, newPosition);
				} else {
					var turnSpeed = 0.1 * $elm$core$Basics$turns(1);
					var targetAngle = $author$project$Game$vecToAngle(
						A2($elm_explorations$linear_algebra$Math$Vector2$sub, target.position, projectile.position));
					var maxTurn = turnSpeed * dt;
					var newAngle = A3($author$project$Game$turnTo, maxTurn, targetAngle, projectile.angle);
					return $author$project$Game$deltaList(
						_List_fromArray(
							[
								A2(
								$author$project$Game$deltaProjectile,
								projectile.id,
								F2(
									function (g, p) {
										return _Utils_update(
											p,
											{angle: newAngle, position: newPosition});
									})),
								A4($author$project$ProjectileThink$deltaTrail, dt, _class, 0, projectile)
							]));
				}
			}
		}
	});
var $author$project$Unit$filterAndMapAll = F3(
	function (game, test, map) {
		var testUnit = F3(
			function (id, unit, list) {
				return test(unit) ? A2(
					$elm$core$List$cons,
					map(unit),
					list) : list;
			});
		return A3($elm$core$Dict$foldl, testUnit, _List_Nil, game.unitById);
	});
var $elm$core$Array$fromListHelp = F3(
	function (list, nodeList, nodeListSize) {
		fromListHelp:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, list);
			var jsArray = _v0.a;
			var remainingItems = _v0.b;
			if (_Utils_cmp(
				$elm$core$Elm$JsArray$length(jsArray),
				$elm$core$Array$branchFactor) < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					true,
					{nodeList: nodeList, nodeListSize: nodeListSize, tail: jsArray});
			} else {
				var $temp$list = remainingItems,
					$temp$nodeList = A2(
					$elm$core$List$cons,
					$elm$core$Array$Leaf(jsArray),
					nodeList),
					$temp$nodeListSize = nodeListSize + 1;
				list = $temp$list;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue fromListHelp;
			}
		}
	});
var $elm$core$Array$fromList = function (list) {
	if (!list.b) {
		return $elm$core$Array$empty;
	} else {
		return A3($elm$core$Array$fromListHelp, list, _List_Nil, 0);
	}
};
var $elm$core$Array$length = function (_v0) {
	var len = _v0.a;
	return len;
};
var $author$project$Collision$anySegment = F2(
	function (f, poly) {
		var polyAsArray = $elm$core$Array$fromList(poly);
		var length = $elm$core$Array$length(polyAsArray);
		var getVertex = function (index) {
			var _v0 = A2(
				$elm$core$Array$get,
				A2($elm$core$Basics$modBy, length, index),
				polyAsArray);
			if (_v0.$ === 'Just') {
				var vertex = _v0.a;
				return vertex;
			} else {
				return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0);
			}
		};
		var segments = A2(
			$elm$core$List$indexedMap,
			F2(
				function (index, v) {
					return _Utils_Tuple2(
						getVertex(index),
						getVertex(index + 1));
				}),
			poly);
		return A2($elm$core$List$any, f, segments);
	});
var $elm_explorations$linear_algebra$Math$Vector2$dot = _MJS_v2dot;
var $author$project$Collision$rightHandNormal = function (v) {
	var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v);
	var x = _v0.x;
	var y = _v0.y;
	return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -y, x);
};
var $author$project$Collision$normalIsSeparatingAxis = F2(
	function (q, _v0) {
		var pointA = _v0.a;
		var pointB = _v0.b;
		var normal = $author$project$Collision$rightHandNormal(
			A2($elm_explorations$linear_algebra$Math$Vector2$sub, pointB, pointA));
		var isRightSide = function (polygonVertex) {
			return A2(
				$elm_explorations$linear_algebra$Math$Vector2$dot,
				normal,
				A2($elm_explorations$linear_algebra$Math$Vector2$sub, polygonVertex, pointA)) > 0;
		};
		return A2($elm$core$List$all, isRightSide, q);
	});
var $author$project$Collision$halfCollision = F2(
	function (p, q) {
		return !A2(
			$author$project$Collision$anySegment,
			$author$project$Collision$normalIsSeparatingAxis(q),
			p);
	});
var $author$project$Collision$collisionPolygonVsPolygon = F2(
	function (p, q) {
		return A2($author$project$Collision$halfCollision, p, q) && A2($author$project$Collision$halfCollision, q, p);
	});
var $author$project$UnitCollision$unitSize = 0.5;
var $author$project$Ease$inCubic = function (time) {
	return A2($elm$core$Basics$pow, time, 3);
};
var $author$project$Ease$inOut = F3(
	function (e1, e2, time) {
		return (time < 0.5) ? (e1(time * 2) / 2) : (0.5 + (e2((time - 0.5) * 2) / 2));
	});
var $author$project$Ease$flip = F2(
	function (easing, time) {
		return 1 - easing(1 - time);
	});
var $author$project$Ease$outCubic = $author$project$Ease$flip($author$project$Ease$inCubic);
var $author$project$Ease$inOutCubic = A2($author$project$Ease$inOut, $author$project$Ease$inCubic, $author$project$Ease$outCubic);
var $author$project$Game$smooth = F3(
	function (t, a, b) {
		var tt = $author$project$Ease$inOutCubic(t);
		return (tt * b) + ((1 - tt) * a);
	});
var $author$project$View$Mech$collider = F3(
	function (t, fireAngle, position) {
		var s = $author$project$Game$smooth(t);
		return A2(
			$elm$core$List$map,
			$elm_explorations$linear_algebra$Math$Vector2$add(position),
			A2(
				$elm$core$List$map,
				$author$project$Game$rotateVector(fireAngle),
				_List_fromArray(
					[
						A2(
						$elm_explorations$linear_algebra$Math$Vector2$vec2,
						A2(s, -0.8, -0.5),
						A2(s, -0.4, -0.9)),
						A2(
						$elm_explorations$linear_algebra$Math$Vector2$vec2,
						A2(s, -0.7, -0.5),
						A2(s, 0.6, 0.9)),
						A2(
						$elm_explorations$linear_algebra$Math$Vector2$vec2,
						A2(s, 0.7, 0.5),
						A2(s, 0.6, 0.9)),
						A2(
						$elm_explorations$linear_algebra$Math$Vector2$vec2,
						A2(s, 0.8, 0.5),
						A2(s, -0.4, -0.9))
					])));
	});
var $author$project$View$Sub$collider = F2(
	function (topAngle, position) {
		return A2(
			$elm$core$List$map,
			$elm_explorations$linear_algebra$Math$Vector2$add(position),
			A2(
				$elm$core$List$map,
				$author$project$Game$rotateVector(topAngle),
				_List_fromArray(
					[
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, 0.4),
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.5, 0.4),
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.5, -0.4),
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, -0.4)
					])));
	});
var $author$project$UnitCollision$unitToPolygon = function (unit) {
	var _v0 = unit.component;
	if (_v0.$ === 'UnitSub') {
		return A2($author$project$View$Sub$collider, unit.moveAngle, unit.position);
	} else {
		var mech = _v0.a;
		return A3($author$project$View$Mech$collider, mech.transformState, unit.fireAngle, unit.position);
	}
};
var $author$project$UnitCollision$vector = F3(
	function (a, b, unit) {
		var d = $elm_explorations$linear_algebra$Math$Vector2$toRecord(
			A2($elm_explorations$linear_algebra$Math$Vector2$sub, a, b));
		var radius = A2(
			$elm$core$Basics$max,
			$elm$core$Basics$abs(d.x),
			$elm$core$Basics$abs(d.y));
		var minimumCollisionDistance = radius + $author$project$UnitCollision$unitSize;
		return (_Utils_cmp(
			A2($elm_explorations$linear_algebra$Math$Vector2$distanceSquared, a, unit.position),
			minimumCollisionDistance * minimumCollisionDistance) > 0) ? false : A2(
			$author$project$Collision$collisionPolygonVsPolygon,
			_List_fromArray(
				[a, b]),
			$author$project$UnitCollision$unitToPolygon(unit));
	});
var $author$project$UnitCollision$closestEnemyToVectorOrigin = F4(
	function (origin, destination, maybeTeamId, game) {
		return A2(
			$elm_community$list_extra$List$Extra$minimumBy,
			function (u) {
				return A2($elm_explorations$linear_algebra$Math$Vector2$distanceSquared, origin, u.position);
			},
			A3(
				$author$project$Unit$filterAndMapAll,
				game,
				function (u) {
					return (!_Utils_eq(u.maybeTeamId, maybeTeamId)) && A3($author$project$UnitCollision$vector, origin, destination, u);
				},
				$elm$core$Basics$identity));
	});
var $author$project$ProjectileThink$thinkStraight = F3(
	function (dt, game, projectile) {
		var oldPosition = projectile.position;
		var _class = $author$project$Projectile$idToClass(projectile.classId);
		var age = game.time - projectile.spawnTime;
		var traveledDistance = (((0.5 * _class.acceleration) * age) * age) + (_class.speed * age);
		var newPosition = A2(
			$elm_explorations$linear_algebra$Math$Vector2$add,
			projectile.spawnPosition,
			A2(
				$elm_explorations$linear_algebra$Math$Vector2$scale,
				A2($elm$core$Basics$min, traveledDistance, _class.range),
				$author$project$Game$angleToVector(projectile.angle)));
		var thinkNoCollision = function (_v2) {
			return (_Utils_cmp(traveledDistance, _class.range) > 0) ? A4($author$project$ProjectileThink$thinkExplode, game, _class, projectile, newPosition) : $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2(
						$author$project$Game$deltaProjectile,
						projectile.id,
						F2(
							function (g, p) {
								return _Utils_update(
									p,
									{position: newPosition});
							})),
						A4($author$project$ProjectileThink$deltaTrail, dt, _class, age, projectile)
					]));
		};
		if (_class.travelsAlongZ) {
			return thinkNoCollision(_Utils_Tuple0);
		} else {
			var _v0 = A4($author$project$UnitCollision$closestEnemyToVectorOrigin, oldPosition, newPosition, projectile.maybeTeamId, game);
			if (_v0.$ === 'Just') {
				var unit = _v0.a;
				return $author$project$Game$deltaList(
					_List_fromArray(
						[
							A4(
							$author$project$ProjectileThink$thinkExplode,
							game,
							_class,
							projectile,
							A2(
								$elm_explorations$linear_algebra$Math$Vector2$scale,
								0.5,
								A2($elm_explorations$linear_algebra$Math$Vector2$add, newPosition, oldPosition))),
							function () {
							var _v1 = _class.effect;
							if (_v1.$ === 'ProjectileDamage') {
								var damage = _v1.a;
								return A2(
									$author$project$Game$deltaUnit,
									unit.id,
									$author$project$Unit$takeDamage(damage));
							} else {
								return $author$project$Game$deltaNone;
							}
						}()
						]));
			} else {
				return thinkNoCollision(_Utils_Tuple0);
			}
		}
	});
var $author$project$ProjectileThink$think = F3(
	function (dt, game, projectile) {
		var _v0 = projectile.maybeTargetId;
		if (_v0.$ === 'Just') {
			var targetId = _v0.a;
			return A4($author$project$ProjectileThink$thinkSeeker, dt, game, targetId, projectile);
		} else {
			return A3($author$project$ProjectileThink$thinkStraight, dt, game, projectile);
		}
	});
var $author$project$Game$generateRandom = F2(
	function (generator, game) {
		var _v0 = A2($elm$random$Random$step, generator, game.seed);
		var value = _v0.a;
		var seed = _v0.b;
		return _Utils_Tuple2(
			value,
			_Utils_update(
				game,
				{seed: seed}));
	});
var $author$project$SetupPhase$addMech = function (inputSourceKey) {
	var startingPosition = A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0);
	var update = function (game) {
		return function (_v0) {
			var _class = _v0.a;
			var g = _v0.b;
			return A5($author$project$Game$addMech, _class, inputSourceKey, $elm$core$Maybe$Nothing, startingPosition, g);
		}(
			A2($author$project$Game$generateRandom, $author$project$Mech$classGenerator, game)).a;
	};
	return $author$project$Game$deltaGame(update);
};
var $elm$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			$elm$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2($elm$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});
var $elm$core$Set$diff = F2(
	function (_v0, _v1) {
		var dict1 = _v0.a;
		var dict2 = _v1.a;
		return $elm$core$Set$Set_elm_builtin(
			A2($elm$core$Dict$diff, dict1, dict2));
	});
var $author$project$Unit$toMech = function (unit) {
	var _v0 = unit.component;
	if (_v0.$ === 'UnitMech') {
		var mech = _v0.a;
		return $elm$core$Maybe$Just(
			_Utils_Tuple2(unit, mech));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$SetupPhase$removeMech = function (inputSourceKey) {
	var keepUnit = F2(
		function (id, unit) {
			var _v0 = $author$project$Unit$toMech(unit);
			if (_v0.$ === 'Nothing') {
				return true;
			} else {
				var _v1 = _v0.a;
				var u = _v1.a;
				var mech = _v1.b;
				return !_Utils_eq(mech.inputKey, inputSourceKey);
			}
		});
	return $author$project$Game$deltaGame(
		function (g) {
			return _Utils_update(
				g,
				{
					unitById: A2($elm$core$Dict$filter, keepUnit, g.unitById)
				});
		});
};
var $author$project$SetupPhase$addAndRemoveMechs = F2(
	function (inputSources, game) {
		var mechs = $elm$core$Set$fromList(
			A2(
				$elm$core$List$map,
				A2(
					$elm$core$Basics$composeR,
					$elm$core$Tuple$second,
					function ($) {
						return $.inputKey;
					}),
				A2(
					$elm$core$List$filterMap,
					$author$project$Unit$toMech,
					$elm$core$Dict$values(game.unitById))));
		var inputs = $elm$core$Set$fromList(inputSources);
		var inputsWithoutMech = $elm$core$Set$toList(
			A2($elm$core$Set$diff, inputs, mechs));
		var mechsWithoutInput = $elm$core$Set$toList(
			A2($elm$core$Set$diff, mechs, inputs));
		return $author$project$Game$deltaList(
			A2(
				$elm$core$List$map,
				$author$project$Game$deltaList,
				_List_fromArray(
					[
						A2($elm$core$List$map, $author$project$SetupPhase$addMech, inputsWithoutMech),
						A2($elm$core$List$map, $author$project$SetupPhase$removeMech, mechsWithoutInput)
					])));
	});
var $author$project$Game$DeltaOutcome = function (a) {
	return {$: 'DeltaOutcome', a: a};
};
var $author$project$Game$OutcomeCanAddBots = {$: 'OutcomeCanAddBots'};
var $author$project$SetupPhase$isReady = function (_v0) {
	var unit = _v0.a;
	var mech = _v0.b;
	return !_Utils_eq(unit.maybeTeamId, $elm$core$Maybe$Nothing);
};
var $author$project$Game$GameFadeOut = {$: 'GameFadeOut'};
var $author$project$SetupPhase$startTransition = function (game) {
	var mechs = A2(
		$elm$core$List$filterMap,
		$author$project$Unit$toMech,
		$elm$core$Dict$values(game.unitById));
	var mechClassByInputKey = function (teamId) {
		return $elm$core$Dict$fromList(
			A2(
				$elm$core$List$map,
				function (mech) {
					return _Utils_Tuple2(mech.inputKey, mech._class);
				},
				A2(
					$elm$core$List$map,
					$elm$core$Tuple$second,
					A2(
						$elm$core$List$filter,
						function (_v0) {
							var u = _v0.a;
							var m = _v0.b;
							return _Utils_eq(
								u.maybeTeamId,
								$elm$core$Maybe$Just(teamId));
						},
						mechs))));
	};
	var addPlayers = function (team) {
		return _Utils_update(
			team,
			{
				mechClassByInputKey: mechClassByInputKey(team.id)
			});
	};
	return A2(
		$author$project$Game$updateTeam,
		addPlayers(game.rightTeam),
		A2(
			$author$project$Game$updateTeam,
			addPlayers(game.leftTeam),
			_Utils_update(
				game,
				{
					maybeTransition: $elm$core$Maybe$Just(
						{fade: $author$project$Game$GameFadeOut, start: game.time})
				})));
};
var $author$project$SetupPhase$maybeExitSetupPhase = function (game) {
	var mechs = A2(
		$elm$core$List$filterMap,
		$author$project$Unit$toMech,
		$elm$core$Dict$values(game.unitById));
	return ((!_Utils_eq(mechs, _List_Nil)) && A2($elm$core$List$all, $author$project$SetupPhase$isReady, mechs)) ? $author$project$Game$deltaList(
		_List_fromArray(
			[
				$author$project$Game$deltaGame($author$project$SetupPhase$startTransition),
				$author$project$Game$DeltaOutcome($author$project$Game$OutcomeCanAddBots)
			])) : $author$project$Game$deltaNone;
};
var $elm_explorations$linear_algebra$Math$Vector2$getX = _MJS_v2getX;
var $author$project$SetupPhase$neutralTilesHalfWidth = 8;
var $author$project$SetupPhase$updateMechTeam = F2(
	function (game, _v0) {
		var unit = _v0.a;
		var mech = _v0.b;
		var setTeam = function (maybeTeamId) {
			return _Utils_eq(unit.maybeTeamId, maybeTeamId) ? $author$project$Game$deltaNone : $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2(
						$author$project$Game$deltaUnit,
						unit.id,
						F2(
							function (g, u) {
								return _Utils_update(
									u,
									{maybeTeamId: maybeTeamId});
							}))
					]));
		};
		return (_Utils_cmp(
			$elm_explorations$linear_algebra$Math$Vector2$getX(unit.position),
			-$author$project$SetupPhase$neutralTilesHalfWidth) < 0) ? setTeam(
			$elm$core$Maybe$Just(game.leftTeam.id)) : ((_Utils_cmp(
			$elm_explorations$linear_algebra$Math$Vector2$getX(unit.position),
			$author$project$SetupPhase$neutralTilesHalfWidth) > 0) ? setTeam(
			$elm$core$Maybe$Just(game.rightTeam.id)) : setTeam($elm$core$Maybe$Nothing));
	});
var $author$project$SetupPhase$updateAllMechsTeam = function (game) {
	return $author$project$Game$deltaList(
		A2(
			$elm$core$List$map,
			$author$project$SetupPhase$updateMechTeam(game),
			A2(
				$elm$core$List$filterMap,
				$author$project$Unit$toMech,
				$elm$core$Dict$values(game.unitById))));
};
var $author$project$SetupPhase$think = F2(
	function (inputSources, game) {
		return $author$project$Game$deltaList(
			_List_fromArray(
				[
					A2($author$project$SetupPhase$addAndRemoveMechs, inputSources, game),
					(!_Utils_eq(game.maybeTransition, $elm$core$Maybe$Nothing)) ? $author$project$Game$deltaNone : $author$project$Game$deltaList(
					_List_fromArray(
						[
							$author$project$SetupPhase$updateAllMechsTeam(game),
							$author$project$SetupPhase$maybeExitSetupPhase(game)
						]))
				]));
	});
var $author$project$Game$deltaTeam = F2(
	function (teamId, update) {
		var updateGame = function (game) {
			if (teamId.$ === 'TeamLeft') {
				return _Utils_update(
					game,
					{
						leftTeam: A2(update, game, game.leftTeam)
					});
			} else {
				return _Utils_update(
					game,
					{
						rightTeam: A2(update, game, game.rightTeam)
					});
			}
		};
		return $author$project$Game$DeltaGame(updateGame);
	});
var $author$project$UnitThink$addBigSubsToEnemyTeam = function (killedUnit) {
	var _v0 = killedUnit.maybeTeamId;
	if (_v0.$ === 'Nothing') {
		return $author$project$Game$deltaNone;
	} else {
		var killedUnitTeamId = _v0.a;
		var enemyTeam = function () {
			if (killedUnitTeamId.$ === 'TeamLeft') {
				return $author$project$Game$TeamRight;
			} else {
				return $author$project$Game$TeamLeft;
			}
		}();
		return A2(
			$author$project$Game$deltaTeam,
			enemyTeam,
			F2(
				function (g, t) {
					return _Utils_update(
						t,
						{bigSubsToSpawn: 3});
				}));
	}
};
var $author$project$Game$GfxFrag = function (a) {
	return {$: 'GfxFrag', a: a};
};
var $elm$random$Random$map5 = F6(
	function (func, _v0, _v1, _v2, _v3, _v4) {
		var genA = _v0.a;
		var genB = _v1.a;
		var genC = _v2.a;
		var genD = _v3.a;
		var genE = _v4.a;
		return $elm$random$Random$Generator(
			function (seed0) {
				var _v5 = genA(seed0);
				var a = _v5.a;
				var seed1 = _v5.b;
				var _v6 = genB(seed1);
				var b = _v6.a;
				var seed2 = _v6.b;
				var _v7 = genC(seed2);
				var c = _v7.a;
				var seed3 = _v7.b;
				var _v8 = genD(seed3);
				var d = _v8.a;
				var seed4 = _v8.b;
				var _v9 = genE(seed4);
				var e = _v9.a;
				var seed5 = _v9.b;
				return _Utils_Tuple2(
					A5(func, a, b, c, d, e),
					seed5);
			});
	});
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $author$project$Game$maybeGetTeam = function (game) {
	return $elm$core$Maybe$map(
		$author$project$Game$getTeam(game));
};
var $author$project$Game$teamColorPattern = F2(
	function (game, teamId) {
		var _v0 = A2($author$project$Game$maybeGetTeam, game, teamId);
		if (_v0.$ === 'Nothing') {
			return $author$project$ColorPattern$neutral;
		} else {
			var team = _v0.a;
			return team.colorPattern;
		}
	});
var $author$project$View$Gfx$deltaAddFrags = F4(
	function (game, n, origin, maybeTeamId) {
		var generateSize = A2(
			$elm$random$Random$pair,
			A2($elm$random$Random$float, 0.1, 0.5),
			A2($elm$random$Random$float, 0.1, 0.5));
		var generateInterval = A2($elm$random$Random$float, -1, 1);
		var generateVector = A3($elm$random$Random$map2, $elm_explorations$linear_algebra$Math$Vector2$vec2, generateInterval, generateInterval);
		var generateBool = A2(
			$elm$random$Random$map,
			function (i) {
				return !i;
			},
			A2($elm$random$Random$int, 0, 1));
		var generateAngle = A2($elm$random$Random$float, -$elm$core$Basics$pi, $elm$core$Basics$pi);
		var colorPattern = A2($author$project$Game$teamColorPattern, game, maybeTeamId);
		var makeGfx = F5(
			function (_v0, v, a, va, isTris) {
				var w = _v0.a;
				var h = _v0.b;
				return $author$project$View$Gfx$deltaAddGfx(
					{
						duration: 2,
						render: $author$project$Game$GfxFrag(
							{
								angle: a,
								angularVelocity: (2 * $elm$core$Basics$pi) * va,
								fill: colorPattern.brightV,
								h: h,
								isTris: isTris,
								origin: origin,
								speed: A2($elm_explorations$linear_algebra$Math$Vector2$scale, 6, v),
								stroke: colorPattern.darkV,
								w: w
							})
					});
			});
		var generateDelta = A6($elm$random$Random$map5, makeGfx, generateSize, generateVector, generateAngle, generateInterval, generateBool);
		var addFrag = $author$project$Game$DeltaRandom(generateDelta);
		return $author$project$Game$deltaList(
			A2($elm$core$List$repeat, n, addFrag));
	});
var $author$project$Game$DeltaNeedsUpdatedGame = function (a) {
	return {$: 'DeltaNeedsUpdatedGame', a: a};
};
var $author$project$SubThink$deltaDefeat = function (maybeTeamId) {
	if (maybeTeamId.$ === 'Nothing') {
		return $author$project$Game$deltaNone;
	} else {
		var defeatedTeamId = maybeTeamId.a;
		var winnerTeamId = function () {
			if (defeatedTeamId.$ === 'TeamLeft') {
				return $author$project$Game$TeamRight;
			} else {
				return $author$project$Game$TeamLeft;
			}
		}();
		return $author$project$Game$deltaGame(
			function (g) {
				return _Utils_update(
					g,
					{
						maybeVictory: $elm$core$Maybe$Just(
							_Utils_Tuple2(winnerTeamId, g.time))
					});
			});
	}
};
var $author$project$Game$DeltaLater = F2(
	function (a, b) {
		return {$: 'DeltaLater', a: a, b: b};
	});
var $author$project$Game$deltaLater = $author$project$Game$DeltaLater;
var $author$project$Game$deltaRandom2 = F3(
	function (_function, generatorA, generatorB) {
		return $author$project$Game$DeltaRandom(
			A3($elm$random$Random$map2, _function, generatorA, generatorB));
	});
var $author$project$SubThink$deltaExplosions = function (position) {
	var skewedFloat = A2(
		$elm$random$Random$map,
		function (n) {
			return A2($elm$core$Basics$pow, n, 4);
		},
		A2($elm$random$Random$float, 0, 1));
	var sizeGenerator = A2($elm$random$Random$float, 0.5, 5);
	var dpGenerator = A2($elm$random$Random$float, -2, 2);
	var positionGenerator = A2(
		$elm$random$Random$map,
		function (_v0) {
			var dx = _v0.a;
			var dy = _v0.b;
			return A2(
				$elm_explorations$linear_algebra$Math$Vector2$add,
				position,
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, dx, dy));
		},
		A2($elm$random$Random$pair, dpGenerator, dpGenerator));
	var deltaSecondary = F2(
		function (size, pos) {
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2($author$project$View$Gfx$deltaAddExplosion, pos, size),
						$author$project$Game$deltaShake(0.1 * size)
					]));
		});
	var deltaRandomSecondary = A3($author$project$Game$deltaRandom2, deltaSecondary, sizeGenerator, positionGenerator);
	var delayGenerator = A2($elm$random$Random$float, 0.1, 5);
	return $author$project$Game$deltaList(
		_List_fromArray(
			[
				A2($author$project$View$Gfx$deltaAddExplosion, position, 20),
				$author$project$Game$deltaShake(0.5),
				$author$project$Game$deltaList(
				A2(
					$elm$core$List$repeat,
					50,
					A2(
						$author$project$Game$deltaRandom,
						function (delay) {
							return A2($author$project$Game$deltaLater, delay, deltaRandomSecondary);
						},
						delayGenerator)))
			]));
};
var $author$project$Base$deltaOccupied = F2(
	function (baseId, update) {
		return A2(
			$author$project$Game$deltaBase,
			baseId,
			$author$project$Base$updateOccupied(update));
	});
var $author$project$Game$deltaSlowMotionBig = $author$project$Game$deltaGame(
	function (g) {
		return _Utils_update(
			g,
			{slowMotionEnd: g.time + 1, timeMultiplier: 0.2});
	});
var $elm$core$Set$singleton = function (key) {
	return $elm$core$Set$Set_elm_builtin(
		A2($elm$core$Dict$singleton, key, _Utils_Tuple0));
};
var $author$project$SubThink$deltaBaseLosesUnit = F3(
	function (unitId, baseId, game) {
		var _v0 = A2($elm$core$Dict$get, baseId, game.baseById);
		if (_v0.$ === 'Nothing') {
			return $author$project$Game$deltaNone;
		} else {
			var base = _v0.a;
			var _v1 = base.maybeOccupied;
			if (_v1.$ === 'Nothing') {
				return $author$project$Game$deltaNone;
			} else {
				var occupied = _v1.a;
				return (!_Utils_eq(
					occupied.unitIds,
					$elm$core$Set$singleton(unitId))) ? A2(
					$author$project$Base$deltaOccupied,
					baseId,
					function (o) {
						return _Utils_update(
							o,
							{
								unitIds: A2($elm$core$Set$remove, unitId, o.unitIds)
							});
					}) : ((!_Utils_eq(base.type_, $author$project$Game$BaseMain)) ? A2(
					$author$project$Game$deltaBase,
					baseId,
					F2(
						function (g, b) {
							return _Utils_update(
								b,
								{maybeOccupied: $elm$core$Maybe$Nothing});
						})) : $author$project$Game$deltaList(
					_List_fromArray(
						[
							$author$project$SubThink$deltaDefeat(occupied.maybeTeamId),
							$author$project$SubThink$deltaExplosions(base.position),
							A4($author$project$View$Gfx$deltaAddFrags, game, 400, base.position, occupied.maybeTeamId),
							A2(
							$author$project$Game$deltaLater,
							0.6,
							$author$project$Game$deltaGame(
								function (g) {
									return _Utils_update(
										g,
										{
											baseById: A2($elm$core$Dict$remove, base.id, g.baseById)
										});
								})),
							$author$project$Game$deltaSlowMotionBig
						])));
			}
		}
	});
var $author$project$SubThink$destroy = F3(
	function (game, unit, sub) {
		var _v0 = sub.mode;
		if (_v0.$ === 'UnitModeBase') {
			var baseId = _v0.a;
			return $author$project$Game$DeltaNeedsUpdatedGame(
				A2($author$project$SubThink$deltaBaseLosesUnit, unit.id, baseId));
		} else {
			return $author$project$Game$deltaNone;
		}
	});
var $author$project$Game$HeliMissile = {$: 'HeliMissile'};
var $author$project$Game$HeliRocket = {$: 'HeliRocket'};
var $author$project$Game$PlaneBullet = {$: 'PlaneBullet'};
var $author$project$Stats$blimp = {beamDamage: 40, beamRange: 10, reload: 1.0, vampireRange: 3};
var $author$project$Game$GfxBeam = F3(
	function (a, b, c) {
		return {$: 'GfxBeam', a: a, b: b, c: c};
	});
var $author$project$View$Gfx$deltaAddBeam = F3(
	function (start, end, colorPattern) {
		return $author$project$View$Gfx$deltaAddGfx(
			{
				duration: 2.0,
				render: A3($author$project$Game$GfxBeam, start, end, colorPattern)
			});
	});
var $elm_explorations$linear_algebra$Math$Vector2$distance = _MJS_v2distance;
var $author$project$UnitCollision$enemiesVsPolygon = F3(
	function (polygon, maybeTeamId, game) {
		return A3(
			$author$project$Unit$filterAndMapAll,
			game,
			function (u) {
				return (!_Utils_eq(u.maybeTeamId, maybeTeamId)) && A2(
					$author$project$Collision$collisionPolygonVsPolygon,
					polygon,
					$author$project$UnitCollision$unitToPolygon(u));
			},
			$elm$core$Basics$identity);
	});
var $author$project$MechThink$beamAttackDelta = F4(
	function (game, unit, mech, start) {
		var halfWidth = 0.2;
		var alongBeamLength = A2(
			$author$project$Game$rotateVector,
			unit.fireAngle,
			A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 1));
		var alongBeamWidth = A2($author$project$Game$rotateVector, $elm$core$Basics$pi / 2, alongBeamLength);
		var b = A2(
			$elm_explorations$linear_algebra$Math$Vector2$add,
			start,
			A2($elm_explorations$linear_algebra$Math$Vector2$scale, -halfWidth, alongBeamWidth));
		var lengthV = A2($elm_explorations$linear_algebra$Math$Vector2$scale, $author$project$Stats$blimp.beamRange, alongBeamLength);
		var c = A2($elm_explorations$linear_algebra$Math$Vector2$add, b, lengthV);
		var end = A2($elm_explorations$linear_algebra$Math$Vector2$add, start, lengthV);
		var a = A2(
			$elm_explorations$linear_algebra$Math$Vector2$add,
			start,
			A2($elm_explorations$linear_algebra$Math$Vector2$scale, halfWidth, alongBeamWidth));
		var d = A2($elm_explorations$linear_algebra$Math$Vector2$add, a, lengthV);
		var beamPolygon = _List_fromArray(
			[a, b, c, d]);
		var maybeTarget = A2(
			$elm_community$list_extra$List$Extra$minimumBy,
			function (target) {
				return A2($elm_explorations$linear_algebra$Math$Vector2$distanceSquared, unit.position, target.position);
			},
			A3($author$project$UnitCollision$enemiesVsPolygon, beamPolygon, unit.maybeTeamId, game));
		if (maybeTarget.$ === 'Nothing') {
			return A3(
				$author$project$View$Gfx$deltaAddBeam,
				start,
				end,
				A2($author$project$Game$teamColorPattern, game, unit.maybeTeamId));
		} else {
			var target = maybeTarget.a;
			var length = A2($elm_explorations$linear_algebra$Math$Vector2$distance, start, target.position);
			var newEnd = A2(
				$elm_explorations$linear_algebra$Math$Vector2$add,
				start,
				A2($elm_explorations$linear_algebra$Math$Vector2$scale, length, alongBeamLength));
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A3(
						$author$project$View$Gfx$deltaAddBeam,
						start,
						newEnd,
						A2($author$project$Game$teamColorPattern, game, unit.maybeTeamId)),
						A2(
						$author$project$Game$deltaUnit,
						target.id,
						$author$project$Unit$takeDamage($author$project$Stats$blimp.beamDamage))
					]));
		}
	});
var $author$project$Projectile$addSpecial = F3(
	function (spawnPosition, _v0, game) {
		var maybeTeamId = _v0.maybeTeamId;
		var position = _v0.position;
		var angle = _v0.angle;
		var classId = _v0.classId;
		var maybeTargetId = _v0.maybeTargetId;
		var projectile = {angle: angle, classId: classId, id: game.lastId + 1, maybeTargetId: maybeTargetId, maybeTeamId: maybeTeamId, position: position, spawnPosition: spawnPosition, spawnTime: game.time};
		var projectileById = A3($elm$core$Dict$insert, projectile.id, projectile, game.projectileById);
		var _class = $author$project$Projectile$idToClass(classId);
		return _Utils_update(
			game,
			{lastId: projectile.id, projectileById: projectileById});
	});
var $author$project$Projectile$add = F2(
	function (seed, game) {
		return A3($author$project$Projectile$addSpecial, seed.position, seed, game);
	});
var $author$project$Projectile$deltaAdd = function (p) {
	return $author$project$Game$deltaGame(
		$author$project$Projectile$add(p));
};
var $author$project$Game$GfxProjectileCase = F2(
	function (a, b) {
		return {$: 'GfxProjectileCase', a: a, b: b};
	});
var $author$project$View$Gfx$deltaAddProjectileCase = F2(
	function (origin, angle) {
		return $author$project$View$Gfx$deltaAddGfx(
			{
				duration: 0.2,
				render: A2($author$project$Game$GfxProjectileCase, origin, angle)
			});
	});
var $author$project$Unit$isMech = function (unit) {
	var _v0 = unit.component;
	if (_v0.$ === 'UnitMech') {
		return true;
	} else {
		return false;
	}
};
var $author$project$View$Mech$leftGunOffset = F2(
	function (t, torsoAngle) {
		return A2(
			$elm_explorations$linear_algebra$Math$Vector2$scale,
			3,
			A2(
				$author$project$Game$rotateVector,
				torsoAngle,
				A2(
					$elm_explorations$linear_algebra$Math$Vector2$vec2,
					-A3($author$project$Game$smooth, t, 0.13, 0.09),
					A3($author$project$Game$smooth, t, 0.21, 0.26))));
	});
var $elm_community$list_extra$List$Extra$maximumBy = F2(
	function (f, ls) {
		var maxBy = F2(
			function (x, _v1) {
				var y = _v1.a;
				var fy = _v1.b;
				var fx = f(x);
				return (_Utils_cmp(fx, fy) > 0) ? _Utils_Tuple2(x, fx) : _Utils_Tuple2(y, fy);
			});
		if (ls.b) {
			if (!ls.b.b) {
				var l_ = ls.a;
				return $elm$core$Maybe$Just(l_);
			} else {
				var l_ = ls.a;
				var ls_ = ls.b;
				return $elm$core$Maybe$Just(
					A3(
						$elm$core$List$foldl,
						maxBy,
						_Utils_Tuple2(
							l_,
							f(l_)),
						ls_).a);
			}
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$MechThink$missileTargetPriority = F2(
	function (shooter, target) {
		var dp = A2($elm_explorations$linear_algebra$Math$Vector2$sub, shooter.position, target.position);
		var distance = $elm_explorations$linear_algebra$Math$Vector2$length(dp);
		var deltaAngle = $elm$core$Basics$abs(
			A3(
				$author$project$Game$turnTo,
				2 * $elm$core$Basics$pi,
				shooter.fireAngle,
				$author$project$Game$vecToAngle(dp)));
		return (0 - distance) - (10 * deltaAngle);
	});
var $author$project$Stats$heli = {chargeTime: 2, cooldown: 0.5, flyReload: 0.5, maxStretchTime: 1.5, salvoSize: 10, walkReload: 0.9};
var $author$project$Stats$plane = {flyReload: 0.05, repairRange: 5, walkReload: 0.05};
var $author$project$Mech$transformMode = function (mech) {
	var _v0 = mech.transformingTo;
	if (_v0.$ === 'ToMech') {
		return (mech.transformState < 1) ? $author$project$Game$ToMech : $author$project$Game$ToFlyer;
	} else {
		return (mech.transformState > 0) ? $author$project$Game$ToFlyer : $author$project$Game$ToMech;
	}
};
var $author$project$Mech$reloadTime = function (mech) {
	var _v0 = mech._class;
	switch (_v0.$) {
		case 'Blimp':
			return $author$project$Stats$blimp.reload;
		case 'Heli':
			var _v1 = $author$project$Mech$transformMode(mech);
			if (_v1.$ === 'ToMech') {
				return $author$project$Stats$heli.walkReload;
			} else {
				return $author$project$Stats$heli.flyReload;
			}
		default:
			var _v2 = $author$project$Mech$transformMode(mech);
			if (_v2.$ === 'ToMech') {
				return $author$project$Stats$plane.walkReload;
			} else {
				return $author$project$Stats$plane.flyReload;
			}
	}
};
var $author$project$View$Mech$rightGunOffset = F2(
	function (t, torsoAngle) {
		return A2(
			$elm_explorations$linear_algebra$Math$Vector2$scale,
			3,
			A2(
				$author$project$Game$rotateVector,
				torsoAngle,
				A2(
					$elm_explorations$linear_algebra$Math$Vector2$vec2,
					A3($author$project$Game$smooth, t, 0.13, 0.09),
					A3($author$project$Game$smooth, t, 0.21, 0.26))));
	});
var $author$project$MechThink$attackDelta = F3(
	function (game, unit, mech) {
		if (_Utils_cmp(game.time, unit.reloadEndTime) < 0) {
			return $author$project$Game$deltaNone;
		} else {
			var rightOrigin = A2(
				$elm_explorations$linear_algebra$Math$Vector2$add,
				unit.position,
				A2($author$project$View$Mech$rightGunOffset, mech.transformState, unit.fireAngle));
			var mode = $author$project$Mech$transformMode(mech);
			var leftOrigin = A2(
				$elm_explorations$linear_algebra$Math$Vector2$add,
				unit.position,
				A2($author$project$View$Mech$leftGunOffset, mech.transformState, unit.fireAngle));
			var deltaFire = F3(
				function (classId, maybeTargetId, origin) {
					return $author$project$Projectile$deltaAdd(
						{angle: unit.fireAngle, classId: classId, maybeTargetId: maybeTargetId, maybeTeamId: unit.maybeTeamId, position: origin});
				});
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2(
						$author$project$Game$deltaUnit,
						unit.id,
						F2(
							function (g, u) {
								return _Utils_update(
									u,
									{
										reloadEndTime: game.time + $author$project$Mech$reloadTime(mech)
									});
							})),
						function () {
						var _v0 = mech._class;
						switch (_v0.$) {
							case 'Blimp':
								return $author$project$Game$deltaList(
									_List_fromArray(
										[
											A4($author$project$MechThink$beamAttackDelta, game, unit, mech, leftOrigin),
											A4($author$project$MechThink$beamAttackDelta, game, unit, mech, rightOrigin)
										]));
							case 'Heli':
								if (mode.$ === 'ToFlyer') {
									return $author$project$Game$deltaList(
										_List_fromArray(
											[
												A3(deltaFire, $author$project$Game$HeliRocket, $elm$core$Maybe$Nothing, leftOrigin),
												A3(deltaFire, $author$project$Game$HeliRocket, $elm$core$Maybe$Nothing, rightOrigin)
											]));
								} else {
									var maybeTargetId = A2(
										$elm$core$Maybe$map,
										$elm$core$Tuple$first,
										A2(
											$elm_community$list_extra$List$Extra$maximumBy,
											$elm$core$Tuple$second,
											A2(
												$elm$core$List$map,
												function (t) {
													return _Utils_Tuple2(
														t.id,
														A2($author$project$MechThink$missileTargetPriority, unit, t));
												},
												A2(
													$elm$core$List$filter,
													function (t) {
														return (!_Utils_eq(t.maybeTeamId, unit.maybeTeamId)) && $author$project$Unit$isMech(t);
													},
													$elm$core$Dict$values(game.unitById)))));
									return $author$project$Game$deltaList(
										_List_fromArray(
											[
												A3(deltaFire, $author$project$Game$HeliMissile, maybeTargetId, leftOrigin),
												A3(deltaFire, $author$project$Game$HeliMissile, maybeTargetId, rightOrigin)
											]));
								}
							default:
								return $author$project$Game$deltaList(
									_List_fromArray(
										[
											A3(deltaFire, $author$project$Game$PlaneBullet, $elm$core$Maybe$Nothing, leftOrigin),
											A2($author$project$View$Gfx$deltaAddProjectileCase, leftOrigin, (unit.fireAngle - $elm$core$Basics$pi) - ($elm$core$Basics$pi / 12)),
											A3(deltaFire, $author$project$Game$PlaneBullet, $elm$core$Maybe$Nothing, rightOrigin),
											A2($author$project$View$Gfx$deltaAddProjectileCase, rightOrigin, unit.fireAngle + ($elm$core$Basics$pi / 12)),
											$author$project$Game$deltaShake(0.02)
										]));
						}
					}()
					]));
		}
	});
var $author$project$Game$clampToGameSize = F3(
	function (game, radius, v) {
		var hw = game.halfWidth - radius;
		var hh = game.halfHeight - radius;
		var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(v);
		var x = _v0.x;
		var y = _v0.y;
		return A2(
			$elm_explorations$linear_algebra$Math$Vector2$vec2,
			A3($elm$core$Basics$clamp, -hw, hw, x),
			A3($elm$core$Basics$clamp, -hh, hh, y));
	});
var $elm_explorations$linear_algebra$Math$Vector2$lengthSquared = _MJS_v2lengthSquared;
var $author$project$Game$clampToRadius = F2(
	function (radius, v) {
		var ll = $elm_explorations$linear_algebra$Math$Vector2$lengthSquared(v);
		return (_Utils_cmp(ll, radius * radius) < 1) ? v : A2(
			$elm_explorations$linear_algebra$Math$Vector2$scale,
			radius / $elm$core$Basics$sqrt(ll),
			v);
	});
var $author$project$MechThink$controlThreshold = 0.1;
var $author$project$MechThink$nextClass = function (_class) {
	switch (_class.$) {
		case 'Plane':
			return $author$project$Game$Heli;
		case 'Heli':
			return $author$project$Game$Blimp;
		default:
			return $author$project$Game$Plane;
	}
};
var $author$project$Game$updateMech = F3(
	function (update, game, unit) {
		var _v0 = unit.component;
		if (_v0.$ === 'UnitMech') {
			var mech = _v0.a;
			return _Utils_update(
				unit,
				{
					component: $author$project$Game$UnitMech(
						update(mech))
				});
		} else {
			return unit;
		}
	});
var $author$project$MechThink$deltaRally = F2(
	function (game, unit) {
		var _v0 = game.mode;
		if (_v0.$ === 'GameModeTeamSelection') {
			return A2(
				$author$project$Game$deltaUnit,
				unit.id,
				F2(
					function (g, u) {
						return A3(
							$author$project$Game$updateMech,
							function (m) {
								return _Utils_update(
									m,
									{
										_class: $author$project$MechThink$nextClass(m._class)
									});
							},
							g,
							_Utils_update(
								u,
								{maybeCharge: $elm$core$Maybe$Nothing}));
					}));
		} else {
			var _v1 = unit.maybeTeamId;
			if (_v1.$ === 'Nothing') {
				return $author$project$Game$deltaNone;
			} else {
				var teamId = _v1.a;
				return A2(
					$author$project$Game$deltaTeam,
					teamId,
					F2(
						function (g, t) {
							return ((g.time - t.markerTime) < 0.2) ? t : _Utils_update(
								t,
								{
									markerPosition: unit.position,
									markerTime: g.time,
									pathing: A2(
										$author$project$Pathfinding$makePaths,
										g,
										$author$project$Game$vec2Tile(unit.position))
								});
						}));
			}
		}
	});
var $author$project$MechThink$fly = F3(
	function (dp, game, unit) {
		return A2($elm_explorations$linear_algebra$Math$Vector2$add, unit.position, dp);
	});
var $author$project$Game$Charging = function (a) {
	return {$: 'Charging', a: a};
};
var $author$project$Game$Cooldown = function (a) {
	return {$: 'Cooldown', a: a};
};
var $author$project$Game$Stretching = function (a) {
	return {$: 'Stretching', a: a};
};
var $author$project$Game$UpwardSalvo = {$: 'UpwardSalvo'};
var $elm$core$Basics$degrees = function (angleInDegrees) {
	return (angleInDegrees * $elm$core$Basics$pi) / 180;
};
var $author$project$MechThink$spawnUpwardRocket = F3(
	function (game, unit, salvoIndex) {
		var _v0 = function () {
			var _v1 = A2($elm$core$Basics$modBy, 3, salvoIndex);
			switch (_v1) {
				case 0:
					return _Utils_Tuple2(
						-1,
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, 0));
				case 1:
					return _Utils_Tuple2(
						0,
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.1, 0));
				default:
					return _Utils_Tuple2(
						1,
						A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.2, 0));
			}
		}();
		var da = _v0.a;
		var dp = _v0.b;
		return $author$project$Projectile$deltaAdd(
			{
				angle: $elm$core$Basics$degrees(da + (0.7 * salvoIndex)),
				classId: $author$project$Game$UpwardSalvo,
				maybeTargetId: $elm$core$Maybe$Nothing,
				maybeTeamId: unit.maybeTeamId,
				position: A2($elm_explorations$linear_algebra$Math$Vector2$add, dp, unit.position)
			});
	});
var $author$project$MechThink$fireUpwardSalvo = F2(
	function (game, unit) {
		var intervalBetweenRockets = 0.1;
		var indexToDelta = function (index) {
			return A2(
				$author$project$Game$deltaLater,
				intervalBetweenRockets * index,
				A3($author$project$MechThink$spawnUpwardRocket, game, unit, index));
		};
		return $author$project$Game$deltaList(
			A2(
				$elm$core$List$map,
				indexToDelta,
				A2($elm$core$List$range, 0, $author$project$Stats$heli.salvoSize - 1)));
	});
var $author$project$Mech$heliSalvoPositions = F2(
	function (stretchTime, unit) {
		var minimumSpacing = 0.5;
		var maxRange = 20;
		var maximumSpacing = maxRange / $author$project$Stats$heli.salvoSize;
		var spacing = minimumSpacing + ((maximumSpacing - minimumSpacing) * (stretchTime / $author$project$Stats$heli.maxStretchTime));
		var distanceFromMech = 2;
		var direction = $author$project$Game$angleToVector(unit.lookAngle);
		var indexToVec = function (index) {
			return A2(
				$elm_explorations$linear_algebra$Math$Vector2$add,
				unit.position,
				A2($elm_explorations$linear_algebra$Math$Vector2$scale, distanceFromMech + (spacing * index), direction));
		};
		return A2(
			$elm$core$List$map,
			indexToVec,
			A2($elm$core$List$range, 1, $author$project$Stats$heli.salvoSize));
	});
var $author$project$Game$DownwardSalvo = {$: 'DownwardSalvo'};
var $author$project$MechThink$spawnDownwardRocket = function (_v0) {
	var target = _v0.target;
	var maybeTeamId = _v0.maybeTeamId;
	var angle = $elm$core$Basics$degrees(160);
	var direction = $author$project$Game$angleToVector(angle);
	var origin = A2(
		$elm_explorations$linear_algebra$Math$Vector2$sub,
		target,
		A2($elm_explorations$linear_algebra$Math$Vector2$scale, $author$project$Stats$downwardSalvo.range, direction));
	return $author$project$Projectile$deltaAdd(
		{angle: angle, classId: $author$project$Game$DownwardSalvo, maybeTargetId: $elm$core$Maybe$Nothing, maybeTeamId: maybeTeamId, position: origin});
};
var $author$project$MechThink$spawnDownwardRocketLater = F3(
	function (unit, index, destination) {
		var delay = index * 0.06;
		return A2(
			$author$project$Game$deltaLater,
			delay,
			$author$project$MechThink$spawnDownwardRocket(
				{maybeTeamId: unit.maybeTeamId, target: destination}));
	});
var $author$project$MechThink$spawnDownwardSalvo = F3(
	function (game, unit, stretchTime) {
		return $author$project$Game$deltaList(
			A2(
				$elm$core$List$indexedMap,
				$author$project$MechThink$spawnDownwardRocketLater(unit),
				A2($author$project$Mech$heliSalvoPositions, stretchTime, unit)));
	});
var $author$project$MechThink$heliFireDelta = F5(
	function (dt, game, unit, mech, isFiring) {
		var deltaResetCharge = A2(
			$author$project$Game$deltaUnit,
			unit.id,
			F2(
				function (g, u) {
					return _Utils_update(
						u,
						{maybeCharge: $elm$core$Maybe$Nothing});
				}));
		var deltaCharge = function (charge) {
			return A2(
				$author$project$Game$deltaUnit,
				unit.id,
				F2(
					function (g, u) {
						return _Utils_update(
							u,
							{
								maybeCharge: $elm$core$Maybe$Just(charge)
							});
					}));
		};
		var _v0 = unit.maybeCharge;
		if (_v0.$ === 'Nothing') {
			return (!isFiring) ? $author$project$Game$deltaNone : (_Utils_eq(
				$author$project$Mech$transformMode(mech),
				$author$project$Game$ToFlyer) ? A3($author$project$MechThink$attackDelta, game, unit, mech) : $author$project$Game$deltaList(
				_List_fromArray(
					[
						deltaCharge(
						$author$project$Game$Charging(game.time)),
						A3($author$project$MechThink$attackDelta, game, unit, mech)
					])));
		} else {
			switch (_v0.a.$) {
				case 'Charging':
					var startTime = _v0.a.a;
					return (!isFiring) ? deltaResetCharge : ((_Utils_cmp(game.time - startTime, $author$project$Stats$heli.chargeTime) > -1) ? $author$project$Game$deltaList(
						_List_fromArray(
							[
								deltaCharge(
								$author$project$Game$Stretching(game.time)),
								A2($author$project$MechThink$fireUpwardSalvo, game, unit)
							])) : $author$project$Game$deltaNone);
				case 'Stretching':
					var startTime = _v0.a.a;
					return (isFiring && (_Utils_cmp(game.time - startTime, $author$project$Stats$heli.maxStretchTime) < 0)) ? $author$project$Game$deltaNone : $author$project$Game$deltaList(
						_List_fromArray(
							[
								deltaCharge(
								$author$project$Game$Cooldown(game.time)),
								A3($author$project$MechThink$spawnDownwardSalvo, game, unit, game.time - startTime)
							]));
				default:
					var startTime = _v0.a.a;
					return (_Utils_cmp(game.time - startTime, $author$project$Stats$heli.cooldown) > 0) ? deltaResetCharge : $author$project$Game$deltaNone;
			}
		}
	});
var $author$project$MechThink$mechCanMove = F3(
	function (game, unit, mech) {
		var _v0 = _Utils_Tuple2(
			mech._class,
			$author$project$Mech$transformMode(mech));
		if ((_v0.a.$ === 'Heli') && (_v0.b.$ === 'ToMech')) {
			var _v1 = _v0.a;
			var _v2 = _v0.b;
			var _v3 = unit.maybeCharge;
			_v3$2:
			while (true) {
				if (_v3.$ === 'Just') {
					switch (_v3.a.$) {
						case 'Charging':
							var chargeStart = _v3.a.a;
							return (game.time - chargeStart) < 0.2;
						case 'Stretching':
							var stretchStart = _v3.a.a;
							return false;
						default:
							break _v3$2;
					}
				} else {
					break _v3$2;
				}
			}
			return true;
		} else {
			return true;
		}
	});
var $author$project$MechThink$mechCanTransform = F3(
	function (game, unit, mech) {
		var _v0 = _Utils_Tuple2(
			mech._class,
			$author$project$Mech$transformMode(mech));
		if ((_v0.a.$ === 'Heli') && (_v0.b.$ === 'ToMech')) {
			var _v1 = _v0.a;
			var _v2 = _v0.b;
			var _v3 = unit.maybeCharge;
			_v3$2:
			while (true) {
				if (_v3.$ === 'Just') {
					switch (_v3.a.$) {
						case 'Charging':
							var chargeStart = _v3.a.a;
							return false;
						case 'Stretching':
							var stretchStart = _v3.a.a;
							return false;
						default:
							break _v3$2;
					}
				} else {
					break _v3$2;
				}
			}
			return true;
		} else {
			return true;
		}
	});
var $author$project$MechThink$mechSpeed = function (mech) {
	var _v0 = $author$project$Mech$transformMode(mech);
	if (_v0.$ === 'ToMech') {
		var _v1 = mech._class;
		switch (_v1.$) {
			case 'Plane':
				return 5.0;
			case 'Heli':
				return 7.0;
			default:
				return 5.0;
		}
	} else {
		var _v2 = mech._class;
		switch (_v2.$) {
			case 'Plane':
				return 18.0;
			case 'Heli':
				return 12.0;
			default:
				return 8.0;
		}
	}
};
var $author$project$MechThink$mechTransformTo = F2(
	function (hasFreeGround, mech) {
		var _v0 = mech.transformingTo;
		if (_v0.$ === 'ToFlyer') {
			return ((mech.transformState === 1) && hasFreeGround) ? $author$project$Game$ToMech : mech.transformingTo;
		} else {
			return (!mech.transformState) ? $author$project$Game$ToFlyer : mech.transformingTo;
		}
	});
var $author$project$Game$GfxFractalBeam = F3(
	function (a, b, c) {
		return {$: 'GfxFractalBeam', a: a, b: b, c: c};
	});
var $author$project$View$Gfx$healingGreen = {
	bright: '#2d0',
	brightV: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 34 / 255, 221 / 255, 0),
	dark: '#090',
	darkV: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0, 153 / 255, 0),
	key: ''
};
var $author$project$View$Gfx$deltaAddRepairBeam = F2(
	function (start, end) {
		return $author$project$View$Gfx$deltaAddGfx(
			{
				duration: 0.04,
				render: A3($author$project$Game$GfxFractalBeam, start, end, $author$project$View$Gfx$healingGreen)
			});
	});
var $author$project$MechThink$repairTargetDelta = F3(
	function (dt, healer, target) {
		if (_Utils_eq(healer, target) || (target.integrity >= 1)) {
			return $author$project$Game$deltaNone;
		} else {
			var repairRate = 0.4;
			var repair = dt * repairRate;
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2(
						$author$project$Game$deltaUnit,
						target.id,
						F2(
							function (g, u) {
								return _Utils_update(
									u,
									{
										integrity: A2($elm$core$Basics$min, 1, u.integrity + repair)
									});
							})),
						A3($author$project$View$Gfx$deltaAddRepairBubbles, 0.1, dt, target.position),
						A2($author$project$View$Gfx$deltaAddRepairBeam, healer.position, target.position)
					]));
		}
	});
var $author$project$MechThink$repairAllies = F3(
	function (dt, game, unit) {
		return $author$project$Game$deltaList(
			A3(
				$author$project$Unit$filterAndMapAll,
				game,
				function (u) {
					return _Utils_eq(u.maybeTeamId, unit.maybeTeamId) && (_Utils_cmp(
						A2($elm_explorations$linear_algebra$Math$Vector2$distance, u.position, unit.position),
						$author$project$Stats$plane.repairRange) < 0);
				},
				A2($author$project$MechThink$repairTargetDelta, dt, unit)));
	});
var $author$project$MechThink$repairDelta = F4(
	function (dt, game, unit, mech) {
		if (unit.integrity >= 1) {
			return $author$project$Game$deltaNone;
		} else {
			var canRepair = function (base) {
				var _v1 = base.maybeOccupied;
				if (_v1.$ === 'Nothing') {
					return false;
				} else {
					var occupied = _v1.a;
					return (occupied.isActive && (_Utils_eq(occupied.maybeTeamId, unit.maybeTeamId) && (occupied.subBuildCompletion > 0))) && (_Utils_cmp(
						A2($elm_explorations$linear_algebra$Math$Vector2$distanceSquared, base.position, unit.position),
						3 * 3) < 0);
				}
			};
			var _v0 = A2(
				$elm_community$list_extra$List$Extra$find,
				canRepair,
				$elm$core$Dict$values(game.baseById));
			if (_v0.$ === 'Nothing') {
				return $author$project$Game$deltaNone;
			} else {
				var base = _v0.a;
				return $author$project$Game$deltaList(
					_List_fromArray(
						[
							A3($author$project$Base$deltaRepairUnit, dt, base.id, unit.id),
							A2($author$project$View$Gfx$deltaAddRepairBeam, base.position, unit.position),
							A3($author$project$View$Gfx$deltaAddRepairBubbles, 4, dt, unit.position)
						]));
			}
		}
	});
var $author$project$MechThink$repairSelf = F2(
	function (dt, unit) {
		if (unit.integrity >= 1) {
			return $author$project$Game$deltaNone;
		} else {
			var repairRate = 0.15;
			var repair = dt * repairRate;
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A2(
						$author$project$Game$deltaUnit,
						unit.id,
						F2(
							function (g, u) {
								return _Utils_update(
									u,
									{
										integrity: A2($elm$core$Basics$min, 1, u.integrity + repair)
									});
							})),
						A3($author$project$View$Gfx$deltaAddRepairBubbles, 1, dt, unit.position)
					]));
		}
	});
var $author$project$Stats$transformTime = 0.5;
var $author$project$View$Gfx$vampireRed = {
	bright: '#f11',
	brightV: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 17 / 255, 17 / 255),
	dark: '#c33',
	darkV: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 204 / 255, 51 / 255, 51 / 255),
	key: ''
};
var $author$project$View$Gfx$deltaAddVampireBeam = F2(
	function (start, end) {
		return $author$project$View$Gfx$deltaAddGfx(
			{
				duration: 0.02,
				render: A3($author$project$Game$GfxFractalBeam, start, end, $author$project$View$Gfx$vampireRed)
			});
	});
var $author$project$MechThink$emptyVampire = F4(
	function (dt, unit, newPosition, game) {
		var start = newPosition;
		var angle = $author$project$Game$normalizeAngle(game.time + unit.id);
		var end = A2(
			$elm_explorations$linear_algebra$Math$Vector2$add,
			start,
			A2(
				$author$project$Game$rotateVector,
				angle,
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0, $author$project$Stats$blimp.vampireRange)));
		return A2($author$project$View$Gfx$deltaAddVampireBeam, start, end);
	});
var $author$project$Unit$takePiercingDamage = F3(
	function (rawDamage, game, unit) {
		var _v0 = $author$project$Unit$hitPointsAndArmor(unit);
		var healthPoints = _v0.a;
		var armor = _v0.b;
		var damage = A2($elm$core$Basics$max, 0, rawDamage / healthPoints);
		return A3($author$project$Unit$removeIntegrity, damage, game, unit);
	});
var $author$project$MechThink$vampireTargetDelta = F3(
	function (dt, attacker, target) {
		var healRatio = 0.005;
		var damageRate = function () {
			var _v0 = target.component;
			if (_v0.$ === 'UnitMech') {
				return 40;
			} else {
				var sub = _v0.a;
				return 14;
			}
		}();
		var damage = dt * damageRate;
		var repair = damage * healRatio;
		return $author$project$Game$deltaList(
			_List_fromArray(
				[
					A2(
					$author$project$Game$deltaUnit,
					attacker.id,
					F2(
						function (g, u) {
							return _Utils_update(
								u,
								{
									integrity: A2($elm$core$Basics$min, 1, u.integrity + repair)
								});
						})),
					A2(
					$author$project$Game$deltaUnit,
					target.id,
					$author$project$Unit$takePiercingDamage(damage)),
					A3($author$project$View$Gfx$deltaAddRepairBubbles, 1.0, dt, attacker.position),
					A2($author$project$View$Gfx$deltaAddVampireBeam, attacker.position, target.position)
				]));
	});
var $author$project$MechThink$vampireDelta = F5(
	function (dt, game, unit, mech, newPosition) {
		if (_Utils_eq(
			$author$project$Mech$transformMode(mech),
			$author$project$Game$ToMech)) {
			return $author$project$Game$deltaNone;
		} else {
			var deltas = A3(
				$author$project$Unit$filterAndMapAll,
				game,
				function (u) {
					return (!_Utils_eq(u.maybeTeamId, unit.maybeTeamId)) && (_Utils_cmp(
						A2($elm_explorations$linear_algebra$Math$Vector2$distance, u.position, unit.position),
						$author$project$Stats$blimp.vampireRange) < 0);
				},
				A2($author$project$MechThink$vampireTargetDelta, dt, unit));
			return (!_Utils_eq(deltas, _List_Nil)) ? $author$project$Game$deltaList(deltas) : A4($author$project$MechThink$emptyVampire, dt, unit, newPosition, game);
		}
	});
var $author$project$MechThink$walk = F3(
	function (dp, game, unit) {
		var originalPosition = unit.position;
		var originalTile = $author$project$Game$vec2Tile(originalPosition);
		var isObstacle = function (tile) {
			return A2($elm$core$Set$member, tile, game.staticObstacles);
		};
		var idealPosition = A2($elm_explorations$linear_algebra$Math$Vector2$add, originalPosition, dp);
		var idealTile = $author$project$Game$vec2Tile(idealPosition);
		var idealPositionIsObstacle = isObstacle(idealTile);
		var didNotChangeTile = _Utils_eq(idealTile, originalTile);
		if (didNotChangeTile || (!idealPositionIsObstacle)) {
			return idealPosition;
		} else {
			var i = $elm_explorations$linear_algebra$Math$Vector2$toRecord(idealPosition);
			var _v0 = originalTile;
			var tX = _v0.a;
			var tY = _v0.b;
			var oX = tX;
			var bottomTile = _Utils_Tuple2(tX, tY - 1);
			var leftTile = _Utils_Tuple2(tX - 1, tY);
			var minX = isObstacle(leftTile) ? oX : (oX - 1);
			var oY = tY;
			var minY = isObstacle(bottomTile) ? oY : (oY - 1);
			var rightTile = _Utils_Tuple2(tX + 1, tY);
			var maxX = isObstacle(rightTile) ? (oX + 0.99) : (oX + 1.99);
			var fX = A3($elm$core$Basics$clamp, minX, maxX, i.x);
			var topTile = _Utils_Tuple2(tX, tY + 1);
			var maxY = isObstacle(topTile) ? (oY + 0.99) : (oY + 1.99);
			var fY = A3($elm$core$Basics$clamp, minY, maxY, i.y);
			return A2($elm_explorations$linear_algebra$Math$Vector2$vec2, fX, fY);
		}
	});
var $author$project$MechThink$mechThink = F5(
	function (_v0, dt, game, unit, mech) {
		var previousInput = _v0.a;
		var currentInput = _v0.b;
		var rally = (currentInput.rally && (!previousInput.rally)) ? A2($author$project$MechThink$deltaRally, game, unit) : $author$project$Game$deltaNone;
		var mode = $author$project$Mech$transformMode(mech);
		var deltaPassive = function () {
			var _v4 = mech._class;
			switch (_v4.$) {
				case 'Plane':
					if (mode.$ === 'ToFlyer') {
						return A3($author$project$MechThink$repairAllies, dt, game, unit);
					} else {
						return A2($author$project$MechThink$repairSelf, dt, unit);
					}
				case 'Heli':
					return $author$project$Game$deltaNone;
				default:
					return $author$project$Game$deltaNone;
			}
		}();
		var canTransform = A3($author$project$MechThink$mechCanTransform, game, unit, mech);
		var canMove = A3($author$project$MechThink$mechCanMove, game, unit, mech);
		var isMoving = canMove && (_Utils_cmp(
			$elm_explorations$linear_algebra$Math$Vector2$length(currentInput.move),
			$author$project$MechThink$controlThreshold) > 0);
		var newPosition = function () {
			if (!isMoving) {
				return unit.position;
			} else {
				var updatePosition = function () {
					if (mode.$ === 'ToMech') {
						return $author$project$MechThink$walk;
					} else {
						return $author$project$MechThink$fly;
					}
				}();
				var dx = A2(
					$elm_explorations$linear_algebra$Math$Vector2$scale,
					$author$project$MechThink$mechSpeed(mech) * dt,
					A2($author$project$Game$clampToRadius, 1, currentInput.move));
				return A3(
					$author$project$Game$clampToGameSize,
					game,
					1,
					A3(updatePosition, dx, game, unit));
			}
		}();
		var fire = _Utils_eq(mech._class, $author$project$Game$Heli) ? A5($author$project$MechThink$heliFireDelta, dt, game, unit, mech, currentInput.fire) : ((!currentInput.fire) ? $author$project$Game$deltaNone : ((_Utils_eq(mech._class, $author$project$Game$Blimp) && _Utils_eq(mode, $author$project$Game$ToFlyer)) ? A5($author$project$MechThink$vampireDelta, dt, game, unit, mech, newPosition) : A3($author$project$MechThink$attackDelta, game, unit, mech)));
		var hasFreeGround = !A2(
			$elm$core$Set$member,
			$author$project$Game$vec2Tile(newPosition),
			game.staticObstacles);
		var transformingTo = (!(currentInput.transform && canTransform)) ? mech.transformingTo : A2($author$project$MechThink$mechTransformTo, hasFreeGround, mech);
		var transformDirection = function () {
			if (transformingTo.$ === 'ToMech') {
				return $elm$core$Basics$sub;
			} else {
				return $elm$core$Basics$add;
			}
		}();
		var updateTransform = function (m) {
			return _Utils_update(
				m,
				{
					transformState: A3(
						$elm$core$Basics$clamp,
						0,
						1,
						A2(transformDirection, mech.transformState, dt / $author$project$Stats$transformTime)),
					transformingTo: transformingTo
				});
		};
		var aimDirection = function () {
			var _v1 = currentInput.aim;
			if (_v1.$ === 'AimAbsolute') {
				var direction = _v1.a;
				return direction;
			} else {
				var mousePosition = _v1.a;
				return A2($elm_explorations$linear_algebra$Math$Vector2$sub, mousePosition, unit.position);
			}
		}();
		var isAiming = _Utils_cmp(
			$elm_explorations$linear_algebra$Math$Vector2$length(aimDirection),
			$author$project$MechThink$controlThreshold) > 0;
		var aimAngle = isAiming ? $author$project$Game$vecToAngle(aimDirection) : (isMoving ? $author$project$Game$vecToAngle(currentInput.move) : unit.fireAngle);
		var updateAim = function (u) {
			return _Utils_update(
				u,
				{
					fireAngle: A3($author$project$Game$turnTo, (2 * $elm$core$Basics$pi) * dt, aimAngle, u.fireAngle),
					lookAngle: A3($author$project$Game$turnTo, (5 * $elm$core$Basics$pi) * dt, aimAngle, u.lookAngle)
				});
		};
		var update = F2(
			function (g, u) {
				return A3(
					$author$project$Game$updateMech,
					updateTransform,
					g,
					updateAim(
						_Utils_update(
							u,
							{position: newPosition})));
			});
		return $author$project$Game$deltaList(
			_List_fromArray(
				[
					A2($author$project$Game$deltaUnit, unit.id, update),
					rally,
					fire,
					A4($author$project$MechThink$repairDelta, dt, game, unit, mech),
					deltaPassive
				]));
	});
var $author$project$Game$removeUnit = F2(
	function (id, game) {
		return _Utils_update(
			game,
			{
				unitById: A2($elm$core$Dict$remove, id, game.unitById)
			});
	});
var $author$project$Game$GfxFlyingHead = F4(
	function (a, b, c, d) {
		return {$: 'GfxFlyingHead', a: a, b: b, c: c, d: d};
	});
var $author$project$View$Gfx$deltaAddFlyingHead = F4(
	function (_class, origin, destination, colorPattern) {
		var speed = 30;
		var duration = A2($elm_explorations$linear_algebra$Math$Vector2$distance, origin, destination) / speed;
		return $author$project$View$Gfx$deltaAddGfx(
			{
				duration: duration,
				render: A4($author$project$Game$GfxFlyingHead, _class, origin, destination, colorPattern)
			});
	});
var $author$project$UnitThink$respawnMech = F3(
	function (game, unit, mech) {
		var _v0 = A2($author$project$Base$teamMainBase, game, unit.maybeTeamId);
		if (_v0.$ === 'Nothing') {
			return $author$project$Game$deltaNone;
		} else {
			var mainBase = _v0.a;
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A4(
						$author$project$View$Gfx$deltaAddFlyingHead,
						mech._class,
						unit.position,
						mainBase.position,
						A2($author$project$Game$teamColorPattern, game, unit.maybeTeamId)),
						A2(
						$author$project$Game$deltaBase,
						mainBase.id,
						$author$project$Base$updateOccupied(
							function (o) {
								return _Utils_update(
									o,
									{
										mechBuildCompletions: A2(
											$elm$core$List$cons,
											_Utils_Tuple2(mech, 0),
											o.mechBuildCompletions)
									});
							}))
					]));
		}
	});
var $author$project$Base$unitCanEnter = F2(
	function (unit, base) {
		var _v0 = base.maybeOccupied;
		if (_v0.$ === 'Nothing') {
			return !_Utils_eq(base.type_, $author$project$Game$BaseMain);
		} else {
			var occupied = _v0.a;
			return _Utils_eq(occupied.maybeTeamId, unit.maybeTeamId) && (_Utils_cmp(
				$elm$core$Set$size(occupied.unitIds),
				$author$project$Base$maxContainedUnits) < 0);
		}
	});
var $author$project$SubThink$deltaGameUnitEntersBase = F3(
	function (unitId, baseId, game) {
		return A3(
			$author$project$Game$withUnit,
			game,
			unitId,
			function (unit) {
				return A3(
					$author$project$Game$withBase,
					game,
					baseId,
					function (base) {
						return A2($author$project$Base$unitCanEnter, unit, base) ? A3($author$project$SubThink$updateUnitEntersBase, unit, base, game) : game;
					});
			});
	});
var $author$project$Base$maximumDistanceForUnitToEnterBase = 2.1;
var $author$project$SubThink$deltaGameUnitMoves = F4(
	function (unitId, moveAngle, dx, game) {
		return A3(
			$author$project$Game$withUnit,
			game,
			unitId,
			function (unit) {
				var newPosition = A2($elm_explorations$linear_algebra$Math$Vector2$add, unit.position, dx);
				var newTilePosition = $author$project$Game$vec2Tile(newPosition);
				var currentTilePosition = $author$project$Game$vec2Tile(unit.position);
				if ((!_Utils_eq(currentTilePosition, newTilePosition)) && A2($elm$core$Set$member, newTilePosition, game.dynamicObstacles)) {
					return game;
				} else {
					var newUnit = _Utils_update(
						unit,
						{moveAngle: moveAngle, position: newPosition});
					var dynamicObstacles = A2($elm$core$Set$insert, newTilePosition, game.dynamicObstacles);
					return A2(
						$author$project$Game$updateUnit,
						newUnit,
						_Utils_update(
							game,
							{dynamicObstacles: dynamicObstacles}));
				}
			});
	});
var $author$project$SubThink$subSpeed = 1.0;
var $author$project$SubThink$move = F4(
	function (dt, game, targetPosition, unit) {
		var targetDistance = 0;
		if (_Utils_cmp(
			A2($author$project$Game$vectorDistance, unit.position, targetPosition),
			targetDistance) < 1) {
			return $author$project$Game$deltaNone;
		} else {
			var unitTile = $author$project$Game$vec2Tile(unit.position);
			var maxLength = $author$project$SubThink$subSpeed * dt;
			var idealDelta = A2($elm_explorations$linear_algebra$Math$Vector2$sub, targetPosition, unit.position);
			var viableDelta = A2($author$project$Game$clampToRadius, maxLength, idealDelta);
			var moveAngle = A3(
				$author$project$Game$turnTo,
				(2 * $elm$core$Basics$pi) * dt,
				$author$project$Game$vecToAngle(viableDelta),
				unit.moveAngle);
			return $author$project$Game$deltaGame(
				A3($author$project$SubThink$deltaGameUnitMoves, unit.id, moveAngle, viableDelta));
		}
	});
var $author$project$Pathfinding$moves = F3(
	function (game, startTile, paths) {
		var mapTile = function (tile) {
			return A2(
				$elm$core$Maybe$map,
				function (distance) {
					return _Utils_Tuple2(tile, distance);
				},
				A2($elm$core$Dict$get, tile, paths));
		};
		var currentDistance = A2(
			$elm$core$Maybe$withDefault,
			999,
			A2($elm$core$Dict$get, startTile, paths));
		return A2(
			$elm$core$List$map,
			$elm$core$Tuple$first,
			A2(
				$elm$core$List$sortBy,
				$elm$core$Tuple$second,
				A2(
					$elm$core$List$filter,
					function (_v0) {
						var tile = _v0.a;
						var distance = _v0.b;
						return _Utils_cmp(distance, currentDistance) < 0;
					},
					A2(
						$elm$core$List$filterMap,
						mapTile,
						A2(
							$elm$core$List$map,
							$elm$core$Tuple$first,
							$elm$core$Set$toList(
								A2($author$project$Pathfinding$availableMoves, game, startTile)))))));
	});
var $author$project$SubThink$movePath = F4(
	function (dt, game, paths, unit) {
		var unitTile = $author$project$Game$vec2Tile(unit.position);
		var maybeTile = A2(
			$elm_community$list_extra$List$Extra$find,
			function (t) {
				return !A2($elm$core$Set$member, t, game.dynamicObstacles);
			},
			A3($author$project$Pathfinding$moves, game, unitTile, paths));
		if (maybeTile.$ === 'Nothing') {
			return $author$project$Game$deltaNone;
		} else {
			var targetTile = maybeTile.a;
			return A4(
				$author$project$SubThink$move,
				dt,
				game,
				$author$project$Game$tile2Vec(targetTile),
				unit);
		}
	});
var $author$project$SubThink$thinkMovement = F4(
	function (dt, game, unit, sub) {
		var _v0 = sub.mode;
		if (_v0.$ === 'UnitModeBase') {
			var baseId = _v0.a;
			return $author$project$Game$deltaNone;
		} else {
			if (unit.isLeavingBase) {
				return A2(
					$author$project$Game$deltaUnit,
					unit.id,
					A2(
						$elm$core$Set$member,
						$author$project$Game$vec2Tile(unit.position),
						game.staticObstacles) ? F2(
						function (g, u) {
							return _Utils_update(
								u,
								{
									position: A2(
										$elm_explorations$linear_algebra$Math$Vector2$add,
										u.position,
										A2(
											$elm_explorations$linear_algebra$Math$Vector2$scale,
											dt * $author$project$SubThink$subSpeed,
											$author$project$Game$angleToVector(unit.moveAngle)))
								});
						}) : F2(
						function (g, u) {
							return _Utils_update(
								u,
								{isLeavingBase: false});
						}));
			} else {
				var _v1 = A2($author$project$Game$maybeGetTeam, game, unit.maybeTeamId);
				if (_v1.$ === 'Nothing') {
					return $author$project$Game$deltaNone;
				} else {
					var team = _v1.a;
					if (sub.isBig) {
						return A4($author$project$SubThink$movePath, dt, game, team.pathing, unit);
					} else {
						var conquerBaseDistanceThreshold = 3.0;
						var baseDistance = function (base) {
							return A2($author$project$Game$vectorDistance, base.position, unit.position) - (($author$project$Base$size(base.type_) / 2) | 0);
						};
						var baseIsConquerable = function (base) {
							return (_Utils_cmp(
								baseDistance(base),
								conquerBaseDistanceThreshold) < 0) && A2($author$project$Base$unitCanEnter, unit, base);
						};
						var _v2 = A2(
							$elm_community$list_extra$List$Extra$find,
							baseIsConquerable,
							$elm$core$Dict$values(game.baseById));
						if (_v2.$ === 'Just') {
							var base = _v2.a;
							return (_Utils_cmp(
								baseDistance(base),
								$author$project$Base$maximumDistanceForUnitToEnterBase) > 0) ? A4($author$project$SubThink$move, dt, game, base.position, unit) : $author$project$Game$deltaGame(
								A2($author$project$SubThink$deltaGameUnitEntersBase, unit.id, base.id));
						} else {
							return A4($author$project$SubThink$movePath, dt, game, team.pathing, unit);
						}
					}
				}
			}
		}
	});
var $author$project$SubThink$thinkRegenerate = F4(
	function (dt, game, unit, sub) {
		if ((!sub.isBig) || (unit.integrity >= 1)) {
			return $author$project$Game$deltaNone;
		} else {
			var repair = 0.03 * dt;
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						A3($author$project$View$Gfx$deltaAddRepairBubbles, 0.3, dt, unit.position),
						A2(
						$author$project$Game$deltaUnit,
						unit.id,
						F2(
							function (g, u) {
								return _Utils_update(
									u,
									{
										integrity: A2($elm$core$Basics$min, 1, u.integrity + repair)
									});
							}))
					]));
		}
	});
var $author$project$Game$BigSubBullet = {$: 'BigSubBullet'};
var $author$project$View$Sub$gunOffset = function (torsoAngle) {
	return A2(
		$author$project$Game$rotateVector,
		torsoAngle,
		A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.3, 0));
};
var $author$project$Stats$subShootRange = function (sub) {
	return sub.isBig ? 8.0 : 7.0;
};
var $author$project$SubThink$searchForTargets = F3(
	function (game, unit, sub) {
		var targetPriority = F2(
			function (distance, target) {
				if (sub.isBig) {
					var _v2 = target.component;
					if (_v2.$ === 'UnitMech') {
						var mech = _v2.a;
						return -8;
					} else {
						var s = _v2.a;
						var _v3 = s.mode;
						if (_v3.$ === 'UnitModeBase') {
							var baseId = _v3.a;
							return -8;
						} else {
							return -distance;
						}
					}
				} else {
					var _v4 = target.component;
					if (_v4.$ === 'UnitMech') {
						var mech = _v4.a;
						return 1;
					} else {
						var s = _v4.a;
						var _v5 = s.mode;
						if (_v5.$ === 'UnitModeBase') {
							var baseId = _v5.a;
							return 2;
						} else {
							return -distance;
						}
					}
				}
			});
		var validTargetPriority = function (target) {
			if (_Utils_eq(target.maybeTeamId, unit.maybeTeamId)) {
				return $elm$core$Maybe$Nothing;
			} else {
				var distance = A2($author$project$Game$vectorDistance, unit.position, target.position);
				return (_Utils_cmp(
					distance,
					$author$project$Stats$subShootRange(sub)) > 0) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
					_Utils_Tuple2(
						target,
						A2(targetPriority, distance, target)));
			}
		};
		var setTarget = function (_v1) {
			var target = _v1.a;
			var priority = _v1.b;
			return A2(
				$author$project$Game$deltaUnit,
				unit.id,
				$author$project$Game$updateSub(
					function (s) {
						return _Utils_update(
							s,
							{targetId: target.id});
					}));
		};
		var ifCloseEnough = function (_v0) {
			var target = _v0.a;
			var priority = _v0.b;
			return (_Utils_cmp(
				A2($author$project$Game$vectorDistance, unit.position, target.position),
				$author$project$Stats$subShootRange(sub)) > 0) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
				A2(
					$author$project$Game$deltaUnit,
					unit.id,
					$author$project$Game$updateSub(
						function (s) {
							return _Utils_update(
								s,
								{targetId: target.id});
						})));
		};
		return A2(
			$elm$core$Maybe$map,
			setTarget,
			A2(
				$elm_community$list_extra$List$Extra$maximumBy,
				$elm$core$Tuple$second,
				A2(
					$elm$core$List$filterMap,
					validTargetPriority,
					$elm$core$Dict$values(game.unitById))));
	});
var $author$project$SubThink$unitAlignsAimToMovement = F2(
	function (dt, unit) {
		return A2(
			$author$project$Game$deltaUnit,
			unit.id,
			F2(
				function (g, u) {
					return _Utils_update(
						u,
						{
							fireAngle: A3($author$project$Game$turnTo, (2 * $elm$core$Basics$pi) * dt, unit.moveAngle, unit.fireAngle),
							lookAngle: A3($author$project$Game$turnTo, (5 * $elm$core$Basics$pi) * dt, unit.moveAngle, unit.lookAngle)
						});
				}));
	});
var $author$project$SubThink$searchForTargetOrAlignToMovement = F4(
	function (dt, game, unit, sub) {
		var _v0 = A3($author$project$SubThink$searchForTargets, game, unit, sub);
		if (_v0.$ === 'Just') {
			var delta = _v0.a;
			return delta;
		} else {
			return A2($author$project$SubThink$unitAlignsAimToMovement, dt, unit);
		}
	});
var $author$project$Stats$subReloadTime = function (sub) {
	return sub.isBig ? 0.4 : 4.0;
};
var $author$project$Stats$subShootDamage = function (sub) {
	return sub.isBig ? 4 : 11;
};
var $author$project$SubThink$thinkTarget = F4(
	function (dt, game, unit, sub) {
		var _v0 = A2($elm$core$Dict$get, sub.targetId, game.unitById);
		if (_v0.$ === 'Nothing') {
			return A4($author$project$SubThink$searchForTargetOrAlignToMovement, dt, game, unit, sub);
		} else {
			var target = _v0.a;
			if (_Utils_cmp(
				A2($author$project$Game$vectorDistance, unit.position, target.position),
				$author$project$Stats$subShootRange(sub)) > 0) {
				return A4($author$project$SubThink$searchForTargetOrAlignToMovement, dt, game, unit, sub);
			} else {
				var dp = A2($elm_explorations$linear_algebra$Math$Vector2$sub, target.position, unit.position);
				return $author$project$Game$deltaList(
					_List_fromArray(
						[
							A2(
							$author$project$Game$deltaUnit,
							unit.id,
							F2(
								function (g, u) {
									return _Utils_update(
										u,
										{
											fireAngle: A3(
												$author$project$Game$turnTo,
												(2 * $elm$core$Basics$pi) * dt,
												$author$project$Game$vecToAngle(dp),
												unit.fireAngle),
											lookAngle: A3(
												$author$project$Game$turnTo,
												(5 * $elm$core$Basics$pi) * dt,
												$author$project$Game$vecToAngle(dp),
												unit.lookAngle)
										});
								})),
							$author$project$Game$deltaList(
							((_Utils_cmp(game.time, unit.reloadEndTime) < 0) || (_Utils_cmp(
								$elm_explorations$linear_algebra$Math$Vector2$lengthSquared(dp),
								A2(
									$elm$core$Basics$pow,
									$author$project$Stats$subShootRange(sub),
									2)) > 0)) ? _List_Nil : _List_fromArray(
								[
									A2(
									$author$project$Game$deltaUnit,
									unit.id,
									F2(
										function (g, u) {
											return _Utils_update(
												u,
												{
													reloadEndTime: game.time + $author$project$Stats$subReloadTime(sub)
												});
										})),
									function () {
									var origin = A2(
										$elm_explorations$linear_algebra$Math$Vector2$add,
										unit.position,
										$author$project$View$Sub$gunOffset(unit.moveAngle));
									var damage = $author$project$Stats$subShootDamage(sub);
									var _v1 = sub.isBig;
									if (!_v1) {
										return $author$project$Game$deltaList(
											_List_fromArray(
												[
													A2(
													$author$project$Game$deltaUnit,
													target.id,
													$author$project$Unit$takeDamage(damage)),
													A3(
													$author$project$View$Gfx$deltaAddBeam,
													origin,
													target.position,
													A2($author$project$Game$teamColorPattern, game, unit.maybeTeamId))
												]));
									} else {
										return $author$project$Projectile$deltaAdd(
											{angle: unit.fireAngle, classId: $author$project$Game$BigSubBullet, maybeTargetId: $elm$core$Maybe$Nothing, maybeTeamId: unit.maybeTeamId, position: origin});
									}
								}()
								]))
						]));
			}
		}
	});
var $author$project$SubThink$think = F4(
	function (dt, game, unit, sub) {
		return $author$project$Game$deltaList(
			_List_fromArray(
				[
					A4($author$project$SubThink$thinkTarget, dt, game, unit, sub),
					A4($author$project$SubThink$thinkMovement, dt, game, unit, sub),
					A4($author$project$SubThink$thinkRegenerate, dt, game, unit, sub)
				]));
	});
var $author$project$UnitThink$think = F4(
	function (dt, pairedInputStates, game, unit) {
		if (unit.integrity <= 0) {
			return $author$project$Game$deltaList(
				_List_fromArray(
					[
						$author$project$Game$deltaGame(
						$author$project$Game$removeUnit(unit.id)),
						A2($author$project$View$Gfx$deltaAddExplosion, unit.position, 1.0),
						function () {
						var _v0 = unit.component;
						if (_v0.$ === 'UnitSub') {
							var sub = _v0.a;
							return $author$project$Game$deltaList(
								_List_fromArray(
									[
										A3($author$project$SubThink$destroy, game, unit, sub),
										A4($author$project$View$Gfx$deltaAddFrags, game, 10, unit.position, unit.maybeTeamId)
									]));
						} else {
							var mech = _v0.a;
							return $author$project$Game$deltaList(
								_List_fromArray(
									[
										A3($author$project$UnitThink$respawnMech, game, unit, mech),
										$author$project$UnitThink$addBigSubsToEnemyTeam(unit),
										A4($author$project$View$Gfx$deltaAddFrags, game, 40, unit.position, unit.maybeTeamId),
										$author$project$Game$deltaShake(0.06)
									]));
						}
					}()
					]));
		} else {
			var _v1 = unit.component;
			if (_v1.$ === 'UnitSub') {
				var sub = _v1.a;
				return A4($author$project$SubThink$think, dt, game, unit, sub);
			} else {
				var mech = _v1.a;
				var input = A2(
					$elm$core$Maybe$withDefault,
					_Utils_Tuple2($author$project$Game$inputStateNeutral, $author$project$Game$inputStateNeutral),
					A2($elm$core$Dict$get, mech.inputKey, pairedInputStates));
				return A5($author$project$MechThink$mechThink, input, dt, game, unit, mech);
			}
		}
	});
var $author$project$Game$OutcomeCanInitBots = {$: 'OutcomeCanInitBots'};
var $author$project$Init$asVersusFromTeamSelection = F2(
	function (map, game) {
		var team = function (t) {
			return {colorPattern: t.colorPattern, mechClassByInputKey: t.mechClassByInputKey};
		};
		return A5(
			$author$project$Init$asVersus,
			game.seed,
			game.time,
			team(game.leftTeam),
			team(game.rightTeam),
			map);
	});
var $author$project$Update$transitionDuration = 0.1;
var $author$project$Update$transitionThink = function (game) {
	var _v0 = game.maybeTransition;
	if (_v0.$ === 'Nothing') {
		return $author$project$Game$deltaNone;
	} else {
		var start = _v0.a.start;
		var fade = _v0.a.fade;
		if (_Utils_cmp(game.time - start, $author$project$Update$transitionDuration) < 0) {
			return $author$project$Game$deltaNone;
		} else {
			if (fade.$ === 'GameFadeIn') {
				return $author$project$Game$deltaGame(
					function (g) {
						return _Utils_update(
							g,
							{maybeTransition: $elm$core$Maybe$Nothing});
					});
			} else {
				var _v2 = game.mode;
				if (_v2.$ === 'GameModeTeamSelection') {
					var map = _v2.a;
					return $author$project$Game$deltaList(
						_List_fromArray(
							[
								$author$project$Game$deltaGame(
								$author$project$Init$asVersusFromTeamSelection(map)),
								$author$project$Game$DeltaOutcome($author$project$Game$OutcomeCanInitBots)
							]));
				} else {
					return $author$project$Game$deltaNone;
				}
			}
		}
	}
};
var $author$project$Update$update = F3(
	function (uncappedDt, pairedInputStatesByKey, oldGame) {
		var units = $elm$core$Dict$values(oldGame.unitById);
		var dt = oldGame.timeMultiplier * A2($elm$core$Basics$min, 0.1, uncappedDt);
		var newTime = oldGame.time + dt;
		var _v0 = A2(
			$elm$core$List$partition,
			function (_v1) {
				var scheduledTime = _v1.a;
				var delta = _v1.b;
				return _Utils_cmp(scheduledTime, newTime) < 0;
			},
			oldGame.laters);
		var latersToExecute = _v0.a;
		var latersToStore = _v0.b;
		var tempGame = _Utils_update(
			oldGame,
			{
				cosmetics: A2(
					$elm$core$List$filter,
					function (c) {
						return _Utils_cmp(newTime, c.removeTime) < 0;
					},
					oldGame.cosmetics),
				dynamicObstacles: $elm$core$Set$fromList(
					A2(
						$elm$core$List$map,
						A2(
							$elm$core$Basics$composeR,
							function ($) {
								return $.position;
							},
							$author$project$Game$vec2Tile),
						units)),
				laters: latersToStore,
				time: newTime
			});
		return A2(
			$author$project$Update$applyGameDeltas,
			tempGame,
			A2(
				$elm$core$List$map,
				$author$project$Game$deltaList,
				_List_fromArray(
					[
						A2($elm$core$List$map, $elm$core$Tuple$second, latersToExecute),
						A2(
						$elm$core$List$map,
						A3($author$project$UnitThink$think, dt, pairedInputStatesByKey, tempGame),
						units),
						_List_fromArray(
						[
							function () {
							var _v2 = tempGame.mode;
							if (_v2.$ === 'GameModeTeamSelection') {
								return A2(
									$author$project$SetupPhase$think,
									$elm$core$Dict$keys(pairedInputStatesByKey),
									tempGame);
							} else {
								return $author$project$Game$deltaNone;
							}
						}()
						]),
						_List_fromArray(
						[
							$author$project$Update$transitionThink(tempGame),
							$author$project$Game$deltaGame(
							$author$project$Update$screenShake(dt)),
							$author$project$Game$deltaGame(
							$author$project$Update$slowMotion(dt))
						]),
						A2(
						$elm$core$List$map,
						A2($author$project$BaseThink$think, dt, tempGame),
						$elm$core$Dict$values(tempGame.baseById)),
						A2(
						$elm$core$List$map,
						A2($author$project$ProjectileThink$think, dt, tempGame),
						$elm$core$Dict$values(tempGame.projectileById))
					])));
	});
var $author$project$MainScene$updateOnGamepad = F3(
	function (gamepadBlob, shell, model) {
		var pairInputStateWithPrevious = F2(
			function (inputKey, currentInputState) {
				var _v2 = A2($elm$core$Dict$get, inputKey, model.previousInputStatesByKey);
				if (_v2.$ === 'Just') {
					var previousInputState = _v2.a;
					return _Utils_Tuple2(previousInputState, currentInputState);
				} else {
					return _Utils_Tuple2(currentInputState, currentInputState);
				}
			});
		var gamepadsInputByKey = $elm$core$Dict$fromList(
			A2(
				$elm$core$List$map,
				$author$project$MainScene$gamepadToInput,
				A2($xarvh$elm_gamepad$Gamepad$getGamepads, shell.config.gamepadDatabase, gamepadBlob)));
		var keyAndMouse = (shell.config.useKeyboardAndMouse || (!$elm$core$Dict$size(gamepadsInputByKey))) ? A2(
			$elm$core$Dict$singleton,
			$author$project$MainScene$inputKeyboardAndMouseKey,
			A2($author$project$MainScene$getKeyboardAndMouseInputState, shell, model)) : $elm$core$Dict$empty;
		var dtInMilliseconds = $xarvh$elm_gamepad$Gamepad$animationFrameDelta(gamepadBlob);
		var dt = dtInMilliseconds / 1000;
		var _v0 = $author$project$MainScene$allBotsThink(model);
		var botStatesByKey = _v0.a;
		var botInputsByKey = _v0.b;
		var inputStatesByKey = A2(
			$elm$core$Dict$map,
			$author$project$MainScene$sanitizeInputState,
			A2(
				$elm$core$Dict$union,
				keyAndMouse,
				A2($elm$core$Dict$union, gamepadsInputByKey, botInputsByKey)));
		var pairedInputStates = A2($elm$core$Dict$map, pairInputStateWithPrevious, inputStatesByKey);
		var _v1 = shell.gameIsPaused ? _Utils_Tuple2(model.game, _List_Nil) : A3($author$project$Update$update, dt, pairedInputStates, model.game);
		var game = _v1.a;
		var outcomes = _v1.b;
		var newModel = _Utils_update(
			model,
			{
				botStatesByKey: botStatesByKey,
				fps: A2(
					$elm$core$List$cons,
					1 / dt,
					A2($elm$core$List$take, 120, model.fps)),
				game: game,
				previousInputStatesByKey: inputStatesByKey
			});
		return A2(
			$elm$core$Tuple$mapSecond,
			$elm$core$Platform$Cmd$batch,
			A3(
				$elm$core$List$foldl,
				$author$project$MainScene$applyOutcome,
				_Utils_Tuple2(newModel, _List_Nil),
				outcomes));
	});
var $author$project$App$updateMainScene = F2(
	function (blob, model) {
		var _v0 = model.scene;
		if (_v0.$ === 'SceneMain') {
			var subScene = _v0.a;
			var scene = _v0.b;
			return (_Utils_eq(model.maybeMenu, $elm$core$Maybe$Nothing) || _Utils_eq(subScene, $author$project$App$SubSceneDemo)) ? A2(
				$elm$core$Tuple$mapFirst,
				function (newScene) {
					return _Utils_update(
						model,
						{
							scene: A2($author$project$App$SceneMain, subScene, newScene)
						});
				},
				A3(
					$author$project$MainScene$updateOnGamepad,
					blob,
					$author$project$App$shell(model),
					scene)) : $author$project$App$noCmd(model);
		} else {
			return $author$project$App$noCmd(model);
		}
	});
var $elm_community$list_extra$List$Extra$dropWhile = F2(
	function (predicate, list) {
		dropWhile:
		while (true) {
			if (!list.b) {
				return _List_Nil;
			} else {
				var x = list.a;
				var xs = list.b;
				if (predicate(x)) {
					var $temp$predicate = predicate,
						$temp$list = xs;
					predicate = $temp$predicate;
					list = $temp$list;
					continue dropWhile;
				} else {
					return list;
				}
			}
		}
	});
var $author$project$App$selectButton = function (button) {
	return $author$project$App$selectButtonByName(button.name);
};
var $author$project$App$menuSelectLastButton = function (model) {
	var _v0 = $elm$core$List$reverse(
		$author$project$App$menuButtons(model));
	if (!_v0.b) {
		return model;
	} else {
		var b = _v0.a;
		var bs = _v0.b;
		return A2($author$project$App$selectButton, b, model);
	}
};
var $author$project$App$selectedButton = function (model) {
	var buttons = A2(
		$elm$core$List$filter,
		function ($) {
			return $.isVisible;
		},
		$author$project$App$menuButtons(model));
	var _v0 = A2(
		$elm_community$list_extra$List$Extra$find,
		function (b) {
			return _Utils_eq(
				$author$project$App$SelectedButton(b.name),
				model.selectedButton);
		},
		buttons);
	if (_v0.$ === 'Just') {
		var button = _v0.a;
		return button;
	} else {
		var _v1 = $elm$core$List$head(buttons);
		if (_v1.$ === 'Just') {
			var button = _v1.a;
			return button;
		} else {
			return {isVisible: false, name: 'this shouldn\'t happen', update: $author$project$App$menuDemo, view: $author$project$App$MenuButtonLabel};
		}
	}
};
var $author$project$App$selectedButtonName = A2(
	$elm$core$Basics$composeR,
	$author$project$App$selectedButton,
	function ($) {
		return $.name;
	});
var $author$project$App$menuSelectNextButton = function (model) {
	var maybeButton = $elm$core$List$head(
		A2(
			$elm$core$List$drop,
			1,
			A2(
				$elm_community$list_extra$List$Extra$dropWhile,
				function (b) {
					return !_Utils_eq(
						b.name,
						$author$project$App$selectedButtonName(model));
				},
				$author$project$App$menuButtons(model))));
	if (maybeButton.$ === 'Nothing') {
		return $author$project$App$menuSelectLastButton(model);
	} else {
		var button = maybeButton.a;
		return A2($author$project$App$selectButton, button, model);
	}
};
var $author$project$App$menuSelectFirstButton = function (model) {
	var _v0 = $author$project$App$menuButtons(model);
	if (!_v0.b) {
		return model;
	} else {
		var b = _v0.a;
		var bs = _v0.b;
		return A2($author$project$App$selectButton, b, model);
	}
};
var $author$project$App$menuSelectPrevButton = function (model) {
	var maybeButton = $elm$core$List$head(
		A2(
			$elm$core$List$drop,
			1,
			A2(
				$elm_community$list_extra$List$Extra$dropWhile,
				function (b) {
					return !_Utils_eq(
						b.name,
						$author$project$App$selectedButtonName(model));
				},
				$elm$core$List$reverse(
					$author$project$App$menuButtons(model)))));
	if (maybeButton.$ === 'Nothing') {
		return $author$project$App$menuSelectFirstButton(model);
	} else {
		var button = maybeButton.a;
		return A2($author$project$App$selectButton, button, model);
	}
};
var $author$project$App$updateOnKeyUp = F2(
	function (keyName, model) {
		switch (keyName) {
			case 'ArrowUp':
				return $author$project$App$noCmd(
					$author$project$App$menuSelectPrevButton(model));
			case 'ArrowLeft':
				return $author$project$App$noCmd(
					$author$project$App$menuSelectPrevButton(model));
			case 'ArrowDown':
				return $author$project$App$noCmd(
					$author$project$App$menuSelectNextButton(model));
			case 'ArrowRight':
				return $author$project$App$noCmd(
					$author$project$App$menuSelectNextButton(model));
			case 'Escape':
				return $author$project$App$menuBack(model);
			case 'Enter':
				return A2(
					$author$project$App$updateOnButton,
					$author$project$App$selectedButtonName(model),
					model);
			case ' ':
				return A2(
					$author$project$App$updateOnButton,
					$author$project$App$selectedButtonName(model),
					model);
			default:
				return $author$project$App$noCmd(model);
		}
	});
var $xarvh$elm_gamepad$Gamepad$wasClicked = F2(
	function (_v0, digital) {
		var mapping = _v0.a;
		var currentFrame = _v0.b;
		var previousFrame = _v0.c;
		return (!A3($xarvh$elm_gamepad$Gamepad$getAsBool, digital, mapping, previousFrame)) && A3($xarvh$elm_gamepad$Gamepad$getAsBool, digital, mapping, currentFrame);
	});
var $author$project$App$updateMenuOnGamepad = F2(
	function (blob, model) {
		var pads = A2($xarvh$elm_gamepad$Gamepad$getGamepads, model.config.gamepadDatabase, blob);
		var isRemapping = function () {
			var _v3 = model.maybeMenu;
			if ((_v3.$ === 'Just') && (_v3.a.$ === 'MenuGamepads')) {
				var remapModel = _v3.a.a;
				return $xarvh$elm_gamepad$Gamepad$isRemapping(remapModel);
			} else {
				return false;
			}
		}();
		var buttonToKey = _List_fromArray(
			[
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickUp, 'ArrowUp'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickDown, 'ArrowDown'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickLeft, 'ArrowLeft'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$LeftStickRight, 'ArrowRight'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightBumper, 'Enter'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$RightTrigger, 'Enter'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$A, 'Enter'),
				_Utils_Tuple2($xarvh$elm_gamepad$Gamepad$B, 'Escape')
			]);
		var buttonClick = function (button) {
			return A2(
				$elm$core$List$any,
				function (pad) {
					return A2($xarvh$elm_gamepad$Gamepad$wasClicked, pad, button);
				},
				pads);
		};
		if (isRemapping) {
			return $author$project$App$noCmd(model);
		} else {
			if (buttonClick($xarvh$elm_gamepad$Gamepad$Start)) {
				return A2($author$project$App$updateOnKeyUp, 'Escape', model);
			} else {
				if (_Utils_eq(model.maybeMenu, $elm$core$Maybe$Nothing)) {
					return $author$project$App$noCmd(model);
				} else {
					var _v0 = A2(
						$elm_community$list_extra$List$Extra$find,
						function (_v1) {
							var b = _v1.a;
							var k = _v1.b;
							return buttonClick(b);
						},
						buttonToKey);
					if (_v0.$ === 'Nothing') {
						return $author$project$App$noCmd(model);
					} else {
						var _v2 = _v0.a;
						var button = _v2.a;
						var key = _v2.b;
						return A2($author$project$App$updateOnKeyUp, key, model);
					}
				}
			}
		}
	});
var $author$project$App$updateOnGamepad = F2(
	function (blob, model) {
		return function (_v0) {
			var _v1 = _v0.a;
			var m = _v1.a;
			var c1 = _v1.b;
			var c2 = _v0.b;
			return _Utils_Tuple2(
				m,
				$elm$core$Platform$Cmd$batch(
					_List_fromArray(
						[c1, c2])));
		}(
			A2(
				$elm$core$Tuple$mapFirst,
				$author$project$App$updateMenuOnGamepad(blob),
				A2($author$project$App$updateMainScene, blob, model)));
	});
var $elm$core$Result$andThen = F2(
	function (callback, result) {
		if (result.$ === 'Ok') {
			var value = result.a;
			return callback(value);
		} else {
			var msg = result.a;
			return $elm$core$Result$Err(msg);
		}
	});
var $elm$core$List$sort = function (xs) {
	return A2($elm$core$List$sortBy, $elm$core$Basics$identity, xs);
};
var $elm$core$Debug$toString = _Debug_toString;
var $elm_community$list_extra$List$Extra$uniqueHelp = F4(
	function (f, existing, remaining, accumulator) {
		uniqueHelp:
		while (true) {
			if (!remaining.b) {
				return $elm$core$List$reverse(accumulator);
			} else {
				var first = remaining.a;
				var rest = remaining.b;
				var computedFirst = f(first);
				if (A2($elm$core$Set$member, computedFirst, existing)) {
					var $temp$f = f,
						$temp$existing = existing,
						$temp$remaining = rest,
						$temp$accumulator = accumulator;
					f = $temp$f;
					existing = $temp$existing;
					remaining = $temp$remaining;
					accumulator = $temp$accumulator;
					continue uniqueHelp;
				} else {
					var $temp$f = f,
						$temp$existing = A2($elm$core$Set$insert, computedFirst, existing),
						$temp$remaining = rest,
						$temp$accumulator = A2($elm$core$List$cons, first, accumulator);
					f = $temp$f;
					existing = $temp$existing;
					remaining = $temp$remaining;
					accumulator = $temp$accumulator;
					continue uniqueHelp;
				}
			}
		}
	});
var $elm_community$list_extra$List$Extra$unique = function (list) {
	return A4($elm_community$list_extra$List$Extra$uniqueHelp, $elm$core$Basics$identity, $elm$core$Set$empty, list, _List_Nil);
};
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (_v0.$ === 'Just') {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $author$project$Map$validate = function (map) {
	var tilesToString = function (tiles) {
		return A2(
			$elm$core$String$join,
			', ',
			A2($elm$core$List$map, $elm$core$Debug$toString, tiles));
	};
	var hw = A3($elm$core$Basics$clamp, $author$project$Map$minSize, $author$project$Map$maxSize, map.halfWidth);
	var hh = A3($elm$core$Basics$clamp, $author$project$Map$minSize, $author$project$Map$maxSize, map.halfHeight);
	var isWithin = function (_v4) {
		var x = _v4.a;
		var y = _v4.b;
		return (_Utils_cmp(x, -hw) > -1) && ((_Utils_cmp(x, hw) < 0) && ((_Utils_cmp(y, -hh) > -1) && (_Utils_cmp(y, hh) < 0)));
	};
	var dictIncrement = function (key) {
		return A2(
			$elm$core$Dict$update,
			key,
			A2(
				$elm$core$Basics$composeR,
				$elm$core$Maybe$withDefault(0),
				A2(
					$elm$core$Basics$composeR,
					$elm$core$Basics$add(1),
					$elm$core$Maybe$Just)));
	};
	var bases = function (baseType) {
		return $elm$core$List$sort(
			$elm$core$Dict$keys(
				A2(
					$elm$core$Dict$filter,
					F2(
						function (tile, t) {
							return _Utils_eq(t, baseType);
						}),
					map.bases)));
	};
	var allTiles = $elm$core$List$concat(
		_List_fromArray(
			[
				$elm$core$Set$toList(map.wallTiles),
				$elm$core$List$concat(
				$elm$core$Dict$values(
					A2(
						$elm$core$Dict$map,
						F2(
							function (tile, baseType) {
								return A2($author$project$Base$tiles, baseType, tile);
							}),
						map.bases)))
			]));
	var outOfBounds = A2(
		$elm$core$List$filter,
		function (t) {
			return !isWithin(t);
		},
		allTiles);
	var overlaps = $elm$core$Dict$keys(
		A2(
			$elm$core$Dict$filter,
			F2(
				function (k, v) {
					return v > 1;
				}),
			function (d) {
				return A3($elm$core$List$foldl, dictIncrement, d, allTiles);
			}(
				$elm$core$Dict$fromList(
					A2(
						$elm$core$List$map,
						function (tile) {
							return _Utils_Tuple2(tile, 0);
						},
						$elm_community$list_extra$List$Extra$unique(allTiles))))));
	if (!_Utils_eq(outOfBounds, _List_Nil)) {
		return $elm$core$Result$Err(
			'Tiles out of bounds: ' + tilesToString(outOfBounds));
	} else {
		if (!_Utils_eq(overlaps, _List_Nil)) {
			return $elm$core$Result$Err(
				'Overlapping tiles: ' + tilesToString(overlaps));
		} else {
			var _v0 = bases($author$project$Game$BaseMain);
			if (!_v0.b) {
				return $elm$core$Result$Err('No main bases');
			} else {
				if (!_v0.b.b) {
					var a = _v0.a;
					return $elm$core$Result$Err('Only 1 main base');
				} else {
					if (_v0.b.b.b) {
						var a = _v0.a;
						var _v1 = _v0.b;
						var b = _v1.a;
						var _v2 = _v1.b;
						var c = _v2.a;
						return $elm$core$Result$Err('Too many main bases');
					} else {
						var left = _v0.a;
						var _v3 = _v0.b;
						var right = _v3.a;
						return $elm$core$Result$Ok(
							{
								author: map.author,
								halfHeight: hh,
								halfWidth: hw,
								leftBase: left,
								name: map.name,
								rightBase: right,
								smallBases: $elm$core$Set$fromList(
									bases($author$project$Game$BaseSmall)),
								wallTiles: map.wallTiles
							});
					}
				}
			}
		}
	}
};
var $author$project$App$updateOnImportString = F3(
	function (mapAsJson, importModel, model) {
		return _Utils_update(
			model,
			{
				maybeMenu: $elm$core$Maybe$Just(
					$author$project$App$MenuImportMap(
						_Utils_update(
							importModel,
							{
								importString: mapAsJson,
								mapResult: A2(
									$elm$core$Result$andThen,
									$author$project$Map$validate,
									$author$project$Map$fromString(mapAsJson))
							})))
			});
	});
var $author$project$App$updateOnRemap = F2(
	function (model, _v0) {
		var remap = _v0.a;
		var maybeUpdateDb = _v0.b;
		var updateDb = A2($elm$core$Maybe$withDefault, $elm$core$Basics$identity, maybeUpdateDb);
		return A2(
			$author$project$App$updateConfig,
			function (config) {
				return _Utils_update(
					config,
					{
						gamepadDatabase: updateDb(model.config.gamepadDatabase)
					});
			},
			_Utils_update(
				model,
				{
					maybeMenu: $elm$core$Maybe$Just(
						$author$project$App$MenuGamepads(remap))
				}));
	});
var $author$project$App$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 'Noop':
				return $author$project$App$noCmd(model);
			case 'OnGamepad':
				var blob = msg.a;
				return A2($author$project$App$updateOnGamepad, blob, model);
			case 'OnStartGame':
				var map = msg.a;
				return A2($author$project$App$updateStartGame, map, model);
			case 'OnImportString':
				var mapAsJson = msg.a;
				var _v1 = model.maybeMenu;
				if ((_v1.$ === 'Just') && (_v1.a.$ === 'MenuImportMap')) {
					var importModel = _v1.a.a;
					return $author$project$App$noCmd(
						A3($author$project$App$updateOnImportString, mapAsJson, importModel, model));
				} else {
					return $author$project$App$noCmd(model);
				}
			case 'OnMenuButton':
				var buttonName = msg.a;
				return A2($author$project$App$updateOnButton, buttonName, model);
			case 'OnSelectButton':
				var name = msg.a;
				return $author$project$App$noCmd(
					A2($author$project$App$selectButtonByName, name, model));
			case 'OnMouseButton':
				var state = msg.a;
				return $author$project$App$noCmd(
					_Utils_update(
						model,
						{mouseIsPressed: state}));
			case 'OnMouseMoves':
				var x = msg.a;
				var y = msg.b;
				return $author$project$App$noCmd(
					_Utils_update(
						model,
						{
							mousePosition: {x: x, y: y}
						}));
			case 'OnWindowResizes':
				var w = msg.a;
				var h = msg.b;
				var windowSize = {height: h, width: w};
				return $author$project$App$noCmd(
					_Utils_update(
						model,
						{
							viewport: $author$project$App$makeViewport(windowSize),
							windowSize: windowSize
						}));
			case 'OnKeyDown':
				var keyName = msg.a;
				return $author$project$App$noCmd(
					_Utils_update(
						model,
						{
							pressedKeys: A2($elm$core$Set$insert, keyName, model.pressedKeys)
						}));
			case 'OnKeyUp':
				var keyName = msg.a;
				return A2(
					$author$project$App$updateOnKeyUp,
					keyName,
					_Utils_update(
						model,
						{
							pressedKeys: A2($elm$core$Set$remove, keyName, model.pressedKeys)
						}));
			case 'OnVisibilityChange':
				return $author$project$App$noCmd(
					_Utils_update(
						model,
						{pressedKeys: $elm$core$Set$empty}));
			case 'OnMapEditorMsg':
				var mapEditorMsg = msg.a;
				var _v2 = _Utils_Tuple2(model.scene, model.maybeMenu);
				if ((_v2.a.$ === 'SceneMapEditor') && (_v2.b.$ === 'Nothing')) {
					var mapEditor = _v2.a.a;
					var _v3 = _v2.b;
					return A2(
						$elm$core$Tuple$mapSecond,
						$elm$core$Platform$Cmd$map($author$project$App$OnMapEditorMsg),
						A2(
							$elm$core$Tuple$mapFirst,
							function (newMapEditor) {
								return _Utils_update(
									model,
									{
										scene: $author$project$App$SceneMapEditor(newMapEditor)
									});
							},
							A3(
								$author$project$MapEditor$update,
								mapEditorMsg,
								$author$project$App$shell(model),
								mapEditor)));
				} else {
					return $author$project$App$noCmd(model);
				}
			default:
				var remapMsg = msg.a;
				var _v4 = model.maybeMenu;
				if ((_v4.$ === 'Just') && (_v4.a.$ === 'MenuGamepads')) {
					var remap = _v4.a.a;
					return A2(
						$author$project$App$updateOnRemap,
						model,
						A3($xarvh$elm_gamepad$Gamepad$remapUpdate, $author$project$App$gamepadButtonMap, remapMsg, remap));
				} else {
					return $author$project$App$noCmd(model);
				}
		}
	});
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $author$project$Svgl$Tree$Nod = F2(
	function (a, b) {
		return {$: 'Nod', a: a, b: b};
	});
var $elm_explorations$webgl$WebGL$Internal$Alpha = function (a) {
	return {$: 'Alpha', a: a};
};
var $elm_explorations$webgl$WebGL$alpha = $elm_explorations$webgl$WebGL$Internal$Alpha;
var $elm_explorations$webgl$WebGL$Internal$Antialias = {$: 'Antialias'};
var $elm_explorations$webgl$WebGL$antialias = $elm_explorations$webgl$WebGL$Internal$Antialias;
var $author$project$View$Game$mechVsUnit = function (units) {
	var folder = F2(
		function (unit, _v1) {
			var mechs = _v1.a;
			var subs = _v1.b;
			var _v0 = unit.component;
			if (_v0.$ === 'UnitMech') {
				var mechRecord = _v0.a;
				return _Utils_Tuple2(
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(unit, mechRecord),
						mechs),
					subs);
			} else {
				var subRecord = _v0.a;
				return _Utils_Tuple2(
					mechs,
					A2(
						$elm$core$List$cons,
						_Utils_Tuple2(unit, subRecord),
						subs));
			}
		});
	return A3(
		$elm$core$List$foldl,
		folder,
		_Utils_Tuple2(_List_Nil, _List_Nil),
		units);
};
var $elm_explorations$webgl$WebGL$Internal$disableSetting = F2(
	function (gl, setting) {
		switch (setting.$) {
			case 'Blend':
				return _WebGL_disableBlend(gl);
			case 'DepthTest':
				return _WebGL_disableDepthTest(gl);
			case 'StencilTest':
				return _WebGL_disableStencilTest(gl);
			case 'Scissor':
				return _WebGL_disableScissor(gl);
			case 'ColorMask':
				return _WebGL_disableColorMask(gl);
			case 'CullFace':
				return _WebGL_disableCullFace(gl);
			case 'PolygonOffset':
				return _WebGL_disablePolygonOffset(gl);
			case 'SampleCoverage':
				return _WebGL_disableSampleCoverage(gl);
			default:
				return _WebGL_disableSampleAlphaToCoverage(gl);
		}
	});
var $elm_explorations$webgl$WebGL$Internal$enableOption = F2(
	function (ctx, option) {
		switch (option.$) {
			case 'Alpha':
				return A2(_WebGL_enableAlpha, ctx, option);
			case 'Depth':
				return A2(_WebGL_enableDepth, ctx, option);
			case 'Stencil':
				return A2(_WebGL_enableStencil, ctx, option);
			case 'Antialias':
				return A2(_WebGL_enableAntialias, ctx, option);
			default:
				return A2(_WebGL_enableClearColor, ctx, option);
		}
	});
var $elm_explorations$webgl$WebGL$Internal$enableSetting = F2(
	function (gl, setting) {
		switch (setting.$) {
			case 'Blend':
				return A2(_WebGL_enableBlend, gl, setting);
			case 'DepthTest':
				return A2(_WebGL_enableDepthTest, gl, setting);
			case 'StencilTest':
				return A2(_WebGL_enableStencilTest, gl, setting);
			case 'Scissor':
				return A2(_WebGL_enableScissor, gl, setting);
			case 'ColorMask':
				return A2(_WebGL_enableColorMask, gl, setting);
			case 'CullFace':
				return A2(_WebGL_enableCullFace, gl, setting);
			case 'PolygonOffset':
				return A2(_WebGL_enablePolygonOffset, gl, setting);
			case 'SampleCoverage':
				return A2(_WebGL_enableSampleCoverage, gl, setting);
			default:
				return A2(_WebGL_enableSampleAlphaToCoverage, gl, setting);
		}
	});
var $elm_explorations$webgl$WebGL$toHtmlWith = F3(
	function (options, attributes, entities) {
		return A3(_WebGL_toHtml, options, attributes, entities);
	});
var $elm_explorations$linear_algebra$Math$Matrix4$translate = _MJS_m4x4translate;
var $elm_explorations$linear_algebra$Math$Matrix4$rotate = _MJS_m4x4rotate;
var $author$project$Svgl$Tree$applyTransform = F2(
	function (t, mat) {
		return A3(
			$elm_explorations$linear_algebra$Math$Matrix4$rotate,
			t.rotate,
			A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0, 0, -1),
			A2($elm_explorations$linear_algebra$Math$Matrix4$translate, t.translate, mat));
	});
var $author$project$Svgl$Tree$recursiveTreeToEntities = F3(
	function (node, transformSoFar, entitiesSoFar) {
		if (node.$ === 'Ent') {
			var matToEntity = node.a;
			return A2(
				$elm$core$List$cons,
				_Utils_Tuple2(
					transformSoFar,
					matToEntity(transformSoFar)),
				entitiesSoFar);
		} else {
			var transforms = node.a;
			var children = node.b;
			var newTransform = A3($elm$core$List$foldl, $author$project$Svgl$Tree$applyTransform, transformSoFar, transforms);
			return A3(
				$elm$core$List$foldr,
				F2(
					function (child, enli) {
						return A3($author$project$Svgl$Tree$recursiveTreeToEntities, child, newTransform, enli);
					}),
				entitiesSoFar,
				children);
		}
	});
var $author$project$Svgl$Tree$treeToEntities = F2(
	function (worldToCamera, node) {
		return A3($author$project$Svgl$Tree$recursiveTreeToEntities, node, worldToCamera, _List_Nil);
	});
var $author$project$Colors$dark = 0.6;
var $author$project$Colors$darkYellow = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, $author$project$Colors$dark, $author$project$Colors$dark, 0);
var $elm_explorations$linear_algebra$Math$Matrix4$identity = _MJS_m4x4identity;
var $author$project$Svgl$Primitives$defaultUniforms = {
	dimensions: A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 1, 1),
	entityToCamera: $elm_explorations$linear_algebra$Math$Matrix4$identity,
	fill: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0.4, 0.4, 0.4),
	opacity: 1,
	stroke: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0.6, 0.6, 0.6),
	strokeWidth: 0.1
};
var $author$project$Svgl$Tree$defaultParams = {fill: $author$project$Svgl$Primitives$defaultUniforms.fill, h: 1, opacity: 1, rotate: 0, stroke: $author$project$Svgl$Primitives$defaultUniforms.stroke, strokeWidth: 0.025, w: 1, x: 0, y: 0, z: 0};
var $author$project$Svgl$Primitives$ellipseFragmentShader = {
	src: '\n        precision mediump float;\n\n        uniform mat4 entityToCamera;\n        uniform vec2 dimensions;\n        uniform vec3 fill;\n        uniform vec3 stroke;\n        uniform float strokeWidth;\n        uniform float opacity;\n\n        varying vec2 localPosition;\n\n        // TODO: transform into `pixelSize`, make it a uniform\n        float pixelsPerTile = 30.0;\n        float e = 0.5 / pixelsPerTile;\n\n\n        float smoothEllipse(vec2 position, vec2 radii) {\n          float x = position.x;\n          float y = position.y;\n          float w = radii.x;\n          float h = radii.y;\n\n          float xx = x * x;\n          float yy = y * y;\n          float ww = w * w;\n          float hh = h * h;\n\n          // We will need the assumption that we are not too far from the ellipse\n          float ew = w + e;\n          float eh = h + e;\n\n          if ( xx / (ew * ew) + yy / (eh * eh) > 1.0 ) {\n            return 1.0;\n          }\n\n          /*\n          Given an ellipse Q with radii W and H, the ellipse P whose every point\n          has distance D from the closest point in A is given by:\n\n            x^2       y^2\n          ------- + ------- = 1\n          (W+D)^2   (H+D)^2\n\n          Assuming D << W and D << H we can solve for D dropping the terms in\n          D^3 and D^4.\n          We obtain: a * d^2 + b * d + c = 0\n          */\n\n          float c = xx * hh + yy * ww - ww * hh;\n          float b = 2.0 * (h * xx + yy * w - h * ww - w * hh);\n          float a = xx + yy - ww - hh - 4.0 * w * h;\n\n          float delta = sqrt(b * b - 4.0 * a * c);\n          //float solution1 = (-b + delta) / (2.0 * a);\n          float solution2 = (-b - delta) / (2.0 * a);\n\n          return smoothstep(-e, e, solution2);\n        }\n\n\n        void main () {\n          vec2 strokeSize = dimensions / 2.0 + strokeWidth;\n          vec2 fillSize = dimensions / 2.0 - strokeWidth;\n\n          float alpha = 1.0 - smoothEllipse(localPosition, strokeSize);\n          float fillVsStroke = smoothEllipse(localPosition, fillSize);\n\n          vec3 color = mix(fill, stroke, fillVsStroke);\n\n          gl_FragColor = opacity * alpha * vec4(color, 1.0);\n        }\n    ',
	attributes: {},
	uniforms: {dimensions: 'dimensions', entityToCamera: 'entityToCamera', fill: 'fill', opacity: 'opacity', stroke: 'stroke', strokeWidth: 'strokeWidth'}
};
var $elm_explorations$webgl$WebGL$entityWith = _WebGL_entity;
var $author$project$Svgl$Primitives$Attributes = function (position) {
	return {position: position};
};
var $elm_explorations$webgl$WebGL$Mesh3 = F2(
	function (a, b) {
		return {$: 'Mesh3', a: a, b: b};
	});
var $elm_explorations$webgl$WebGL$triangles = $elm_explorations$webgl$WebGL$Mesh3(
	{elemSize: 3, indexSize: 0, mode: 4});
var $author$project$Svgl$Primitives$normalizedQuadMesh = $elm_explorations$webgl$WebGL$triangles(
	_List_fromArray(
		[
			_Utils_Tuple3(
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, -0.5)),
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.5, -0.5)),
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.5, 0.5))),
			_Utils_Tuple3(
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, -0.5)),
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, 0.5)),
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.5, 0.5)))
		]));
var $author$project$Svgl$Primitives$quadVertexShader = {
	src: '\n        precision mediump float;\n\n        attribute vec2 position;\n\n        uniform mat4 entityToCamera;\n        uniform vec2 dimensions;\n        uniform vec3 fill;\n        uniform vec3 stroke;\n        uniform float strokeWidth;\n\n        varying vec2 localPosition;\n\n        void main () {\n            localPosition = (dimensions + strokeWidth * 2.0) * position;\n            gl_Position = entityToCamera * vec4(localPosition, 0, 1);\n        }\n    ',
	attributes: {position: 'position'},
	uniforms: {dimensions: 'dimensions', entityToCamera: 'entityToCamera', fill: 'fill', stroke: 'stroke', strokeWidth: 'strokeWidth'}
};
var $elm_explorations$webgl$WebGL$Internal$Blend = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return {$: 'Blend', a: a, b: b, c: c, d: d, e: e, f: f, g: g, h: h, i: i, j: j};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $elm_explorations$webgl$WebGL$Settings$Blend$custom = function (_v0) {
	var r = _v0.r;
	var g = _v0.g;
	var b = _v0.b;
	var a = _v0.a;
	var color = _v0.color;
	var alpha = _v0.alpha;
	var expand = F2(
		function (_v1, _v2) {
			var eq1 = _v1.a;
			var f11 = _v1.b;
			var f12 = _v1.c;
			var eq2 = _v2.a;
			var f21 = _v2.b;
			var f22 = _v2.c;
			return $elm_explorations$webgl$WebGL$Internal$Blend(eq1)(f11)(f12)(eq2)(f21)(f22)(r)(g)(b)(a);
		});
	return A2(expand, color, alpha);
};
var $elm_explorations$webgl$WebGL$Settings$Blend$Blender = F3(
	function (a, b, c) {
		return {$: 'Blender', a: a, b: b, c: c};
	});
var $elm_explorations$webgl$WebGL$Settings$Blend$customAdd = F2(
	function (_v0, _v1) {
		var factor1 = _v0.a;
		var factor2 = _v1.a;
		return A3($elm_explorations$webgl$WebGL$Settings$Blend$Blender, 32774, factor1, factor2);
	});
var $elm_explorations$webgl$WebGL$Settings$Blend$add = F2(
	function (factor1, factor2) {
		return $elm_explorations$webgl$WebGL$Settings$Blend$custom(
			{
				a: 0,
				alpha: A2($elm_explorations$webgl$WebGL$Settings$Blend$customAdd, factor1, factor2),
				b: 0,
				color: A2($elm_explorations$webgl$WebGL$Settings$Blend$customAdd, factor1, factor2),
				g: 0,
				r: 0
			});
	});
var $elm_explorations$webgl$WebGL$Settings$Blend$Factor = function (a) {
	return {$: 'Factor', a: a};
};
var $elm_explorations$webgl$WebGL$Settings$Blend$one = $elm_explorations$webgl$WebGL$Settings$Blend$Factor(1);
var $elm_explorations$webgl$WebGL$Settings$Blend$oneMinusSrcAlpha = $elm_explorations$webgl$WebGL$Settings$Blend$Factor(771);
var $author$project$Svgl$Primitives$settings = _List_fromArray(
	[
		A2($elm_explorations$webgl$WebGL$Settings$Blend$add, $elm_explorations$webgl$WebGL$Settings$Blend$one, $elm_explorations$webgl$WebGL$Settings$Blend$oneMinusSrcAlpha)
	]);
var $author$project$Svgl$Primitives$ellipse = A4($elm_explorations$webgl$WebGL$entityWith, $author$project$Svgl$Primitives$settings, $author$project$Svgl$Primitives$quadVertexShader, $author$project$Svgl$Primitives$ellipseFragmentShader, $author$project$Svgl$Primitives$normalizedQuadMesh);
var $author$project$Svgl$Tree$Ent = function (a) {
	return {$: 'Ent', a: a};
};
var $author$project$Svgl$Tree$entity = F2(
	function (primitive, p) {
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					{
					rotate: p.rotate,
					translate: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, p.x, p.y, 0)
				}
				]),
			_List_fromArray(
				[
					$author$project$Svgl$Tree$Ent(
					function (entityToCamera) {
						return primitive(
							_Utils_update(
								$author$project$Svgl$Primitives$defaultUniforms,
								{
									dimensions: A2($elm_explorations$linear_algebra$Math$Vector2$vec2, p.w, p.h),
									entityToCamera: entityToCamera,
									fill: p.fill,
									opacity: p.opacity,
									stroke: p.stroke,
									strokeWidth: p.strokeWidth
								}));
					})
				]));
	});
var $author$project$Svgl$Tree$ellipse = $author$project$Svgl$Tree$entity($author$project$Svgl$Primitives$ellipse);
var $author$project$Svgl$Primitives$rectFragmentShader = {
	src: '\n        precision mediump float;\n\n        uniform mat4 entityToCamera;\n        uniform vec2 dimensions;\n        uniform vec3 fill;\n        uniform vec3 stroke;\n        uniform float strokeWidth;\n        uniform float opacity;\n\n        varying vec2 localPosition;\n\n        // TODO: transform into `pixelSize`, make it a uniform\n        float pixelsPerTile = 30.0;\n        float e = 0.5 / pixelsPerTile;\n\n        /*\n         *     0               1                            1                     0\n         *     |------|--------|----------------------------|----------|----------|\n         *  -edge-e  -edge  -edge+e                      edge-e      edge      edge+e\n         */\n        float mirrorStep (float edge, float p) {\n          return smoothstep(-edge - e, -edge + e, p) - smoothstep(edge - e, edge + e, p);\n        }\n\n        void main () {\n          vec2 strokeSize = dimensions / 2.0 + strokeWidth;\n          vec2 fillSize = dimensions / 2.0 - strokeWidth;\n\n          float alpha = mirrorStep(strokeSize.x, localPosition.x) * mirrorStep(strokeSize.y, localPosition.y);\n          float strokeVsFill = mirrorStep(fillSize.x, localPosition.x) * mirrorStep(fillSize.y, localPosition.y);\n          vec3 color = mix(stroke, fill, strokeVsFill);\n\n          gl_FragColor = opacity * alpha * vec4(color, 1.0);\n        }\n    ',
	attributes: {},
	uniforms: {dimensions: 'dimensions', entityToCamera: 'entityToCamera', fill: 'fill', opacity: 'opacity', stroke: 'stroke', strokeWidth: 'strokeWidth'}
};
var $author$project$Svgl$Primitives$rect = A4($elm_explorations$webgl$WebGL$entityWith, $author$project$Svgl$Primitives$settings, $author$project$Svgl$Primitives$quadVertexShader, $author$project$Svgl$Primitives$rectFragmentShader, $author$project$Svgl$Primitives$normalizedQuadMesh);
var $author$project$Svgl$Tree$rect = $author$project$Svgl$Tree$entity($author$project$Svgl$Primitives$rect);
var $elm_explorations$linear_algebra$Math$Vector2$getY = _MJS_v2getY;
var $author$project$Svgl$Tree$translate = function (v) {
	return {
		rotate: 0,
		translate: A3(
			$elm_explorations$linear_algebra$Math$Vector3$vec3,
			$elm_explorations$linear_algebra$Math$Vector2$getX(v),
			$elm_explorations$linear_algebra$Math$Vector2$getY(v),
			0)
	};
};
var $author$project$View$Gfx$fractalBeam = F4(
	function (start, end, colorPattern, t) {
		var x2 = $elm$core$Basics$cos(50 * t);
		var x1 = $elm$core$Basics$sin(13 * t);
		var p = A2(
			$elm_explorations$linear_algebra$Math$Vector2$add,
			A2($elm_explorations$linear_algebra$Math$Vector2$scale, t, start),
			A2($elm_explorations$linear_algebra$Math$Vector2$scale, 1 - t, end));
		var dp = A2($elm_explorations$linear_algebra$Math$Vector2$sub, end, start);
		var l = $elm_explorations$linear_algebra$Math$Vector2$length(dp);
		var a = $author$project$Game$vecToAngle(dp);
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$translate(p)
				]),
			_List_fromArray(
				[
					$author$project$Svgl$Tree$rect(
					_Utils_update(
						$author$project$Svgl$Tree$defaultParams,
						{fill: colorPattern.brightV, h: 0.3, rotate: 7 * x1, stroke: colorPattern.darkV, w: 0.3}))
				]));
	});
var $author$project$Colors$orange = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0.65, 0);
var $author$project$Svgl$Primitives$normalizedRightTriMesh = $elm_explorations$webgl$WebGL$triangles(
	_List_fromArray(
		[
			_Utils_Tuple3(
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, -0.5)),
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, -0.5, 0.5)),
			$author$project$Svgl$Primitives$Attributes(
				A2($elm_explorations$linear_algebra$Math$Vector2$vec2, 0.5, -0.5)))
		]));
var $author$project$Svgl$Primitives$rightTri = A4($elm_explorations$webgl$WebGL$entityWith, $author$project$Svgl$Primitives$settings, $author$project$Svgl$Primitives$quadVertexShader, $author$project$Svgl$Primitives$rectFragmentShader, $author$project$Svgl$Primitives$normalizedRightTriMesh);
var $author$project$Svgl$Tree$rightTri = $author$project$Svgl$Tree$entity($author$project$Svgl$Primitives$rightTri);
var $author$project$Svgl$Tree$rotateRad = function (radians) {
	return {
		rotate: radians,
		translate: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0, 0, 0)
	};
};
var $author$project$Colors$grey = function (g) {
	return A3($elm_explorations$linear_algebra$Math$Vector3$vec3, g, g, g);
};
var $author$project$Colors$smokeFill = $author$project$Colors$grey(0.4);
var $author$project$Ease$inExpo = function (time) {
	return (time === 0.0) ? 0.0 : A2($elm$core$Basics$pow, 2, 10 * (time - 1));
};
var $author$project$Ease$outExpo = $author$project$Ease$flip($author$project$Ease$inExpo);
var $author$project$View$Gfx$straightBeam = F4(
	function (t, start, end, colorPattern) {
		var width = 0.1 * (1 + (3 * t));
		var difference = A2($elm_explorations$linear_algebra$Math$Vector2$sub, end, start);
		var height = $elm_explorations$linear_algebra$Math$Vector2$length(difference);
		var rotate = $author$project$Game$vecToAngle(difference);
		var _v0 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(
			A2(
				$elm_explorations$linear_algebra$Math$Vector2$scale,
				0.5,
				A2($elm_explorations$linear_algebra$Math$Vector2$add, start, end)));
		var x = _v0.x;
		var y = _v0.y;
		return $author$project$Svgl$Tree$rect(
			_Utils_update(
				$author$project$Svgl$Tree$defaultParams,
				{
					fill: colorPattern.brightV,
					h: height,
					opacity: 1 - $author$project$Ease$outExpo(t),
					rotate: rotate,
					strokeWidth: 0,
					w: width,
					x: x,
					y: y
				}));
	});
var $author$project$Svgl$Tree$translate2 = F2(
	function (x, y) {
		return {
			rotate: 0,
			translate: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, x, y, 0)
		};
	});
var $author$project$Colors$yellow = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 1, 0);
var $author$project$View$Gfx$view = F2(
	function (game, cosmetic) {
		var t = (game.time - cosmetic.spawnTime) / (cosmetic.removeTime - cosmetic.spawnTime);
		var _v0 = cosmetic.render;
		switch (_v0.$) {
			case 'GfxFractalBeam':
				var start = _v0.a;
				var end = _v0.b;
				var colorPattern = _v0.c;
				return A4($author$project$View$Gfx$fractalBeam, start, end, colorPattern, t);
			case 'GfxProjectileCase':
				var origin = _v0.a;
				var angle = _v0.b;
				return A2(
					$author$project$Svgl$Tree$Nod,
					_List_fromArray(
						[
							$author$project$Svgl$Tree$translate(origin),
							$author$project$Svgl$Tree$rotateRad(angle),
							A2($author$project$Svgl$Tree$translate2, t, 0)
						]),
					_List_fromArray(
						[
							$author$project$Svgl$Tree$rect(
							_Utils_update(
								$author$project$Svgl$Tree$defaultParams,
								{fill: $author$project$Colors$yellow, h: 0.15, stroke: $author$project$Colors$darkYellow, strokeWidth: 0.02, w: 0.1}))
						]));
			case 'GfxBeam':
				var start = _v0.a;
				var end = _v0.b;
				var colorPattern = _v0.c;
				return A4($author$project$View$Gfx$straightBeam, t, start, end, colorPattern);
			case 'GfxExplosion':
				var position = _v0.a;
				var rawSize = _v0.b;
				var angle = _v0.c;
				var size = 0.3 * rawSize;
				var particleDiameter = (2 * size) * ((t * 0.9) + 0.1);
				var particleCount = A2(
					$elm$core$Basics$min,
					6,
					$elm$core$Basics$ceiling(1.6 * rawSize));
				var particleByIndex = function (index) {
					var a = angle + $elm$core$Basics$turns(index / particleCount);
					var x = (t * size) * $elm$core$Basics$cos(a);
					var y = (t * size) * $elm$core$Basics$sin(a);
					return $author$project$Svgl$Tree$ellipse(
						_Utils_update(
							$author$project$Svgl$Tree$defaultParams,
							{fill: $author$project$Colors$yellow, h: particleDiameter, opacity: 1 - t, stroke: $author$project$Colors$orange, w: particleDiameter, x: x, y: y}));
				};
				return A2(
					$author$project$Svgl$Tree$Nod,
					_List_fromArray(
						[
							$author$project$Svgl$Tree$translate(position)
						]),
					A2(
						$elm$core$List$map,
						particleByIndex,
						A2($elm$core$List$range, 0, particleCount - 1)));
			case 'GfxFlyingHead':
				var _class = _v0.a;
				var origin = _v0.b;
				var destination = _v0.c;
				var colorPattern = _v0.d;
				return A2($author$project$Svgl$Tree$Nod, _List_Nil, _List_Nil);
			case 'GfxRepairBubble':
				var position = _v0.a;
				var _short = 0.1;
				var params = _Utils_update(
					$author$project$Svgl$Tree$defaultParams,
					{fill: $author$project$View$Gfx$healingGreen.brightV, opacity: 1 - (t * t), stroke: $author$project$View$Gfx$healingGreen.brightV, strokeWidth: 0});
				var _long = 3 * _short;
				return A2(
					$author$project$Svgl$Tree$Nod,
					_List_fromArray(
						[
							$author$project$Svgl$Tree$translate(position),
							A2($author$project$Svgl$Tree$translate2, 0, t)
						]),
					_List_fromArray(
						[
							$author$project$Svgl$Tree$rect(
							_Utils_update(
								params,
								{h: _long, w: _short})),
							$author$project$Svgl$Tree$rect(
							_Utils_update(
								params,
								{h: _short, w: _short, x: _short})),
							$author$project$Svgl$Tree$rect(
							_Utils_update(
								params,
								{h: _short, w: _short, x: -_short}))
						]));
			case 'GfxTrail':
				var position = _v0.a;
				var angle = _v0.b;
				var stretch = _v0.c;
				return $author$project$Svgl$Tree$ellipse(
					_Utils_update(
						$author$project$Svgl$Tree$defaultParams,
						{
							fill: $author$project$Colors$smokeFill,
							h: (1.5 - t) * stretch,
							opacity: 0.05 * (1 - (t * t)),
							rotate: angle,
							w: 0.1 + (t * 0.2),
							x: $elm_explorations$linear_algebra$Math$Vector2$getX(position),
							y: $elm_explorations$linear_algebra$Math$Vector2$getY(position)
						}));
			default:
				var fill = _v0.a.fill;
				var stroke = _v0.a.stroke;
				var w = _v0.a.w;
				var h = _v0.a.h;
				var origin = _v0.a.origin;
				var angle = _v0.a.angle;
				var speed = _v0.a.speed;
				var angularVelocity = _v0.a.angularVelocity;
				var isTris = _v0.a.isTris;
				var prim = isTris ? $author$project$Svgl$Tree$rightTri : $author$project$Svgl$Tree$rect;
				var a = angle + (t * angularVelocity);
				var _v1 = $elm_explorations$linear_algebra$Math$Vector2$toRecord(
					A2(
						$elm_explorations$linear_algebra$Math$Vector2$add,
						origin,
						A2($elm_explorations$linear_algebra$Math$Vector2$scale, t, speed)));
				var x = _v1.x;
				var y = _v1.y;
				return prim(
					_Utils_update(
						$author$project$Svgl$Tree$defaultParams,
						{fill: fill, h: h, opacity: 1 - t, rotate: a, stroke: stroke, w: w, x: x, y: y}));
		}
	});
var $author$project$Base$colorPattern = F2(
	function (game, base) {
		return A2(
			$author$project$Game$teamColorPattern,
			game,
			function () {
				var _v0 = base.maybeOccupied;
				if (_v0.$ === 'Just') {
					var occupied = _v0.a;
					return occupied.isActive ? occupied.maybeTeamId : $elm$core$Maybe$Nothing;
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}());
	});
var $author$project$Stats$maxHeight = {base: 0.5, mech: 0.3, projectile: 0.6, sub: 0.2, wall: 0.4};
var $author$project$Svgl$Tree$rotateDeg = A2($elm$core$Basics$composeR, $elm$core$Basics$degrees, $author$project$Svgl$Tree$rotateRad);
var $author$project$View$Base$teeth = F3(
	function (completion, radius, params) {
		var phase = (2 * $elm$core$Basics$pi) * completion;
		var n = 30;
		var indexToAngle = function (index) {
			return $elm$core$Basics$turns(index / n);
		};
		var angleToDot = function (angle) {
			return A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateRad(angle),
						A2($author$project$Svgl$Tree$translate2, radius, 0),
						$author$project$Svgl$Tree$rotateDeg(-90)
					]),
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rect(
						_Utils_update(
							params,
							{
								h: (0.1 * (1.1 + $elm$core$Basics$sin((1.7 * angle) + phase))) * radius,
								strokeWidth: params.strokeWidth * radius,
								w: 0.15 * radius
							}))
					]));
		};
		var amplitude = (2 * $elm$core$Basics$pi) / n;
		var shiftAngle = function (angle) {
			return angle + (amplitude * $elm$core$Basics$sin(angle + phase));
		};
		var dots = A2(
			$elm$core$List$map,
			A2(
				$elm$core$Basics$composeR,
				indexToAngle,
				A2($elm$core$Basics$composeR, shiftAngle, angleToDot)),
			A2($elm$core$List$range, 0, n - 1));
		return A2($author$project$Svgl$Tree$Nod, _List_Nil, dots);
	});
var $author$project$View$Base$main_ = F3(
	function (completion, bright, dark) {
		var slowSin = $elm$core$Basics$sin((2 * $elm$core$Basics$pi) * completion);
		var params = _Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{fill: bright, stroke: dark});
		var height = $author$project$Stats$maxHeight.base;
		var re = function (_v3) {
			var x = _v3.x;
			var y = _v3.y;
			var z = _v3.z;
			var w = _v3.w;
			var h = _v3.h;
			return $author$project$Svgl$Tree$rect(
				_Utils_update(
					params,
					{h: h, w: w, x: x, y: y, z: z * height}));
		};
		var tri = function (_v2) {
			var x = _v2.x;
			var y = _v2.y;
			var z = _v2.z;
			return $author$project$Svgl$Tree$ellipse(
				_Utils_update(
					params,
					{h: 0.1, w: 0.4, x: x, y: y, z: z * height}));
		};
		var fastSin = $elm$core$Basics$sin((4 * $elm$core$Basics$pi) * (completion + 0.25));
		var cir = function (_v1) {
			var x = _v1.x;
			var y = _v1.y;
			var z = _v1.z;
			var r = _v1.r;
			return $author$project$Svgl$Tree$ellipse(
				_Utils_update(
					params,
					{h: r * 2, w: r * 2, x: x, y: y, z: z * height}));
		};
		var cirtri = function (_v0) {
			var z = _v0.z;
			var a = _v0.a;
			return cir(
				{
					r: 0.15,
					x: 1.6 * $elm$core$Basics$cos(
						$elm$core$Basics$degrees(a)),
					y: 1.6 * $elm$core$Basics$sin(
						$elm$core$Basics$degrees(a)),
					z: z
				});
		};
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			_List_fromArray(
				[
					re(
					{h: 1.8, w: 1.8, x: -1, y: -1, z: 0.92}),
					re(
					{h: 1.8, w: 1.8, x: 1, y: -1, z: 0.92}),
					re(
					{h: 1.8, w: 1.8, x: 1, y: 1, z: 0.92}),
					re(
					{h: 1.8, w: 1.8, x: -1, y: 1, z: 0.92}),
					re(
					{h: 0.4, w: 1, x: 0, y: -1.8, z: 0.925}),
					re(
					{h: 3, w: 0.2, x: (-1.2) + (0.2 * slowSin), y: 0, z: 0.925}),
					tri(
					{x: -1.9, y: -0.5, z: 0.93}),
					tri(
					{x: -1.9, y: -0.8, z: 0.93}),
					tri(
					{x: -1.9, y: -1.1, z: 0.93}),
					tri(
					{x: -1.9, y: 0.5, z: 0.93}),
					tri(
					{x: -1.9, y: 0.8, z: 0.93}),
					tri(
					{x: -1.9, y: 1.1, z: 0.93}),
					re(
					{h: 0.5, w: 0.2, x: 0.4, y: 1.4 + (0.1 * slowSin), z: 0.93}),
					re(
					{h: 0.5, w: 0.2, x: 0.7, y: 1.4, z: 0.93}),
					re(
					{h: 0.5, w: 0.2, x: 1.0, y: 1.4 + (0.1 * fastSin), z: 0.93}),
					cir(
					{r: 0.5, x: 0, y: 0, z: 0.94}),
					A2(
					$author$project$Svgl$Tree$Nod,
					_List_fromArray(
						[
							$author$project$Svgl$Tree$rotateRad($elm$core$Basics$pi * (slowSin - fastSin))
						]),
					_List_fromArray(
						[
							re(
							{h: 0.3, w: 0.3, x: -0.5, y: 0, z: 0.951}),
							re(
							{h: 0.3, w: 0.3, x: 0, y: -0.5, z: 0.952}),
							re(
							{h: 0.3, w: 0.3, x: 0.5, y: 0, z: 0.953}),
							re(
							{h: 0.3, w: 0.3, x: 0, y: 0.5, z: 0.954})
						])),
					cir(
					{r: 0.1, x: 0.5 * fastSin, y: 0.5 * slowSin, z: 0.96}),
					cir(
					{r: 0.1, x: 0.5 * slowSin, y: 0.5 * (-fastSin), z: 0.96}),
					cir(
					{r: 0.1, x: 0.5 * (-slowSin), y: 0.5 * (-slowSin), z: 0.96}),
					cir(
					{r: 0.1, x: 0.5 * (-slowSin), y: 0.5 * fastSin, z: 0.96}),
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						params,
						{fill: dark, h: 2.2 * completion, opacity: 0.7, stroke: dark, w: 2.2 * completion, z: 0.97 * height})),
					A3(
					$author$project$View$Base$teeth,
					completion,
					1.1,
					_Utils_update(
						params,
						{z: 0.98 * height})),
					cir(
					{r: 0.4, x: 1.8, y: 1.8, z: 0.99}),
					cir(
					{r: 0.4, x: -1.8, y: 1.8, z: 0.99}),
					cir(
					{r: 0.4, x: -1.8, y: -1.8, z: 0.99}),
					cir(
					{r: 0.4, x: 1.8, y: -1.8, z: 0.99}),
					cirtri(
					{a: -20, z: 0.99}),
					cirtri(
					{a: (-40) + (5 * fastSin), z: 0.98}),
					cirtri(
					{a: -60, z: 0.99})
				]));
	});
var $author$project$Colors$darkRed = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, $author$project$Colors$dark, 0, 0);
var $author$project$View$Mech$height = $author$project$Stats$maxHeight.mech;
var $author$project$Colors$red = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 0);
var $author$project$View$Mech$eye = function (_v0) {
	var x = _v0.x;
	var y = _v0.y;
	var a = _v0.a;
	return $author$project$Svgl$Tree$ellipse(
		_Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{
				fill: $author$project$Colors$red,
				h: 0.16,
				rotate: $elm$core$Basics$degrees(a),
				stroke: $author$project$Colors$darkRed,
				strokeWidth: 0.02,
				w: 0.1,
				x: x,
				y: y,
				z: $author$project$View$Mech$height
			}));
};
var $author$project$View$Mech$primitiveColor = F4(
	function (primitive, fill, stroke, _v0) {
		var x = _v0.x;
		var y = _v0.y;
		var z = _v0.z;
		var a = _v0.a;
		var w = _v0.w;
		var h = _v0.h;
		return primitive(
			_Utils_update(
				$author$project$Svgl$Tree$defaultParams,
				{
					fill: fill,
					h: h,
					rotate: $elm$core$Basics$degrees(a),
					stroke: stroke,
					w: w,
					x: x,
					y: y,
					z: z
				}));
	});
var $author$project$View$Mech$rectangleColor = $author$project$View$Mech$primitiveColor($author$project$Svgl$Tree$rect);
var $author$project$View$Mech$blimpHead = F4(
	function (t, fillColor, strokeColor, angle) {
		var y = 0.35;
		var sm = $author$project$Game$smooth(t);
		var x = A2(sm, 0.1, 0);
		var h = 0.2;
		var a = A2(sm, -35, 0);
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$rotateRad(angle)
				]),
			_List_fromArray(
				[
					A3(
					$author$project$View$Mech$rectangleColor,
					fillColor,
					strokeColor,
					{
						a: 0,
						h: A2(sm, 0.9, 0.5),
						w: A2(sm, 0.4, 0.1),
						x: 0,
						y: 0,
						z: 0.99 * $author$project$View$Mech$height
					}),
					$author$project$View$Mech$eye(
					{
						a: -a,
						x: -x,
						y: A2(sm, y, 0.4)
					}),
					$author$project$View$Mech$eye(
					{
						a: a,
						x: x,
						y: A2(sm, y, 0.4)
					}),
					$author$project$View$Mech$eye(
					{
						a: a,
						x: x,
						y: A2(sm, y - h, -0.4)
					}),
					$author$project$View$Mech$eye(
					{
						a: a,
						x: x,
						y: A2(sm, y - (2 * h), -0.4)
					}),
					$author$project$View$Mech$eye(
					{
						a: a,
						x: x,
						y: A2(sm, y - (3 * h), -0.4)
					})
				]));
	});
var $author$project$View$Mech$ellipseColor = $author$project$View$Mech$primitiveColor($author$project$Svgl$Tree$ellipse);
var $author$project$Colors$gunFill = $author$project$Colors$grey(0.5);
var $author$project$Colors$gunStroke = $author$project$Colors$grey(0.4);
var $author$project$View$Mech$mirrorRectanglesColor = F3(
	function (fill, stroke, params) {
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			_List_fromArray(
				[
					A3(
					$author$project$View$Mech$rectangleColor,
					fill,
					stroke,
					_Utils_update(
						params,
						{a: -params.a, x: -params.x})),
					A3($author$project$View$Mech$rectangleColor, fill, stroke, params)
				]));
	});
var $author$project$View$Mech$guns = function (_v0) {
	var x = _v0.x;
	var y = _v0.y;
	var w = _v0.w;
	var h = _v0.h;
	return A3(
		$author$project$View$Mech$mirrorRectanglesColor,
		$author$project$Colors$gunFill,
		$author$project$Colors$gunStroke,
		{a: 0, h: h, w: w, x: x, y: y, z: 0.9 * $author$project$View$Mech$height});
};
var $author$project$Game$step = F4(
	function (t, threshold, a, b) {
		return (_Utils_cmp(t, threshold) > 0) ? b : a;
	});
var $author$project$View$Mech$blimp = function (args) {
	var st = A2($author$project$Game$step, args.transformState, 0);
	var sm = $author$project$Game$smooth(args.transformState);
	var shY = -0.2;
	var shX = 0.63;
	var shW = 0.4;
	var shH = 0.6;
	var shA = 10;
	var rectangle = A2($author$project$View$Mech$rectangleColor, args.fill, args.stroke);
	var mirrorRectangles = A2($author$project$View$Mech$mirrorRectanglesColor, args.fill, args.stroke);
	var ellipse = A2($author$project$View$Mech$ellipseColor, args.fill, args.stroke);
	var armY = 0.2;
	var armX = 0.4;
	var armW = 0.2;
	var armH = 0.8;
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateRad(args.fireAngle)
					]),
				_List_fromArray(
					[
						$author$project$View$Mech$guns(
						{
							h: 0.9,
							w: A2(sm, 0.24, 0.15),
							x: A2(sm, 0.42, 0.25),
							y: A2(sm, 0.63, 0.3)
						}),
						mirrorRectangles(
						{
							a: A2(sm, 30, 45),
							h: 0.3,
							w: A2(sm, 0.2, 0.3),
							x: A2(sm, 0.3, 0.3),
							y: A2(sm, -0.15, -0.8),
							z: 0.91 * $author$project$View$Mech$height
						}),
						mirrorRectangles(
						{
							a: A2(sm, -15, 0),
							h: 0.2,
							w: A2(sm, 0.45, 0.35),
							x: A2(sm, 0.25, 0.35),
							y: A2(sm, -0.35, -0.94),
							z: 0.92 * $author$project$View$Mech$height
						}),
						mirrorRectangles(
						{
							a: A2(sm, 80 + (360 * 10), 40),
							h: A2(sm, 0.1, 0.3),
							w: A2(sm, 0.7, 0.5),
							x: A2(sm, 0.6, 0.5),
							y: A2(sm, 0.2, 0),
							z: 0.93 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, armH, 2.4),
							w: A2(sm, armW, 1.0),
							x: A2(sm, armX, 0),
							y: A2(sm, armY, 0),
							z: 0.94 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, armH, 2.4),
							w: A2(sm, armW, 0.65),
							x: A2(sm, -armX, 0),
							y: A2(sm, armY, 0),
							z: 0.95 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, 0.55, 2.4),
							w: A2(sm, 1.2, 0.25),
							x: 0,
							y: A2(sm, -0.1, 0),
							z: 0.96 * $author$project$View$Mech$height
						}),
						rectangle(
						{
							a: A2(sm, shA, 0),
							h: A2(sm, shH, 0.3),
							w: A2(sm, shW, 0.1),
							x: A2(sm, shX, 0),
							y: A2(sm, shY, -0.8),
							z: 0.97 * $author$project$View$Mech$height
						}),
						rectangle(
						{
							a: A2(sm, -shA, 0),
							h: A2(sm, shH, 0.2),
							w: A2(sm, shW, 0.1),
							x: A2(sm, -shX, 0),
							y: A2(sm, shY, -0.94),
							z: 0.98 * $author$project$View$Mech$height
						})
					])),
				A4(
				$author$project$View$Mech$blimpHead,
				args.transformState,
				args.fill,
				args.stroke,
				A2(st, args.lookAngle, args.fireAngle))
			]));
};
var $author$project$View$Mech$heliHead = F4(
	function (t, fillColor, strokeColor, angle) {
		var sm = $author$project$Game$smooth(t);
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$rotateRad(angle)
				]),
			_List_fromArray(
				[
					A3(
					$author$project$View$Mech$ellipseColor,
					fillColor,
					strokeColor,
					{
						a: 0,
						h: A2(sm, 0.8, 0.4),
						w: A2(sm, 0.48, 0.22),
						x: 0,
						y: A2(sm, 0.03, 0.75),
						z: 0.99 * $author$project$View$Mech$height
					}),
					$author$project$View$Mech$eye(
					{
						a: A2(sm, 0, 0),
						x: 0,
						y: A2(sm, 0.32, 0.85)
					}),
					$author$project$View$Mech$eye(
					{
						a: A2(sm, 15, -10),
						x: A2(sm, -0.14, -0.09),
						y: A2(sm, 0.18, 0.7)
					}),
					$author$project$View$Mech$eye(
					{
						a: A2(sm, -15, 10),
						x: A2(sm, 0.14, 0.09),
						y: A2(sm, 0.18, 0.7)
					})
				]));
	});
var $author$project$Game$periodLinear = F3(
	function (time, phase, period) {
		var t = time + (phase * period);
		var n = $elm$core$Basics$floor(t / period);
		return (t / period) - n;
	});
var $author$project$View$Mech$heliPropeller = F2(
	function (diameter, t) {
		var w = 0.05 * diameter;
		var h = 0.5 * diameter;
		var da = 360 * A3($author$project$Game$periodLinear, t, 0, 0.037);
		var prop = function (a) {
			return A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateDeg(a + da)
					]),
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rect(
						_Utils_update(
							$author$project$Svgl$Tree$defaultParams,
							{fill: $author$project$Colors$gunFill, h: h, stroke: $author$project$Colors$gunStroke, strokeWidth: 0.01, w: w, x: w / 2, y: h / 2}))
					]));
		};
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			_List_fromArray(
				[
					prop(0),
					prop(72),
					prop(142),
					prop(-142),
					prop(-72),
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						$author$project$Svgl$Tree$defaultParams,
						{fill: $author$project$Colors$gunFill, h: diameter, opacity: 0.1, stroke: $author$project$Colors$gunFill, strokeWidth: 0.01, w: diameter}))
				]));
	});
var $author$project$View$Mech$heli = function (args) {
	var st = A2($author$project$Game$step, args.transformState, 0);
	var sm = $author$project$Game$smooth(args.transformState);
	var rectangle = A2($author$project$View$Mech$rectangleColor, args.fill, args.stroke);
	var mirrorRectangles = A2($author$project$View$Mech$mirrorRectanglesColor, args.fill, args.stroke);
	var ellipse = A2($author$project$View$Mech$ellipseColor, args.fill, args.stroke);
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateRad(args.fireAngle)
					]),
				_List_fromArray(
					[
						$author$project$View$Mech$guns(
						{
							h: 0.3,
							w: 0.24,
							x: 0.42,
							y: A2(sm, 0.63, 0.33)
						}),
						mirrorRectangles(
						{
							a: A2(sm, -90, 20),
							h: 0.3,
							w: 0.7,
							x: A2(sm, 0.5, 0.4),
							y: A2(sm, 0.3, 0.16),
							z: 0.91 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, 0.37, 1.9),
							w: A2(sm, 0.8, 0.42),
							x: 0,
							y: A2(sm, -0.04, 0),
							z: 0.92 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, 0.5, 0.5),
							w: A2(sm, 1.4, 0.42),
							x: 0,
							y: A2(sm, -0.04, 0),
							z: 0.93 * $author$project$View$Mech$height
						}),
						mirrorRectangles(
						{
							a: 5,
							h: A2(sm, 0.4, 0.68),
							w: 0.2,
							x: 0.2,
							y: A2(sm, -0.4, 0),
							z: 0.94 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, 0.4, 0.7),
							w: 0.3,
							x: 0,
							y: A2(sm, -0.41, 0.1),
							z: 0.95 * $author$project$View$Mech$height
						}),
						mirrorRectangles(
						{
							a: A2(sm, 110, 20),
							h: A2(sm, 0.42, 0.12),
							w: A2(sm, 0.52, 0.32),
							x: A2(sm, -0.55, 0.2),
							y: A2(sm, -0.05, -1.39),
							z: 0.96 * $author$project$View$Mech$height
						}),
						ellipse(
						{
							a: 0,
							h: A2(sm, 0.2, 0.57),
							w: 0.2,
							x: 0,
							y: A2(sm, -0.35, -1.15),
							z: 0.97 * $author$project$View$Mech$height
						})
					])),
				A4(
				$author$project$View$Mech$heliHead,
				args.transformState,
				args.fill,
				args.stroke,
				A2(st, args.lookAngle, args.fireAngle)),
				A2($author$project$View$Mech$heliPropeller, 2.4 * args.transformState, args.time)
			]));
};
var $author$project$View$Mech$planeHead = F4(
	function (t, fillColor, strokeColor, angle) {
		var sm = $author$project$Game$smooth(t);
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$rotateRad(angle)
				]),
			_List_fromArray(
				[
					A3(
					$author$project$View$Mech$ellipseColor,
					fillColor,
					strokeColor,
					{
						a: 0,
						h: 6 * A2(sm, 0.17, 0.34),
						w: 0.48,
						x: 0,
						y: -0.03,
						z: 0.99 * $author$project$View$Mech$height
					}),
					$author$project$View$Mech$eye(
					{
						a: 14,
						x: 0.09,
						y: A2(sm, 0.3, 0.66)
					}),
					$author$project$View$Mech$eye(
					{
						a: -14,
						x: -0.09,
						y: A2(sm, 0.3, 0.66)
					}),
					$author$project$View$Mech$eye(
					{
						a: 6,
						x: 0.15,
						y: A2(sm, 0.09, 0.45)
					}),
					$author$project$View$Mech$eye(
					{
						a: -6,
						x: -0.15,
						y: A2(sm, 0.09, 0.45)
					})
				]));
	});
var $author$project$View$Mech$plane = function (args) {
	var st = A2($author$project$Game$step, args.transformState, 0);
	var sm = $author$project$Game$smooth(args.transformState);
	var rectangle = A2($author$project$View$Mech$rectangleColor, args.fill, args.stroke);
	var mirrorRectangles = A2($author$project$View$Mech$mirrorRectanglesColor, args.fill, args.stroke);
	var ellipse = A2($author$project$View$Mech$ellipseColor, args.fill, args.stroke);
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateRad(args.fireAngle)
					]),
				_List_fromArray(
					[
						$author$project$View$Mech$guns(
						{
							h: 3 * 0.26,
							w: 3 * A2(sm, 0.08, 0.05),
							x: 3 * A2(sm, 0.14, 0.1),
							y: 3 * A2(sm, 0.21, 0.26)
						}),
						mirrorRectangles(
						{
							a: A2(sm, 0, 15),
							h: 3 * A2(sm, 0.23, 0.15),
							w: 3 * A2(sm, 0.1, 0.4),
							x: 3 * A2(sm, 0.18, 0.25),
							y: 3 * A2(sm, 0.1, 0.03),
							z: 0.96 * $author$project$View$Mech$height
						}),
						rectangle(
						{
							a: 0,
							h: 3 * A2(sm, 0.17, 0.12),
							w: 3 * A2(sm, 0.45, 0.3),
							x: 0,
							y: 3 * A2(sm, -0.04, 0.04),
							z: 0.97 * $author$project$View$Mech$height
						}),
						mirrorRectangles(
						{
							a: A2(sm, 10, -45),
							h: 3 * A2(sm, 0.23, 0.25),
							w: 3 * A2(sm, 0.15, 0.15),
							x: 3 * A2(sm, 0.21, 0.12),
							y: 3 * A2(sm, -0.04, -0.25),
							z: 0.98 * $author$project$View$Mech$height
						})
					])),
				A4(
				$author$project$View$Mech$planeHead,
				args.transformState,
				args.fill,
				args.stroke,
				A2(st, args.lookAngle, args.fireAngle))
			]));
};
var $author$project$View$Mech$mech = function (_class) {
	switch (_class.$) {
		case 'Plane':
			return $author$project$View$Mech$plane;
		case 'Heli':
			return $author$project$View$Mech$heli;
		default:
			return $author$project$View$Mech$blimp;
	}
};
var $elm_explorations$linear_algebra$Math$Vector3$add = _MJS_v3add;
var $elm_explorations$linear_algebra$Math$Vector3$scale = _MJS_v3scale;
var $author$project$Game$mix3 = F3(
	function (a, b, w) {
		return A2(
			$elm_explorations$linear_algebra$Math$Vector3$add,
			A2($elm_explorations$linear_algebra$Math$Vector3$scale, w, a),
			A2($elm_explorations$linear_algebra$Math$Vector3$scale, 1 - w, b));
	});
var $author$project$View$Base$small = F3(
	function (completion, bright, dark) {
		var params = _Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{fill: bright, stroke: dark});
		var height = $author$project$Stats$maxHeight.base;
		var re = function (_v1) {
			var x = _v1.x;
			var y = _v1.y;
			var z = _v1.z;
			var w = _v1.w;
			var h = _v1.h;
			return $author$project$Svgl$Tree$rect(
				_Utils_update(
					params,
					{h: h, w: w, x: x, y: y, z: z * height}));
		};
		var cir = function (_v0) {
			var x = _v0.x;
			var y = _v0.y;
			var z = _v0.z;
			var r = _v0.r;
			return $author$project$Svgl$Tree$ellipse(
				_Utils_update(
					params,
					{h: r * 2, w: r * 2, x: x, y: y, z: z * height}));
		};
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			_List_fromArray(
				[
					cir(
					{r: 1, x: 0, y: 0, z: 0.94}),
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						params,
						{fill: dark, h: 1.2 * completion, opacity: 0.7, w: 1.2 * completion, z: 0.95})),
					A3(
					$author$project$View$Base$teeth,
					completion,
					0.7,
					_Utils_update(
						params,
						{z: 0.955 * height})),
					re(
					{h: 0.4, w: 0.2, x: -1, y: 0, z: 0.96}),
					re(
					{h: 0.15, w: 0.2, x: 1, y: 0.15, z: 0.96}),
					re(
					{h: 0.15, w: 0.2, x: 1, y: -0.15, z: 0.96}),
					cir(
					{r: 0.4, x: 0.8, y: 0.8, z: 0.97}),
					cir(
					{r: 0.4, x: -0.8, y: 0.8, z: 0.97}),
					cir(
					{r: 0.4, x: -0.8, y: -0.8, z: 0.97}),
					cir(
					{r: 0.4, x: 0.8, y: -0.8, z: 0.97})
				]));
	});
var $author$project$Svgl$Tree$translateVz = F2(
	function (v, z) {
		return {
			rotate: 0,
			translate: A3(
				$elm_explorations$linear_algebra$Math$Vector3$vec3,
				$elm_explorations$linear_algebra$Math$Vector2$getX(v),
				$elm_explorations$linear_algebra$Math$Vector2$getY(v),
				z)
		};
	});
var $author$project$View$Game$viewBase = F2(
	function (game, base) {
		var colorPattern = A2($author$project$Base$colorPattern, game, base);
		var _v0 = function () {
			var _v1 = base.maybeOccupied;
			if (_v1.$ === 'Nothing') {
				return _Utils_Tuple2($elm$core$Maybe$Nothing, 0);
			} else {
				var occupied = _v1.a;
				return A2(
					$elm$core$Maybe$withDefault,
					_Utils_Tuple2($elm$core$Maybe$Nothing, occupied.subBuildCompletion),
					A2(
						$elm$core$Maybe$map,
						$elm$core$Tuple$mapFirst($elm$core$Maybe$Just),
						A2($elm_community$list_extra$List$Extra$maximumBy, $elm$core$Tuple$second, occupied.mechBuildCompletions)));
			}
		}();
		var buildTarget = _v0.a;
		var completion = _v0.b;
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					A2($author$project$Svgl$Tree$translateVz, base.position, 0)
				]),
			_List_fromArray(
				[
					function () {
					var _v2 = base.type_;
					if (_v2.$ === 'BaseSmall') {
						return A3($author$project$View$Base$small, completion, colorPattern.brightV, colorPattern.darkV);
					} else {
						return A3($author$project$View$Base$main_, completion, colorPattern.brightV, colorPattern.darkV);
					}
				}(),
					function () {
					if (buildTarget.$ === 'Nothing') {
						return A2($author$project$Svgl$Tree$Nod, _List_Nil, _List_Nil);
					} else {
						var mech = buildTarget.a;
						return A2(
							$author$project$View$Mech$mech,
							mech._class,
							{
								fill: A3($author$project$Game$mix3, colorPattern.brightV, colorPattern.darkV, completion),
								fireAngle: 0,
								lookAngle: 0,
								stroke: A3($author$project$Game$mix3, colorPattern.darkV, colorPattern.brightV, completion),
								time: 0,
								transformState: 1
							});
					}
				}()
				]));
	});
var $author$project$View$Hud$bar = F2(
	function (color, completion) {
		var w = 0.95;
		var h = 0.15;
		var frameColor = $author$project$Colors$grey(0.15);
		var border = 0.025;
		return _List_fromArray(
			[
				$author$project$Svgl$Tree$rect(
				_Utils_update(
					$author$project$Svgl$Tree$defaultParams,
					{fill: frameColor, h: h, stroke: frameColor, strokeWidth: border, w: w})),
				$author$project$Svgl$Tree$rect(
				_Utils_update(
					$author$project$Svgl$Tree$defaultParams,
					{fill: color, h: h, stroke: frameColor, strokeWidth: border, w: w * completion, x: border - ((w * (1 - completion)) / 2)}))
			]);
	});
var $author$project$Colors$blue = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0, 0, 1);
var $author$project$View$Hud$chargeBar = function (charge) {
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_fromArray(
			[
				A2($author$project$Svgl$Tree$translate2, 0, -0.65)
			]),
		A2($author$project$View$Hud$bar, $author$project$Colors$blue, charge));
};
var $author$project$Unit$colorPattern = F2(
	function (game, unit) {
		return A2($author$project$Game$teamColorPattern, game, unit.maybeTeamId);
	});
var $author$project$View$Hud$salvoMark = F3(
	function (time, _v0, position) {
		var brightV = _v0.brightV;
		var darkV = _v0.darkV;
		var p = $elm_explorations$linear_algebra$Math$Vector2$toRecord(position);
		var _v1 = (A3($author$project$Game$periodLinear, time, 0, 0.1) > 0.5) ? _Utils_Tuple2(brightV, darkV) : _Utils_Tuple2(darkV, brightV);
		var fillColor = _v1.a;
		var strokeColor = _v1.b;
		return $author$project$Svgl$Tree$ellipse(
			_Utils_update(
				$author$project$Svgl$Tree$defaultParams,
				{fill: fillColor, h: 0.2, stroke: strokeColor, strokeWidth: 0.03, w: 0.2, x: p.x, y: p.y}));
	});
var $author$project$View$Game$viewCharge = F2(
	function (game, unit) {
		var _v0 = unit.maybeCharge;
		_v0$2:
		while (true) {
			if (_v0.$ === 'Just') {
				switch (_v0.a.$) {
					case 'Charging':
						var startTime = _v0.a.a;
						return ((game.time - startTime) < 0.3) ? A2($author$project$Svgl$Tree$Nod, _List_Nil, _List_Nil) : A2(
							$author$project$Svgl$Tree$Nod,
							_List_fromArray(
								[
									$author$project$Svgl$Tree$translate(unit.position)
								]),
							_List_fromArray(
								[
									$author$project$View$Hud$chargeBar((game.time - startTime) / $author$project$Stats$heli.chargeTime)
								]));
					case 'Stretching':
						var startTime = _v0.a.a;
						return A2(
							$author$project$Svgl$Tree$Nod,
							_List_Nil,
							A2(
								$elm$core$List$map,
								A2(
									$author$project$View$Hud$salvoMark,
									game.time,
									A2($author$project$Unit$colorPattern, game, unit)),
								A2($author$project$Mech$heliSalvoPositions, game.time - startTime, unit)));
					default:
						break _v0$2;
				}
			} else {
				break _v0$2;
			}
		}
		return A2($author$project$Svgl$Tree$Nod, _List_Nil, _List_Nil);
	});
var $author$project$Colors$green = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0, 1, 0);
var $author$project$View$Hud$healthBar = function (integrity) {
	var color = (integrity > 0.8) ? $author$project$Colors$green : ((integrity > 0.4) ? $author$project$Colors$yellow : $author$project$Colors$red);
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_fromArray(
			[
				A2($author$project$Svgl$Tree$translate2, 0, -0.8)
			]),
		A2($author$project$View$Hud$bar, color, integrity));
};
var $author$project$View$Game$viewHealthbar = function (unit) {
	return (unit.integrity > 0.95) ? A2($author$project$Svgl$Tree$Nod, _List_Nil, _List_Nil) : A2(
		$author$project$Svgl$Tree$Nod,
		_List_fromArray(
			[
				$author$project$Svgl$Tree$translate(unit.position)
			]),
		_List_fromArray(
			[
				$author$project$View$Hud$healthBar(unit.integrity)
			]));
};
var $author$project$Colors$white = $author$project$Colors$grey(1);
var $author$project$View$Game$unitColors = F2(
	function (game, unit) {
		if (((game.time - unit.lastDamaged) < 0.5) && (A3($author$project$Game$periodLinear, game.time, unit.id / 77, 0.1) < 0.1)) {
			return {bright: $author$project$Colors$white, dark: $author$project$Colors$white};
		} else {
			var colorPattern = A2($author$project$Game$teamColorPattern, game, unit.maybeTeamId);
			return {bright: colorPattern.brightV, dark: colorPattern.darkV};
		}
	});
var $author$project$View$Game$viewMech = F2(
	function (game, _v0) {
		var unit = _v0.a;
		var mech = _v0.b;
		var _v1 = A2($author$project$View$Game$unitColors, game, unit);
		var bright = _v1.bright;
		var dark = _v1.dark;
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$translate(unit.position)
				]),
			_List_fromArray(
				[
					A2(
					$author$project$View$Mech$mech,
					mech._class,
					{fill: bright, fireAngle: unit.fireAngle, lookAngle: unit.lookAngle, stroke: dark, time: game.time, transformState: mech.transformState})
				]));
	});
var $author$project$View$Projectile$red = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 0, 0);
var $author$project$View$Projectile$yellow = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 1, 1, 0);
var $author$project$View$Projectile$bullet = F2(
	function (position, angle) {
		return $author$project$Svgl$Tree$ellipse(
			_Utils_update(
				$author$project$Svgl$Tree$defaultParams,
				{
					fill: $author$project$View$Projectile$yellow,
					h: 0.45,
					rotate: angle,
					stroke: $author$project$View$Projectile$red,
					strokeWidth: 0.015,
					w: 0.25,
					x: $elm_explorations$linear_algebra$Math$Vector2$getX(position),
					y: $elm_explorations$linear_algebra$Math$Vector2$getY(position),
					z: $author$project$Stats$maxHeight.projectile
				}));
	});
var $author$project$View$Projectile$gray = A3($elm_explorations$linear_algebra$Math$Vector3$vec3, 0.6, 0.6, 0.6);
var $author$project$View$Projectile$rocket = F6(
	function (position, angle, bodyColor, fillColor, strokeColor, time) {
		var w = 0.3;
		var params = _Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{strokeWidth: 0.01});
		var h = 0.4;
		var hh = h / 2;
		var exhaust = 1 + A3($author$project$Game$periodLinear, time, 0, 0.1);
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$translate(position),
					$author$project$Svgl$Tree$rotateRad(angle)
				]),
			_List_fromArray(
				[
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						params,
						{fill: $author$project$View$Projectile$yellow, h: exhaust * h, stroke: $author$project$View$Projectile$yellow, w: w, y: -hh})),
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						params,
						{fill: fillColor, h: w, stroke: fillColor, w: w - 0.02, y: hh})),
					$author$project$Svgl$Tree$rect(
					_Utils_update(
						params,
						{fill: bodyColor, h: h, stroke: bodyColor, w: w}))
				]));
	});
var $author$project$View$Projectile$projectile = function (_v0) {
	var classId = _v0.classId;
	var position = _v0.position;
	var angle = _v0.angle;
	var age = _v0.age;
	var colorPattern = _v0.colorPattern;
	switch (classId.$) {
		case 'PlaneBullet':
			return A2($author$project$View$Projectile$bullet, position, angle);
		case 'BigSubBullet':
			return A2($author$project$View$Projectile$bullet, position, angle);
		case 'HeliRocket':
			return A6($author$project$View$Projectile$rocket, position, angle, $author$project$View$Projectile$gray, colorPattern.brightV, colorPattern.darkV, age);
		case 'HeliMissile':
			var _v2 = (A3($author$project$Game$periodLinear, age, 0, 0.1) > 0.5) ? _Utils_Tuple2($author$project$Colors$white, colorPattern.brightV) : _Utils_Tuple2(colorPattern.darkV, $author$project$Colors$white);
			var a = _v2.a;
			var b = _v2.b;
			return A6($author$project$View$Projectile$rocket, position, angle, a, b, a, age);
		case 'UpwardSalvo':
			return A6($author$project$View$Projectile$rocket, position, angle, $author$project$View$Projectile$gray, colorPattern.brightV, colorPattern.darkV, age);
		default:
			return A6($author$project$View$Projectile$rocket, position, angle, $author$project$View$Projectile$gray, colorPattern.brightV, colorPattern.darkV, age);
	}
};
var $author$project$View$Game$viewProjectile = F2(
	function (game, projectile) {
		return $author$project$View$Projectile$projectile(
			{
				age: game.time - projectile.spawnTime,
				angle: projectile.angle,
				classId: projectile.classId,
				colorPattern: A2($author$project$Game$teamColorPattern, game, projectile.maybeTeamId),
				position: projectile.position
			});
	});
var $author$project$View$Hud$arrow = F2(
	function (fill, stroke) {
		var params = _Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{fill: fill, stroke: stroke});
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$rect(
					_Utils_update(
						params,
						{h: 0.25, w: 0.25, y: -0.08})),
					$author$project$Svgl$Tree$rightTri(
					_Utils_update(
						params,
						{
							h: 0.35,
							rotate: $elm$core$Basics$degrees(135),
							w: 0.35
						}))
				]));
	});
var $author$project$Game$periodHarmonic = F3(
	function (time, phase, period) {
		return $elm$core$Basics$sin(
			(2 * $elm$core$Basics$pi) * A3($author$project$Game$periodLinear, time, phase, period));
	});
var $author$project$View$Hud$rallyPoint = F3(
	function (t, fill, stroke) {
		var params = _Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{fill: fill, stroke: stroke});
		var distance = 0.5 + (0.25 * A3($author$project$Game$periodHarmonic, t, 0, 0.3));
		var arro = function (a) {
			return A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateDeg(a),
						A2($author$project$Svgl$Tree$translate2, 0, -distance)
					]),
				_List_fromArray(
					[
						A2($author$project$View$Hud$arrow, fill, stroke)
					]));
		};
		var angle = A3($author$project$Game$periodHarmonic, t, 0.1, 20) * 180;
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						params,
						{h: 0.6, w: 0.5})),
					$author$project$Svgl$Tree$ellipse(
					_Utils_update(
						params,
						{h: 0.3, strokeWidth: 0.7 * params.strokeWidth, w: 0.25, y: 0.13})),
					arro(angle + 45),
					arro(angle + 135),
					arro(angle + 225),
					arro(angle + (-45))
				]));
	});
var $author$project$View$Game$viewRallyPoint = F2(
	function (game, team) {
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					$author$project$Svgl$Tree$translate(team.markerPosition)
				]),
			_List_fromArray(
				[
					A3($author$project$View$Hud$rallyPoint, game.time, team.colorPattern.darkV, team.colorPattern.brightV)
				]));
	});
var $author$project$SetupPhase$viewArrows = F4(
	function (direction, colorPattern, x, game) {
		var params = {fill: colorPattern.darkV, stroke: colorPattern.brightV};
		var hh = game.halfHeight - 1;
		var arrow = function (y) {
			return A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						A2(
						$author$project$Svgl$Tree$translate2,
						x + (0.1 * A3($author$project$Game$periodHarmonic, game.time, 0.17 * y, 1)),
						y),
						$author$project$Svgl$Tree$rotateRad(direction)
					]),
				_List_fromArray(
					[
						A2($author$project$View$Hud$arrow, colorPattern.darkV, colorPattern.brightV)
					]));
		};
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_Nil,
			A2(
				$elm$core$List$map,
				arrow,
				A2($elm$core$List$range, -hh, hh)));
	});
var $author$project$SetupPhase$view = function (game) {
	return _List_fromArray(
		[
			A4(
			$author$project$SetupPhase$viewArrows,
			$elm$core$Basics$degrees(-90),
			game.leftTeam.colorPattern,
			-$author$project$SetupPhase$neutralTilesHalfWidth,
			game),
			A4(
			$author$project$SetupPhase$viewArrows,
			$elm$core$Basics$degrees(90),
			game.rightTeam.colorPattern,
			$author$project$SetupPhase$neutralTilesHalfWidth,
			game)
		]);
};
var $author$project$View$Game$viewSetup = function (game) {
	var _v0 = game.mode;
	if (_v0.$ === 'GameModeTeamSelection') {
		return $author$project$SetupPhase$view(game);
	} else {
		return _List_Nil;
	}
};
var $author$project$View$Sub$sub = function (_v0) {
	var lookAngle = _v0.lookAngle;
	var moveAngle = _v0.moveAngle;
	var fireAngle = _v0.fireAngle;
	var bright = _v0.bright;
	var dark = _v0.dark;
	var isBig = _v0.isBig;
	var height = $author$project$Stats$maxHeight.sub;
	var gunOrigin = $author$project$View$Sub$gunOffset(moveAngle);
	var eyeParams = _Utils_update(
		$author$project$Svgl$Tree$defaultParams,
		{fill: $author$project$Colors$red, stroke: $author$project$Colors$darkRed, strokeWidth: 0.02});
	var _v1 = isBig ? _Utils_Tuple2(dark, bright) : _Utils_Tuple2(bright, dark);
	var fillColor = _v1.a;
	var strokeColor = _v1.b;
	var params = _Utils_update(
		$author$project$Svgl$Tree$defaultParams,
		{fill: fillColor, stroke: strokeColor});
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						A2($author$project$Svgl$Tree$translateVz, gunOrigin, 0),
						$author$project$Svgl$Tree$rotateRad(fireAngle)
					]),
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rect(
						_Utils_update(
							$author$project$Svgl$Tree$defaultParams,
							{fill: $author$project$Colors$gunFill, h: 1.1, stroke: $author$project$Colors$gunStroke, w: 0.21, y: 0.21, z: 0.5 * height}))
					])),
				A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateRad(moveAngle)
					]),
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rect(
						_Utils_update(
							params,
							{h: 0.4, w: 0.9, z: 0.7 * height}))
					])),
				A2(
				$author$project$Svgl$Tree$Nod,
				_List_fromArray(
					[
						$author$project$Svgl$Tree$rotateRad(lookAngle)
					]),
				_List_fromArray(
					[
						$author$project$Svgl$Tree$ellipse(
						_Utils_update(
							params,
							{h: 0.6, w: 0.5, z: 0.9 * height})),
						(!isBig) ? $author$project$Svgl$Tree$ellipse(
						_Utils_update(
							eyeParams,
							{h: 0.3, w: 0.25, y: 0.135})) : A2(
						$author$project$Svgl$Tree$Nod,
						_List_Nil,
						_List_fromArray(
							[
								$author$project$Svgl$Tree$ellipse(
								_Utils_update(
									eyeParams,
									{
										h: 0.2,
										rotate: $elm$core$Basics$degrees(30),
										w: 0.1,
										x: -0.08,
										y: 0.1
									})),
								$author$project$Svgl$Tree$ellipse(
								_Utils_update(
									eyeParams,
									{
										h: 0.16,
										rotate: $elm$core$Basics$degrees(-20),
										w: 0.09,
										x: 0.1,
										y: 0.13
									})),
								$author$project$Svgl$Tree$ellipse(
								_Utils_update(
									eyeParams,
									{
										h: 0.16,
										rotate: $elm$core$Basics$degrees(-20),
										w: 0.09,
										x: 0.1,
										y: -0.05
									}))
							]))
					]))
			]));
};
var $author$project$View$Game$viewSub = F2(
	function (game, _v0) {
		var unit = _v0.a;
		var subRecord = _v0.b;
		var z = function () {
			var _v2 = subRecord.mode;
			if (_v2.$ === 'UnitModeFree') {
				return 0;
			} else {
				return $author$project$Stats$maxHeight.base;
			}
		}();
		var _v1 = A2($author$project$View$Game$unitColors, game, unit);
		var bright = _v1.bright;
		var dark = _v1.dark;
		return A2(
			$author$project$Svgl$Tree$Nod,
			_List_fromArray(
				[
					A2($author$project$Svgl$Tree$translateVz, unit.position, z)
				]),
			_List_fromArray(
				[
					$author$project$View$Sub$sub(
					{bright: bright, dark: dark, fireAngle: unit.fireAngle, isBig: subRecord.isBig, lookAngle: unit.lookAngle, moveAngle: unit.moveAngle})
				]));
	});
var $author$project$View$Game$viewWall = function (_v0) {
	var xi = _v0.a;
	var yi = _v0.b;
	var yf = yi;
	var xf = xi;
	var d = $elm$core$Basics$sin(xf * 1372347) + $elm$core$Basics$sin(yf * 98325987);
	var color = (1 + d) / 4;
	var c = $elm$core$Basics$sin(xf * 9982399) + $elm$core$Basics$sin(yf * 17324650);
	var rot = 5 * c;
	return $author$project$Svgl$Tree$rect(
		_Utils_update(
			$author$project$Svgl$Tree$defaultParams,
			{
				fill: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, color, color, color),
				h: 1.1,
				rotate: $elm$core$Basics$degrees(rot),
				stroke: A3($elm_explorations$linear_algebra$Math$Vector3$vec3, color, color, color),
				w: 1.1,
				x: xf + 0.5,
				y: yf + 0.5
			}));
};
var $elm$svg$Svg$Attributes$height = _VirtualDom_attribute('height');
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$SplitScreen$style = function (tuples) {
	return A2(
		$elm$core$List$map,
		function (_v0) {
			var k = _v0.a;
			var v = _v0.b;
			return A2($elm$html$Html$Attributes$style, k, v);
		},
		tuples);
};
var $author$project$SplitScreen$viewportToStyle = function (viewport) {
	return _List_fromArray(
		[
			_Utils_Tuple2(
			'width',
			$elm$core$String$fromInt(viewport.w) + 'px'),
			_Utils_Tuple2(
			'height',
			$elm$core$String$fromInt(viewport.h) + 'px'),
			_Utils_Tuple2(
			'left',
			$elm$core$String$fromInt(viewport.x) + 'px'),
			_Utils_Tuple2(
			'top',
			$elm$core$String$fromInt(viewport.y) + 'px')
		]);
};
var $elm$svg$Svg$Attributes$width = _VirtualDom_attribute('width');
var $author$project$SplitScreen$viewportToWebGLAttributes = function (viewport) {
	return $elm$core$List$concat(
		_List_fromArray(
			[
				_List_fromArray(
				[
					$elm$svg$Svg$Attributes$width(
					$elm$core$String$fromInt(viewport.w)),
					$elm$svg$Svg$Attributes$height(
					$elm$core$String$fromInt(viewport.h))
				]),
				$author$project$SplitScreen$style(
				$author$project$SplitScreen$viewportToStyle(viewport))
			]));
};
var $elm_explorations$linear_algebra$Math$Matrix4$makeScale = _MJS_m4x4makeScale;
var $author$project$SplitScreen$normalizedSize = function (viewport) {
	var pixelW = viewport.w;
	var pixelH = viewport.h;
	var minSize = A2($elm$core$Basics$min, pixelW, pixelH);
	return {height: pixelH / minSize, width: pixelW / minSize};
};
var $author$project$View$Game$worldToCameraMatrix = F2(
	function (size, viewport) {
		var viewportScale = 2 / A2($author$project$View$Game$tilesToViewport, size, viewport);
		var normalizedSize = $author$project$SplitScreen$normalizedSize(viewport);
		return $elm_explorations$linear_algebra$Math$Matrix4$makeScale(
			A3($elm_explorations$linear_algebra$Math$Vector3$vec3, viewportScale / normalizedSize.width, viewportScale / normalizedSize.height, 1));
	});
var $author$project$View$Game$view = F2(
	function (viewport, game) {
		var units = A2(
			$elm$core$List$sortBy,
			function ($) {
				return $.id;
			},
			$elm$core$Dict$values(game.unitById));
		var shake = $elm_explorations$linear_algebra$Math$Vector2$toRecord(game.shakeVector);
		var worldToCamera = A2(
			$elm_explorations$linear_algebra$Math$Matrix4$translate,
			A3($elm_explorations$linear_algebra$Math$Vector3$vec3, shake.x, shake.y, 0),
			A2($author$project$View$Game$worldToCameraMatrix, game, viewport));
		var _v0 = $author$project$View$Game$mechVsUnit(units);
		var mechs = _v0.a;
		var subs = _v0.b;
		var _v1 = A2(
			$elm$core$List$partition,
			function (_v2) {
				var unit = _v2.a;
				var mech = _v2.b;
				return _Utils_eq(
					$author$project$Mech$transformMode(mech),
					$author$project$Game$ToFlyer);
			},
			mechs);
		var flyingMechs = _v1.a;
		var walkingMechs = _v1.b;
		var _v3 = A2(
			$elm$core$List$partition,
			function (_v4) {
				var unit = _v4.a;
				var sub = _v4.b;
				return _Utils_eq(sub.mode, $author$project$Game$UnitModeFree);
			},
			subs);
		var freeSubs = _v3.a;
		var baseSubs = _v3.b;
		return A3(
			$elm_explorations$webgl$WebGL$toHtmlWith,
			_List_fromArray(
				[
					$elm_explorations$webgl$WebGL$alpha(true),
					$elm_explorations$webgl$WebGL$antialias
				]),
			$author$project$SplitScreen$viewportToWebGLAttributes(viewport),
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$second,
				A2(
					$author$project$Svgl$Tree$treeToEntities,
					worldToCamera,
					A2(
						$author$project$Svgl$Tree$Nod,
						_List_Nil,
						$elm$core$List$concat(
							_List_fromArray(
								[
									$author$project$View$Game$viewSetup(game),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewSub(game),
									freeSubs),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewMech(game),
									walkingMechs),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewWall,
									$elm$core$Set$toList(game.wallTiles)),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewBase(game),
									$elm$core$Dict$values(game.baseById)),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewSub(game),
									baseSubs),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewMech(game),
									flyingMechs),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewProjectile(game),
									$elm$core$Dict$values(game.projectileById)),
									(!_Utils_eq(game.mode, $author$project$Game$GameModeVersus)) ? _List_Nil : A2(
									$elm$core$List$map,
									$author$project$View$Game$viewRallyPoint(game),
									_List_fromArray(
										[game.leftTeam, game.rightTeam])),
									A2(
									$elm$core$List$map,
									$author$project$View$Gfx$view(game),
									game.cosmetics),
									A2($elm$core$List$map, $author$project$View$Game$viewHealthbar, units),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewCharge(game),
									units)
								]))))));
	});
var $elm$core$Basics$round = _Basics_round;
var $elm$core$List$sum = function (numbers) {
	return A3($elm$core$List$foldl, $elm$core$Basics$add, 0, numbers);
};
var $author$project$MainScene$viewFps = F2(
	function (model, shell) {
		if (!shell.config.showFps) {
			return $elm$html$Html$text('');
		} else {
			var fps = $elm$core$Basics$round(
				$elm$core$List$sum(model.fps) / $elm$core$List$length(model.fps));
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('fps nonSelectable')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(
						'FPS ' + $elm$core$String$fromInt(fps))
					]));
		}
	});
var $elm$core$String$fromFloat = _String_fromNumber;
var $elm$html$Html$span = _VirtualDom_node('span');
var $author$project$MainScene$viewVictory = F2(
	function (viewport, game) {
		var _v0 = game.maybeVictory;
		if (_v0.$ === 'Nothing') {
			return $elm$html$Html$text('');
		} else {
			var _v1 = _v0.a;
			var teamId = _v1.a;
			var victoryTime = _v1.b;
			var team = A2($author$project$Game$getTeam, game, teamId);
			var size = A2($elm$core$Basics$min, viewport.w, viewport.h);
			var toPx = function (f) {
				return $elm$core$String$fromFloat(size * f) + 'px';
			};
			var pattern = team.colorPattern;
			var fadeInDuration = 1;
			var dt = game.time - victoryTime;
			var opacity = A2($elm$core$Basics$min, 1, dt / fadeInDuration);
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('fullWindow flex justifyCenter academy')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$span,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nonSelectable mt2'),
								A2($elm$html$Html$Attributes$style, '   -moz-text-fill-color', pattern.bright),
								A2($elm$html$Html$Attributes$style, '-webkit-text-fill-color', pattern.bright),
								A2($elm$html$Html$Attributes$style, '   -moz-text-stroke-color', pattern.dark),
								A2($elm$html$Html$Attributes$style, '-webkit-text-stroke-color', pattern.dark),
								A2(
								$elm$html$Html$Attributes$style,
								'   -moz-text-stroke-width',
								toPx(0.0055)),
								A2(
								$elm$html$Html$Attributes$style,
								'-webkit-text-stroke-width',
								toPx(0.0055)),
								A2(
								$elm$html$Html$Attributes$style,
								'font-size',
								toPx(0.16)),
								A2(
								$elm$html$Html$Attributes$style,
								'opacity',
								$elm$core$String$fromFloat(opacity))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(pattern.key + ' wins!')
							]))
					]));
		}
	});
var $author$project$SplitScreen$viewportsWrapper = $elm$html$Html$div(
	$author$project$SplitScreen$style(
		_List_fromArray(
			[
				_Utils_Tuple2('width', '100vw'),
				_Utils_Tuple2('height', '100vh'),
				_Utils_Tuple2('overflow', 'hidden')
			])));
var $author$project$MainScene$view = F2(
	function (shell, model) {
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('game-area')
					]),
				_List_fromArray(
					[
						$author$project$SplitScreen$viewportsWrapper(
						_List_fromArray(
							[
								A2($author$project$View$Game$view, shell.viewport, model.game)
							]))
					])),
				A2($author$project$MainScene$viewFps, model, shell),
				A2($author$project$MainScene$viewVictory, shell.viewport, model.game)
			]);
	});
var $author$project$MapEditor$DimensionHeight = {$: 'DimensionHeight'};
var $author$project$MapEditor$DimensionWidth = {$: 'DimensionWidth'};
var $author$project$MapEditor$FieldMapJson = {$: 'FieldMapJson'};
var $author$project$MapEditor$OnMapClick = {$: 'OnMapClick'};
var $author$project$MapEditor$SymmetryNone = {$: 'SymmetryNone'};
var $author$project$MapEditor$OnSwitchMode = function (a) {
	return {$: 'OnSwitchMode', a: a};
};
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$checked = $elm$html$Html$Attributes$boolProperty('checked');
var $elm$html$Html$input = _VirtualDom_node('input');
var $elm$html$Html$label = _VirtualDom_node('label');
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 'Normal', a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $author$project$MapEditor$modeRadio = F2(
	function (model, _v0) {
		var name = _v0.a;
		var mode = _v0.b;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('flex')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('radio'),
							$elm$html$Html$Events$onClick(
							$author$project$MapEditor$OnSwitchMode(mode)),
							$elm$html$Html$Attributes$checked(
							_Utils_eq(model.editMode, mode))
						]),
					_List_Nil),
					A2(
					$elm$html$Html$label,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('mr1')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(name)
						]))
				]));
	});
var $author$project$MapEditor$OnChangeSize = F2(
	function (a, b) {
		return {$: 'OnChangeSize', a: a, b: b};
	});
var $elm$html$Html$Attributes$max = $elm$html$Html$Attributes$stringProperty('max');
var $elm$html$Html$Attributes$min = $elm$html$Html$Attributes$stringProperty('min');
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 'MayStopPropagation', a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$MapEditor$sizeInput = F2(
	function (model, _v0) {
		var name = _v0.a;
		var get = _v0.b;
		var dimension = _v0.c;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('flex')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('number'),
							$elm$html$Html$Attributes$value(
							$elm$core$String$fromInt(
								get(model.map))),
							$elm$html$Html$Attributes$min(
							$elm$core$String$fromInt($author$project$MapEditor$minSize)),
							$elm$html$Html$Attributes$max(
							$elm$core$String$fromInt($author$project$MapEditor$maxSize)),
							$elm$html$Html$Events$onInput(
							$author$project$MapEditor$OnChangeSize(dimension))
						]),
					_List_Nil),
					A2(
					$elm$html$Html$label,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('mr1')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(name)
						]))
				]));
	});
var $author$project$MapEditor$OnTextBlur = {$: 'OnTextBlur'};
var $author$project$MapEditor$OnTextInput = F2(
	function (a, b) {
		return {$: 'OnTextInput', a: a, b: b};
	});
var $elm$html$Html$Events$onBlur = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'blur',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$MapEditor$stringInput = F3(
	function (model, inputField, currentValue) {
		var maybeUserIsTyping = function () {
			var _v0 = model.maybeFocus;
			if (_v0.$ === 'Nothing') {
				return $elm$core$Maybe$Nothing;
			} else {
				var _v1 = _v0.a;
				var string = _v1.a;
				var currentFocus = _v1.b;
				return _Utils_eq(inputField, currentFocus) ? $elm$core$Maybe$Just(string) : $elm$core$Maybe$Nothing;
			}
		}();
		var content = A2($elm$core$Maybe$withDefault, currentValue, maybeUserIsTyping);
		return A2(
			$elm$html$Html$input,
			_List_fromArray(
				[
					$elm$html$Html$Events$onInput(
					$author$project$MapEditor$OnTextInput(inputField)),
					$elm$html$Html$Events$onBlur($author$project$MapEditor$OnTextBlur),
					$elm$html$Html$Attributes$value(content),
					A2($elm$html$Html$Attributes$style, 'width', '100%')
				]),
			_List_Nil);
	});
var $author$project$MapEditor$OnSwitchSymmetry = function (a) {
	return {$: 'OnSwitchSymmetry', a: a};
};
var $author$project$MapEditor$symmetryRadio = F2(
	function (model, _v0) {
		var name = _v0.a;
		var symmetry = _v0.b;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('flex')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$input,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$type_('radio'),
							$elm$html$Html$Events$onClick(
							$author$project$MapEditor$OnSwitchSymmetry(symmetry)),
							$elm$html$Html$Attributes$checked(
							_Utils_eq(model.symmetry, symmetry))
						]),
					_List_Nil),
					A2(
					$elm$html$Html$label,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('mr1')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(name)
						]))
				]));
	});
var $author$project$Map$tileEncoder = function (_v0) {
	var x = _v0.a;
	var y = _v0.b;
	return A2(
		$elm$json$Json$Encode$list,
		$elm$json$Json$Encode$int,
		_List_fromArray(
			[x, y]));
};
var $author$project$Map$encodeBases = F2(
	function (baseType, map) {
		return A2(
			$elm$json$Json$Encode$list,
			$author$project$Map$tileEncoder,
			$elm$core$Dict$keys(
				A2(
					$elm$core$Dict$filter,
					F2(
						function (tile, type_) {
							return _Utils_eq(type_, baseType);
						}),
					map.bases)));
	});
var $elm$json$Json$Encode$set = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$Set$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(_Utils_Tuple0),
				entries));
	});
var $author$project$Map$setOfTilesEncoder = function (tiles) {
	return A2($elm$json$Json$Encode$set, $author$project$Map$tileEncoder, tiles);
};
var $author$project$Map$mapEncoder = function (map) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'name',
				$elm$json$Json$Encode$string(map.name)),
				_Utils_Tuple2(
				'author',
				$elm$json$Json$Encode$string(map.author)),
				_Utils_Tuple2(
				'halfWidth',
				$elm$json$Json$Encode$int(map.halfWidth)),
				_Utils_Tuple2(
				'halfHeight',
				$elm$json$Json$Encode$int(map.halfHeight)),
				_Utils_Tuple2(
				'mainBases',
				A2($author$project$Map$encodeBases, $author$project$Game$BaseMain, map)),
				_Utils_Tuple2(
				'smallBases',
				A2($author$project$Map$encodeBases, $author$project$Game$BaseSmall, map)),
				_Utils_Tuple2(
				'wallTiles',
				$author$project$Map$setOfTilesEncoder(map.wallTiles))
			]));
};
var $author$project$Map$toString = function (map) {
	return A2(
		$elm$json$Json$Encode$encode,
		0,
		$author$project$Map$mapEncoder(map));
};
var $author$project$View$Game$viewMapEditorBase = function (_v0) {
	var tile = _v0.a;
	var baseType = _v0.b;
	var colorPattern = $author$project$ColorPattern$neutral;
	return A2(
		$author$project$Svgl$Tree$Nod,
		_List_fromArray(
			[
				$author$project$Svgl$Tree$translate(
				$author$project$Game$tile2Vec(tile))
			]),
		_List_fromArray(
			[
				function () {
				if (baseType.$ === 'BaseSmall') {
					return A3($author$project$View$Base$small, 0, colorPattern.brightV, colorPattern.darkV);
				} else {
					return A3($author$project$View$Base$main_, 0, colorPattern.brightV, colorPattern.darkV);
				}
			}()
			]));
};
var $author$project$View$Game$viewMap = F2(
	function (viewport, map) {
		var worldToCamera = A2($author$project$View$Game$worldToCameraMatrix, map, viewport);
		return A3(
			$elm_explorations$webgl$WebGL$toHtmlWith,
			_List_fromArray(
				[
					$elm_explorations$webgl$WebGL$alpha(true),
					$elm_explorations$webgl$WebGL$antialias
				]),
			$author$project$SplitScreen$viewportToWebGLAttributes(viewport),
			A2(
				$elm$core$List$map,
				$elm$core$Tuple$second,
				A2(
					$author$project$Svgl$Tree$treeToEntities,
					worldToCamera,
					A2(
						$author$project$Svgl$Tree$Nod,
						_List_Nil,
						$elm$core$List$concat(
							_List_fromArray(
								[
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewWall,
									$elm$core$Set$toList(map.wallTiles)),
									A2(
									$elm$core$List$map,
									$author$project$View$Game$viewMapEditorBase,
									$elm$core$Dict$toList(map.bases))
								]))))));
	});
var $author$project$MapEditor$view = F2(
	function (shell, model) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('flex relative')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Events$onClick($author$project$MapEditor$OnMapClick)
						]),
					_List_fromArray(
						[
							$author$project$SplitScreen$viewportsWrapper(
							_List_fromArray(
								[
									A2(
									$author$project$View$Game$viewMap,
									$author$project$MapEditor$viewport(shell),
									model.map)
								]))
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$Attributes$style,
							'height',
							$elm$core$String$fromInt($author$project$MapEditor$toolbarHeightInPixels) + 'px'),
							$elm$html$Html$Attributes$class('map-editor-toolbar flex alignCenter nonSelectable')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Size'),
									A2(
									$elm$html$Html$div,
									_List_Nil,
									A2(
										$elm$core$List$map,
										$author$project$MapEditor$sizeInput(model),
										_List_fromArray(
											[
												_Utils_Tuple3(
												'Width',
												function ($) {
													return $.halfWidth;
												},
												$author$project$MapEditor$DimensionWidth),
												_Utils_Tuple3(
												'Height',
												function ($) {
													return $.halfHeight;
												},
												$author$project$MapEditor$DimensionHeight)
											])))
								])),
							A2(
							$elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Symmetry:'),
									A2(
									$elm$html$Html$div,
									_List_Nil,
									A2(
										$elm$core$List$map,
										$author$project$MapEditor$symmetryRadio(model),
										_List_fromArray(
											[
												_Utils_Tuple2('Central', $author$project$MapEditor$SymmetryCentral),
												_Utils_Tuple2('Vertical', $author$project$MapEditor$SymmetryVertical),
												_Utils_Tuple2('Horizontal', $author$project$MapEditor$SymmetryHorizontal),
												_Utils_Tuple2('None', $author$project$MapEditor$SymmetryNone)
											])))
								])),
							A2(
							$elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Edit mode'),
									A2(
									$elm$html$Html$div,
									_List_Nil,
									A2(
										$elm$core$List$map,
										$author$project$MapEditor$modeRadio(model),
										_List_fromArray(
											[
												_Utils_Tuple2(
												'Walls',
												$author$project$MapEditor$EditWalls($elm$core$Maybe$Nothing)),
												_Utils_Tuple2('Main Base', $author$project$MapEditor$EditMainBase),
												_Utils_Tuple2('Small Bases', $author$project$MapEditor$EditSmallBases)
											])))
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('flex1')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text(
											$elm$core$Debug$toString(model.mouseTile))
										])),
									A3(
									$author$project$MapEditor$stringInput,
									model,
									$author$project$MapEditor$FieldMapJson,
									$author$project$Map$toString(model.map)),
									A2(
									$elm$html$Html$div,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text(
											A2($elm$core$String$left, 50, model.error))
										])),
									A2(
									$elm$html$Html$div,
									_List_Nil,
									_List_fromArray(
										[
											function () {
											var _v0 = $author$project$Map$validate(model.map);
											if (_v0.$ === 'Err') {
												var error = _v0.a;
												return A2(
													$elm$html$Html$span,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('red')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(error)
														]));
											} else {
												var vm = _v0.a;
												return $elm$html$Html$text('Validation Ok!');
											}
										}()
										]))
								]))
						]))
				]));
	});
var $author$project$App$OnImportString = function (a) {
	return {$: 'OnImportString', a: a};
};
var $author$project$App$OnStartGame = function (a) {
	return {$: 'OnStartGame', a: a};
};
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$html$Html$li = _VirtualDom_node('li');
var $xarvh$elm_gamepad$Gamepad$cssStyle = A2(
	$elm$core$String$join,
	'\n',
	_List_fromArray(
		['.elm-gamepad-mapping-unavailable { color: red; }', '.elm-gamepad-mapping-available { color: green; }', '.elm-gamepad-gamepad-index::before { content: \'Gamepad \'; }', '.elm-gamepad-gamepad-index::after { content: \': \'; }', '.elm-gamepad-remapping-skip { margin-top: 0.5rem; }', '.elm-gamepad-remapping-cancel { margin-top: 0.5rem; }']));
var $xarvh$elm_gamepad$Gamepad$getRaw = function (_v0) {
	var currentBlobFrame = _v0.a;
	var previousBlobFrame = _v0.b;
	return A2(
		$elm$core$List$map,
		function (g) {
			return _Utils_Tuple2(g.id, g.index);
		},
		currentBlobFrame.gamepads);
};
var $elm$virtual_dom$VirtualDom$node = function (tag) {
	return _VirtualDom_node(
		_VirtualDom_noScript(tag));
};
var $elm$html$Html$node = $elm$virtual_dom$VirtualDom$node;
var $elm$html$Html$ul = _VirtualDom_node('ul');
var $xarvh$elm_gamepad$Gamepad$OnStartRemapping = F2(
	function (a, b) {
		return {$: 'OnStartRemapping', a: a, b: b};
	});
var $xarvh$elm_gamepad$Gamepad$findIndex = F2(
	function (index, pads) {
		return A2(
			$elm_community$list_extra$List$Extra$find,
			function (pad) {
				return _Utils_eq(
					$xarvh$elm_gamepad$Gamepad$getIndex(pad),
					index);
			},
			pads);
	});
var $xarvh$elm_gamepad$Gamepad$viewGamepad = F4(
	function (actions, userMappings, blob, _v0) {
		var id = _v0.a;
		var index = _v0.b;
		var maybeGamepadWithoutConfig = A2(
			$xarvh$elm_gamepad$Gamepad$findIndex,
			index,
			A2($xarvh$elm_gamepad$Gamepad$getGamepads, $xarvh$elm_gamepad$Gamepad$emptyUserMappings, blob));
		var maybeGamepad = A2(
			$xarvh$elm_gamepad$Gamepad$findIndex,
			index,
			A2($xarvh$elm_gamepad$Gamepad$getGamepads, userMappings, blob));
		var _v1 = function () {
			if (maybeGamepad.$ === 'Nothing') {
				return {
					buttonLabel: 'Map',
					signal: _Utils_eq(
						A2($xarvh$elm_gamepad$Gamepad$estimateOrigin, blob, index),
						$elm$core$Maybe$Nothing) ? 'idle' : 'Receiving signal',
					status: 'Needs mapping',
					symbolClass: 'elm-gamepad-mapping-unavailable',
					symbolFace: '✘'
				};
			} else {
				var gamepad = maybeGamepad.a;
				return {
					buttonLabel: 'Remap',
					signal: A2(
						$elm$core$Maybe$withDefault,
						'idle',
						A2(
							$elm$core$Maybe$map,
							$elm$core$Tuple$first,
							A2(
								$elm_community$list_extra$List$Extra$find,
								A2(
									$elm$core$Basics$composeR,
									$elm$core$Tuple$second,
									$xarvh$elm_gamepad$Gamepad$isPressed(gamepad)),
								actions))),
					status: _Utils_eq(maybeGamepad, maybeGamepadWithoutConfig) ? 'Standard mapping' : 'Custom mapping',
					symbolClass: 'elm-gamepad-mapping-available',
					symbolFace: '✔'
				};
			}
		}();
		var symbolFace = _v1.symbolFace;
		var symbolClass = _v1.symbolClass;
		var buttonLabel = _v1.buttonLabel;
		var status = _v1.status;
		var signal = _v1.signal;
		return A2(
			$elm$html$Html$li,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('elm-gamepad-gamepad-list-item')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('elm-gamepad-gamepad-index')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(
							$elm$core$String$fromInt(index))
						])),
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class(symbolClass)
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(symbolFace)
						])),
					A2(
					$elm$html$Html$span,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('elm-gamepad-mapping-state-text')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(status)
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('elm-gamepad-current-action-text')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(signal)
						])),
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('elm-gamepad-remap-button'),
							$elm$html$Html$Events$onClick(
							A2($xarvh$elm_gamepad$Gamepad$OnStartRemapping, id, index))
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(buttonLabel)
						]))
				]));
	});
var $xarvh$elm_gamepad$Gamepad$OnCancel = {$: 'OnCancel'};
var $xarvh$elm_gamepad$Gamepad$OnSkip = function (a) {
	return {$: 'OnSkip', a: a};
};
var $xarvh$elm_gamepad$Gamepad$viewRemapping = F2(
	function (actions, remapping) {
		var statusClass = $elm$html$Html$Attributes$class('elm-gamepad-remapping-tellsUserWhatIsHappening');
		var instructionClass = $elm$html$Html$Attributes$class('elm-gamepad-remapping-tellsUserWhatToDo');
		var _v0 = A2($xarvh$elm_gamepad$Gamepad$nextUnmappedAction, actions, remapping);
		if (_v0.$ === 'Nothing') {
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('elm-gamepad-remapping-complete')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[statusClass]),
						_List_fromArray(
							[
								$elm$html$Html$text(
								'Remapping Gamepad ' + ($elm$core$String$fromInt(remapping.index) + ' complete.'))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[instructionClass]),
						_List_fromArray(
							[
								$elm$html$Html$text('Press any button to go back.')
							]))
					]));
		} else {
			var _v1 = _v0.a;
			var actionName = _v1.a;
			var destination = _v1.b;
			return A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('elm-gamepad-remapping')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[statusClass]),
						_List_fromArray(
							[
								$elm$html$Html$text(
								'Remapping Gamepad ' + $elm$core$String$fromInt(remapping.index))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[instructionClass]),
						_List_fromArray(
							[
								$elm$html$Html$text('Press:')
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('elm-gamepad-remapping-action-name')
							]),
						_List_fromArray(
							[
								$elm$html$Html$text(actionName)
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('elm-gamepad-remapping-skip')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Events$onClick(
										$xarvh$elm_gamepad$Gamepad$OnSkip(destination))
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Skip this action')
									]))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('elm-gamepad-remapping-cancel')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$button,
								_List_fromArray(
									[
										$elm$html$Html$Events$onClick($xarvh$elm_gamepad$Gamepad$OnCancel)
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('Cancel remapping')
									]))
							]))
					]));
		}
	});
var $xarvh$elm_gamepad$Gamepad$remapView = F3(
	function (actionNames, db, _v0) {
		var model = _v0.a;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('elm-gamepad')
				]),
			_List_fromArray(
				[
					function () {
					var _v1 = model.maybeRemapping;
					if (_v1.$ === 'Just') {
						var remapping = _v1.a;
						return A2($xarvh$elm_gamepad$Gamepad$viewRemapping, actionNames, remapping);
					} else {
						var _v2 = $xarvh$elm_gamepad$Gamepad$getRaw(model.blob);
						if (!_v2.b) {
							return A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('elm-gamepad-no-gamepads')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('No gamepads detected')
									]));
						} else {
							var idsAndIndices = _v2;
							return A2(
								$elm$html$Html$ul,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('elm-gamepad-gamepad-list')
									]),
								A2(
									$elm$core$List$map,
									A3($xarvh$elm_gamepad$Gamepad$viewGamepad, actionNames, db, model.blob),
									idsAndIndices));
						}
					}
				}(),
					A3(
					$elm$html$Html$node,
					'style',
					_List_Nil,
					_List_fromArray(
						[
							$elm$html$Html$text($xarvh$elm_gamepad$Gamepad$cssStyle)
						]))
				]));
	});
var $elm$html$Html$section = _VirtualDom_node('section');
var $elm$html$Html$textarea = _VirtualDom_node('textarea');
var $author$project$App$OnMenuButton = function (a) {
	return {$: 'OnMenuButton', a: a};
};
var $author$project$App$OnSelectButton = function (a) {
	return {$: 'OnSelectButton', a: a};
};
var $elm$html$Html$Events$onFocus = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'focus',
		$elm$json$Json$Decode$succeed(msg));
};
var $author$project$App$viewMapPreview = F2(
	function (model, map) {
		var width = (model.windowSize.width / 6) | 0;
		var size = {height: ((2 * width) / 3) | 0, width: width};
		var viewport = A2(
			$elm$core$Maybe$withDefault,
			$author$project$SplitScreen$defaultViewport,
			$elm$core$List$head(
				A2($author$project$SplitScreen$makeViewports, size, 1)));
		var mmmap = {
			author: map.author,
			bases: $elm$core$Dict$fromList(
				A2(
					$elm$core$List$map,
					function (tile) {
						return _Utils_Tuple2(tile, $author$project$Game$BaseSmall);
					},
					$elm$core$Set$toList(map.smallBases))),
			halfHeight: map.halfHeight,
			halfWidth: map.halfWidth,
			name: map.name,
			wallTiles: map.wallTiles
		};
		return A2(
			$elm$html$Html$div,
			_List_Nil,
			_List_fromArray(
				[
					A2($author$project$View$Game$viewMap, viewport, mmmap)
				]));
	});
var $author$project$App$viewToggle = F2(
	function (label, state) {
		return _List_fromArray(
			[
				A2(
				$elm$html$Html$span,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text(label)
					])),
				A2(
				$elm$html$Html$span,
				_List_Nil,
				_List_fromArray(
					[
						$elm$html$Html$text(
						state ? 'Yes' : 'No')
					]))
			]);
	});
var $author$project$App$viewMenuButton = F2(
	function (model, b) {
		var isSelected = _Utils_eq(
			b.name,
			$author$project$App$selectedButtonName(model));
		var borderColor = isSelected ? 'black' : 'transparent';
		var _v0 = function () {
			var _v1 = b.view;
			switch (_v1.$) {
				case 'MenuButtonLabel':
					return _Utils_Tuple2(
						'label',
						_List_fromArray(
							[
								$elm$html$Html$text(b.name)
							]));
				case 'MenuButtonMap':
					var map = _v1.a;
					return _Utils_Tuple2(
						'map-preview',
						_List_fromArray(
							[
								A2($author$project$App$viewMapPreview, model, map)
							]));
				default:
					var getter = _v1.a;
					return _Utils_Tuple2(
						'label flex justifyBetween',
						A2(
							$author$project$App$viewToggle,
							b.name,
							getter(model)));
			}
		}();
		var className = _v0.a;
		var content = _v0.b;
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('menu-button'),
					A2($elm$html$Html$Attributes$style, 'border', '3px solid ' + borderColor)
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$button,
					_List_fromArray(
						[
							$elm$html$Html$Events$onClick(
							$author$project$App$OnMenuButton(b.name)),
							$elm$html$Html$Events$onFocus(
							$author$project$App$OnSelectButton(b.name)),
							$elm$html$Html$Attributes$class(className)
						]),
					content)
				]));
	});
var $author$project$App$viewMenu = F2(
	function (menu, model) {
		switch (menu.$) {
			case 'MenuMain':
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('flex flexColumn alignCenter')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('mb2')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('Press Esc or ▶ (Start) to toggle Menu')
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('flex flexColumn')
								]),
							A2(
								$elm$core$List$map,
								$author$project$App$viewMenuButton(model),
								$author$project$App$menuButtons(model)))
						]));
			case 'MenuMapSelection':
				return A2(
					$elm$html$Html$div,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$section,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('flex flexColumn alignCenter')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_Nil,
									_List_fromArray(
										[
											$elm$html$Html$text('Select map')
										])),
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('map-selection')
										]),
									A2(
										$elm$core$List$map,
										$author$project$App$viewMenuButton(model),
										A2(
											$elm$core$List$filter,
											function (b) {
												return !_Utils_eq(b.view, $author$project$App$MenuButtonLabel);
											},
											$author$project$App$menuButtons(model))))
								])),
							A2(
							$elm$html$Html$section,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('flex justifyCenter')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_Nil,
									A2(
										$elm$core$List$map,
										$author$project$App$viewMenuButton(model),
										A2(
											$elm$core$List$filter,
											function (b) {
												return _Utils_eq(b.view, $author$project$App$MenuButtonLabel);
											},
											$author$project$App$menuButtons(model))))
								]))
						]));
			case 'MenuImportMap':
				var importString = menu.a.importString;
				var mapResult = menu.a.mapResult;
				return A2(
					$elm$html$Html$section,
					_List_Nil,
					_List_fromArray(
						[
							A2(
							$elm$html$Html$label,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Import a map from JSON')
								])),
							A2(
							$elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									A2(
									$elm$html$Html$textarea,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$value(importString),
											$elm$html$Html$Events$onInput($author$project$App$OnImportString)
										]),
									_List_Nil)
								])),
							function () {
							if (mapResult.$ === 'Err') {
								var message = mapResult.a;
								return A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('red')
										]),
									_List_fromArray(
										[
											$elm$html$Html$text(message)
										]));
							} else {
								var map = mapResult.a;
								return A2(
									$elm$html$Html$button,
									_List_fromArray(
										[
											$elm$html$Html$Events$onClick(
											$author$project$App$OnStartGame(map))
										]),
									_List_fromArray(
										[
											$elm$html$Html$text('Play on this map')
										]));
							}
						}()
						]));
			case 'MenuHowToPlay':
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('flex flexColumn alignCenter')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('> How to Play <')
								])),
							A2(
							$elm$html$Html$section,
							_List_Nil,
							_List_fromArray(
								[
									A2(
									$elm$html$Html$ul,
									_List_Nil,
									A2(
										$elm$core$List$map,
										function (t) {
											return A2(
												$elm$html$Html$li,
												_List_Nil,
												_List_fromArray(
													[
														$elm$html$Html$text(t)
													]));
										},
										_List_fromArray(
											['Arrow keys or ASDW to move', 'Q to move the Rally point', 'E to transform', 'Click to fire', 'ESC to toggle the Menu', 'Your goal is to destroy all four drones guarding the main enemy base', 'Rally your drones close to an unoccupied base to conquer it', 'Conquered bases produce more drones and repair your mech', 'Drones inside bases are a lot hardier than free romaing ones', 'When a mech is destroyed, the enemy will produce three special drones', 'Special drones are very strong against other drones, but can\'t enter bases'])))
								])),
							A2(
							$elm$html$Html$section,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('flex justifyCenter')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_Nil,
									A2(
										$elm$core$List$map,
										$author$project$App$viewMenuButton(model),
										$author$project$App$menuButtons(model)))
								]))
						]));
			case 'MenuGamepads':
				var remap = menu.a;
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('flex flexColumn alignCenter')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('mb2')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('> Gamepads <')
								])),
							A2(
							$elm$html$Html$section,
							_List_Nil,
							_List_fromArray(
								[
									A2(
									$elm$html$Html$map,
									$author$project$App$OnRemapMsg,
									A3($xarvh$elm_gamepad$Gamepad$remapView, $author$project$App$gamepadButtonMap, model.config.gamepadDatabase, remap))
								]))
						]));
			default:
				return A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('flex flexColumn alignCenter')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('mb2')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text('> Gamepads <')
								])),
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('flex flexColumn')
								]),
							A2(
								$elm$core$List$map,
								$author$project$App$viewMenuButton(model),
								$author$project$App$menuButtons(model)))
						]));
		}
	});
var $author$project$App$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('relative')
			]),
		_List_fromArray(
			[
				function () {
				var _v0 = model.scene;
				if (_v0.$ === 'SceneMain') {
					var subScene = _v0.a;
					var scene = _v0.b;
					return A2(
						$elm$html$Html$div,
						_List_Nil,
						A2(
							$author$project$MainScene$view,
							$author$project$App$shell(model),
							scene));
				} else {
					var mapEditor = _v0.a;
					return A2(
						$elm$html$Html$map,
						$author$project$App$OnMapEditorMsg,
						A2(
							$author$project$MapEditor$view,
							$author$project$App$shell(model),
							mapEditor));
				}
			}(),
				function () {
				var _v1 = model.maybeMenu;
				if (_v1.$ === 'Nothing') {
					return $elm$html$Html$text('');
				} else {
					var menu = _v1.a;
					return A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('fullWindow bgOpaque flex alignCenter justifyCenter')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('menu p2')
									]),
								_List_fromArray(
									[
										A2($author$project$App$viewMenu, menu, model)
									]))
							]));
				}
			}()
			]));
};
var $author$project$Main$view = function (model) {
	return {
		body: _List_fromArray(
			[
				$author$project$App$view(model)
			]),
		title: 'Herzog Drei'
	};
};
var $author$project$Main$main = $elm$browser$Browser$document(
	{init: $author$project$App$init, subscriptions: $author$project$App$subscriptions, update: $author$project$App$update, view: $author$project$Main$view});
_Platform_export({'Main':{'init':$author$project$Main$main(
	A2(
		$elm$json$Json$Decode$andThen,
		function (windowWidth) {
			return A2(
				$elm$json$Json$Decode$andThen,
				function (windowHeight) {
					return A2(
						$elm$json$Json$Decode$andThen,
						function (mapEditorCurrentMap) {
							return A2(
								$elm$json$Json$Decode$andThen,
								function (dateNow) {
									return A2(
										$elm$json$Json$Decode$andThen,
										function (customMaps) {
											return A2(
												$elm$json$Json$Decode$andThen,
												function (config) {
													return $elm$json$Json$Decode$succeed(
														{config: config, customMaps: customMaps, dateNow: dateNow, mapEditorCurrentMap: mapEditorCurrentMap, windowHeight: windowHeight, windowWidth: windowWidth});
												},
												A2($elm$json$Json$Decode$field, 'config', $elm$json$Json$Decode$string));
										},
										A2($elm$json$Json$Decode$field, 'customMaps', $elm$json$Json$Decode$string));
								},
								A2($elm$json$Json$Decode$field, 'dateNow', $elm$json$Json$Decode$int));
						},
						A2($elm$json$Json$Decode$field, 'mapEditorCurrentMap', $elm$json$Json$Decode$string));
				},
				A2($elm$json$Json$Decode$field, 'windowHeight', $elm$json$Json$Decode$int));
		},
		A2($elm$json$Json$Decode$field, 'windowWidth', $elm$json$Json$Decode$int)))(0)}});}(this));