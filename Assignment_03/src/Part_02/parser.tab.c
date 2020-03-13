/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.4"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 1 "parser.y" /* yacc.c:339  */

    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    int yylex(); 
    void yyerror(const char *s);

    #define YYDEBUG 1
    #define MAX_ATTR_LIST 1024
    #define MAX_RECORD_LEN 1024
    #define MAX_COL_LIMIT 30
    #define MAX_RECORDS 30
    #define MAX_LEN 1024
    #define DB_PATH "data/"

    typedef
    struct custom_list{
        char * arr[MAX_ATTR_LIST];
        int last;
    } custom_list;
    void list_insert_string( custom_list* lst , char * str){
        // NULL check
        if(lst == NULL){
            yyerror("Inserting into NULL");
            return;
        }
        
        lst->arr[lst->last] = str;
        (lst->last)++;
        return; 
    }
    void copy_list( custom_list *list1 ,  custom_list list2){
        for(int i = 0; i < list2.last; ++i){
            list_insert_string(list1, (list2.arr)[i]);
        }
        return;
    }
    void list_show(const char * name, custom_list* lst){
        if(lst == NULL){
            yyerror("Inserting into NULL");
            return;
        }
        
        printf("%s : ", name);
        for(int i = 0; i < lst->last; ++i){
            printf("%s ", (lst->arr)[i]);
        }
        printf("\n");
        return;
    }


    typedef
    struct string_pair{
            char *first_attr;
            char* second_attr;
            char *first_tbl;
            char* second_tbl;
    } string_pair;

    typedef
    struct list_pair{
        custom_list first_attr;
        custom_list second_attr;
        custom_list first_tbl;
        custom_list second_tbl;
    } list_pair;

    char** read_record(FILE* fptr);
    bool cartesian_product(char *table_1 , char * table_2);
    bool project(custom_list * c , char * tbl);
    bool equi_join(char* table_1 , char * table_2 , list_pair * l);

#line 141 "parser.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "parser.tab.h".  */
#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    MORE = 258,
    RP = 259,
    LP = 260,
    EQUAL = 261,
    COMMA = 262,
    LESS = 263,
    LESSEQUAL = 264,
    MOREEQUAL = 265,
    NOTEQUAL = 266,
    WHITESPACE = 267,
    NUM = 268,
    QUOTE = 269,
    SEMI = 270,
    DOT = 271,
    AND = 272,
    OR = 273,
    NOT = 274,
    SELECT = 275,
    PROJECT = 276,
    CARTESIAN_PRODUCT = 277,
    EQUI_JOIN = 278,
    ID = 279
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 76 "parser.y" /* yacc.c:355  */

        char* str;
        void* attr_set;
        void* attr_pair;
        void* attr_pair_list;
       

#line 214 "parser.tab.c" /* yacc.c:355  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 231 "parser.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  10
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   64

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  25
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  13
/* YYNRULES -- Number of rules.  */
#define YYNRULES  29
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  71

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   279

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,   112,   112,   112,   116,   119,   128,   137,   145,   151,
     156,   163,   166,   171,   174,   179,   180,   184,   188,   188,
     188,   188,   188,   188,   192,   192,   192,   196,   205,   217
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "MORE", "RP", "LP", "EQUAL", "COMMA",
  "LESS", "LESSEQUAL", "MOREEQUAL", "NOTEQUAL", "WHITESPACE", "NUM",
  "QUOTE", "SEMI", "DOT", "AND", "OR", "NOT", "SELECT", "PROJECT",
  "CARTESIAN_PRODUCT", "EQUI_JOIN", "ID", "$accept", "QUERY_LIST", "QUERY",
  "TABLE", "ATTR_LIST", "SELECT_COND", "OR_NOT_COND", "NOT_COND", "COND",
  "OP", "CONST_OR_ID", "JOIN_COND", "EQUI_COND", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279
};
# endif

#define YYPACT_NINF -17

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-17)))

