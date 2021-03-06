!  
!   
!                             MLD2P4  version 2.1
!    MultiLevel Domain Decomposition Parallel Preconditioners Package
!               based on PSBLAS (Parallel Sparse BLAS version 3.5)
!    
!    (C) Copyright 2008, 2010, 2012, 2015, 2017 
!  
!        Salvatore Filippone    Cranfield University, UK
!        Pasqua D'Ambra         IAC-CNR, Naples, IT
!        Daniela di Serafino    University of Campania "L. Vanvitelli", Caserta, IT
!   
!    Redistribution and use in source and binary forms, with or without
!    modification, are permitted provided that the following conditions
!    are met:
!      1. Redistributions of source code must retain the above copyright
!         notice, this list of conditions and the following disclaimer.
!      2. Redistributions in binary form must reproduce the above copyright
!         notice, this list of conditions, and the following disclaimer in the
!         documentation and/or other materials provided with the distribution.
!      3. The name of the MLD2P4 group or the names of its contributors may
!         not be used to endorse or promote products derived from this
!         software without specific written permission.
!   
!    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!    TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!    PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE MLD2P4 GROUP OR ITS CONTRIBUTORS
!    BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!    POSSIBILITY OF SUCH DAMAGE.
!   
!  
! File: mld_base_prec_type.F90
!
! Module: mld_base_prec_type
!
!  Constants and utilities in common to all type variants of MLD preconditioners.
!  - integer constants defining the preconditioner;
!  - character constants describing the preconditioner (used by the routines
!    printing out a preconditioner description);
!  - the interfaces to the routines for the management of the preconditioner
!    data structure (see below);
!  - The data type encapsulating the parameters defining the ML preconditioner
!  - The data type encapsulating the basic aggregation map.
!
!  It contains routines for
!  - converting character constants defining the preconditioner into integer
!    constants; 
!  - checking if the preconditioner is correctly defined;
!  - printing a	description of the preconditioner;
!  - deallocating the preconditioner data structure.  
!

