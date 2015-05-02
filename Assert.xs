#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define MY_CXT_KEY "Devel::Assert::_guts" XS_VERSION
typedef struct {
    SV* enabled_sv;
} my_cxt_t;

START_MY_CXT;

STATIC OP*
assert_checker(pTHX_ OP *op, GV *namegv, SV *ckobj) {
    dMY_CXT;
    if (!SvTRUE_nomg(MY_CXT.enabled_sv)) {
        op_free(op);
        return newOP(OP_NULL, 0);
    }

    return op;
}

MODULE = Devel::Assert      PACKAGE = Devel::Assert
PROTOTYPES: DISABLE

BOOT:
{
    CV* assert_cv = get_cv("Devel::Assert::assert", 0);
    cv_set_call_checker(assert_cv, assert_checker, (SV*)assert_cv);

    MY_CXT_INIT;
    MY_CXT.enabled_sv = get_sv("Devel::Assert::__ASSERT_ON", GV_ADD);
}

#ifdef MULTIPLICITY

void
CLONE(...)
CODE:
    MY_CXT_CLONE;
    MY_CXT.enabled_sv = get_sv("Devel::Assert::__ASSERT_ON", GV_ADD);

#endif

