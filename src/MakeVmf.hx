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
package ;

import makevmf.MapEntity;
import arguable.ArgParser;

import makevmf.VmfWriter;

class MakeVmf
{
	static function main() 
	{
		var args = ArgParser.parse(Sys.args());

		var input = args.get("in");
		var output = args.get("out");

		if (input == null) {
			Sys.stderr().writeString("Usage:\n  makevmf --in <inputfile> [--out <output file>]");
			Sys.stderr().writeString("\n\nConverts Q3 .map files into HL2 .vmf files");
			Sys.stderr().writeString("\n\nVersion 0.4");
			Sys.stderr().writeString("\n(C) Nesterov A., 2018");
			Sys.stderr().writeString("\n");
			Sys.exit(1);
		}

		var inFilename = input.value;
		var outFilename = if (output != null) output.value else haxe.io.Path.withoutExtension(input.value) + ".vmf";

		Sys.stderr().writeString('Converting ${inFilename} to ${outFilename}');

		var infile = try {
			sys.io.File.getContent(inFilename);
		} catch (e : Dynamic) {
			Sys.stderr().writeString('Error while trying to open file "$inFilename" : $e');
			Sys.exit(1);
			null;
		}

		var parser = new makevmf.MapParser(infile);

		var worldspawn = null;
		var entities : Array< MapEntity > = [];
		
		while (true) {
			if (parser.isEof())
				break;
			
			var ent = parser.entity();

			if (ent.classname == "worldspawn") {
				if (worldspawn != null)
					Sys.stderr().writeString("Warning: more than one 'worldspawn' in one map. Only first one is preserved.\n -- send me a sample --");
				else
					worldspawn = ent;
			} else {
				entities.push(ent);
			}
		}

		var outputFile = sys.io.File.write(outFilename, false);

		var writer = new VmfWriter(outputFile);
		writer.writeHeader();
		writer.writeWorld(worldspawn);
		for (e in entities) {
			writer.writeEntity(e);
		}
		writer.writeFooter();

		outputFile.close();

		Sys.exit(0);
	}
}
