# Introduction #

When you want to register delegate class, you'll need to declare some methods and include some type information. In Objective-C subjects this is being handled automatically by runtime, but this is impossible for subjects, written in other languages. For this purpose, plainEngine uses Objective-C type encodings. Type encoding is c-string, which is defined for every scalar type.

# Encodings table #

PlainEngine supports quite definite number of scalar types. This is table of supported types and their encodings:

| **Type** | **Encoding** |
|:---------|:-------------|
| `double` | `"d"`        |
| `float`  | `"f"`        |
| `long`   | `"l"`        |
| `unsigned long` | `"L"`        |
| `long long` | `"q"`        |
| `unsigned long long` | `"Q"`        |
| `char`   | `"c"`        |
| `unsigned char` | `"C"`        |
| `short`  | `"s"`        |
| `unsigned short` | `"S"`        |
| `int`    | `"i"`        |
| `unsigned int` | `"I"`        |