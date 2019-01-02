#include <cstdlib>
#include <fstream>
#include <iostream>

using namespace std;

int printUsage(){
    cout << "Usage: stripleading <output file> <number of bytes to pad to> <input files> \n";
    return 0;
}

int main(int argc, char **argv){
    //Check for valid command line args
    if(argc < 4)
        return printUsage();
    if(atoi(argv[2]) <= 0)
        return printUsage();

    //Try to open the output file
    ofstream out(argv[1], ios_base::binary);
    if(!out.is_open()){
        cout << "Unable to open file: " << argv[1] << endl;
        return 0;
    }

    char *buffer = (char*)malloc(1024);
    for(int x = 3; x < argc; x++){
        //Try to open the input file
        ifstream in(argv[x], ios_base::binary);
        if(!in.is_open()){
            cout << "Unable to open file: " << argv[x] << endl;
            out.close();
            free(buffer);
            return 0;
        }

        //Get the file size
        in.seekg(0, ios_base::end);
        int size = (int)in.tellg();
        in.seekg(0);

        //Copy the the file
        for(int i = 0; i < size; size += 1024){
            in.read(buffer, 1024);
            out.write(buffer, in.gcount());
            if(!in.good())
                break;
        }
    }

    //Pad the output file
    for(int i = (int)out.tellp(); i < atoi(argv[2]); i++)
        out.put(0);

    //Cleanup
    free(buffer);
    out.close();
    return 0;
}

