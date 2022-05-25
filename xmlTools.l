import system'io;
import extensions;
import system'collections;
import system'routines;


/**
* Class representing a node in an xml file.
* An xml file represents a tree, therfore we save each element in the file as a node. this class represents one of those nodes.
*
* class fields:
* sons - a system'collections'ArrayList (or array in normal language) that contains the node's sons.
* attr - a system'collections'ArrayList that contains the node's attributes.
* text - a string that contaons the node's content.
* bool debug - a boolean that decides whether debug messages are printed.
* string sep - the seperating character between attribute names and their values (elena doesn't have dictionary like python, so instead of {attrName:attrValue} we have to save as string like this: "attrNameSEP_STRINGattrValue".
*/
public class xmlNode
{
    name;
    sons;
    attr;
    text;
    bool debug;
    string sep;
    
    /**
    * default constructor.
    */
    constructor(string _name)
    {
        debug := false;
        name := name;
        sons := new ArrayList();
        attr := new ArrayList();
        text := "";
    }
    /**
    * constructor that gets a bool represnting if to print debug messages or not.
    */
    constructor(bool DEBUG, string _name)
    {
        debug := DEBUG;
        name := _name;
        sons := new ArrayList();
        attr := new ArrayList();
        text := "";
        sep := ($9829).toString();
    }
    method getName()
    {
        ^ name;
    }
    method getSons()
    {
        ^ sons;
    }
    method getAttributes()
    {
        ^ attr;
    }
    method getText()
    {
        ^ text;
    }
    addText(string _text)
    {
        text := _text;
    }
    /**
    * adds a son to the node by creating a new xmlNode and adding it to the current node's sons.
    */
    addSon(string _name)
    {
        var newNode := new xmlNode(_name);
        sons.append(newNode);
        ^ newNode;
    }
    
    addSons(var _sons)
    {
        for(var i := 0, i < _sons.Length, i += 1)
        {
            sons.append(_sons[i]);
        }
    }
    
    findAllSons(string _name)
    {
        var matching := new ArrayList();
        for(var i := 0, i < sons.Length, i += 1)
        {
            if(sons[i].getName() == _name)
            {
                matching.append(sons[i]);
            };
        };
        ^ matching;
    }
    
    /**
    * adds an attribute to the node by adding an attribute string ("nameSEP_VALUEvalue") to the attr array.
    * name - name of the attribute
    * value - the value of the attribute
    */
    addAttr(string name, string value)
    {
        attr.append(name+sep+value);
    }
    /*
    * gets one of the node's attributes' value provided the attributes name. return empty string ("") if not found.
    * _name - the name of the attribute whos value is wanted.
    */
    getAttr(string _name)
    {
        string name;
        string value;
        for(var i := 0, i < attr.Length, i += 1)
        {
            name := (attr[i].splitBy(sep)).FirstMember;
            value := (attr[i].splitBy(sep)).LastMember;
            if(name == _name)
            {
                if(debug)
                {
                    console.writeLine("DBG: found attribute "+_name+" with value "+value);
                };
                ^ value;
            };
        };
        if(debug)
        {
            console.writeLine("DBG: attribute "+_name+"was not found");
        };
        ^ "".toString();
    }
    printNode()
    {
        self.printNode("");
    }
    printNode(var indent)
    {
        console.writeLine(indent+"Name: "+name);
        console.writeLine(indent+"Text: " + text);
        console.writeLine(indent+"Sons: " + sons.Length.toString());
        for(var i := 0, i < sons.Length, i += 1)
        {
            sons[i].printNode(indent + "    ".toString());
        };
        if(sons.Length == 0)
        {
            console.writeLine("");
        };
    }
    writeNode(var fname)
    {
        self.writeNode(fname, "");
    }
    writeNode(var fname, string indent)
    {
        using(auto writer := File.assign(fname).logger())
        {
            // repeating until the empty line is entered
            writer.writeLine(indent + "<"+name+">"+text);
        };
        for(var i := 0, i < sons.Length, i += 1)
        {
            sons[i].writeNode(fname, indent + ($9).toString());
        };
        using(auto writer := File.assign(fname).logger())
        {
            // repeating until the empty line is entered
            writer.writeLine(indent + "</"+name+">");
        };
    }
}

public class xmlParser
{
    string fpath;
    string ftext;
    xmlNode root;
    int curIndex := 0;
    constructor(string _fpath)
    {
        fpath := _fpath;
        ftext := self.getFileAsText();
        curIndex := 0;
        self.makeTree();
        console.writeLine("no success!");
        root.printNode();
        console.writeLine("success!");
    }
    method getRoot()
    {
        ^ root;
    }
    method getFileAsText()
    {
        string fileText := "";
        using(auto reader := File.assign(fpath).textreader())
        {
            while(reader.Available)
            {
                fileText += reader.readLine();
            };
        };
        ^ fileText;
    }
    
