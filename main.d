module main;
import std.file, std.stdio, std.path, std.string, std.json;
import std.algorithm.sorting : sort;
import std.algorithm.searching : canFind;
import std.conv : to;
import std.range;
import std.process;
static import conf = config;
//possibly add size, date modified, etc. to files
//add config option for full path, reverse order, additional file extensions
string[] sortedConfigPaths; //ignore this just some stuff for organization
string[] sortedConfigFiles;
string[] splitDefaultPaths;
string[] sortedDefPaths;
string[] sortedDefFiles;
string[] sortedPaths;
void main()
{
    //writeln(conf.extraExts);
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
        splitDefaultPaths = defaultPaths.split(pathSeparator);
        sortedDefPaths = splitDefaultPaths.sort().release();
        string[] execs;
        foreach (i, string v; splitDefaultPaths)
        {
            if (!canFind(v, "C:\\windows"))
            { //if this is ommited, it causes an AccessDenied error
                foreach (_, string vt; conf.extraExts()) { //might be mandatory for dirEntries loops
                    foreach (string n; dirEntries(v, vt, SpanMode.breadth))         //STILL SHOWS OLD EXTENSIONS
                    {
                        execs = execs ~ n;
                    }
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
            foreach (i, vt; v.array)
            { //look for config execs here in this scope
                string[] execs;
                try
                {
                    foreach (_, string vtt; conf.extraExts()) {
                        foreach (string n; dirEntries(vt.str, vtt, SpanMode.breadth))             //here
                        { //specifies .exe files (for now)
                            execs = execs ~ n;
                        } 
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
    foreach (_, string v; sortedPaths) //this is where you should edit settings for the execs, it loops through every directory, both path and config ones
    {
        string nfile;
        if (!(conf.showPaths())) {
            auto file = split(v, "\\"); //gets just the filename
            nfile = file[file.length - 1].toLower();
        } else {
            nfile = v.toLower();
        }
        if (!(conf.showExts())) {
            nfile = nfile.stripExtension(); //removes extension
        }
        if (!(conf.moreInfo())) {
            sortedFiles = sortedFiles ~ nfile;
        } else {
            nfile = nfile ~ "       Modified " ~ v.timeLastModified().toString() ~ "       " ~ to!string(v.getSize() / 1_000_000) ~ " MB";
            sortedFiles = sortedFiles ~ nfile;
        }
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
        foreach (i, v; sortedPaths) {
            foreach (_, string vt; conf.extraExts()) {
                foreach (string n; dirEntries(v, vt, SpanMode.breadth)) {           //here
                    if (canFind(n, rln.split()[1] ~ ".exe")) {
                        spawnProcess(n);
                    }
                }
            }
        }
        checkProg();
    }
}