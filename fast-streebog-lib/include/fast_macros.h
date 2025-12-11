#ifndef FAST_MACROS_H
#define FAST_MACROS_H

#define FAST_NAMESPACE(name) fast_##name
#define STREEBOG_NAMESPACE(name) streebog_##name

/* DLL/dylib export/import macros */
#ifdef _WIN32
#ifdef STREEBOG_BUILD_DLL
#define STREEBOG_API __declspec(dllexport)
#elif defined(STREEBOG_USE_DLL)
#define STREEBOG_API __declspec(dllimport)
#else
#define STREEBOG_API
#endif
#elif defined(__APPLE__) || defined(__linux__)
#if defined(STREEBOG_BUILD_DLL) || defined(STREEBOG_USE_DLL)
#define STREEBOG_API __attribute__((visibility("default")))
#else
#define STREEBOG_API
#endif
#else
#define STREEBOG_API
#endif

#endif // FAST_MACROS_H