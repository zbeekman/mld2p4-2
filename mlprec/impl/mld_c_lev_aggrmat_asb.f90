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
! File: mld_c_lev_aggrmat_asb.f90
!
! Subroutine: mld_c_lev_aggrmat_asb
! Version:    complex
!
!  This routine builds the matrix associated to the current level of the
!  multilevel preconditioner from the matrix associated to the previous level,
!  by using the user-specified aggregation technique (therefore, it also builds the
!  prolongation and restriction operators mapping the current level to the
!  previous one and vice versa). 
!  The current level is regarded as the coarse one, while the previous as
!  the fine one. This is in agreement with the fact that the routine is called,
!  by mld_mlprec_bld, only on levels >=2.
!  The main structure is:
!  1. Perform sanity checks;
!  2. Call mld_Xaggrmat_asb to compute prolongator/restrictor/AC
!  3. According to the choice of DIST/REPL for AC, build a descriptor DESC_AC,
!     and adjust the column numbering of AC/OP_PROL/OP_RESTR
!  4. Pack restrictor and prolongator into p%map
!  5. Fix base_a and base_desc pointers.
!
! 
! Arguments:
!    p       -  type(mld_c_onelev_type), input/output.
!               The 'one-level' data structure containing the control
!               parameters and (eventually) coarse matrix and prolongator/restrictors. 
!               
!    a       -  type(psb_cspmat_type).
!               The sparse matrix structure containing the local part of the
!               fine-level matrix.
!    desc_a  -  type(psb_desc_type), input.
!               The communication descriptor of a.
!    ilaggr     -  integer, dimension(:), input
!                  The mapping between the row indices of the coarse-level
!                  matrix and the row indices of the fine-level matrix.
!                  ilaggr(i)=j means that node i in the adjacency graph
!                  of the fine-level matrix is mapped onto node j in the
!                  adjacency graph of the coarse-level matrix. Note that the indices
!                  are assumed to be shifted so as to make sure the ranges on
!                  the various processes do not   overlap.
!    nlaggr     -  integer, dimension(:) input
!                  nlaggr(i) contains the aggregates held by process i.
!    op_prol    -  type(psb_cspmat_type), input/output
!               The tentative prolongator on input, released on output. 
!               
!    info    -  integer, output.
!               Error code.         
!  
subroutine mld_c_lev_aggrmat_asb(p,a,desc_a,ilaggr,nlaggr,op_prol,info)

  use psb_base_mod
  use mld_base_prec_type
  use mld_c_inner_mod, mld_protect_name => mld_c_lev_aggrmat_asb

  implicit none

  ! Arguments
  type(mld_c_onelev_type), intent(inout), target :: p
  type(psb_cspmat_type), intent(in)  :: a
  type(psb_desc_type), intent(in)    :: desc_a
  integer(psb_ipk_), intent(inout) :: ilaggr(:),nlaggr(:)
  type(psb_cspmat_type), intent(inout)  :: op_prol
  integer(psb_ipk_), intent(out)      :: info
  

  ! Local variables
  character(len=20)                :: name
  integer(psb_mpik_)               :: ictxt, np, me
  integer(psb_ipk_)                :: err_act
  type(psb_cspmat_type)            :: ac, op_restr
  type(psb_c_coo_sparse_mat)       :: acoo, bcoo
  type(psb_c_csr_sparse_mat)       :: acsr1
  integer(psb_ipk_)                :: nzl, ntaggr
  integer(psb_ipk_)            :: debug_level, debug_unit

  name='mld_c_lev_aggrmat_asb'
  if (psb_get_errstatus().ne.0) return 
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()
  info  = psb_success_
  ictxt = desc_a%get_context()
  call psb_info(ictxt,me,np)

  call mld_check_def(p%parms%aggr_prol,'Smoother',&
       &   mld_smooth_prol_,is_legal_ml_aggr_prol)
  call mld_check_def(p%parms%coarse_mat,'Coarse matrix',&
       &   mld_distr_mat_,is_legal_ml_coarse_mat)
  call mld_check_def(p%parms%aggr_filter,'Use filtered matrix',&
       &   mld_no_filter_mat_,is_legal_aggr_filter)
  call mld_check_def(p%parms%aggr_omega_alg,'Omega Alg.',&
       &   mld_eig_est_,is_legal_ml_aggr_omega_alg)
  call mld_check_def(p%parms%aggr_eig,'Eigenvalue estimate',&
       &   mld_max_norm_,is_legal_ml_aggr_eig)
  call mld_check_def(p%parms%aggr_omega_val,'Omega',szero,is_legal_s_omega)


  !
  ! Build the coarse-level matrix from the fine-level one, starting from 
  ! the mapping defined by mld_aggrmap_bld and applying the aggregation
  ! algorithm specified by p%iprcparm(mld_aggr_prol_)
  !
  call mld_caggrmat_asb(a,desc_a,ilaggr,nlaggr,p%parms,ac,op_prol,op_restr,info)

  if(info /= psb_success_) then
    call psb_errpush(psb_err_from_subroutine_,name,a_err='mld_aggrmat_asb')
    goto 9999
  end if


  ! Common code refactored here.

  ntaggr = sum(nlaggr)

  select case(p%parms%coarse_mat)

  case(mld_distr_mat_) 

    call ac%mv_to(bcoo)
    nzl = bcoo%get_nzeros()

    if (info == psb_success_) call psb_cdall(ictxt,p%desc_ac,info,nl=nlaggr(me+1))
    if (info == psb_success_) call psb_cdins(nzl,bcoo%ia,bcoo%ja,p%desc_ac,info)
    if (info == psb_success_) call psb_cdasb(p%desc_ac,info)
    if (info == psb_success_) call psb_glob_to_loc(bcoo%ia(1:nzl),p%desc_ac,info,iact='I')
    if (info == psb_success_) call psb_glob_to_loc(bcoo%ja(1:nzl),p%desc_ac,info,iact='I')
    if (info /= psb_success_) then
      call psb_errpush(psb_err_internal_error_,name,&
           & a_err='Creating p%desc_ac and converting ac')
      goto 9999
    end if
    if (debug_level >= psb_debug_outer_) &
         & write(debug_unit,*) me,' ',trim(name),&
         & 'Assembld aux descr. distr.'
    call p%ac%mv_from(bcoo)

    call p%ac%set_nrows(p%desc_ac%get_local_rows())
    call p%ac%set_ncols(p%desc_ac%get_local_cols())
    call p%ac%set_asb()

    if (info /= psb_success_) then
      call psb_errpush(psb_err_from_subroutine_,name,a_err='psb_sp_free')
      goto 9999
    end if

    if (np>1) then 
      call op_prol%mv_to(acsr1)
      nzl = acsr1%get_nzeros()
      call psb_glob_to_loc(acsr1%ja(1:nzl),p%desc_ac,info,'I')
      if(info /= psb_success_) then
        call psb_errpush(psb_err_from_subroutine_,name,a_err='psb_glob_to_loc')
        goto 9999
      end if
      call op_prol%mv_from(acsr1)
    endif
    call op_prol%set_ncols(p%desc_ac%get_local_cols())

    if (np>1) then 
      call op_restr%cscnv(info,type='coo',dupl=psb_dupl_add_)
      call op_restr%mv_to(acoo)
      nzl = acoo%get_nzeros()
      if (info == psb_success_) call psb_glob_to_loc(acoo%ia(1:nzl),p%desc_ac,info,'I')
      call acoo%set_dupl(psb_dupl_add_)
      if (info == psb_success_) call op_restr%mv_from(acoo)
      if (info == psb_success_) call op_restr%cscnv(info,type='csr')        
      if(info /= psb_success_) then
        call psb_errpush(psb_err_internal_error_,name,&
             & a_err='Converting op_restr to local')
        goto 9999
      end if
    end if
    !
    ! Clip to local rows.
    !
    call op_restr%set_nrows(p%desc_ac%get_local_rows())

    if (debug_level >= psb_debug_outer_) &
         & write(debug_unit,*) me,' ',trim(name),&
         & 'Done ac '

  case(mld_repl_mat_) 
    !
    !
    call psb_cdall(ictxt,p%desc_ac,info,mg=ntaggr,repl=.true.)
    if (info == psb_success_) call psb_cdasb(p%desc_ac,info)
    if (info == psb_success_) &
         & call psb_gather(p%ac,ac,p%desc_ac,info,dupl=psb_dupl_add_,keeploc=.false.)

    if (info /= psb_success_) goto 9999

  case default 
    info = psb_err_internal_error_
    call psb_errpush(info,name,a_err='invalid mld_coarse_mat_')
    goto 9999
  end select

  call p%ac%cscnv(info,type='csr',dupl=psb_dupl_add_)
  if(info /= psb_success_) then
    call psb_errpush(psb_err_from_subroutine_,name,a_err='spcnv')
    goto 9999
  end if

  !
  ! Copy the prolongation/restriction matrices into the descriptor map.
  !  op_restr => PR^T   i.e. restriction  operator
  !  op_prol => PR     i.e. prolongation operator
  !  

  p%map = psb_linmap(psb_map_aggr_,desc_a,&
       & p%desc_ac,op_restr,op_prol,ilaggr,nlaggr)
  if (info == psb_success_) call op_prol%free()
  if (info == psb_success_) call op_restr%free()
  if(info /= psb_success_) then
    call psb_errpush(psb_err_from_subroutine_,name,a_err='sp_Free')
    goto 9999
  end if
  !
  ! Fix the base_a and base_desc pointers for handling of residuals.
  ! This is correct because this routine is only called at levels >=2.
  !
  p%base_a    => p%ac
  p%base_desc => p%desc_ac

  call psb_erractionrestore(err_act)
  return

9999 call psb_error_handler(err_act)
  return

end subroutine mld_c_lev_aggrmat_asb
