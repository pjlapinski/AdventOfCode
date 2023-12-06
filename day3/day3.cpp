#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

struct num_t {
    size_t lineNo;
    size_t startIdx;
    std::string value;
};

struct symbol_t {
    size_t lineNo;
    size_t idx;
    char value;
};

void findNumsAndGears(std::ifstream &fs, std::vector<symbol_t> &outSym, std::vector<num_t> &outNum) {
    num_t currentNum;
    bool findingNum;

    std::string line;
    size_t lineNo = 0;
    while (std::getline(fs, line)) {
        for (size_t i = 0; i < line.length(); ++i) {
            if (line[i] >= '0' && line[i] <= '9') {
                if (findingNum) {
                    currentNum.value.append({ line[i] });
                } else {
                    findingNum = true;
                    currentNum = {
                        .lineNo = lineNo,
                        .startIdx = i,
                        .value = { line[i] }
                    };
                }
                continue;
            }
            if (findingNum) {
                outNum.push_back(currentNum);
                findingNum = false;
            }
            if (line[i] != '.') {
                outSym.push_back({ .lineNo = lineNo, .idx = i, .value = line[i] });
            }
        }
        if (findingNum) {
            outNum.push_back(currentNum);
            findingNum = false;
        }
        ++lineNo;
    }
}

bool isNumAdjacentToSymbol(const num_t &num, const symbol_t &symbol) {
    size_t i = num.lineNo == 0 ? 0 : num.lineNo - 1;
    for (; i <= num.lineNo + 1; ++i) {
        size_t j = num.startIdx == 0 ? 0 : num.startIdx - 1;
        for (; j <= num.startIdx + num.value.length(); ++j) {
            if (symbol.lineNo == i && symbol.idx == j) {
                return true;
            }
        }
    }
    return false;
}

int solution1(std::ifstream &fs) {
    std::vector<symbol_t> symbols;
    std::vector<num_t> nums;
    findNumsAndGears(fs, symbols, nums);

    int sum = 0;
    for (num_t n : nums) {
        int adjs = 0;
        for (symbol_t s : symbols) {
            adjs += isNumAdjacentToSymbol(n, s);
        }
        sum += std::stoi(n.value) * adjs;
    }

    return sum;
}

int solution2(std::ifstream &fs) {
    std::vector<symbol_t> symbols;
    std::vector<num_t> nums;
    findNumsAndGears(fs, symbols, nums);

    int sum = 0;
    for (symbol_t s : symbols) {
        int adjs = 0;
        int product = 1;
        for (num_t n : nums) {
            if (s.value == '*' && isNumAdjacentToSymbol(n, s)) {
                ++adjs;
                product *= std::stoi(n.value);
            }
        }
        if (adjs == 2) {
            sum += product;
        }
    }
    return sum;
}

int main(int argc, char **argv) {
    char *input = argv[1];
    std::ifstream fs;
    fs.open(input);

    std::cout << solution2(fs) << std::endl;

    fs.close();
    return 0;
}
