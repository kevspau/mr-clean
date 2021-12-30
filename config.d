module config;

import std.json, std.file, std.path;

private string config;
static this() {
    config = readText("." ~ dirSeparator ~ ".config");
}
private JSONValue pc;
static this() {
    pc = config.parseJSON();
}

public enum SortBy {
    alphabetical,
    size,
    date_modified
}
public bool showExts() {
    foreach (string k, v; pc) { //look into JSONValue properties to avoid too many foreach loops
        if (k == "extra_settings") {
            foreach (string kt, vt; v) {
                if (kt == "show_extensions" && vt.type is JSONType.true_) {
                    return true;
                } else if (kt == "show_extensions" && vt.type is JSONType.false_){
                    return false;
                }
            }
        }
    }
    return false;
}
public SortBy sorted() {
    foreach (string k, v; pc) {
        if (k == "extra_settings") {
            foreach (string kt, vt; v) {
                if (kt == "sort_by") {
                    if (vt.str == "alphabetical") {
                        return SortBy.alphabetical;
                    } else if (vt.str == "size") {
                        return SortBy.size;
                    } else if (vt.str == "date_modified") {
                        return SortBy.date_modified;
                    }
                }
            }
        }
    }
    return SortBy.alphabetical;
}
public bool showPaths() {
    foreach (string k, v; pc) {
        if (k == "extra_settings") {
            foreach (string kt, vt; v) {
                if (kt == "show_directories" && vt.type is JSONType.true_) {
                    return true;
                } else if (kt == "show_directories" && vt.type is JSONType.false_) {
                    return false;
                }
            }
        }
    }
    return false;
}
public bool moreInfo() {
    foreach (string k, v; pc) {
        if (k == "extra_settings") {
            foreach (string kt, vt; v) {
                if (kt == "extra_info" && vt.type is JSONType.true_) {
                    return true;
                } else if (kt == "extra_info" && vt.type is JSONType.false_) {
                    return false;
                }
            }
        }
    }
    return false;
}

public bool reverseOrder() {
    foreach (string k, v; pc) {
        if (k == "extra_settings") {
            foreach (string kt, vt; v) {
                if (kt == "reverse_order" && vt.type is JSONType.true_) {
                    return true;
                } else if (kt == "reverse_order" && vt.type is JSONType.false_) {
                    return false;
                }
            }
        }
    }
    return false;
}
public string[] extraExts() {
    foreach (string k, v; pc) {
        if (k == "extra_settings") {
            foreach (string kt, vt; v) {
                if (kt == "extensions" && vt.type is JSONType.array) {
                    string[] stuff;
                    foreach (_, vtt; vt.array) {
                        stuff = stuff ~ vtt.str;
                    }
                    return stuff;
                }
            }
        }
    }
    return [];
}