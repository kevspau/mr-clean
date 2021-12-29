module main;
import std.file, std.stdio, std.path, std.string, std.json;
import std.algorithm.sorting : sort;
import std.algorithm.searching : canFind;
import std.range;
import std.process;
static import conf = config;
//possibly add size, date modified, etc. to files
//add config option for full path, reverse order, additional file extensions
string[] sortedConfigPaths;
string[] sortedConfigFiles;
string[] SplitDefaultPaths;
string[] sortedDefPaths;
string[] sortedDefFiles;
string[] sortedPaths;
void main()
{
    auto dir = dirName(thisExePath());
    auto defaultPaths = environment.get("PATH");
    auto config = readText("." ~ dirSeparator ~ ".config");
    auto parsedConfig = config.parseJSON();
    if (defaultPaths is null)
    {
        defaultPaths = "";
    }
    else
    {
        SplitDefaultPaths = defaultPaths.split(pathSeparator);
        sortedDefPaths = SplitDefaultPaths.sort().release();
        string[] execs;
        foreach (_, string v; SplitDefaultPaths)
        {
            if (!canFind(v, "C:\\windows"))
            { //if this is ommited, it causes an AccessDenied error
                foreach (string n; dirEntries(v, "*.exe", SpanMode.breadth))
                {
                    execs = execs ~ n;
                }
            }
        }
        sortedDefFiles = execs;
    }
    //parses, sorts, and appends config paths to total paths
    foreach (string k, v; parsedConfig)
    {
        if (k == "paths" && v.type == JSONType.array)
        {
            foreach (_, vt; v.array)
            { //look for config execs here in this scope
                string[] execs;
                try
                {
                    foreach (string n; dirEntries(vt.str, "*.exe", SpanMode.breadth))
                    { //specifies .exe files (for now)
                        execs = execs ~ n;
                    }
                    sortedConfigFiles = sortedConfigFiles ~ execs;
                }
                catch (FileException)
                {
                    throw new Error("FileException: Directory " ~ vt.str ~ " does not exist");
                } /*finally {
                    throw new Error("Unknown error occured relating to .config file.");
                }*/
            }
        }
    }
    sortedConfigPaths = sortedConfigPaths.sort().release(); //actually sorts config paths
    sortedPaths = sortedDefFiles ~ sortedConfigFiles;
        sortedPaths = sortedPaths.sort().release(); //sorts all paths together normally
    sortedPaths = sortedPaths.sort().release(); //sorts all paths together
    string[] sortedFiles; //sorted files(JUST FILENAMES), might include extensions
    foreach (_, string v; sortedPaths)
    {
        //if (!(conf.showPaths())) {
            auto file = split(v, "\\"); //gets just the filename
        //}
        string nfile = file[file.length - 1];
        if (!(conf.showExts())) {
            nfile = nfile.stripExtension(); //removes extension
        }
        sortedFiles = sortedFiles ~ nfile;
    }
    if (conf.reverseOrder) {
        sortedFiles.sort!("a > b").release();
    } else {
        sortedFiles.sort().release();
    }
    //end
    writeln("You can add or remove additional search paths in " ~ dir ~ dirSeparator ~ ".config\n\n"); //get default executables from $PATH
    foreach (_, v; sortedFiles)
    {
        writeln(v);
    }
    checkProg();
    writeln("Press ENTER to exit the program.");
    readln();
}


void checkProg() {
    auto rln = readln();
    if (rln.startsWith("r ")) {
        foreach (_, v; sortedPaths) {
            foreach (string n; dirEntries(v, "*.exe", SpanMode.breadth)) {
                if (n.endsWith(rln.split()[1] ~ ".exe")) {
                    spawnProcess(n);
                }
            }
        }
        checkProg();
    }
}