!!$ 
!!$ 
!!$                           MLD2P4  version 2.0
!!$  MultiLevel Domain Decomposition Parallel Preconditioners Package
!!$             based on PSBLAS (Parallel Sparse BLAS version 3.0)
!!$  
!!$  (C) Copyright 2008,2009,2010
!!$
!!$                      Salvatore Filippone  University of Rome Tor Vergata
!!$                      Alfredo Buttari      CNRS-IRIT, Toulouse
!!$                      Pasqua D'Ambra       ICAR-CNR, Naples
!!$                      Daniela di Serafino  Second University of Naples
!!$ 
!!$  Redistribution and use in source and binary forms, with or without
!!$  modification, are permitted provided that the following conditions
!!$  are met:
!!$    1. Redistributions of source code must retain the above copyright
!!$       notice, this list of conditions and the following disclaimer.
!!$    2. Redistributions in binary form must reproduce the above copyright
!!$       notice, this list of conditions, and the following disclaimer in the
!!$       documentation and/or other materials provided with the distribution.
!!$    3. The name of the MLD2P4 group or the names of its contributors may
!!$       not be used to endorse or promote products derived from this
!!$       software without specific written permission.
!!$ 
!!$  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!!$  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!!$  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!!$  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE MLD2P4 GROUP OR ITS CONTRIBUTORS
!!$  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!!$  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!!$  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!!$  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!!$  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!!$  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!!$  POSSIBILITY OF SUCH DAMAGE.
!!$ 
!!$
! File: mld_inner_mod.f90
!
! Module: mld_inner_mod
!
!  This module defines the interfaces to the real/complex, single/double
!  precision versions of the MLD2P4 routines, except those of the user level,
!  whose interfaces are defined in mld_prec_mod.f90.
!
module mld_s_inner_mod
  use mld_s_prec_type
  use mld_s_move_alloc_mod

  interface mld_baseprec_aply
    subroutine mld_sbaseprec_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_desc_type),intent(in)      :: desc_data
      type(mld_sbaseprec_type), intent(in) :: prec
      real(psb_spk_),intent(in)         :: x(:)
      real(psb_spk_),intent(inout)      :: y(:)
      real(psb_spk_),intent(in)         :: alpha,beta
      character(len=1)                    :: trans
      real(psb_spk_),target             :: work(:)
      integer, intent(out)                :: info
    end subroutine mld_sbaseprec_aply
  end interface mld_baseprec_aply

  interface mld_mlprec_bld
    subroutine mld_smlprec_bld(a,desc_a,prec,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sprec_type
      implicit none
      type(psb_sspmat_type), intent(in), target   :: a
      type(psb_desc_type), intent(in), target     :: desc_a
      type(mld_sprec_type), intent(inout), target :: prec
      integer, intent(out)                        :: info
!!$      character, intent(in),optional             :: upd
    end subroutine mld_smlprec_bld
  end interface mld_mlprec_bld

  interface mld_as_aply
    subroutine mld_sas_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_desc_type),intent(in)      :: desc_data
      type(mld_sbaseprec_type), intent(in) :: prec
      real(psb_spk_),intent(in)         :: x(:)
      real(psb_spk_),intent(inout)      :: y(:)
      real(psb_spk_),intent(in)         :: alpha,beta
      character(len=1)                    :: trans
      real(psb_spk_),target             :: work(:)
      integer, intent(out)                :: info
    end subroutine mld_sas_aply
  end interface mld_as_aply

  interface mld_mlprec_aply
    subroutine mld_smlprec_aply(alpha,p,x,beta,y,desc_data,trans,work,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type, mld_sprec_type
      type(psb_desc_type),intent(in)      :: desc_data
      type(mld_sprec_type), intent(in)  :: p
      real(psb_spk_),intent(in)         :: alpha,beta
      real(psb_spk_),intent(in)         :: x(:)
      real(psb_spk_),intent(inout)      :: y(:)
      character,intent(in)              :: trans
      real(psb_spk_),target             :: work(:)
      integer, intent(out)              :: info
    end subroutine mld_smlprec_aply
  end interface mld_mlprec_aply


  interface mld_asmat_bld
    Subroutine mld_sasmat_bld(ptype,novr,a,blk,desc_data,upd,desc_p,info,outfmt)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      integer, intent(in)                 :: ptype,novr
      Type(psb_sspmat_type), Intent(in)   ::  a
      Type(psb_sspmat_type), Intent(out)  ::  blk
      Type(psb_desc_type), Intent(inout)  :: desc_p
      Type(psb_desc_type), Intent(in)     :: desc_data 
      Character, Intent(in)               :: upd
      integer, intent(out)                :: info
      character(len=5), optional          :: outfmt
    end Subroutine mld_sasmat_bld
  end interface mld_asmat_bld

  interface mld_sp_renum
    subroutine mld_ssp_renum(a,blck,p,atmp,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type), intent(in)      :: a,blck
      type(psb_sspmat_type), intent(out)     :: atmp
      type(mld_sbaseprec_type), intent(inout) :: p
      integer, intent(out)   :: info
    end subroutine mld_ssp_renum
  end interface mld_sp_renum

  interface mld_coarse_bld
    subroutine mld_scoarse_bld(a,desc_a,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type, mld_sonelev_type
      type(psb_sspmat_type), intent(in)              :: a
      type(psb_desc_type), intent(in)                :: desc_a
      type(mld_sonelev_type), intent(inout), target :: p
      integer, intent(out)                           :: info
    end subroutine mld_scoarse_bld
  end interface mld_coarse_bld

  interface mld_aggrmap_bld
    subroutine mld_saggrmap_bld(aggr_type,theta,a,desc_a,ilaggr,nlaggr,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      integer, intent(in)               :: aggr_type
      real(psb_spk_), intent(in)        :: theta
      type(psb_sspmat_type), intent(in) :: a
      type(psb_desc_type), intent(in)   :: desc_a
      integer, allocatable, intent(out) :: ilaggr(:),nlaggr(:)
      integer, intent(out)              :: info
    end subroutine mld_saggrmap_bld
  end interface mld_aggrmap_bld

  interface mld_aggrmat_asb
    subroutine mld_saggrmat_asb(a,desc_a,ilaggr,nlaggr,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type, mld_sonelev_type
      type(psb_sspmat_type), intent(in)              :: a
      type(psb_desc_type), intent(in)                :: desc_a
      integer, intent(inout)                         :: ilaggr(:), nlaggr(:)
      type(mld_sonelev_type), intent(inout), target :: p
      integer, intent(out)                           :: info
    end subroutine mld_saggrmat_asb
  end interface mld_aggrmat_asb

  interface mld_aggrmat_nosmth_asb
    subroutine mld_saggrmat_nosmth_asb(a,desc_a,ilaggr,nlaggr,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type, mld_sonelev_type
      type(psb_sspmat_type), intent(in)              :: a
      type(psb_desc_type), intent(in)                :: desc_a
      integer, intent(inout)                         :: ilaggr(:), nlaggr(:)
      type(mld_sonelev_type), intent(inout), target :: p
      integer, intent(out)                           :: info
    end subroutine mld_saggrmat_nosmth_asb
  end interface mld_aggrmat_nosmth_asb

  interface mld_aggrmat_smth_asb
    subroutine mld_saggrmat_smth_asb(a,desc_a,ilaggr,nlaggr,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type, mld_sonelev_type
      type(psb_sspmat_type), intent(in)              :: a
      type(psb_desc_type), intent(in)                :: desc_a
      integer, intent(inout)                         :: ilaggr(:), nlaggr(:)
      type(mld_sonelev_type), intent(inout), target :: p
      integer, intent(out)                           :: info
    end subroutine mld_saggrmat_smth_asb
  end interface mld_aggrmat_smth_asb

  interface mld_baseprec_bld
    subroutine mld_sbaseprec_bld(a,desc_a,p,info,upd)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type), target              :: a
      type(psb_desc_type), intent(in), target    :: desc_a
      type(mld_sbaseprec_type),intent(inout)      :: p
      integer, intent(out)                       :: info
      character, intent(in), optional            :: upd
    end subroutine mld_sbaseprec_bld
  end interface mld_baseprec_bld

  interface mld_as_bld
    subroutine mld_sas_bld(a,desc_a,p,upd,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type),intent(in), target :: a
      type(psb_desc_type), intent(in), target  :: desc_a
      type(mld_sbaseprec_type),intent(inout)   :: p
      character, intent(in)                    :: upd
      integer, intent(out)                     :: info
    end subroutine mld_sas_bld
  end interface mld_as_bld

  interface mld_diag_bld
    subroutine mld_sdiag_bld(a,desc_data,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      integer, intent(out) :: info
      type(psb_sspmat_type), intent(in), target :: a
      type(psb_desc_type),intent(in)            :: desc_data
      type(mld_sbaseprec_type), intent(inout)    :: p
    end subroutine mld_sdiag_bld
  end interface mld_diag_bld

  interface mld_fact_bld
    subroutine mld_sfact_bld(a,p,upd,info,blck)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type), intent(in), target :: a
      type(mld_sbaseprec_type), intent(inout)    :: p
      integer, intent(out)                      :: info
      character, intent(in)                     :: upd
      type(psb_sspmat_type), intent(in), target, optional  :: blck
    end subroutine mld_sfact_bld
  end interface mld_fact_bld

  interface mld_ilu_bld
    subroutine mld_silu_bld(a,p,upd,info,blck)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      integer, intent(out) :: info
      type(psb_sspmat_type), intent(in), target :: a
      type(mld_sbaseprec_type), intent(inout)    :: p
      character, intent(in)                     :: upd
      type(psb_sspmat_type), intent(in), optional :: blck
    end subroutine mld_silu_bld
  end interface mld_ilu_bld

  interface mld_sludist_bld
    subroutine mld_ssludist_bld(a,desc_a,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type), intent(inout)   :: a
      type(psb_desc_type), intent(in)         :: desc_a
      type(mld_sbaseprec_type), intent(inout) :: p
      integer, intent(out)                    :: info
    end subroutine mld_ssludist_bld
  end interface mld_sludist_bld

  interface mld_slu_bld
    subroutine mld_sslu_bld(a,desc_a,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type), intent(inout)      :: a
      type(psb_desc_type), intent(in)        :: desc_a
      type(mld_sbaseprec_type), intent(inout) :: p
      integer, intent(out)                   :: info
    end subroutine mld_sslu_bld
  end interface mld_slu_bld

  interface mld_umf_bld
    subroutine mld_sumf_bld(a,desc_a,p,info)
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_
      use mld_s_prec_type, only : mld_sbaseprec_type
      type(psb_sspmat_type), intent(inout)    :: a
      type(psb_desc_type), intent(in)         :: desc_a
      type(mld_sbaseprec_type), intent(inout) :: p
      integer, intent(out)                    :: info
    end subroutine mld_sumf_bld
  end interface mld_umf_bld


end module mld_s_inner_mod
