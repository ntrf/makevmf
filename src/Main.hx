package ;

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
			Sys.stderr().writeString("\n\nVersion 0.4");
			Sys.stderr().writeString("\n(C) Nesterov A., 2018");
			Sys.stderr().writeString("\nConverts Q3 .map files into HL2 .vmf files");
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
		
		var ent = parser.entity();

		var outputFile = sys.io.File.write(outFilename, false);
		
		var writer = new VmfWriter(outputFile);
		writer.writeHeader();
		writer.writeWorld(ent);
		writer.writeFooter();

		outputFile.close();

		Sys.exit(0);
	}
}
