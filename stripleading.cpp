#include <cstdlib>
#include <fstream>
#include <iostream>

using namespace std;

int printUsage(){
    cout << "Usage: stripleading <input file> <output file> <number of bytes to strip>\n";
    return 0;
}

int main(int argc, char **argv){
    //Check for valid command line args
    if(argc != 4)
        return printUsage();
    if(atoi(argv[3]) <= 0)
        return printUsage();

    //Try to open the input file
    ifstream in(argv[1], ios_base::binary);
    if(!in.is_open()){
        cout << "Unable to open file: " << argv[1] << endl;
        return 0;
    }

    //Try to open the output file
    ofstream out(argv[2], ios_base::binary);
    if(!out.is_open()){
        cout << "Unable to open file: " << argv[2] << endl;
        return 0;
    }

    //Get the file size
    in.seekg(0, ios_base::end);
    int size = (int)in.tellg() - atoi(argv[3]);

    //Skip ahead of the stripped section
    in.seekg(atoi(argv[3]));

    //Copy the rest of the file
    char *buffer = (char*)malloc(1024);
    for(int i = 0; i < size; size += 1024){
        in.read(buffer, 1024);
        out.write(buffer, in.gcount());
        if(!in.good())
            break;
    }


    //Cleanup
    free(buffer);
    in.close();
    out.close();
    return 0;
}

