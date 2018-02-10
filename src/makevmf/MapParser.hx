package makevmf;

import makevmf.MapEntity;

enum Token 
{
	TOpenBlock;
	TCloseBlock;
	Comment;
	TVecOpen;
	TVecClose;
	TNumber(v : String);
	TString(v : String);
	TClass(v : String);
	TEof;
}

class MapLexer extends hxparse.Lexer implements hxparse.RuleBuilder
{
	static var buf : StringBuf;

	public static var tok = @:rule [
		"{" => TOpenBlock,
		"}" => TCloseBlock,
		"\\(" => TVecOpen,
		"\\)" => TVecClose,
		"-?(([1-9][0-9]*)|0)(\\.[0-9]+)?" => TNumber(lexer.current),
		'"' => {
			buf = new StringBuf();
			lexer.token(string);
			TString(buf.toString());
		},
		
		"[A-Za-z][^ ]*" => TClass(lexer.current),
		
		// Skip whitespace and comments
		"//[^\n\r]*" => lexer.token(tok),
		"[\r\n\t ]" => lexer.token(tok),
		"" => TEof
	];
	static var string = @:rule [
		"\\\\t" => {
			buf.addChar("\t".code);
			lexer.token(string);
		},
		"\\\\n" => {
			buf.addChar("\n".code);
			lexer.token(string);
		},
		"\\\\r" => {
			buf.addChar("\r".code);
			lexer.token(string);
		},
		'\\\\"' => {
			buf.addChar('"'.code);
			lexer.token(string);
		},
		"\\\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]" => {
			buf.add(String.fromCharCode(Std.parseInt("0x" +lexer.current.substr(2))));
			lexer.token(string);
		},
		'"' => {
			lexer.curPos().pmax;
		},
		'[^"]' => {
			buf.add(lexer.current);
			lexer.token(string);
		},
	];
}

class MapParser
{
	public var entities : Array< makevmf.MapEntity > = [];

	var token : Token = TEof;
	var lex : MapLexer;

	function fetch() {
		token = lex.token(MapLexer.tok);
	}

	public function new(input : String)
	{
		lex = new MapLexer(byte.ByteData.ofString(input));
		fetch();
	}

	public function wantString() : Null<String>
	{
		return switch (token) {
			case TString(v) : v;
			case TClass(v) : v;
			case TNumber(v) : v;
			default : throw 'Expected string, but found "$token" at ${lex.curPos()}';
		};
	}

	public function wantFloat() : Float
	{
		var v = switch (token) {
			case TNumber(v) : Std.parseFloat(v);
			default : throw 'Expected float, but found "$token" at ${lex.curPos()}';
		};
		return v;
	}

	public function wantInt() : Int
	{
		return switch (token) {
			case TNumber(v) : Std.parseInt(v);
			default : throw 'Expected int, but found "$token" at ${lex.curPos()}';
		};
	}

	public function entity() : makevmf.MapEntity
	{
		var ent = new makevmf.MapEntity();

		if (token != TOpenBlock)
			throw 'Expected `{` but found $token at ${lex.curPos()}';

		fetch();
		while (true) {
			switch (token) {
				case TCloseBlock : 
					fetch();
					return ent;

				case TString(k):
					if (k == "classname") {
						fetch();
						ent.classname = wantString();
						fetch();
					} else {
						fetch();
						var value = wantString();
						fetch();
						ent.properties.set(k, value);
					}
				case TOpenBlock:
					fetch();
					var brush = parseBrush();

					if (ent.brushes == null) {
						ent.brushes = [];
					}
					ent.brushes.push(brush);

				default: throw 'Unexpected $token at ${lex.curPos()}';
			}
		}
	}

	public function parseBrush()
	{
		var brush = new MapBrush();

		while (true) {
			if (token == TCloseBlock) {
				fetch();
				return brush;
			}

			var coords = [];
			for (p in 0 ... 3) {
				if (token != TVecOpen)
					throw 'Expected `(` but found $token at ${lex.curPos()}';
				fetch();
				coords.push(wantFloat());
				fetch();
				coords.push(wantFloat());
				fetch();
				coords.push(wantFloat());
				fetch();

				if (token != TVecClose)
					throw 'Expected `)` but found $token at ${lex.curPos()}';
				fetch();
			}
			
			var texname = wantString();
			fetch();

			var tex_xsh = wantFloat(); fetch();
			var tex_ysh = wantFloat(); fetch();
			var tex_rot = wantFloat(); fetch();
			var tex_xscale = wantFloat(); fetch();
			var tex_yscale = wantFloat(); fetch();

			try {
				wantInt(); fetch();
				wantInt(); fetch();
				wantInt(); fetch();
			} catch(e : Any) {
				// ignore
			}

			var side = new MapBrushSide();
			side.points = coords;
			side.tex_xshift = tex_xsh;
			side.tex_yshift = tex_ysh;
			side.tex_rotate = tex_rot;
			side.tex_xscale = tex_xscale;
			side.tex_yscale = tex_yscale;
			side.texture = texname;

			side.postParse();

			brush.sides.push(side);
		}
	}
}