module mld_base_prec_type

  !
  ! This reduces the size of .mod file. Without the ONLY clause compilation 
  ! blows up on some systems.
  !
  use psb_const_mod
  use psb_base_mod, only :&
       & psb_desc_type, psb_i_vect_type, psb_i_base_vect_type,&
       & psb_ipk_, psb_dpk_, psb_spk_, psb_long_int_k_,  &
       & psb_cdfree, psb_halo_, psb_none_, psb_sum_, psb_avg_, &
       & psb_nohalo_, psb_square_root_, psb_toupper, psb_root_,&
       & psb_sizeof_int, psb_sizeof_long_int, psb_sizeof_sp, &
       & psb_sizeof_dp, psb_sizeof,&
       & psb_cd_get_context, psb_info, psb_min, psb_sum, psb_bcast,&
       & psb_sizeof, psb_free, psb_cdfree, &
       & psb_errpush, psb_act_abort_, psb_act_ret_,&
       & psb_erractionsave, psb_erractionrestore, psb_error, psb_get_errstatus, &
       & psb_get_erraction, psb_success_, psb_err_alloc_dealloc_,&
       & psb_err_from_subroutine_, psb_err_missing_override_method_, &
       & psb_error_handler, psb_out_unit, psb_err_unit

  ! 
  ! Version numbers
  !
  character(len=*), parameter   :: mld_version_string_ = "2.1.0"
  integer(psb_ipk_), parameter  :: mld_version_major_  = 2
  integer(psb_ipk_), parameter  :: mld_version_minor_  = 1
  integer(psb_ipk_), parameter  :: mld_patchlevel_     = 0

  type mld_ml_parms
    integer(psb_ipk_) :: sweeps_pre, sweeps_post
    integer(psb_ipk_) :: ml_cycle
    integer(psb_ipk_) :: aggr_type, par_aggr_alg
    integer(psb_ipk_) :: aggr_ord, aggr_prol
    integer(psb_ipk_) :: aggr_omega_alg, aggr_eig, aggr_filter
    integer(psb_ipk_) :: coarse_mat, coarse_solve
  contains
    procedure, pass(pm) :: get_coarse  => ml_parms_get_coarse
    procedure, pass(pm) :: clone       => ml_parms_clone
    procedure, pass(pm) :: descr       => ml_parms_descr
    procedure, pass(pm) :: mldescr     => ml_parms_mldescr
    procedure, pass(pm) :: coarsedescr => ml_parms_coarsedescr
    procedure, pass(pm) :: printout    => ml_parms_printout
  end type mld_ml_parms


  type, extends(mld_ml_parms) :: mld_sml_parms
    real(psb_spk_) :: aggr_omega_val,  aggr_thresh
  contains
    procedure, pass(pm) :: clone => s_ml_parms_clone
    procedure, pass(pm) :: descr => s_ml_parms_descr
    procedure, pass(pm) :: printout => s_ml_parms_printout
  end type mld_sml_parms

  type, extends(mld_ml_parms) :: mld_dml_parms
    real(psb_dpk_) :: aggr_omega_val,  aggr_thresh
  contains
    procedure, pass(pm) :: clone => d_ml_parms_clone
    procedure, pass(pm) :: descr => d_ml_parms_descr
    procedure, pass(pm) :: printout => d_ml_parms_printout
  end type mld_dml_parms


  !
  ! Entries in iprcparm
  !
  ! These are in baseprec
  ! 
  integer(psb_ipk_), parameter :: mld_smoother_type_   =  1         
  integer(psb_ipk_), parameter :: mld_sub_solve_       =  2
  integer(psb_ipk_), parameter :: mld_sub_restr_       =  3
  integer(psb_ipk_), parameter :: mld_sub_prol_        =  4
  integer(psb_ipk_), parameter :: mld_sub_ovr_         =  6
  integer(psb_ipk_), parameter :: mld_sub_fillin_      =  7
  integer(psb_ipk_), parameter :: mld_ilu_scale_       =  8

  !
  ! These are in onelev
  ! 
  integer(psb_ipk_), parameter :: mld_ml_cycle_             = 20
  integer(psb_ipk_), parameter :: mld_smoother_sweeps_pre_  = 21
  integer(psb_ipk_), parameter :: mld_smoother_sweeps_post_ = 22
  integer(psb_ipk_), parameter :: mld_aggr_type_            = 23
  integer(psb_ipk_), parameter :: mld_aggr_prol_            = 24
  integer(psb_ipk_), parameter :: mld_par_aggr_alg_         = 25
  integer(psb_ipk_), parameter :: mld_aggr_ord_             = 26
  integer(psb_ipk_), parameter :: mld_aggr_omega_alg_       = 27
  integer(psb_ipk_), parameter :: mld_aggr_eig_             = 28
  integer(psb_ipk_), parameter :: mld_aggr_filter_          = 29
  integer(psb_ipk_), parameter :: mld_coarse_mat_           = 30
  integer(psb_ipk_), parameter :: mld_coarse_solve_         = 31 
  integer(psb_ipk_), parameter :: mld_coarse_sweeps_        = 32
  integer(psb_ipk_), parameter :: mld_coarse_fillin_        = 33
  integer(psb_ipk_), parameter :: mld_coarse_subsolve_      = 34
  integer(psb_ipk_), parameter :: mld_smoother_sweeps_      = 36
  integer(psb_ipk_), parameter :: mld_solver_sweeps_        = 37
  integer(psb_ipk_), parameter :: mld_min_coarse_size_      = 38
  integer(psb_ipk_), parameter :: mld_n_prec_levs_          = 39
  integer(psb_ipk_), parameter :: mld_max_levs_             = 40
  integer(psb_ipk_), parameter :: mld_min_cr_ratio_         = 41
  integer(psb_ipk_), parameter :: mld_outer_sweeps_         = 42
  integer(psb_ipk_), parameter :: mld_ifpsz_                = 43

  !
  ! Legal values for entry: mld_smoother_type_
  ! 
  integer(psb_ipk_), parameter :: mld_min_prec_ = 0
  integer(psb_ipk_), parameter :: mld_noprec_   = 0
  integer(psb_ipk_), parameter :: mld_base_smooth_ = 0
  integer(psb_ipk_), parameter :: mld_jac_      = 1
  integer(psb_ipk_), parameter :: mld_bjac_     = 2
  integer(psb_ipk_), parameter :: mld_as_       = 3
  integer(psb_ipk_), parameter :: mld_max_prec_ = 3
  integer(psb_ipk_), parameter :: mld_fbgs_     = 4
  !
  ! Constants for pre/post signaling. Now only used internally
  !
  integer(psb_ipk_), parameter :: mld_smooth_pre_     = 1
  integer(psb_ipk_), parameter :: mld_smooth_post_    = 2
  integer(psb_ipk_), parameter :: mld_smooth_both_    = 3

  !
  !  This is a quick&dirty fix, but I have nothing better now...
  !
  ! Legal values for entry: mld_sub_solve_
  !
  integer(psb_ipk_), parameter :: mld_slv_delta_     = mld_max_prec_+1
  integer(psb_ipk_), parameter :: mld_f_none_        = mld_slv_delta_+0
  integer(psb_ipk_), parameter :: mld_diag_scale_    = mld_slv_delta_+1
  integer(psb_ipk_), parameter :: mld_gs_            = mld_slv_delta_+2
  integer(psb_ipk_), parameter :: mld_ilu_n_         = mld_slv_delta_+3
  integer(psb_ipk_), parameter :: mld_milu_n_        = mld_slv_delta_+4
  integer(psb_ipk_), parameter :: mld_ilu_t_         = mld_slv_delta_+5
  integer(psb_ipk_), parameter :: mld_slu_           = mld_slv_delta_+6
  integer(psb_ipk_), parameter :: mld_umf_           = mld_slv_delta_+7
  integer(psb_ipk_), parameter :: mld_sludist_       = mld_slv_delta_+8
  integer(psb_ipk_), parameter :: mld_mumps_         = mld_slv_delta_+9
  integer(psb_ipk_), parameter :: mld_bwgs_          = mld_slv_delta_+10
  integer(psb_ipk_), parameter :: mld_max_sub_solve_ = mld_slv_delta_+10
  integer(psb_ipk_), parameter :: mld_min_sub_solve_ = mld_diag_scale_

  !
  ! Legal values for entry: mld_ilu_scale_
  !
  integer(psb_ipk_), parameter :: mld_ilu_scale_none_    = 0
  integer(psb_ipk_), parameter :: mld_ilu_scale_maxval_  = 1
  integer(psb_ipk_), parameter :: mld_ilu_scale_diag_    = 2
  integer(psb_ipk_), parameter :: mld_ilu_scale_arwsum_  = 3 
  integer(psb_ipk_), parameter :: mld_ilu_scale_aclsum_  = 4
  integer(psb_ipk_), parameter :: mld_ilu_scale_arcsum_  = 5
  ! For the time being enable only maxval scale
  integer(psb_ipk_), parameter :: mld_max_ilu_scale_     = 1
  !
  ! Legal values for entry: mld_ml_cycle_
  !
  integer(psb_ipk_), parameter :: mld_no_ml_        = 0
  integer(psb_ipk_), parameter :: mld_add_ml_       = 1
  integer(psb_ipk_), parameter :: mld_mult_ml_      = 2
  integer(psb_ipk_), parameter :: mld_vcycle_ml_    = 3
  integer(psb_ipk_), parameter :: mld_wcycle_ml_    = 4
  integer(psb_ipk_), parameter :: mld_kcycle_ml_    = 5
  integer(psb_ipk_), parameter :: mld_kcyclesym_ml_ = 6
  integer(psb_ipk_), parameter :: mld_new_ml_prec_  = 7
  integer(psb_ipk_), parameter :: mld_mult_dev_ml_  = 7
  integer(psb_ipk_), parameter :: mld_max_ml_cycle_  = 8
  !
  ! Legal values for entry: mld_aggr_type_
  !
  integer(psb_ipk_), parameter :: mld_noalg_       = 0
  integer(psb_ipk_), parameter :: mld_vmb_         = 1
  !
  ! Legal values for entry: mld_aggr_prol_
  !
  integer(psb_ipk_), parameter :: mld_no_smooth_   = 0
  integer(psb_ipk_), parameter :: mld_smooth_prol_ = 1
  integer(psb_ipk_), parameter :: mld_min_energy_  = 2
  integer(psb_ipk_), parameter :: mld_biz_prol_    = 3
  ! Disabling biz_prol for the time being.
  integer(psb_ipk_), parameter :: mld_max_aggr_prol_=mld_min_energy_
  !
  ! Legal values for entry: mld_aggr_filter_
  !
  integer(psb_ipk_), parameter :: mld_no_filter_mat_  = 0
  integer(psb_ipk_), parameter :: mld_filter_mat_     = 1
  integer(psb_ipk_), parameter :: mld_max_filter_mat_ = mld_filter_mat_
  !  
  ! Legal values for entry: mld_par_aggr_alg_
  !
  integer(psb_ipk_), parameter :: mld_dec_aggr_      = 0
  integer(psb_ipk_), parameter :: mld_sym_dec_aggr_  = 1
  integer(psb_ipk_), parameter :: mld_ext_aggr_      = 2 
  integer(psb_ipk_), parameter :: mld_bcmatch_aggr_  = 3
  integer(psb_ipk_), parameter :: mld_max_par_aggr_alg_  = mld_ext_aggr_     
  !  
  ! Legal values for entry: mld_aggr_ord_
  !
  integer(psb_ipk_), parameter :: mld_aggr_ord_nat_      = 0
  integer(psb_ipk_), parameter :: mld_aggr_ord_desc_deg_ = 1
  integer(psb_ipk_), parameter :: mld_max_aggr_ord_      = mld_aggr_ord_desc_deg_
  !
  ! Legal values for entry: mld_aggr_omega_alg_
  !
  integer(psb_ipk_), parameter :: mld_eig_est_     = 0
  integer(psb_ipk_), parameter :: mld_user_choice_ = 999
  !
  ! Legal values for entry: mld_aggr_eig_
  !
  integer(psb_ipk_), parameter :: mld_max_norm_ = 0
  !
  ! Legal values for entry: mld_coarse_mat_
  !
  integer(psb_ipk_), parameter :: mld_distr_mat_      = 0
  integer(psb_ipk_), parameter :: mld_repl_mat_       = 1
  integer(psb_ipk_), parameter :: mld_max_coarse_mat_ = mld_repl_mat_  
  !
  ! Legal values for entry: mld_prec_status_
  !
  integer(psb_ipk_), parameter :: mld_prec_built_ = 98765

  !
  ! Entries in rprcparm: ILU(k,t) threshold, smoothed aggregation omega
  !
  integer(psb_ipk_), parameter :: mld_sub_iluthrs_    = 1
  integer(psb_ipk_), parameter :: mld_aggr_omega_val_ = 2
  integer(psb_ipk_), parameter :: mld_aggr_thresh_    = 3
  integer(psb_ipk_), parameter :: mld_coarse_iluthrs_ = 4
  integer(psb_ipk_), parameter :: mld_solver_eps_     = 6
  integer(psb_ipk_), parameter :: mld_rfpsz_          = 8


  !
  ! Entries for mumps
  !
  !parameter controling the sequential/parallel building of MUMPS
  integer(psb_ipk_), parameter :: mld_as_sequential_   = 40
  !parameter regulating the error printing of MUMPS
  integer(psb_ipk_), parameter :: mld_mumps_print_err_ = 41

  !
  ! Fields for sparse matrices ensembles stored in av()
  ! 
  integer(psb_ipk_), parameter :: mld_l_pr_        = 1
  integer(psb_ipk_), parameter :: mld_u_pr_        = 2
  integer(psb_ipk_), parameter :: mld_bp_ilu_avsz_ = 2
  integer(psb_ipk_), parameter :: mld_ap_nd_       = 3
  integer(psb_ipk_), parameter :: mld_ac_          = 4
  integer(psb_ipk_), parameter :: mld_sm_pr_t_     = 5
  integer(psb_ipk_), parameter :: mld_sm_pr_       = 6
  integer(psb_ipk_), parameter :: mld_smth_avsz_   = 6
  integer(psb_ipk_), parameter :: mld_max_avsz_    = mld_smth_avsz_ 

  !
  ! Character constants used by mld_file_prec_descr
  !
  character(len=19), parameter, private :: &
       &  eigen_estimates(0:0)=(/'infinity norm     '/)
  character(len=15), parameter, private :: &
       &  aggr_prols(0:3)=(/'unsmoothed    ','smoothed      ',&
       &           'min energy    ','bizr. smoothed'/)
  character(len=15), parameter, private :: &
       &  aggr_filters(0:1)=(/'no filtering  ','filtering     '/)
  character(len=15), parameter, private :: &
       &  matrix_names(0:1)=(/'distributed   ','replicated    '/)
  character(len=18), parameter, private :: &
       &  aggr_type_names(0:1)=(/'No aggregation    ',&
       &  'VMB aggregation   '/)
  character(len=18), parameter, private :: &
       &  par_aggr_alg_names(0:3)=(/'decoupled aggr.   ',&
       &  'sym. dec. aggr.   ',&
       &  'user defined aggr.', 'matching aggr.    '/)
  character(len=18), parameter, private :: &
       &  ord_names(0:1)=(/'Natural ordering  ','Desc. degree ord. '/)
  character(len=6), parameter, private :: &
       &  restrict_names(0:4)=(/'none ','halo ','     ','     ','     '/)
  character(len=12), parameter, private :: &
       &  prolong_names(0:3)=(/'none       ','sum        ', &
       & 'average    ','square root'/)
  character(len=15), parameter, private :: &
       &  ml_names(0:7)=(/'none          ','additive      ',&
       &  'multiplicative', 'VCycle        ','WCycle        ',&
       &  'KCycle        ','KCycleSym     ','new ML        '/)
  character(len=15), parameter :: &
       &  mld_fact_names(0:mld_max_sub_solve_)=(/&
       & 'none          ','none          ',&
       & 'none          ','none          ',&
       & 'none          ','Point Jacobi  ',&
       & 'Gauss-Seidel  ','ILU(n)        ',&
       & 'MILU(n)       ','ILU(t,n)      ',&
       & 'SuperLU       ','UMFPACK LU    ',&
       & 'SuperLU_Dist  ','MUMPS         ',&
       & 'Backward GS   '/)

  interface mld_check_def
    module procedure mld_icheck_def, mld_scheck_def, mld_dcheck_def
  end interface

  interface psb_bcast 
    module procedure mld_ml_bcast, mld_sml_bcast, mld_dml_bcast
  end interface psb_bcast

  interface mld_equal_aggregation
    module procedure mld_d_equal_aggregation, mld_s_equal_aggregation
  end interface mld_equal_aggregation

