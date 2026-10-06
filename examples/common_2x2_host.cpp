#include "common_2x2.hpp"
#include <cstdio>
int main() {
    static kibo::examples::Common2x2 problem;
    const auto status=problem.run();
    std::printf("{\"status\":%u,\"correct\":%s,\"numeric_bytes\":%zu,\"matvec\":[%.17g,%.17g],\"solve\":[%.17g,%.17g]}\n",
        static_cast<unsigned>(status.code),problem.correct()?"true":"false",sizeof(problem),
        problem.product[0],problem.product[1],problem.solution[0],problem.solution[1]);
    return !status || !problem.correct();
}
