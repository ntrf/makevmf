/*
 * Copyright (c) 2018 Anton Nesterov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
package makevmf;

import makevmf.MapEntity;

class VmfWriter
{
	var output : haxe.io.Output;

	var genid = 0;

	static inline var cFileHeader =
		"versioninfo\n"+
		"{\n"+
		"\t\"editorname\" \"BlamodMakeVMF\"\n"+
		"\t\"editorversion\" \"1.0\"\n"+
		"\t\"editorbuild\" \"1\"\n"+
		"\t\"mapversion\" \"1\"\n"+
		"\t\"formatversion\" \"100\"\n"+
		"\t\"prefab\" \"0\"\n"+
		"}\n"+
		"visgroups\n"+
		"{\n"+
		"}\n"+
		"viewsettings\n"+
		"{\n"+
		"\t\"bSnapToGrid\" \"1\"\n"+
		"\t\"bShowGrid\" \"1\"\n"+
		"\t\"bShow3DGrid\" \"0\"\n"+
		"\t\"nGridSpacing\" \"64\"\n"+
		"\t\"bIgnoreGrouping\" \"0\"\n"+
		"\t\"bHideFaceMask\" \"0\"\n"+
		"\t\"bHideNullTextures\" \"0\"\n"+
		"\t\"bTextureLock\" \"1\"\n"+
		"\t\"bTextureScalingLock\" \"0\"\n"+
		"}\n";


	public function writeHeader()
	{
		output.writeString(cFileHeader);
	}

	function writeProperies(ent : makevmf.MapEntity)
	{
		var keys = ent.properties.keys();
		for (k in keys) {
			output.writeString('\t"$k" "${ent.properties.get(k)}"\n');
		}
	}

	public function writeWorld(worldspan : makevmf.MapEntity)
	{
		output.writeString("world\n{\n");
		output.writeString('\t"id" "1"\n');
		output.writeString('\t"mapversion" "1"\n');
		output.writeString('\t"skyname" "sky_wasteland02"\n');
		output.writeString('\t"class" "worldspan"\n');
		writeProperies(worldspan);

		for (br in worldspan.brushes) {
			writeBrush(br);
		}

		output.writeString("}\n");
	}

	function writeBrush(br : MapBrush)
	{
		var id = ++genid;
		output.writeString("\tsolid\n\t{\n");
		output.writeString('\t\t"id" "$id"\n');

		for (side in br.sides) {
			var sid = ++genid;

			var texname = "effect/combinedisplay_core_";

			output.writeString('\t\tside\n\t\t{\n');
			output.writeString('\t\t\t"id" "$sid"\n');
			output.writeString('\t\t\t"plane" "');
			output.writeString('(${side.points[0]} ${side.points[1]} ${side.points[2]}) ');
			output.writeString('(${side.points[3]} ${side.points[4]} ${side.points[5]}) ');
			output.writeString('(${side.points[6]} ${side.points[7]} ${side.points[8]})"\n');
			output.writeString('\t\t\t"material" "$texname"\n');
            output.writeString('\t\t\t"uaxis" "[${side.texture_u[0]} ${side.texture_u[1]} ${side.texture_u[2]} ${side.texture_u[3]}] ${side.tex_xscale}"\n');
            output.writeString('\t\t\t"vaxis" "[${side.texture_v[0]} ${side.texture_v[1]} ${side.texture_v[2]} ${side.texture_v[3]}] ${side.tex_yscale}"\n');
			output.writeString('\t\t\t"rotation" "${side.tex_rotate}"\n');
			output.writeString('\t\t}\n');
		}

		var cg = Std.random(64) + 127;
		var cb = Std.random(64) + 127;

		output.writeString('\t\teditor\n\t\t{\n');
        output.writeString('\t\t\t"color" "0 $cg $cb"\n');
		output.writeString('\t\t\t"visgroupshown" "1"\n');
        output.writeString('\t\t\t"visgroupautoshown" "1"\n');
//		output.writeString('\t\t\t"parentid" "$id"\n');
        output.writeString('\t\t}\n');

		output.writeString("\t}\n");
	}

	static inline var cFileFooter = 
		'cameras\n'+
		'{\n'+
		'\t"activecamera" "0"\n'+
		'\tcamera\n'+
		'\t{\n'+
		'\t\t"position" "[0.00000000 0.00000000 0.00000000]"\n'+
		'\t\t"look" "[96.00000000 0.00000000 0.00000000]"\n'+
		'\t}\n'+
		'}\n'+
		'cordon\n'+
		'{\n'+
		'\t"mins" "(-1024.0000 -1024.0000 -1024.0000)"\n'+
		'\t"maxs" "(1024.0000 1024.0000 1024.0000)"\n'+
		'\t"active" "0"\n'+
		'}';

	public function writeFooter()
	{
		output.writeString(cFileFooter);
	}

	public function new(out : haxe.io.Output) 
	{
		output = out;
	}
}