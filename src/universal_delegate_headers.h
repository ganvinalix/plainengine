#ifndef __UNIVERSAL_DELEGATE_HEADERS_H__
#define __UNIVERSAL_DELEGATE_HEADERS_H__

#include <mp_object.h>
#include <dictionary.h>

typedef void (*delegateInitFunc)(void *userInfo, MPHandle oHandle, void *classInfo);
typedef void (*delegateCleanFunc)(void *userInfo, void *classInfo);
typedef void (*delegateSetFeatureFunc)(void *userInfo, char const *featureName, char const *featureValue, dictionary userDict, void *classInfo);
typedef void (*delegateRemoveFeatureFunc)(void *userInfo, char const *featureName, dictionary userDict, void *classInfo);
typedef void (*delegateMethod)(char const* methodName, void *userInfo, void *params[], void *resultBuf, void *classInfo);

#define DECLARE_INIT_FUNC(name)\
	void name(void *userInfo, MPHandle oHandle, void *classInfo)

#define DECLARE_CLEAN_FUNC(name)\
	void name(void *userInfo, void *classInfo)

#define DECLARE_SET_FEATURE_FUNC(name)\
	void name(void *userInfo, char const *featureName, char const *featureValue, dictionary userDict, void *classInfo)

#define DECLARE_REMOVE_FEATURE_FUNC(name)\
	void name(void *userInfo, char const *featureName, dictionary userDict, void *classInfo)

#define DECLARE_METHOD(name)\
	void name(char const *methodName, void *userInfo, void *params[], void *resultBuffer, void *classInfo)

#define BEGIN_ENUMERATING_PARAMS\
	unsigned __params_counter=0

#define LOAD_PARAM(type, name)\
	type name=*(type *)(params[__params_counter++])

#define FOR_EACH_PARAM(counter, count, parampointer)\
	void *parampointer = params[0]\
	unsigned counter = 0;\
	for(; counter<count; parampointer = params[++counter])

#define END_ENUMERATING_PARAMS //Reserved for future use

#define FIELD_FROM_STRUCT(type, field)\
	(((type*)userInfo)->field)

#define SET_RESULT_VALUE(type, value)\
	*((type *)resultBuffer) = (value)


#endif

