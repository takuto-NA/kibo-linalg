#pragma once
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <Windows.h>
#include <intrin.h>
#include <cstdio>
inline bool pin_probe(){
    if(!SetProcessAffinityMask(GetCurrentProcess(),DWORD_PTR{1})) {
        std::fprintf(stderr,"Cannot pin diagnostic process to logical CPU0: %lu\n",GetLastError());
        return false;
    }
    return true;
}
inline unsigned probe_core_type(){
    int info[4]{};__cpuidex(info,0,0);
    if(info[0]<0x1a)return 0;
    __cpuidex(info,0x1a,0);return static_cast<unsigned>(info[0])>>24;
}
