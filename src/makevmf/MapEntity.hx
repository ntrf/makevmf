package makevmf;

@:publicFields
class MapBrushSide
{
	// ( 312 120 0 ) ( 320 128 0 ) ( 64 128 0 ) none 31 -63 90 1.000015 1.000046 0 0 0
	var points : Array< Float > = []; // 9 coordinates of 3 points of this side

	var texture : String;
	var tex_xshift : Float = 0.0;
	var tex_yshift : Float = 0.0;
	var tex_rotate : Float = 0.0;
	var tex_xscale : Float = 0.0;
	var tex_yscale : Float = 0.0;

	var normal : Array< Float >;

	//var contents : Int = 0;
	//var flags : Int = 0;
	//var value : Int = 0;

	var texture_u : Array< Float > = [];
	var texture_v : Array< Float > = [];

	public function computeNormal()
	{
		normal = [];

		var v1x = points[0] - points[3];
		var v1y = points[1] - points[4];
		var v1z = points[2] - points[5];
		var v2x = points[6] - points[3];
		var v2y = points[7] - points[4];
		var v2z = points[8] - points[5];

		var nx = v1y * v2z - v2y * v1z;
		var ny = v1z * v2x - v2z * v1x;
		var nz = v1x * v2y - v2x * v1y;

		var l = nx * nx + ny * ny + nz * nz;

		if (l == 0) throw 'Computed bad normal!';
		
		l = 1.0 / Math.sqrt(l);
		nx *= l; ny *= l; nz *= l;

		normal[0] = nx;
		normal[1] = ny;
		normal[2] = nz;
	}

	static var sampleAxis : Array< Float > = [
		0,0,1,   1,0,0,  0,-1,0,  // floor
		0,0,-1,  1,0,0,  0,-1,0,  // ceiling
		1,0,0,   0,1,0,  0,0,-1,  // west wall
		-1,0,0,  0,1,0,  0,0,-1,  // east wall
		0,1,0,   1,0,0,  0,0,-1,  // south wall
		0,-1,0,  1,0,0,  0,0,-1   // north wall
	];

	public function computeTextureAxis()
	{
		// find coodinate set which better suits the normal
		function checkAxis(i : Int) {
			return normal[0] * sampleAxis[0 + 9 * i] +
			       normal[1] * sampleAxis[1 + 9 * i] +
				   normal[2] * sampleAxis[2 + 9 * i];
		}
		var axis = 0;
		var bestDot = checkAxis(0);

		for (i in 1 ... 6) {
			var d = checkAxis(i);
			if (d < bestDot) continue;

			axis = i;
			bestDot = d;
		}

		var ux = sampleAxis[3 + 9 * axis];
		var uy = sampleAxis[4 + 9 * axis];
		var uz = sampleAxis[5 + 9 * axis];
		var vx = sampleAxis[6 + 9 * axis];
		var vy = sampleAxis[7 + 9 * axis];
		var vz = sampleAxis[8 + 9 * axis];

		// rotate the axis appropriately
		var sinv : Float;
		var cosv : Float;
		if (tex_rotate == 0) { 
			sinv = 0; 
			cosv = 1; 
		} else if (tex_rotate == 90) { 
			sinv = 1;
			cosv = 0;
		} else if (tex_rotate == 180) {
			sinv = 0;
			cosv = -1;
		} else if (tex_rotate == 270) {
			sinv = -1;
			cosv = 0;
		} else {	
			var ang = tex_rotate / 180.0 * Math.PI;
			sinv = Math.sin(ang);
			cosv = Math.cos(ang);
		}

		var sx = (ux * cosv - vx * sinv);
		var sy = (uy * cosv - vy * sinv);
		var sz = (uz * cosv - vz * sinv);
		var tx = (vx * cosv + ux * sinv);
		var ty = (vy * cosv + uy * sinv);
		var tz = (vz * cosv + uz * sinv);

		texture_u = [sx, sy, sz, tex_xshift];
		texture_v = [tx, ty, tz, tex_yshift];
	}

	public function postParse()
	{
		computeNormal();
		computeTextureAxis();
	}

	public function new() { }
}

@:publicFields
class MapBrush
{
	public var sides : Array< MapBrushSide > = [];

	public function new() { }
}

@:publicFields
class MapEntity
{
	public var classname : String;
	public var properties : Map< String, String > = new Map< String, String>();
	public var brushes : Array< MapBrush > = null;

	public function new() { }
}