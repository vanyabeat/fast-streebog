#ifndef FAST_MACROS_H
#define FAST_MACROS_H

#define FAST_NAMESPACE(name) fast_##name
#define STREEBOG_NAMESPACE(name) streebog_##name

// DLL export/import macros for Windows
#ifdef _WIN32
#ifdef STREEBOG_BUILD_DLL
#define STREEBOG_API __declspec(dllexport)
#elif defined(STREEBOG_USE_DLL)
#define STREEBOG_API __declspec(dllimport)
#else
#define STREEBOG_API
#endif
#else
#if defined(__GNUC__) && __GNUC__ >= 4
#define STREEBOG_API __attribute__((visibility("default")))
#else
#define STREEBOG_API
#endif
#endif

#endif // FAST_MACROS_H