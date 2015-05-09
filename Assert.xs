#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

STATIC OP*
assert_checker(pTHX_ OP *op, GV *namegv, SV *ckobj) {
    op_free(op);
    return newOP(OP_NULL, 0);
}

STATIC CV*
find_context_cv(pTHX) {
    for (PERL_CONTEXT* cx = cxstack + cxstack_ix; cx >= cxstack; --cx) {
        if (CxTYPE(cx) == CXt_SUB || CxTYPE(cx) == CXt_FORMAT)  return cx->blk_sub.cv;
        if (CxTYPE(cx) == CXt_EVAL && cx->blk_eval.cv)          return cx->blk_eval.cv;
    }

    return PL_main_cv;
}

MODULE = Devel::Assert      PACKAGE = Devel::Assert
PROTOTYPES: DISABLE

BOOT:
{
    CV* assert_cv = get_cv("Devel::Assert::assert_off", 0);
    cv_set_call_checker(assert_cv, assert_checker, (SV*)assert_cv);
}

void
assert_on(...)
PPCODE:
{
    if (items != 1) croak("Wrong number of arguments in assert() call");
    if (SvTRUE(ST(0))) XSRETURN_UNDEF;

    PUSHMARK(SP);
    EXTEND(SP, 3);

    /* B.xs declares 'make_*_object' as static, so had to borrow it */
#define push_b_object(type, ptr) STMT_START {   \
    SV* tmpsv = sv_newmortal();                 \
    sv_setiv(newSVrv(tmpsv, type), PTR2IV(ptr));\
    PUSHs(tmpsv);                               \
} STMT_END

    OP* op = ((UNOP*)PL_op)->op_first;
    if (!op->op_sibling || op->op_sibling->op_type == OP_NULL) op = ((UNOP*)op)->op_first;
    push_b_object("B::UNOP", op);

    push_b_object("B::COP", PL_curcop);
    push_b_object("B::CV", find_context_cv(aTHX));

    PUTBACK;
    call_sv((SV*)get_cv("Devel::Assert::assert_fail", 0), G_VOID);
    SPAGAIN;

    XSRETURN_UNDEF;
}

