// a code generator for the ALU chain in the 32-bit ALU
// look at example_generator.cpp for inspiration

// make generator
// ./generator
#include <iostream>

int main() {

    int width = 32;
    std::cout<<"    alu1 alu1_"<<"0"<<"(out["<<"0"<<"], carryout["<<"0"<<"], A["<<"0"<<"], B["<<"0"<<"], control["<<"0"<<"], control);" << std::endl;
    for (int i = 1; i < width; i++) {
        std::cout<<"    alu1 alu1_"<<i<<"(out["<<i<<"], carryout["<<i<<"], A["<<i<<"], B["<<i<<"], carryout["<<i-1<<"], control);" << std::endl;
    }

    std::cout<<"    or o_"<<"0"<<"(chain["<<"0"<<"], out["<<"0"<<"], "<<"0);"<<std::endl;
    for (int i = 1; i < width; i++) {
        std::cout<<"    or o_"<<i<<"(chain["<<i<<"], out["<<i<<"], chain["<<i-1<<"]);"<<std::endl;
    }

    return 0;
}