#define YYTABLE_NINF -1

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int8 yypact[] =
{
      -4,   -15,     2,     3,    12,     4,   -17,    10,   -11,    -2,
     -17,    -4,   -16,   -17,     5,    -9,   -17,    17,    11,     9,
     -17,    15,    23,    28,   -17,    27,    25,    20,   -17,    30,
     -11,   -11,   -17,   -17,   -17,   -17,   -17,   -17,    -9,    -2,
      31,   -15,   -15,   -17,   -15,   -17,   -17,   -17,   -17,   -15,
      33,    22,    36,    24,    38,    40,   -17,    21,    41,   -15,
     -17,   -17,    43,   -15,   -17,   -15,    46,    35,   -17,    29,
     -17
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     0,     0,     0,     0,     8,     0,     0,     0,
       1,     2,     0,    26,     0,     0,    24,     0,    11,    13,
      16,     0,     9,     0,     3,     0,     0,     0,    15,     0,
       0,     0,    20,    18,    19,    21,    22,    23,     0,     0,
       0,     0,     0,    25,     0,    12,    14,    17,    10,     0,
       0,     0,     0,    27,     0,     0,     6,     0,     0,     0,
       4,     5,     0,     0,    28,     0,     0,     0,     7,     0,
      29
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -17,    44,   -17,    -1,     8,    26,    32,   -17,    37,   -17,
      16,     0,   -17
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     4,     5,    51,    23,    17,    18,    19,    20,    38,
      21,    52,    53
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_uint8 yytable[] =
{
       7,     1,    13,    14,    13,    14,    25,    26,    15,     6,
       8,     9,    10,    16,    12,    16,     2,     3,    32,    11,
      29,    33,    22,    34,    35,    36,    37,    31,    30,    27,
      39,    40,    41,    42,    43,    44,    49,    56,    57,    58,
      50,    59,    60,    54,    61,    62,    63,    48,    55,    65,
      68,    69,    28,    70,    47,    24,    45,     0,     0,    64,
       0,     0,    66,    46,    67
};

static const yytype_int8 yycheck[] =
{
       1,     5,    13,    14,    13,    14,    22,    23,    19,    24,
       8,     8,     0,    24,     4,    24,    20,    21,     3,    15,
       3,     6,    24,     8,     9,    10,    11,    18,    17,    24,
       7,     3,     5,     8,    14,     5,     5,     4,    16,     3,
      41,    17,     4,    44,     4,    24,     5,    39,    49,     6,
       4,    16,    15,    24,    38,    11,    30,    -1,    -1,    59,
      -1,    -1,    63,    31,    65
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     5,    20,    21,    26,    27,    24,    28,     8,     8,
       0,    15,     4,    13,    14,    19,    24,    30,    31,    32,
      33,    35,    24,    29,    26,    22,    23,    24,    33,     3,
      17,    18,     3,     6,     8,     9,    10,    11,    34,     7,
       3,     5,     8,    14,     5,    30,    31,    35,    29,     5,
      28,    28,    36,    37,    28,    28,     4,    16,     3,    17,
       4,     4,    24,     5,    36,     6,    28,    28,     4,    16,
      24
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    25,    26,    26,    27,    27,    27,    27,    28,    29,
      29,    30,    30,    31,    31,    32,    32,    33,    34,    34,
      34,    34,    34,    34,    35,    35,    35,    36,    36,    37
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     2,     3,     7,     7,     7,    10,     1,     1,
       3,     1,     3,     1,     3,     2,     1,     3,     1,     1,
       1,     1,     1,     1,     1,     3,     1,     1,     3,     7
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 4:
#line 116 "parser.y" /* yacc.c:1646  */
    {
        }
#line 1346 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 119 "parser.y" /* yacc.c:1646  */
    {
           if(!project((custom_list *)(yyvsp[-4].attr_set) , (yyvsp[-1].str))){
               yyerror("unsuccesful project");
           }

           free((yyvsp[-1].str));
           free((yyvsp[-4].attr_set));
        }
#line 1359 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 128 "parser.y" /* yacc.c:1646  */
    {
           if(!cartesian_product((yyvsp[-5].str) , (yyvsp[-1].str))){
               yyerror("unsuccesful cartesian_product\n");
           }

           free((yyvsp[-5].str));
           free((yyvsp[-1].str));
        }
#line 1372 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 137 "parser.y" /* yacc.c:1646  */
    {
            if(!equi_join((yyvsp[-8].str) , (yyvsp[-1].str), (list_pair *) (yyvsp[-4].attr_pair_list))){
                yyerror("unsuccesful equi_join operation\n");
            }
         }
#line 1382 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 145 "parser.y" /* yacc.c:1646  */
    {
        (yyval.str) = (yyvsp[0].str);
    }
#line 1390 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 151 "parser.y" /* yacc.c:1646  */
    {
                custom_list * l_ptr = (custom_list *)malloc(sizeof(custom_list));
                list_insert_string(l_ptr, (yyvsp[0].str));
                (yyval.attr_set) = (void *)(l_ptr);
            }
#line 1400 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 10:
#line 156 "parser.y" /* yacc.c:1646  */
    {
            list_insert_string((custom_list *) (yyvsp[0].attr_set), (yyvsp[-2].str));
            (yyval.attr_set) = (yyvsp[0].attr_set);
          }
#line 1409 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 11:
#line 163 "parser.y" /* yacc.c:1646  */
    {
              }
#line 1416 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 166 "parser.y" /* yacc.c:1646  */
    {
              }
#line 1423 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 171 "parser.y" /* yacc.c:1646  */
    {
              }
#line 1430 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 174 "parser.y" /* yacc.c:1646  */
    {
              }
#line 1437 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 196 "parser.y" /* yacc.c:1646  */
    {
                    list_pair *l = (list_pair *)malloc(sizeof(list_pair));
                    string_pair* equi_c = (string_pair *) (yyvsp[0].attr_pair);
                    list_insert_string(&(l->first_attr) ,  equi_c->first_attr);
                    list_insert_string(&(l->second_attr) , equi_c->second_attr);
                    list_insert_string(&(l->first_tbl) ,  equi_c->first_tbl);
                    list_insert_string(&(l->second_tbl) , equi_c->second_tbl);
                    (yyval.attr_pair_list) = (void *) l;
            }
#line 1451 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 205 "parser.y" /* yacc.c:1646  */
    {
                    list_pair *l = (list_pair *) (yyvsp[0].attr_pair_list);
                    string_pair* equi_c = (string_pair *) (yyvsp[-2].attr_pair);
                    list_insert_string(&(l->first_attr) ,  equi_c->first_attr);
                    list_insert_string(&(l->second_attr) , equi_c->second_attr);
                    list_insert_string(&(l->first_tbl) ,  equi_c->first_tbl);
                    list_insert_string(&(l->second_tbl) , equi_c->second_tbl);
                    (yyval.attr_pair_list) = (void *)l;
             }
#line 1465 "parser.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 217 "parser.y" /* yacc.c:1646  */
    {
                  string_pair *s = (string_pair*) malloc(sizeof(string_pair));
                  s->first_attr = (yyvsp[-4].str);
                  s->second_attr = (yyvsp[0].str);
                  s->first_tbl = (yyvsp[-6].str);
                  s->second_tbl = (yyvsp[-2].str);
                  (yyval.attr_pair) = (void *) s;
            }
#line 1478 "parser.tab.c" /* yacc.c:1646  */
    break;


#line 1482 "parser.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 228 "parser.y" /* yacc.c:1906  */

void print_record(char** record)
{
    char * val;
    int index = 0;
    while((val = record[index++]) != NULL){
        printf(":%s:", val);
    }
    printf("\n");
    return;
}

int main(void){
    // FILE *fptr = fopen("data/t1.csv" , "r");
    // char ** record;
    // while((record = read_record(fptr))){
    
    // }
    // //yydebug = 1;
    return yyparse();
}
void yyerror(const char *s){
    fprintf(stderr, "%s", s);
    exit(1);
}

char* is_valid_table(char* table)
{
    char* path1 = (char*) malloc(sizeof(char)*MAX_LEN);
    strcpy(path1,DB_PATH);
    strcat(path1,table);
    strcat(path1,".csv");
    FILE *fptr1 = fopen(path1,"r");
    if(fptr1 == NULL) {
        char error_string[MAX_LEN] = {'\0'};
        strcpy(error_string,path1);
        strcat(error_string," does not exist\n");
        yyerror(error_string);
        return NULL;
    }
    return path1;
}

char** read_record(FILE* fptr){
    char buff[MAX_RECORD_LEN + 1] = {'\0'};
    if(fgets(buff , MAX_RECORD_LEN , fptr)){
        buff[strlen(buff)-1]='\0';
        char ** output_str = malloc(sizeof(char *) * MAX_COL_LIMIT);
        const char delim[2] = ",";
        char *token = strtok(buff, delim);
        int index = 0;
        while( token != NULL ) {
            char *token_str = (char *)malloc(sizeof(char) * MAX_LEN);
            strcpy(token_str , token);
            output_str[index++] = token_str;
            token = strtok(NULL, delim);
        }
        return output_str;
    } else NULL;
}
char** merge_arrays(char** array1 , char** array2){
        char ** output_str = malloc(sizeof(char *) * MAX_COL_LIMIT);
        char * val;
        int index = 0;
        int out = 0;
        while((val = array1[index++]) != NULL){
            output_str[out++] = val;
        }
        index = 0;
        while((val = array2[index++]) != NULL){
            output_str[out++] = val;
        }
        return output_str;
}

char* coma_separated_string(char ** arr){
    char * output_str = (char *) malloc(sizeof(char) * MAX_COL_LIMIT * MAX_LEN);
    int flag = 0;
    char* val;
    int index = 0;
    while((val = arr[index++]) != NULL){
            flag = 1;
            strcat(output_str , val);
            strcat(output_str , ",");
    }
    if(flag) output_str[strlen(output_str) - 1] = '\0';
    return output_str;
        
}

char*** read_all_records(FILE* fptr)
{
    char*** output = (char***) malloc(sizeof(char**) * MAX_RECORDS);
    char ** record;
    int index = 0;
    while((record = read_record(fptr))){
        output[index++] = record;
    }
    return output;
}

bool cartesian_product(char *table_1 , char * table_2){
    printf("TABLE_1 = %s, TABLE_2 = %s\n", table_1, table_2);
    
    // Check tables exist
    char* path1 = is_valid_table(table_1);
    char* path2 = is_valid_table(table_2);
    if(path1 == NULL || path2 == NULL) return false;
    
    // Open files
    FILE* fptr1 = fopen(path1,"r");
    FILE* fptr2 = fopen(path2,"r");
    char output_path[MAX_LEN] = {'\0'};
    strcpy(output_path,table_1);
    strcat(output_path,"_");
    strcat(output_path,table_2);
    strcat(output_path,"_cart.csv");
    FILE* output = fopen(output_path,"w");
    
    // Write column names
    char** column_list1 = read_record(fptr1);
    char** column_list2 = read_record(fptr2);
    char** all_columns = merge_arrays(column_list1,column_list2);
    fprintf(output,"%s\n",coma_separated_string(all_columns));
    
    // Read table 2 into memory
    char *** file2 = read_all_records(fptr2);
    
    // Print into output file
    char ** record1;
    while((record1 = read_record(fptr1))){
        char ** record2;
        int index = 0;
        while((record2 = file2[index++])){
          char** merged_record = merge_arrays(record1,record2);
          fprintf(output,"%s\n",coma_separated_string(merged_record));    
        }
    }

    // Close files
    fclose(fptr1);
    fclose(fptr2);
    fclose(output);

    printf("cartesian_product succesful\n");
    return true;
}

bool project(custom_list * c , char * tbl){
    if(c->last == 0) return true;
    char* path = is_valid_table(tbl);
    if(path == NULL) return false;
    int indexes[c->last + 1];
    for(int i = 0; i < c->last; ++i){
        indexes[i] = -1;
    }
    FILE* fptr = fopen(path,"r");
    char output_path[MAX_LEN];
    strcpy(output_path,tbl);
    strcat(output_path,"_proj.csv");
    FILE* output = fopen(output_path,"w");
    char ** column_list = read_record(fptr);
    for(int i = c->last-1; i >=0 ; i--){
        int index = 0;
        char * val;
        while((val = column_list[index++])){
            if(strcmp(val , (c->arr)[i]) == 0){
                indexes[i] = index - 1;
            }
        }
        if(indexes[i] == -1){
            char error_string[MAX_LEN];
            strcpy(error_string,(c->arr)[i]);
            strcat(error_string," not found in ");
            strcat(error_string,tbl);
            yyerror(error_string);
            return false;
        }
    }
    char** record;
    for(int i = c->last-1;i>0;i--)
    {
        fprintf(output,"%s,",(c->arr)[i]);
    }
    fprintf(output,"%s\n",(c->arr)[0]);
    while(record = read_record(fptr))
    {
        int index = 0;
        char newRecord[MAX_COL_LIMIT * MAX_LEN] = {'\0'};
        for(index = c->last-1;index >=0;index--){
            strcat(newRecord,record[indexes[index]]);
            strcat(newRecord,",");

        }
        if(c->last > 0) newRecord[strlen(newRecord) - 1] = '\n';
        fprintf(output,"%s",newRecord);
    }
    fclose(fptr);
    fclose(output);

    printf("project succesful\n");
    return true;
}

bool equi_join(char* table_1 , char * table_2 , list_pair * l){
    char* path1 = is_valid_table(table_1);
    char* path2 = is_valid_table(table_2);
    if(path1 == NULL ||  path2 == NULL) return false;
    //first_tbl.first_attr
    for(int i = 0; i < (l->first_tbl).last; i++){ 
        char table_name1[MAX_LEN];
        char table_name2[MAX_LEN];
        strcpy(table_name1,(l->first_tbl).arr[i]);
        strcpy(table_name2,(l->second_tbl).arr[i]);
        if( (strcmp(table_name1, table_1) != 0 && strcmp(table_name1, table_2) != 0)
            || (strcmp(table_name2 , table_1) != 0 && strcmp(table_name2 , table_2) != 0)
        ) 
        { 
            yyerror("attribute list is not correct\n");
            return false;
        }
    }
    FILE* fptr1 = fopen(path1,"r");
    FILE* fptr2 = fopen(path2,"r");
    char ** column_list1 = read_record(fptr1);
    char ** column_list2 = read_record(fptr2);
    int indexes1[l->first_attr.last + 1][2];
    int indexes2[l->second_attr.last + 1][2];
    //indexes[][0] = index
    //indexes[][1] = table_id i.e 1 or 2
    for(int i = 0; i<l->first_attr.last;i++)
    {
        indexes1[i][0] = -1;
    }
    for(int i = 0; i<l->second_attr.last;i++)
    {
        indexes2[i][0] = -1;
    }
    for(int i = 0;i < (l->first_attr).last;i++)
    {
        char table_name1[MAX_LEN];
        strcpy(table_name1,(l->first_tbl).arr[i]);
        // printf("table_name1 : %s table_1 : %s\n",table_name1,table_1);
        if(strcmp(table_name1,table_1) == 0)
        {
            int index = 0;
            char* val;
            while(val = column_list1[index++])
            {
                // printf("column_list1[index] : %s; and first_attr[i] : %s;\n",val,(l->first_attr).arr[i]);
                if(strcmp(val,(l->first_attr).arr[i]) == 0) {
                    // printf("index : %d\n", index-1);
                    indexes1[i][0] = index - 1;
                    indexes1[i][1] = 1;
                }
            }
            // printf("indexes1[i] : %d and i : %d\n",indexes1[i],i);
            if(indexes1[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->first_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_1);
                yyerror(error_string);
                return false;
            }
        }
        else{
            int index = 0;
            char* val;
            while(val = column_list2[index++])
            {
                // printf("column_list2[index] : %s; and first_attr[i] : %s;\n",val,(l->first_attr).arr[i]);
                if(strcmp(val,(l->first_attr).arr[i]) == 0) indexes1[i][0] = index - 1;
                indexes1[i][1] = 2;
            }
            if(indexes1[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->first_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_2);
                yyerror(error_string);
                return false;
            }
        }
    }
    for(int i = 0;i < (l->second_attr).last;i++)
    {
        char table_name1[MAX_LEN];
        strcpy(table_name1,(l->second_attr).arr[i]);
        // printf("table_name1 : %s table_1 : %s\n",table_name1,table_1);
        if(strcmp(table_name1,table_1) == 0)
        {
            int index = 0;
            char* val;
            while(val = column_list1[index++])
            {
                // printf("column_list1[index] : %s; and second_attr[i] : %s;\n",val,(l->second_attr).arr[i]);
                if(strcmp(val,(l->second_attr).arr[i]) == 0) {
                    // printf("inside strcmp\n");
                    // printf("index : %d\n", index-1);
                    indexes2[i][0] = index - 1;
                    indexes2[i][1] = 1;
                }
            }
            if(indexes2[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->second_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_1);
                yyerror(error_string);
                return false;
            }
        }
        else{
            int index = 0;
            char* val;
            while(val = column_list2[index++])
            {
                // printf("column_list2[index] : %s; and second_attr[i] : %s;\n",val,(l->second_attr).arr[i]);
                if(strcmp(val,(l->second_attr).arr[i]) == 0) indexes2[i][0] = index - 1;
                indexes2[i][1] = 2;

            }
            if(indexes2[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->second_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_2);
                yyerror(error_string);
                return false;
            }
        }
    }
    // for(int i = 0;i<l->first_attr.last;i++)
    // {
    //     // printf("index : %d and indexes for first attr[0] : %d\n",i,indexes1[i][0]);
    // } for(int i = 0;i<l->second_attr.last;i++)
    // {
    //     // printf("index : %d and indexes for second attr[0] : %d\n",i,indexes2[i][0]);
    // }
    char output_file[MAX_LEN];
    strcpy(output_file,table_1);
    strcat(output_file,"_");
    strcat(output_file,table_2);
    strcat(output_file,"_equi_join.csv");
    FILE* output = fopen(output_file,"w");
    char ** record1 , **record2;
    fprintf(output,"%s,%s\n",coma_separated_string(column_list1),coma_separated_string(column_list2));
    char*** file2 = read_all_records(fptr2);
    while(record1 = read_record(fptr1)){
        int idx = 0;
        while(record2 = file2[idx++]){
            // printf("record1 : %s\n record2 : %s\n",coma_separated_string(record1),coma_separated_string(record2));


            bool result = true;
            for(int i = 0 ; i < (l->first_attr.last) ; i++){
                char * left_val, *right_val;
                if(indexes1[i][1] == 1){
                    left_val = record1[indexes1[i][0]];
                    right_val = record2[indexes2[i][0]];
                }else{
                    left_val = record2[indexes1[i][0]];
                    right_val = record1[indexes2[i][0]];
                }
                // printf("leftval : %s and rightval : %s\n",left_val,right_val);
                if(strcmp(left_val, right_val) != 0){
                    result = false;
                    break;
                }
            }
            if(result){
                fprintf(output,"%s,%s\n",coma_separated_string(record1),coma_separated_string(record2));
            }
        }
        
    }
    printf("equi_join succesful\n");
    return true;
}
