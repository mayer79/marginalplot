// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// findInterval_equi
IntegerVector findInterval_equi(NumericVector x, double low, double high, int nbin, bool right);
RcppExport SEXP _effectplots_findInterval_equi(SEXP xSEXP, SEXP lowSEXP, SEXP highSEXP, SEXP nbinSEXP, SEXP rightSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< double >::type low(lowSEXP);
    Rcpp::traits::input_parameter< double >::type high(highSEXP);
    Rcpp::traits::input_parameter< int >::type nbin(nbinSEXP);
    Rcpp::traits::input_parameter< bool >::type right(rightSEXP);
    rcpp_result_gen = Rcpp::wrap(findInterval_equi(x, low, high, nbin, right));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_effectplots_findInterval_equi", (DL_FUNC) &_effectplots_findInterval_equi, 5},
    {NULL, NULL, 0}
};

RcppExport void R_init_effectplots(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}