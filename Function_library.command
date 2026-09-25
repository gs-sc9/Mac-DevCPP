#!/bin/zsh
# Function library.command
# 模式1：传入 header_auto 错误信息 → 返回需要添加的 #include
# 模式2：传入 func_auto 函数名 → 返回C++函数源码
MODE="$1"
ARG="$2"

case "${MODE}" in
header_auto)
    ERR_TEXT="${ARG}"
    if echo "$ERR_TEXT" | grep -qE "cout|cin"; then
        echo "#include <iostream>"
    elif echo "$ERR_TEXT" | grep -qE "std::string|string|getline"; then
        echo "#include <string>"
    elif echo "$ERR_TEXT" | grep -qE "printf|scanf|getchar|putchar"; then
        echo "#include <cstdio>"
    elif echo "$ERR_TEXT" | grep -qE "strlen|strcmp|strcpy|memset|memcpy|memmove|memcmp"; then
        echo "#include <cstring>"
    elif echo "$ERR_TEXT" | grep -qE "sqrt|abs|ceil|floor|pow|log|log10|exp|fabs"; then
        echo "#include <cmath>"
    elif echo "$ERR_TEXT" | grep -qE "sort|swap|max|min|upper_bound|lower_bound|reverse|fill"; then
        echo "#include <algorithm>"
    elif echo "$ERR_TEXT" | grep -qE "atoi|atol|atof|rand|srand|exit"; then
        echo "#include <cstdlib>"
    elif echo "$ERR_TEXT" | grep -qE "isdigit|isalpha|tolower|toupper"; then
        echo "#include <cctype>"
    elif echo "$ERR_TEXT" | grep -qE "accumulate"; then
        echo "#include <numeric>"
    else
        echo ""
    fi
;;
func_auto)
    FUNC_NAME="${ARG}"
    case "${FUNC_NAME}" in
    "qsort")
cat <<'EOF'
#include <cstdlib>
int cmp_int(const void *a, const void *b){
    return *(int*)a - *(int*)b;
}
void qsort(int *arr,size_t n,size_t sz,int (*cmp)(const void*,const void*)){
    ::qsort(arr,n,sz,cmp);
}
EOF
;;
    "abs")
cat <<'EOF'
int abs(int x){
    return (x>0)?x:-x;
}
long long abs(long long x){
    return (x>0)?x:-x;
}
EOF
;;
    "sqrt")
cat <<'EOF'
#include <cmath>
double sqrt(double x){
    return ::sqrt(x);
}
EOF
;;
    "strlen")
cat <<'EOF'
size_t strlen(const char *s){
    size_t len=0;
    while(s[len]!='\0') len++;
    return len;
}
EOF
;;
    "strcmp")
cat <<'EOF'
int strcmp(const char *a,const char *b){
    int i=0;
    while(a[i]&&b[i]&&a[i]==b[i])i++;
    return a[i]-b[i];
}
EOF
;;
    "strcpy")
cat <<'EOF'
char* strcpy(char *dest,const char *src){
    int i=0;
    while(src[i]){
        dest[i]=src[i];
        i++;
    }
    dest[i]='\0';
    return dest;
}
EOF
;;
    "memset")
cat <<'EOF'
#include <cstring>
void* memset(void* buf,int val,size_t len){
    unsigned char *p=(unsigned char*)buf;
    for(size_t i=0;i<len;i++) p[i]=val;
    return buf;
}
EOF
;;
    "memcpy")
cat <<'EOF'
#include <cstring>
void* memcpy(void* dest, const void* src, size_t n){
    unsigned char *d=(unsigned char*)dest;
    const unsigned char *s=(const unsigned char*)src;
    for(size_t i=0;i<n;i++) d[i]=s[i];
    return dest;
}
EOF
;;
    "memmove")
cat <<'EOF'
#include <cstring>
void* memmove(void* dest, const void* src, size_t n){
    unsigned char *d=(unsigned char*)dest;
    const unsigned char *s=(const unsigned char*)src;
    if(d<s){
        for(size_t i=0;i<n;i++) d[i]=s[i];
    }else{
        for(size_t i=n;i>0;i--) d[i-1]=s[i-1];
    }
    return dest;
}
EOF
;;
    "memcmp")
