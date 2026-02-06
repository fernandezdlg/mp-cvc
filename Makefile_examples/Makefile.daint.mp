# ##########
work=/project/s1197/mpetschl/software
srcdir=..

limedir=$(work)/LIME/build-gcc

lemondir=$(work)/LEMON/build-gcc

fftwdir=$(work)/FFTW/build-gcc

lhpcdir=$(work)/AFF/build-gcc

tmLQCD_src=$(work)/TMLQCD/tmLQCD

tmLQCDdir=$(work)/TMLQCD/build-gcc-dev-mp/

tmLQCD_libs= -lwrapper -lhmc -lmonomial -loperator -lsolver -linit -lmeas -llinalg -lhmc -lxchange -lrational -lio -lsmear -lbuffers

qudadir=$(work)/QUDA/build-gcc-dev-mp/

cudadir=/opt/nvidia/cudatoolkit10.2/10.2.89_3.28-2.1__g52c0314

# hdf5dir=/opt/cray/pe/hdf5/1.12.0.0/GNU/8.2
hdf5dir=/opt/cray/pe/hdf5-parallel/1.12.0.4/GNU/8.2

kqeddir=$(work)/KQED/build/


defines= -DF_ -DHAVE_MPI -DPARALLELTXYZ -DHAVE_LIBLEMON -DHAVE_LHPC_AFF -DHAVE_TMLQCD_LIBWRAPPER -DTM_USE_MPI -DHAVE_OPENMP -DHAVE_HDF5 -DTM_USE_QUDA -DGPU_DIRECT_SOLVER -D_SMEAR_QUDA -DHAVE_KQED

CXX=CC -fopenmp
CXXFLAGS= -pedantic -Wall -g -O3 -mavx -mfma  $(defines) -D_CHARGED_LVC_LVC_TENSOR=1 -D_NEUTRAL_LVC_LVC_TENSOR=0 -D_NEUTRAL_CVC_LVC_TENSOR=0 

CCDEP = g++ $(defines)
DEPFLAGS = -MM

INCLUDE = -I$(lemondir)/include/ -I$(limedir)/include/ -I$(srcdir) -I$(fftwdir)/include -I. -I$(lhpcdir)/include -I$(tmLQCDdir)/include -I$(hdf5dir)/include -I$(kqeddir)/include

LIBS = -L$(kqeddir)/lib -L$(qudadir)/lib -L$(hdf5dir)/lib -L$(lhpcdir)/lib  -L$(lemondir)/lib/  -L$(limedir)/lib/ -L$(fftwdir)/lib -lfftw_mpi -lfftw  -L$(tmLQCDdir)/lib/ $(tmLQCD_libs) -lquda -lcublas -lcuda -llemon -llime  -llhpc-aff -lhdf5_parallel -lhdf5 -lm -lKQED

LDFLAGS = -L$(kqeddir)/lib -L$(qudadir)/lib -L$(hdf5dir)/lib -L$(lemondir)/lib/ -L$(limedir)/lib/ -L$(fftwdir)/lib -lfftw_mpi -lfftw -L$(tmLQCDdir)/lib/ $(tmLQCD_libs) -lquda -lcublas -lcuda -llemon -llime -llhpc-aff -lhdf5_parallel -lhdf5 -lm -ldl -lKQED


LINK = $(CXX) -o $@ ${LDFLAGS}
COMPILE = ${CXX} $(INCLUDE) -o $@ ${CXXFLAGS}

MODULES = DML_crc32 dml getopt cvc_utils cvc_geometry mpi_init io io_utils propagator_io read_input_parser_cvc \
          get_index gauge_io contractions_io ranlxd ranlxs Q_phi set_default \
          Q_clover_phi prepare_source matrix_init project make_x_orbits smearing_techniques clover \
          prepare_propagator scalar_products  contract_cvc_tensor gamma rotations  \
          gitversion contract_cvc_tensor_eo_lm_factors vdag_w_utils dummy_solver contract_factorized \
	  contract_loop uwerr incomp_gamma

HEADERS = getopt cvc_complex cvc_geometry cvc_linalg iblas icontract cvc_utils default_input_values dml global io io_utils \
          mpi_init propagator_io read_input_parser get_index gauge_io contractions_io \
          ranlxd ranlxs Q_phi set_default laplace_linalg Q_clover_phi \
          prepare_source matrix_init project make_x_orbits smearing_techniques clover \
          prepare_propagator scalar_products contract_cvc_tensor gamma gamma_mult_table rotations \
          table_init_d table_init_z contract_cvc_tensor_eo_lm_factors vdag_w_utils dummy_solver contract_factorized \
	  contract_loop uwerr incomp_gamma


PROGRAM = avgx_invert_contract kaon2pt_invert_contract kaon2pt_simple_invert_contract p2gg_local p2gg_invert_contract_local \
	  eta_invert_contract loop_invert_contract hlbl_mII_invert_contract


all: dep $(PROGRAM) 


# ##########

read_input_parser_cvc.cpp: ${srcdir}/read_input_parser_cvc.l
	${LEX} -P cvc_ -i -t $< > ${srcdir}/read_input_parser_cvc.cpp

$(addsuffix .d,$(MODULES)): %.d: ${srcdir}/%.cpp
	 @ $(CCDEP) ${DEPFLAGS} ${INCLUDE} $< > $@

$(addsuffix .d,$(PROGRAM)): %.d: ${srcdir}/%.cpp
	 @ $(CCDEP) ${DEPFLAGS} ${INCLUDE} $< > $@

dep: $(addsuffix .d,$(MODULES) ${PROGRAM})

$(addsuffix .o,${MODULES}): %.o: ${srcdir}/%.cpp $(addprefix ${srcdir}/, $(addsuffix .h, ${HEADERS})) %.d
	${COMPILE} ${OPTARGS} -c $< 

$(addsuffix .o,${PROGRAM}): %.o: ${srcdir}/%.cpp %.d
	${COMPILE} ${OPTARGS} -c $< 

${PROGRAM}: %: %.o gitversion.cpp $(addsuffix .o,${MODULES})
	${LINK}  $(addsuffix .o,${MODULES}) $@.o $(LIBS)

gitversion.cpp: ${srcdir}/.git/HEAD ${srcdir}/.git/index
	echo "namespace cvc { const char *g_gitversion = \"$(shell cd ${srcdir} && git rev-parse HEAD && cd -)\"; }" > ${srcdir}/gitversion.cpp

# ##########


clean:
	rm -f *~ *.o *.d $(PROGRAM) ${srcdir}/gitversion.cpp

.PHONY: clean

# ##########
