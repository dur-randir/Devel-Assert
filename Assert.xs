#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

STATIC SV* enabled_sv;

STATIC OP*
assert_checker(pTHX_ OP *op, GV *namegv, SV *ckobj) {
    if (!SvTRUE_nomg(enabled_sv)) {
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

    enabled_sv = get_sv("Devel::Assert::__ASSERT_ON", GV_ADD);
}

