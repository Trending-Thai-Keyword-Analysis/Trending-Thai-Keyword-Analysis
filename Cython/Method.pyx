# distutils: language=c++
from libc.string cimport strlen, strcmp
from libc.stdlib cimport malloc, free
from libc.stdio cimport printf
cdef extern from "Python.h":
    const char* PyUnicode_AsUTF8(object unicode)
    object PyUnicode_DecodeUTF8(const char* utf8string, Py_ssize_t size, const char *errors)

cdef const char ** to_cstring_array(list_str, int length):
    cdef const char **ret = <const char **>malloc(length * sizeof(char *))
    for i in xrange(length):
        ret[i] = PyUnicode_AsUTF8(list_str[i])
    return ret

cpdef lcs(S1, S2, int m, int n):
    cdef int i = 0
    cdef int j = 0
    cdef int k = 0
    cdef int len = 0
    cdef int *L = <int *>malloc(((m+1) * (n+1)) * sizeof(int))
    for i in range((m+1) * (n+1)):
        L[i] = 0
    cdef const char **c_arr1 = to_cstring_array(S1,m)
    cdef const char **c_arr2 = to_cstring_array(S2,n)

    result = []
    i = 1

    try:
        for i in range(1,m+1):
            j = 1
            for j in range(1,n+1):
                if strcmp(c_arr1[i-1],c_arr2[j-1]) == 0:
                    #printf("%s | %s\n",c_arr1[i-1],c_arr2[j-1])
                    L[i*(n+1) + j] = L[i*(n+1) + j - n - 2] + 1
                    if len < L[i*(n+1) + j]:
                        if 2 < L[i*(n+1) + j] < 9:
                            len = L[i*(n+1) + j]
                            #printf("%d\n",len)
                            result = []
                            k = 0
                            LCS = ""
                            #printf("%d | %d\n",k,len)
                            for k in range(len):
                                LCS = PyUnicode_DecodeUTF8(c_arr1[i-1-k],strlen(c_arr1[i-1-k]),"surrogateescape") + LCS
                                #print(LCS)
                            if LCS not in result:
                                result.append(LCS)
                    elif len == L[i*(n+1) + j]:
                        k = 0
                        LCS = ""
                        #printf("%d | %d\n",k,len)
                        for k in range(len):
                            LCS = PyUnicode_DecodeUTF8(c_arr1[i-1-k],strlen(c_arr1[i-1-k]),"surrogateescape") + LCS
                            #print(LCS)
                        if LCS not in result:
                            result.append(LCS)

        return result,len
    finally:
        free(L)
        free(c_arr1)
        free(c_arr2)
    