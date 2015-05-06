#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

STATIC OP*
assert_checker(pTHX_ OP *op, GV *namegv, SV *ckobj) {
    op_free(op);
    return newOP(OP_NULL, 0);
}

MODULE = Devel::Assert      PACKAGE = Devel::Assert
PROTOTYPES: DISABLE

BOOT:
{
    CV* assert_cv = get_cv("Devel::Assert::assert_off", 0);
    cv_set_call_checker(assert_cv, assert_checker, (SV*)assert_cv);
}