    method curChar()
    {
        //console.writeLine("getting char - cur: "+curIndex.toString() + " length: "+ftext.Length.toString());
        if(curIndex == ftext.Length)
        {
            ^ "";
        };
        ^ ftext[curIndex];
    }
    method curChar(var offset)
    {
        if(curIndex + offset >= ftext.Length)
        {
            ^ "";
        };
        ^ ftext[curIndex + offset];
    }
    method incChar()
    {
        if(curIndex + 1 <= ftext.Length)
        {
            curIndex += 1;
        };
    }
    method incChar(var step)
    {
        if(curIndex + step <= ftext.Length)
        {
            curIndex += step;
        };
    }
    method makeTree()
    {
        root := self.parseText().FirstMember;
    }
    
    method parseText()
    {
        var nodes := new ArrayList();
        var text := "";
        var opened := new ArrayList();
        
        //console.writeLine("started parsing!");
        
        if(self.curChar().toString() == "")
        {
            console.writeLine("no current char!");
            ^ false;
        };
        while(self.curChar() != "")
        {
            //console.writeLine("started parsing loop! curChar: " + self.curChar());
            if(self.curChar() == "<" && self.curChar(1) != "/" && (self.curChar(1).toString()+self.curChar(2).toString()+self.curChar(3).toString()) != "!--")
            {
                //console.writeLine("opening tag!");
                self.incChar();
                var tagName := "";
                while(self.curChar() != " " && self.curChar() != ">")
                {
                    tagName += self.curChar();
                    self.incChar();
                };
                while(self.curChar() != ">")
                {
                    self.incChar();
                };
                self.incChar();
                if(tagName != "?xml")
                {
                    //console.writeLine("made node "+tagName);
                    opened.append(tagName);
                    var node := new xmlNode(true, tagName);
                    var tmp := self.parseText();
                    //console.writeLine("poop");
                    if(tmp.LastMember == "text")
                    {
                        tmp.remove(tmp.Length - 1);
                        node.addText(tmp[0]);
                    }
                    else if (tmp.LastMember == "nodes")
                    {
                        tmp.remove(tmp.Length - 1);
                        node.addSons(tmp);
                    };
                    nodes.append(node);
                }
            }
            else if (self.curChar() == "<" && self.curChar(1) == "/")
            {
                //console.writeLine("closing tag!");
                //self.incChar(2);
                var tagName := "";
                var offset := 2;
                while(self.curChar(offset) != ">")
                {
                    tagName += self.curChar(offset);
                    offset += 1;
                    //self.incChar();
                };
                //self.incChar();
                //console.writeLine(opened.Length.toString()+" "+tagName);
                if(opened.Length > 0)
                {
                    //console.writeLine("closed tag! "+tagName);
                    opened.remove(opened.Length - 1);
                    self.incChar(2);
                    while(self.curChar() != ">")
                    {
                        tagName += self.curChar();
                        self.incChar();
                    };
                    self.incChar();
                }
                else
                {
                    //console.writeLine("closed tag! "+tagName);
                    if(nodes.Length == 0)
                    {
                        //console.writeLine("returned text");
                        var textArray := new ArrayList();
                        textArray.append(text);
                        textArray.append("text");
                        ^ textArray;
                    }
                    else
                    {
                        //console.writeLine("returned nodes");
                        nodes.append("nodes");
                        ^ nodes;
                    };
                };
            }
            //this won't work if not inbetween elements
            else if (self.curChar() == "<" && (self.curChar(1).toString()+self.curChar(2).toString()+self.curChar(3).toString()) == "!--")
            {
                //console.writeLine("entered comment");
                while((self.curChar().toString()+self.curChar(1).toString()+self.curChar(2).toString()) != "-->")
                {
                    self.incChar();
                };
                self.incChar(3);
                //console.writeLine("exited comment");
            }
            else if (self.curChar() == ($10).toString() || self.curChar() == ($13).toString() || self.curChar() == " ".toString() ||
            self.curChar() == ($9).toString())
            {
                //console.writeLine("encountered new line char");
                self.incChar();
            }
            else
            {
                //console.writeLine("entered text");
                while(self.curChar() != "<" && self.curChar() != ($10).toString() && self.curChar() != ($13).toString())
                {
                    text += self.curChar();
                    self.incChar();
                };
                //console.writeLine("returned text");
                var textArray := new ArrayList();
                textArray.append(text);
                textArray.append("text");
                ^ textArray;
            };
        };
        //console.writeLine("ended while " + nodes.Length.toString() + " ");
        if(nodes.Length == 0)
        {
            //console.writeLine("returned text");
            var textArray := new ArrayList();
            textArray.append(text);
            textArray.append("text");
            ^ textArray;
        }
        else
        {
            //console.writeLine("returned nodes");
            nodes.append("nodes");
            ^ nodes;
        };
    }
}