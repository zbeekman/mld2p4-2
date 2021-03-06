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
subroutine mld_z_base_onelev_csetc(lv,what,val,info,pos)
  
  use psb_base_mod
  use mld_z_onelev_mod, mld_protect_name => mld_z_base_onelev_csetc

  Implicit None

  ! Arguments
  class(mld_z_onelev_type), intent(inout) :: lv 
  character(len=*), intent(in)              :: what 
  character(len=*), intent(in)              :: val
  integer(psb_ipk_), intent(out)            :: info
  character(len=*), optional, intent(in)      :: pos
  ! Local 
  integer(psb_ipk_)  :: ipos_, err_act
  character(len=20) :: name='z_base_onelev_csetc'
  integer(psb_ipk_) :: ival 

  call psb_erractionsave(err_act)

  info = psb_success_

  ival = lv%stringval(val)
  if (ival >= 0) then 
    call lv%set(what,ival,info,pos=pos)
  else
    
    if (present(pos)) then
      select case(psb_toupper(trim(pos)))
      case('PRE')
        ipos_ = mld_smooth_pre_
      case('POST')
        ipos_ = mld_smooth_post_
      case default
        ipos_ = mld_smooth_both_
      end select
    else
      ipos_ = mld_smooth_both_
    end if

    if ((ipos_==mld_smooth_pre_) .or.(ipos_==mld_smooth_both_)) then 
      if (allocated(lv%sm)) then 
        call lv%sm%set(what,val,info)
      end if
    end if
    
    if ((ipos_==mld_smooth_post_).or.(ipos_==mld_smooth_both_))then 
      if (allocated(lv%sm2a)) then 
        call lv%sm2a%set(what,val,info)
      end if
    end if
    
  end if


  if (info /= psb_success_) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 call psb_error_handler(err_act)
  return

end subroutine mld_z_base_onelev_csetc