contains

  !
  ! Function: mld_stringval
  !
  !  This routine converts the string contained into string into the corresponding
  !  integer value.
  !
  ! Arguments:
  !    string  -  character(len=*), input.
  !               The string to be converted.
  !    val     -  integer, output.
  !               The integer value corresponding to the string
  !
  function mld_stringval(string) result(val)
    implicit none 
  ! Arguments
    character(len=*), intent(in) :: string
    integer(psb_ipk_) :: val 
    character(len=*), parameter :: name='mld_stringval'
  ! Local variable
    integer :: index_tab
    character(len=15) ::string2
    index_tab=index(string,char(9))
    if (index_tab.NE.0)  then
       string2=string(1:index_tab-1)
    else 
       string2=string
    endif
    select case(psb_toupper(trim(string2)))
    case('NONE')
      val = 0
    case('HALO')
      val = psb_halo_ 
    case('SUM')
      val = psb_sum_
    case('AVG')
      val = psb_avg_
    case('FACT_NONE')
      val = mld_f_none_
    case('FBGS')
      val = mld_fbgs_
    case('GS','FGS','FWGS')
      val = mld_gs_
    case('BGS','BWGS')
      val = mld_bwgs_
    case('ILU')
      val = mld_ilu_n_
    case('MILU')
      val = mld_milu_n_
    case('ILUT')
      val = mld_ilu_t_
    case('MUMPS')
      val = mld_mumps_
    case('UMF')
      val = mld_umf_
    case('SLU')
      val = mld_slu_
    case('SLUDIST')
      val = mld_sludist_
    case('DIAG')
      val = mld_diag_scale_
    case('ADD')
      val = mld_add_ml_
    case('MULT_DEV')
      val = mld_mult_dev_ml_
    case('MULT')
      val = mld_mult_ml_
    case('VCYCLE')
      val = mld_vcycle_ml_
    case('WCYCLE')
      val = mld_wcycle_ml_
    case('KCYCLE')
      val = mld_kcycle_ml_
    case('KCYCLESYM')
      val = mld_kcyclesym_ml_
    case('VMB')
      val = mld_vmb_
    case('DEC')
      val = mld_dec_aggr_
    case('SYMDEC')
      val = mld_sym_dec_aggr_
    case('BCMATCH')
      val = mld_bcmatch_aggr_
    case('NAT','NATURAL')
      val =  mld_aggr_ord_nat_
    case('DESC','RDEGREE','DEGREE')
      val = mld_aggr_ord_desc_deg_
    case('REPL')
      val = mld_repl_mat_
    case('DIST')
      val = mld_distr_mat_
    case('UNSMOOTHED','NONSMOOTHED')
      val = mld_no_smooth_
    case('SMOOTHED')
      val = mld_smooth_prol_
    case('MINENERGY')
      val = mld_min_energy_
    case('NOPREC')
      val = mld_noprec_
    case('BJAC')
      val = mld_bjac_
    case('JAC','JACOBI')
      val = mld_jac_
    case('AS')
      val = mld_as_
    case('A_NORMI')
      val = mld_max_norm_
    case('USER_CHOICE')
      val = mld_user_choice_
    case('EIG_EST')
      val = mld_eig_est_
    case('FILTER')
      val = mld_filter_mat_
    case('NOFILTER')
      val = mld_no_filter_mat_
    case('OUTER_SWEEPS')
      val = mld_outer_sweeps_
    case default
      val  = -1
    end select
  end function mld_stringval

  subroutine  ml_parms_get_coarse(pm,pmin)
    implicit none 
    class(mld_ml_parms), intent(inout) :: pm
    class(mld_ml_parms), intent(in)    :: pmin
    pm%coarse_mat   = pmin%coarse_mat
    pm%coarse_solve = pmin%coarse_solve
  end subroutine ml_parms_get_coarse
    
    
  
  subroutine ml_parms_printout(pm,iout)
    implicit none 
    class(mld_ml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    
    write(iout,*) 'ML    : ',pm%ml_cycle
    write(iout,*) 'Sweeps: ',pm%sweeps_pre,pm%sweeps_post
    write(iout,*) 'AGGR  : ',pm%par_aggr_alg,pm%aggr_prol, pm%aggr_ord
    write(iout,*) '      : ',pm%aggr_omega_alg,pm%aggr_eig,pm%aggr_filter
    write(iout,*) 'COARSE: ',pm%coarse_mat,pm%coarse_solve
  end subroutine ml_parms_printout
    
  
  subroutine s_ml_parms_printout(pm,iout)
    implicit none 
    class(mld_sml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    
    call pm%mld_ml_parms%printout(iout)
    write(iout,*) 'REAL  : ',pm%aggr_omega_val,pm%aggr_thresh
  end subroutine s_ml_parms_printout
    
  
  subroutine d_ml_parms_printout(pm,iout)
    implicit none 
    class(mld_dml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    
    call pm%mld_ml_parms%printout(iout)
    write(iout,*) 'REAL  : ',pm%aggr_omega_val,pm%aggr_thresh
  end subroutine d_ml_parms_printout
    

  !
  ! Routines printing out a description of the preconditioner
  !
  
  subroutine ml_parms_mldescr(pm,iout,info)

    Implicit None

    ! Arguments
    class(mld_ml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    integer(psb_ipk_), intent(out)            :: info

    info = psb_success_
    if ((pm%ml_cycle>=mld_no_ml_).and.(pm%ml_cycle<=mld_max_ml_cycle_)) then

      
      write(iout,*) '  Multilevel cycle: ',&
           &   ml_names(pm%ml_cycle)
      select case (pm%ml_cycle)
      case (mld_add_ml_)
        write(iout,*) '  Number of smoother sweeps : ',&
             & pm%sweeps_pre
      case (mld_mult_ml_,mld_vcycle_ml_, mld_wcycle_ml_, mld_kcycle_ml_, mld_kcyclesym_ml_)
        write(iout,*) '  Number of smoother sweeps : pre: ',&
             &  pm%sweeps_pre ,'  post: ', pm%sweeps_post
      end select
      
      write(iout,*) '  Aggregation type: ',&
           & aggr_type_names(pm%aggr_type) 
      write(iout,*) '  parallel algorithm: ',&
           &   par_aggr_alg_names(pm%par_aggr_alg)
      if (pm%par_aggr_alg /= mld_ext_aggr_) then
        if ( pm%aggr_ord /= mld_aggr_ord_nat_) &
             & write(iout,*) '               with initial ordering: ',&
             &   ord_names(pm%aggr_ord)
        write(iout,*) '  Aggregation prolongator: ', &
             &  aggr_prols(pm%aggr_prol)
        if (pm%aggr_prol /= mld_no_smooth_) then
        write(iout,*) '              with: ', aggr_filters(pm%aggr_filter)                  
          if (pm%aggr_omega_alg == mld_eig_est_) then 
            write(iout,*) '  Damping omega computation: spectral radius estimate'
            write(iout,*) '  Spectral radius estimate: ', &
                 & eigen_estimates(pm%aggr_eig)
          else if (pm%aggr_omega_alg == mld_user_choice_) then 
            write(iout,*) '  Damping omega computation: user defined value.'
          else 
            write(iout,*) '  Damping omega computation: unknown value in iprcparm!!'
          end if
        end if
      end if
    else
      write(iout,*) '  Multilevel type: Unkonwn value. Something is amis....',&
           & pm%ml_cycle           
    end if
    
    return

  end subroutine ml_parms_mldescr

  subroutine ml_parms_coarsedescr(pm,iout,info)


    Implicit None

    ! Arguments
    class(mld_ml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    integer(psb_ipk_), intent(out)            :: info

    info = psb_success_
    write(iout,*) '  Coarse matrix: ',&
         & matrix_names(pm%coarse_mat)
    if ((pm%coarse_solve == mld_bjac_).or.(pm%coarse_solve==mld_as_)) then 
      write(iout,*) '  Number of sweeps : ',&
           & pm%sweeps_pre
      write(iout,*) '  Coarse solver: ',&
           & 'Block Jacobi'
    else
      write(iout,*) '  Coarse solver: ',&
           & mld_fact_names(pm%coarse_solve)
    end if

  end subroutine ml_parms_coarsedescr

  subroutine ml_parms_descr(pm,iout,info,coarse)

    Implicit None

    ! Arguments
    class(mld_ml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    integer(psb_ipk_), intent(out)            :: info
    logical, intent(in), optional   :: coarse
    logical :: coarse_

    info = psb_success_
    if (present(coarse)) then 
      coarse_ = coarse
    else
      coarse_ = .false.
    end if

    if (coarse_) then 
      call pm%coarsedescr(iout,info)
    end if

    return

  end subroutine ml_parms_descr

  subroutine s_ml_parms_descr(pm,iout,info,coarse)

    Implicit None

    ! Arguments
    class(mld_sml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    integer(psb_ipk_), intent(out)            :: info
    logical, intent(in), optional   :: coarse

    info = psb_success_

    call pm%mld_ml_parms%descr(iout,info,coarse)
    if (pm%aggr_prol /= mld_no_smooth_) then
      write(iout,*) '  Damping omega value  :',pm%aggr_omega_val
    end if
    write(iout,*) '  Aggregation threshold:',pm%aggr_thresh

    return

  end subroutine s_ml_parms_descr

  subroutine d_ml_parms_descr(pm,iout,info,coarse)

    Implicit None

    ! Arguments
    class(mld_dml_parms), intent(in) :: pm
    integer(psb_ipk_), intent(in)             :: iout
    integer(psb_ipk_), intent(out)            :: info
    logical, intent(in), optional   :: coarse

    info = psb_success_

    call pm%mld_ml_parms%descr(iout,info,coarse)
    if (pm%aggr_prol /= mld_no_smooth_) then
      write(iout,*) '  Damping omega value  :',pm%aggr_omega_val
    end if
    write(iout,*) '  Aggregation threshold:',pm%aggr_thresh

    return

  end subroutine d_ml_parms_descr


  !
  ! Functions/subroutines checking if the preconditioner is correctly defined
  !

  function is_legal_base_prec(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_base_prec

    is_legal_base_prec = ((ip>=mld_noprec_).and.(ip<=mld_max_prec_))
    return
  end function is_legal_base_prec
  function is_int_non_negative(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_int_non_negative

    is_int_non_negative = (ip >= 0) 
    return
  end function is_int_non_negative
  function is_legal_ilu_scale(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ilu_scale
    is_legal_ilu_scale = ((ip >= mld_ilu_scale_none_).and.(ip <= mld_max_ilu_scale_))
    return
  end function is_legal_ilu_scale
  function is_int_positive(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_int_positive

    is_int_positive = (ip >= 1) 
    return
  end function is_int_positive
  function is_legal_prolong(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_prolong
    is_legal_prolong = ((ip>=psb_none_).and.(ip<=psb_square_root_))
    return
  end function is_legal_prolong
  function is_legal_restrict(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_restrict
    is_legal_restrict = ((ip == psb_nohalo_).or.(ip==psb_halo_))
    return
  end function is_legal_restrict
  function is_legal_ml_cycle(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_cycle

    is_legal_ml_cycle = ((ip>=mld_no_ml_).and.(ip<=mld_max_ml_cycle_))
    return
  end function is_legal_ml_cycle
  function is_legal_ml_par_aggr_alg(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_par_aggr_alg

    is_legal_ml_par_aggr_alg = ((ip>=mld_dec_aggr_).and.(ip<=mld_max_par_aggr_alg_))
    return
  end function is_legal_ml_par_aggr_alg
  function is_legal_ml_aggr_type(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_aggr_type

    is_legal_ml_aggr_type = (ip == mld_vmb_)
    return
  end function is_legal_ml_aggr_type
  function is_legal_ml_aggr_ord(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_aggr_ord

    is_legal_ml_aggr_ord = ((mld_aggr_ord_nat_<=ip).and.(ip<=mld_max_aggr_ord_))
    return
  end function is_legal_ml_aggr_ord
  function is_legal_ml_aggr_omega_alg(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_aggr_omega_alg

    is_legal_ml_aggr_omega_alg = ((ip == mld_eig_est_).or.(ip==mld_user_choice_))
    return
  end function is_legal_ml_aggr_omega_alg
  function is_legal_ml_aggr_eig(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_aggr_eig

    is_legal_ml_aggr_eig = (ip == mld_max_norm_)
    return
  end function is_legal_ml_aggr_eig
  function is_legal_ml_aggr_prol(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_aggr_prol

    is_legal_ml_aggr_prol = ((ip>=0).and.(ip<=mld_max_aggr_prol_))
    return
  end function is_legal_ml_aggr_prol
  function is_legal_ml_coarse_mat(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_coarse_mat

    is_legal_ml_coarse_mat = ((ip>=0).and.(ip<=mld_max_coarse_mat_))
    return
  end function is_legal_ml_coarse_mat
  function is_legal_aggr_filter(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_aggr_filter

    is_legal_aggr_filter = ((ip>=0).and.(ip<=mld_max_filter_mat_))
    return
  end function is_legal_aggr_filter
  function is_distr_ml_coarse_mat(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_distr_ml_coarse_mat

    is_distr_ml_coarse_mat = (ip == mld_distr_mat_)
    return
  end function is_distr_ml_coarse_mat
  function is_legal_ml_fact(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ml_fact
    ! Here the minimum is really 1, mld_fact_none_ is not acceptable.
    is_legal_ml_fact = ((ip>=mld_min_sub_solve_)&
         & .and.(ip<=mld_max_sub_solve_))
    return
  end function is_legal_ml_fact
  function is_legal_ilu_fact(ip)
    implicit none 
    integer(psb_ipk_), intent(in) :: ip
    logical             :: is_legal_ilu_fact

    is_legal_ilu_fact = ((ip==mld_ilu_n_).or.&
         & (ip==mld_milu_n_).or.(ip==mld_ilu_t_))
    return
  end function is_legal_ilu_fact
  function is_legal_d_omega(ip)
    implicit none 
    real(psb_dpk_), intent(in) :: ip
    logical             :: is_legal_d_omega
    is_legal_d_omega = ((ip>=0.0d0).and.(ip<=2.0d0))
    return
  end function is_legal_d_omega
  function is_legal_d_fact_thrs(ip)
    implicit none 
    real(psb_dpk_), intent(in) :: ip
    logical             :: is_legal_d_fact_thrs

    is_legal_d_fact_thrs = (ip>=0.0d0)
    return
  end function is_legal_d_fact_thrs
  function is_legal_d_aggr_thrs(ip)
    implicit none 
    real(psb_dpk_), intent(in) :: ip
    logical             :: is_legal_d_aggr_thrs

    is_legal_d_aggr_thrs = (ip>=0.0d0)
    return
  end function is_legal_d_aggr_thrs

  function is_legal_s_omega(ip)
    implicit none 
    real(psb_spk_), intent(in) :: ip
    logical             :: is_legal_s_omega
    is_legal_s_omega = ((ip>=0.0).and.(ip<=2.0))
    return
  end function is_legal_s_omega
  function is_legal_s_fact_thrs(ip)
    implicit none 
    real(psb_spk_), intent(in) :: ip
    logical             :: is_legal_s_fact_thrs

    is_legal_s_fact_thrs = (ip>=0.0)
    return
  end function is_legal_s_fact_thrs
  function is_legal_s_aggr_thrs(ip)
    implicit none 
    real(psb_spk_), intent(in) :: ip
    logical             :: is_legal_s_aggr_thrs

    is_legal_s_aggr_thrs = (ip>=0.0)
    return
  end function is_legal_s_aggr_thrs


  subroutine mld_icheck_def(ip,name,id,is_legal)
    implicit none 
    integer(psb_ipk_), intent(inout) :: ip
    integer(psb_ipk_), intent(in)    :: id
    character(len=*), intent(in) :: name
    interface 
      function is_legal(i)
        import :: psb_ipk_
        integer(psb_ipk_), intent(in) :: i
        logical             :: is_legal
      end function is_legal
    end interface
    character(len=20), parameter :: rname='mld_check_def'

    if (.not.is_legal(ip)) then     
      write(0,*)trim(rname),': Error: Illegal value for ',&
           & name,' :',ip, '. defaulting to ',id
      ip = id
    end if
  end subroutine mld_icheck_def

  subroutine mld_scheck_def(ip,name,id,is_legal)
    implicit none 
    real(psb_spk_), intent(inout) :: ip
    real(psb_spk_), intent(in)    :: id
    character(len=*), intent(in) :: name
    interface 
      function is_legal(i)
        use psb_base_mod, only : psb_spk_
        real(psb_spk_), intent(in) :: i
        logical             :: is_legal
      end function is_legal
    end interface
    character(len=20), parameter :: rname='mld_check_def'

    if (.not.is_legal(ip)) then     
      write(0,*)trim(rname),': Error: Illegal value for ',&
           & name,' :',ip, '. defaulting to ',id
      ip = id
    end if
  end subroutine mld_scheck_def

  subroutine mld_dcheck_def(ip,name,id,is_legal)
    implicit none 
    real(psb_dpk_), intent(inout) :: ip
    real(psb_dpk_), intent(in)    :: id
    character(len=*), intent(in) :: name
    interface 
      function is_legal(i)
        use psb_base_mod, only : psb_dpk_
        real(psb_dpk_), intent(in) :: i
        logical             :: is_legal
      end function is_legal
    end interface
    character(len=20), parameter :: rname='mld_check_def'

    if (.not.is_legal(ip)) then     
      write(0,*)trim(rname),': Error: Illegal value for ',&
           & name,' :',ip, '. defaulting to ',id
      ip = id
    end if
  end subroutine mld_dcheck_def


  function pr_to_str(iprec)
    implicit none 

    integer(psb_ipk_), intent(in)  :: iprec
    character(len=10)     :: pr_to_str

    select case(iprec)
    case(mld_noprec_)
      pr_to_str='NOPREC'
    case(mld_jac_)         
      pr_to_str='JAC'
    case(mld_bjac_)         
      pr_to_str='BJAC'
    case(mld_as_)      
      pr_to_str='AS'
    end select

  end function pr_to_str

  subroutine mld_ml_bcast(ictxt,dat,root)

    implicit none 
    integer(psb_ipk_), intent(in)      :: ictxt
    type(mld_ml_parms), intent(inout)   :: dat
    integer(psb_ipk_), intent(in), optional :: root

    call psb_bcast(ictxt,dat%sweeps_pre,root)
    call psb_bcast(ictxt,dat%sweeps_post,root)
    call psb_bcast(ictxt,dat%ml_cycle,root)
    call psb_bcast(ictxt,dat%aggr_type,root)
    call psb_bcast(ictxt,dat%par_aggr_alg,root)
    call psb_bcast(ictxt,dat%aggr_ord,root)
    call psb_bcast(ictxt,dat%aggr_prol,root)
    call psb_bcast(ictxt,dat%aggr_omega_alg,root)
    call psb_bcast(ictxt,dat%aggr_eig,root)
    call psb_bcast(ictxt,dat%aggr_filter,root)
    call psb_bcast(ictxt,dat%coarse_mat,root)
    call psb_bcast(ictxt,dat%coarse_solve,root)

  end subroutine mld_ml_bcast

  subroutine mld_sml_bcast(ictxt,dat,root)

    implicit none 
    integer(psb_ipk_), intent(in)      :: ictxt
    type(mld_sml_parms), intent(inout)   :: dat
    integer(psb_ipk_), intent(in), optional :: root

    call psb_bcast(ictxt,dat%mld_ml_parms,root)
    call psb_bcast(ictxt,dat%aggr_omega_val,root)
    call psb_bcast(ictxt,dat%aggr_thresh,root)
  end subroutine mld_sml_bcast

  subroutine mld_dml_bcast(ictxt,dat,root)
    implicit none 
    integer(psb_ipk_), intent(in)      :: ictxt
    type(mld_dml_parms), intent(inout)   :: dat
    integer(psb_ipk_), intent(in), optional :: root

    call psb_bcast(ictxt,dat%mld_ml_parms,root)
    call psb_bcast(ictxt,dat%aggr_omega_val,root)
    call psb_bcast(ictxt,dat%aggr_thresh,root)
  end subroutine mld_dml_bcast

  subroutine ml_parms_clone(pm,pmout,info)

    implicit none 
    class(mld_ml_parms), intent(inout) :: pm
    class(mld_ml_parms), intent(out)   :: pmout
    integer(psb_ipk_), intent(out)     :: info

    info = psb_success_
    pmout%sweeps_pre     = pm%sweeps_pre
    pmout%sweeps_post    = pm%sweeps_post
    pmout%ml_cycle       = pm%ml_cycle
    pmout%aggr_type      = pm%aggr_type
    pmout%par_aggr_alg   = pm%par_aggr_alg
    pmout%aggr_ord       = pm%aggr_ord
    pmout%aggr_prol      = pm%aggr_prol
    pmout%aggr_omega_alg = pm%aggr_omega_alg
    pmout%aggr_eig       = pm%aggr_eig
    pmout%aggr_filter    = pm%aggr_filter
    pmout%coarse_mat     = pm%coarse_mat
    pmout%coarse_solve   = pm%coarse_solve

  end subroutine ml_parms_clone
  
  subroutine s_ml_parms_clone(pm,pmout,info)

    implicit none 
    class(mld_sml_parms), intent(inout) :: pm
    class(mld_ml_parms), intent(out)   :: pmout
    integer(psb_ipk_), intent(out)     :: info

      
    integer(psb_ipk_) :: err_act
    integer(psb_ipk_) :: ierr(5)
    character(len=20)  :: name='clone'
  
    info = 0
    select type(pout => pmout)
    class is (mld_sml_parms)
      call pm%mld_ml_parms%clone(pout%mld_ml_parms,info)
      pout%aggr_omega_val = pm%aggr_omega_val
      pout%aggr_thresh    = pm%aggr_thresh
    class default
      info = psb_err_invalid_dynamic_type_
      ierr(1) = 2
      info = psb_err_missing_override_method_
      call psb_errpush(info,name,i_err=ierr)
      call psb_get_erraction(err_act)
      call psb_error_handler(err_act)
    end select
      
  end subroutine s_ml_parms_clone

  subroutine d_ml_parms_clone(pm,pmout,info)

    implicit none 
    class(mld_dml_parms), intent(inout) :: pm
    class(mld_ml_parms), intent(out)   :: pmout
    integer(psb_ipk_), intent(out)     :: info

      
    integer(psb_ipk_) :: err_act
    integer(psb_ipk_) :: ierr(5)
    character(len=20)  :: name='clone'
  
    info = 0
    select type(pout => pmout)
    class is (mld_dml_parms)
      call pm%mld_ml_parms%clone(pout%mld_ml_parms,info)
      pout%aggr_omega_val = pm%aggr_omega_val
      pout%aggr_thresh    = pm%aggr_thresh
    class default
      info = psb_err_invalid_dynamic_type_
      ierr(1) = 2
      info = psb_err_missing_override_method_
      call psb_errpush(info,name,i_err=ierr)
      call psb_get_erraction(err_act)
      call psb_error_handler(err_act)
      return
    end select
      
  end subroutine d_ml_parms_clone

  function mld_s_equal_aggregation(parms1, parms2) result(val)
    type(mld_sml_parms), intent(in) :: parms1, parms2
    logical :: val
    
    val  = (parms1%par_aggr_alg     == parms2%par_aggr_alg        ) .and. &
         & (parms1%aggr_type        == parms2%aggr_type       ) .and. &
         & (parms1%aggr_ord         == parms2%aggr_ord        ) .and. &
         & (parms1%aggr_prol        == parms2%aggr_prol       ) .and. &
         & (parms1%aggr_omega_alg   == parms2%aggr_omega_alg  ) .and. &
         & (parms1%aggr_eig         == parms2%aggr_eig        ) .and. &
         & (parms1%aggr_filter      == parms2%aggr_filter     ) .and. &
         & (parms1%aggr_omega_val   == parms2%aggr_omega_val  ) .and. &
         & (parms1%aggr_thresh      == parms2%aggr_thresh     )
  end function mld_s_equal_aggregation

  function mld_d_equal_aggregation(parms1, parms2) result(val)
    type(mld_dml_parms), intent(in) :: parms1, parms2
    logical :: val
    
    val  = (parms1%par_aggr_alg     == parms2%par_aggr_alg        ) .and. &
         & (parms1%aggr_type        == parms2%aggr_type       ) .and. &
         & (parms1%aggr_ord         == parms2%aggr_ord        ) .and. &
         & (parms1%aggr_prol        == parms2%aggr_prol       ) .and. &
         & (parms1%aggr_omega_alg   == parms2%aggr_omega_alg  ) .and. &
         & (parms1%aggr_eig         == parms2%aggr_eig        ) .and. &
         & (parms1%aggr_filter      == parms2%aggr_filter     ) .and. &
         & (parms1%aggr_omega_val   == parms2%aggr_omega_val  ) .and. &
         & (parms1%aggr_thresh      == parms2%aggr_thresh     )
  end function mld_d_equal_aggregation
         
end module mld_base_prec_type