cat <<'EOF'
#include <cstring>
int memcmp(const void* a,const void* b,size_t n){
    const unsigned char *p=(const unsigned char*)a;
    const unsigned char *q=(const unsigned char*)b;
    for(size_t i=0;i<n;i++){
        if(p[i]!=q[i]) return p[i]-q[i];
    }
    return 0;
}
EOF
;;
    "sort")
cat <<'EOF'
#include <algorithm>
template<typename T>
void sort(T* l,T* r){
    std::sort(l,r);
}
EOF
;;
    "swap")
cat <<'EOF'
template<typename T>
void swap(T &a,T &b){
    T t=a;a=b;b=t;
}
EOF
;;
    "max")
cat <<'EOF'
template<typename T>
T max(T a,T b){
    return (a>b)?a:b;
}
EOF
;;
    "min")
cat <<'EOF'
template<typename T>
T min(T a,T b){
    return (a<b)?a:b;
}
EOF
;;
    "printf")
cat <<'EOF'
#include <cstdio>
int printf(const char *fmt,...){
    return ::printf(fmt, __builtin_va_arg_pack());
}
EOF
;;
    "scanf")
cat <<'EOF'
#include <cstdio>
int scanf(const char *fmt,...){
    return ::scanf(fmt, __builtin_va_arg_pack());
}
EOF
;;
    "atoi")
cat <<'EOF'
#include <cstdlib>
int atoi(const char *s){
    return ::atoi(s);
}
EOF
;;
    "atol")
cat <<'EOF'
#include <cstdlib>
long atol(const char *s){
    return ::atol(s);
}
EOF
;;
    "atof")
cat <<'EOF'
#include <cstdlib>
double atof(const char *s){
    return ::atof(s);
}
EOF
;;
    "isdigit")
cat <<'EOF'
#include <cctype>
int isdigit(int c){
    return ::isdigit(c);
}
EOF
;;
    "isalpha")
cat <<'EOF'
#include <cctype>
int isalpha(int c){
    return ::isalpha(c);
}
EOF
;;
    "tolower")
cat <<'EOF'
#include <cctype>
int tolower(int c){
    return ::tolower(c);
}
EOF
;;
    "toupper")
cat <<'EOF'
#include <cctype>
int toupper(int c){
    return ::toupper(c);
}
EOF
;;
    "ceil")
cat <<'EOF'
#include <cmath>
double ceil(double x){
    return ::ceil(x);
}
EOF
;;
    "floor")
cat <<'EOF'
#include <cmath>
double floor(double x){
    return ::floor(x);
}
EOF
;;
    "pow")
cat <<'EOF'
#include <cmath>
double pow(double a,double b){
    return ::pow(a,b);
}
EOF
;;
    "log")
cat <<'EOF'
#include <cmath>
double log(double x){
    return ::log(x);
}
EOF
;;
    "log10")
cat <<'EOF'
#include <cmath>
double log10(double x){
    return ::log10(x);
}
EOF
;;
    "exp")
cat <<'EOF'
#include <cmath>
double exp(double x){
    return ::exp(x);
}
EOF
;;
    "fabs")
cat <<'EOF'
#include <cmath>
double fabs(double x){
    return ::fabs(x);
}
EOF
;;
    "upper_bound")
cat <<'EOF'
#include <algorithm>
template<typename T>
T* upper_bound(T* l,T* r,const T &val){
    return std::upper_bound(l,r,val);
}
EOF
;;
    "lower_bound")
cat <<'EOF'
#include <algorithm>
template<typename T>
T* lower_bound(T* l,T* r,const T &val){
    return std::lower_bound(l,r,val);
}
EOF
;;
    "reverse")
cat <<'EOF'
#include <algorithm>
template<typename T>
void reverse(T* l,T* r){
    std::reverse(l,r);
}
EOF
;;
    "fill")
cat <<'EOF'
#include <algorithm>
template<typename T>
void fill(T* l,T* r,const T &v){
    std::fill(l,r,v);
}
EOF
;;
    "accumulate")
cat <<'EOF'
#include <numeric>
template<typename T>
T accumulate(T* l,T* r,T init){
    return std::accumulate(l,r,init);
}
EOF
;;
    *)
        echo ""
    ;;
    esac
;;
*)
    echo ""
;;
esac
