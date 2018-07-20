module esh3d

  use utils  
  implicit none

contains 

  ! Calculate Is
  subroutine EshS4(vm,a,S4,PIvec)  
    implicit none  
    real(8) :: vm,a(3),Ifir(3),Isec(3,3),rate,theta,m,B,D,F,E,denom,           &
        Sten(3,3,3,3),S4(6,6),PIvec(3)
    rate=a(1)/a(3)
    ! Check geometry category, assuming a(1)>a(2)>a(3)
    if (a(1)-a(2)<1.d-6*a(1) .and. a(2)-a(3)<1.d-6*a(1)) then ! Spherical case 
       Ifir=(f4/f3)*pi
       Isec=0.8*pi*a(1)**2
    elseif (a(1)-a(2)>1.d-6*a(1) .and. a(2)-a(3)<1.d-6*a(1)) then ! Prolate case 
       Ifir(2)=f2*pi*a(1)*a(3)**2/((a(1)**2-a(3)**2)**1.5)                     &
          *(rate*sqrt(rate**2-f1)-acosh(rate))
       Ifir(3)=Ifir(2) 
       Ifir(1)=f4*pi-2*Ifir(2) 
       Isec=f0
       Isec(1,2)=(Ifir(2)-Ifir(1))/(a(1)**2-a(2)**2)
       Isec(1,3)=Isec(1,2) 
       Isec(2,1)=Isec(1,2)
       Isec(3,1)=Isec(1,3)
       Isec(1,1)=(f4*pi/a(1)**2-f2*Isec(1,2))/f3
       Isec(2,3)=pi/(a(2)**2)-(Ifir(2)-Ifir(1))/(f4*(a(1)**2-a(2)**2))
       Isec(3,2)=Isec(2,3)
       Isec(2,2)=Isec(2,3)
       Isec(3,3)=Isec(2,3)
    elseif (a(1)-a(2)<1.d-6*a(1) .and. a(2)-a(3)>1.d-6*a(2)) then ! Oblate case
       rate=a(3)/a(1)
       Ifir(1)=f2*pi*a(1)**2*a(3)/((a(1)**2-a(3)**2)**1.5)*(acos(rate)         &
               -rate*sqrt(1-rate**2))
       Ifir(2)=Ifir(1)
       Ifir(3)=f4*pi-2*Ifir(1)
       Isec=f0
       Isec(1,3)=(Ifir(1)-Ifir(3))/(a(3)**2-a(1)**2)
       Isec(3,1)=Isec(1,3)
       Isec(2,3)=Isec(1,3)
       Isec(3,2)=Isec(2,3)
       Isec(1,2)=pi/a(1)**2-Isec(1,3)*0.25
       Isec(2,1)=Isec(1,2)
       Isec(1,1)=Isec(1,2)
       Isec(2,2)=Isec(1,2)
       Isec(3,3)=(f4*pi/a(3)**2-f2*Isec(1,3))/f3
    else ! Ellipsoid case
       theta=asin(sqrt(1-(a(3)/a(1))**2))
       m=(a(1)**2-a(2)**2)/(a(1)**2-a(3)**2)
       call elbd(theta,0.5*pi-theta,f1-m,B,D)
       F=B+D; E=B+(f1-m)*D
       Ifir(1)=(f4*pi*product(a)/((a(1)**2-a(2)**2)*sqrt(a(1)**2-a(3)**2)))    &
          *(F-E)
       Ifir(3)=(f4*pi*product(a)/((a(2)**2-a(3)**2)*sqrt((a(1)**2-a(3)**2))))  &
          *(a(2)*sqrt((a(1)**2-a(3)**2))/(a(1)*a(3))-E)
       Ifir(2)=f4*pi-Ifir(1)-Ifir(3)
       Isec=f0
       Isec(1,2)=(Ifir(2)-Ifir(1))/(a(1)**2-a(2)**2)
       Isec(2,3)=(Ifir(3)-Ifir(2))/(a(2)**2-a(3)**2)
       Isec(3,1)=(Ifir(1)-Ifir(3))/(a(3)**2-a(1)**2)
       Isec(2,1)=Isec(1,2)
       Isec(3,2)=Isec(2,3)
       Isec(1,3)=Isec(3,1)
       Isec(1,1)=(f4*pi/a(1)**2-Isec(1,2)-Isec(1,3))/f3
       Isec(2,2)=(f4*pi/a(2)**2-Isec(2,3)-Isec(2,1))/f3
       Isec(3,3)=(f4*pi/a(3)**2-Isec(3,1)-Isec(3,2))/f3
    end if
    denom=f8*pi*(f1-vm);
    Sten(1,1,1,1)=(f3*a(1)**2*Isec(1,1)+(f1-2*vm)*Ifir(1))/denom
    Sten(2,2,2,2)=(f3*a(2)**2*Isec(2,2)+(f1-2*vm)*Ifir(2))/denom
    Sten(3,3,3,3)=(f3*a(3)**2*Isec(3,3)+(f1-2*vm)*Ifir(3))/denom
    Sten(1,1,2,2)=(a(2)**2*Isec(1,2)-(f1-2*vm)*Ifir(1))/denom
    Sten(2,2,3,3)=(a(3)**2*Isec(2,3)-(f1-2*vm)*Ifir(2))/denom
    Sten(3,3,1,1)=(a(1)**2*Isec(3,1)-(f1-2*vm)*Ifir(3))/denom
    Sten(1,1,3,3)=(a(3)**2*Isec(1,3)-(f1-2*vm)*Ifir(1))/denom
    Sten(2,2,1,1)=(a(1)**2*Isec(2,1)-(f1-2*vm)*Ifir(2))/denom
    Sten(3,3,2,2)=(a(2)**2*Isec(3,2)-(f1-2*vm)*Ifir(3))/denom
    Sten(1,2,1,2)=((a(1)**2+a(2)**2)*Isec(1,2)+(f1-f2*vm)*(Ifir(1)+Ifir(2)))   &
       /(2*denom)
    Sten(2,3,2,3)=((a(2)**2+a(3)**2)*Isec(2,3)+(f1-f2*vm)*(Ifir(2)+Ifir(3)))   &
       /(2*denom)
    Sten(3,1,3,1)=((a(3)**2+a(1)**2)*Isec(3,1)+(f1-f2*vm)*(Ifir(3)+Ifir(1)))   &
       /(2*denom)
    Sten(1,3,1,3)=Sten(3,1,3,1)
    ! Original stress order 
    !S4(1,:)=(/Sten(1,1,1,1),f0,f0,Sten(1,1,2,2),f0,Sten(1,1,3,3)/) 
    !S4(2,:)=(/f0,2*Sten(1,2,1,2),f0,f0,f0,f0/)
    !S4(3,:)=(/f0,f0,2*Sten(1,3,1,3),f0,f0,f0/)
    !S4(4,:)=(/Sten(2,2,1,1),f0,f0,Sten(2,2,2,2),f0,Sten(2,2,3,3)/)
    !S4(5,:)=(/f0,f0,f0,f0,2*Sten(2,3,2,3),f0/)
    !S4(6,:)=(/Sten(3,3,1,1),f0,f0,Sten(3,3,2,2),f0,Sten(3,3,3,3)/)
    ! FEM stress order
    S4(1,:)=(/Sten(1,1,1,1),Sten(1,1,2,2),Sten(1,1,3,3),f0,f0,f0/)
    S4(2,:)=(/Sten(2,2,1,1),Sten(2,2,2,2),Sten(2,2,3,3),f0,f0,f0/)
    S4(3,:)=(/Sten(3,3,1,1),Sten(3,3,2,2),Sten(3,3,3,3),f0,f0,f0/)
    S4(4,:)=(/f0,f0,f0,2*Sten(1,2,1,2),f0,f0/)
    S4(5,:)=(/f0,f0,f0,f0,2*Sten(2,3,2,3),f0/)
    S4(6,:)=(/f0,f0,f0,f0,f0,2*Sten(1,3,1,3)/)
    PIvec(2)=-f2*(Ifir(1)-Ifir(3))/(f8*pi)
    PIvec(3)=-f2*(Ifir(2)-Ifir(1))/(f8*pi)
    PIvec(1)=-f2*(Ifir(3)-Ifir(2))/(f8*pi)
  end subroutine EshS4    

  subroutine EshD4(vm,a,x,D4,fderphi,tderpsi)
    implicit none
    integer :: i,j,k,l,q,p,r
    real(8) :: vm,a(3),x(3),D4(3,3,3,3),fderphi(3),tderpsi(3,3,3) ! In(out)put
    real(8) :: a_21(3,3),a_22(3,3),coef(1:4,0:4),root(1:4),root_im2,root_im3,  &
               lambda,theta,m,B,D,F,F_21(3,3),F_22(3,3),E,Ifir(3),Isec(3,3),   &
               del,bbar,dbar,ultadelfir(3),ultadelfir_21(3,3),                 &
               ultadelfir_22(3,3),ultadelsec(3,3),fderlambda(3),               &
               fderlambda_21(3,3),c1,c2,c3,fderlambda_22(3,3),diagvals(3,3),   &
               nondiagvals(3,3),fderc1(3),fderc1_21(3,3),fderc1_22(3,3),       &
               fderF(3,3),sderc1(3,3),sderlambda(3,3),fderIfir(3,3),           &
               sderF(3,3,3),zeefir(3),zeesec(3,3),sderIfir(3,3,3),             &
               fderIsec(3,3,3),sderIsec(3,3,3,3),tderlambda(3,3,3),            &
               sderVfir(3,3,3),tderVfir(3,3,3,3),sderphi(3,3),tderphi(3,3,3),  &
               foderpsi(3,3,3,3),premult1,delta1,delta2,delta3,delta4,delta5,  &
               Fvec(3),fderc2(3),fderc2_21(3,3),fderc2_22(3,3)
    coef=f0
    coef(3,3)=f1 ! coefficient of lambds**3 term
    coef(3,2)=a(1)**2+a(2)**2+a(3)**2-(x(1)**2+x(2)**2+x(3)**2) 
    coef(3,1)=a(1)**2*a(2)**2+a(1)**2*a(3)**2+a(2)**2*a(3)**2-((a(2)**2+       &
              a(3)**2)*x(1)**2+(a(1)**2+a(3)**2)*x(2)**2+(a(1)**2+a(2)**2)     &
              *x(3)**2) 
    coef(3,0)=a(1)**2*a(2)**2*a(3)**2-(a(2)**2*a(3)**2*x(1)**2+a(1)**2*a(3)**2*&
              x(2)**2+a(1)**2*a(2)**2*x(3)**2) 
    call Root_4(3,coef,root,root_im2,root_im3)
    lambda=f0
    if (x(1)**2/a(1)**2+x(2)**2/a(2)**2+x(3)**2/a(3)**2>f1) then
       if (root_im2==f0 .and. root_im3==f0) then 
          lambda=max(f0,maxval(root))
       else 
          lambda=max(f0,root(3))
       end if 
    end if
    theta=asin(sqrt((a(1)**2-a(3)**2)/(a(1)**2+lambda))) ! the amplitude
    m=(a(1)**2-a(2)**2)/(a(1)**2-a(3)**2) ! m=k**2 is the parameter
    call elbd(theta,0.5*pi-theta,f1-m,B,D)
    F=B+D; E=B+(f1-m)*D
    ! Calculation of Is 
    if (a(1)==a(2) .and. a(1)==a(3)) then
       Ifir=(4/3)*pi*a(1)**3/(a(1)**2+lambda)**(3/2)
       Isec=(4/5)*pi*a(1)**3/(a(1)**2+lambda)**(1/2)
    elseif (a(1)>a(2) .and. a(3)==a(2)) then
       del=sqrt((a(1)**2+lambda)*(a(2)**2+lambda)*(a(3)**2+lambda))
       bbar=sqrt(a(1)**2+lambda)/sqrt(a(3)**2+lambda)
       dbar=sqrt(a(1)**2-a(3)**2)/sqrt(a(3)**2+lambda)
       Ifir(1)=4*pi*a(1)*a(2)**2*(acosh(bbar)-dbar/bbar)/(a(1)**2-a(2)**2)**1.5
       Ifir(2)=2*pi*a(1)*a(2)**2*(-acosh(bbar)+dbar*bbar)/(a(1)**2-a(2)**2)**1.5
       Ifir(3)=Ifir(2)
       Isec(1,2)=(Ifir(2)-Ifir(1))/(a(1)**2-a(2)**2)
       Isec(1,3)=Isec(1,2)
       Isec(2,1)=Isec(1,2)
       Isec(3,1)=Isec(1,3)
       Isec(2,3)=pi*product(a)/((a(3)**2+lambda)*del)-Isec(1,3)*0.25
       Isec(3,2)=Isec(2,3)
       Isec(1,1)=((f4*pi*product(a))/((a(1)**2+lambda)*del)-Isec(1,2)-         &
                 Isec(1,3))/f3
       Isec(2,2)=Isec(2,3)
       Isec(3,3)=Isec(2,3)
    elseif (a(1)==a(2) .and. a(2)>a(3)) then
       del=sqrt((a(1)**2+lambda)*(a(2)**2+lambda)*(a(3)**2+lambda))
       bbar=sqrt(a(3)**2+lambda)/sqrt(a(1)**2+lambda)
       dbar=sqrt(a(1)**2-a(3)**2)/sqrt(a(1)**2+lambda)
       Ifir(1)=2*pi*a(1)**2*a(3)*(acos(bbar)-dbar*bbar)/(a(1)**2-a(3)**2)**1.5
       Ifir(2)=Ifir(1)
       Ifir(3)=4*pi*product(a)/del-2*Ifir(1)
       Isec(1,3)=(Ifir(3)-Ifir(1))/(a(1)**2-a(3)**2)
       Isec(3,1)=Isec(1,3)
       Isec(2,3)=Isec(1,3)
       Isec(3,2)=Isec(2,3)
       Isec(1,1)=pi*product(a)/((a(1)**2+lambda)*del)-Isec(1,3)*0.25
       Isec(1,2)=Isec(1,1)
       Isec(2,1)=Isec(1,2)
       Isec(2,2)=Isec(1,1)
       Isec(3,3)=((f4*pi*product(a))/((a(3)**2+lambda)*del)-Isec(1,3)-         &
                 Isec(2,3))/f3
    else
       del=sqrt((a(1)**2+lambda)*(a(2)**2+lambda)*(a(3)**2+lambda))
       Ifir(1)=f4*pi*product(a)*F/sqrt(a(1)**2-a(3)**2)*(f1-E/F)/(a(1)**2-     &
               a(2)**2)
       Ifir(2)=f4*pi*product(a)*(E*sqrt(a(1)**2-a(3)**2)/((a(1)**2-a(2)**2)*   &
               (a(2)**2-a(3)**2))-F/((a(1)**2-a(2)**2)*sqrt(a(1)**2-a(3)**2))- &
               (f1/(a(2)**2-a(3)**2))*sqrt((a(3)**2+lambda)/((a(1)**2+lambda)* &
               (a(2)**2+lambda))))
       Ifir(3)=f4*pi*product(a)/del-Ifir(1)-Ifir(2)
       Isec(1,2)=(Ifir(2)-Ifir(1))/(a(1)**2-a(2)**2)
       Isec(2,1)=Isec(1,2)
       Isec(1,3)=(Ifir(3)-Ifir(1))/(a(1)**2-a(3)**2)
       Isec(3,1)=Isec(1,3)
       Isec(2,3)=(Ifir(3)-Ifir(2))/(a(2)**2-a(3)**2)
       Isec(3,2)=Isec(2,3)
       Isec(1,1)=((4*pi*product(a))/((a(1)**2+lambda)*del)-Isec(1,2)-          &
                 Isec(1,3))/f3
       Isec(2,2)=((4*pi*product(a))/((a(2)**2+lambda)*del)-Isec(1,2)-          &
                 Isec(2,3))/f3
       Isec(3,3)=((4*pi*product(a))/((a(3)**2+lambda)*del)-Isec(1,3)-          &
                 Isec(2,3))/f3
    end if

    ! I derivatives
    call buildtensors(a,a_21,a_22) 
    ultadelfir=-f2*pi*product(a)/((a**2+lambda)*del)
    call buildtensors(ultadelfir,ultadelfir_21,ultadelfir_22) 
    ultadelsec=-f2*pi*product(a)/((a_21**2+lambda)*(a_22**2+lambda)*del)
    ! derivatives of lambda 
    c1=sum((x**2)/((a**2+lambda)**2))
    c2=sum((x**2)/((a**2+lambda)**3))
    c3=sum((x**2)/((a**2+lambda)**4))
    Fvec=f2*x/(a**2+lambda)
    call buildtensors(Fvec,F_21,F_22)
    if (lambda==0) then 
       fderlambda=f0 
    else
       fderlambda=Fvec/c1
    end if 
    call buildtensors(fderlambda,fderlambda_21,fderlambda_22)
    diagvals=f0;nondiagvals=f0
    do i=1,3
       do j=1,3
          if (i==j) then
             diagvals(i,j)=f1
          else
             nondiagvals(i,j)=f1
          end if
       end do
    end do
    fderF=nondiagvals*(f1/(a_21**2+lambda))*(-F_21*fderlambda_22)+diagvals*    &
          (f1/(a_21**2+lambda))*(f2-F_21*fderlambda_22)
    fderc1=Fvec/(a**2+lambda)-f2*c2*fderlambda
    call buildtensors(fderc1,fderc1_21,fderc1_22) 
    fderc2=Fvec/(a**2+lambda)**2-f3*c3*fderlambda
    call buildtensors(fderc2,fderc2_21,fderc2_22) 
    if (lambda==f0) then 
       sderlambda=f0 
    else
       sderlambda=(fderF-fderlambda_21*fderc1_22)/c1
    end if 
    sderc1=(f1/(a_21**2+lambda))*(fderF-fderlambda_22*F_21/(a_21**2+lambda))-  &
       f2*(fderc2_22*fderlambda_21+c2*sderlambda)
    fderIfir=ultadelfir_21*fderlambda_22
    do q=1,3 
       do p=1,3 
          do r=1,3 
             sderF(q,p,r)=-(fderF(q,p)*fderlambda(r)+fderF(q,r)*fderlambda(p)+ &
                          Fvec(q)*sderlambda(p,r))/(a(q)**2+lambda)
          end do 
       end do 
    end do
    zeefir=f1/(a**2+lambda)+0.5*sum(f1/(a**2+lambda))
    zeesec=f1/(a_21**2+lambda)+f1/(a_22**2+lambda)+0.5*sum(f1/(a**2+lambda))
    do i=1,3 
       do j=1,3 
          do k=1,3 
             sderIfir(i,j,k)=ultadelfir(i)*(sderlambda(j,k)-fderlambda(j)*     &
                             fderlambda(k)*zeefir(i))
          end do 
       end do 
    end do 
    do i=1,3 
       do j=1,3 
          do k=1,3 
             fderIsec(i,j,k)=ultadelsec(i,j)*fderlambda(k)
          end do 
       end do 
    end do 
    do i=1,3 
       do j=1,3 
          do k=1,3 
             do l=1,3 
                sderIsec(i,j,k,l)=ultadelsec(i,j)*(sderlambda(k,l)-            &
                                  fderlambda(k)*fderlambda(l)*zeesec(i,j))
             end do 
          end do 
       end do 
    end do 
    do q=1,3 
       do p=1,3 
          do r=1,3 
             if (lambda==0) then 
                tderlambda(q,p,r)=f0
             else
                tderlambda(q,p,r)=(-f1/c1)*(sderlambda(q,p)*fderc1(r)-         &
                                  sderF(q,p,r)+sderlambda(q,r)*fderc1(p)+      &
                                  fderlambda(q)*sderc1(p,r))
             end if 
          end do 
       end do 
    end do 
    
    !Calculation of V-potentials 
    do i=1,3 
       do p=1,3 
          do q=1,3 
             call kdelta(p,q,delta1) 
             sderVfir(i,p,q)=-(delta1*Isec(p,i)+x(p)*fderIsec(p,i,q))
          end do 
       end do 
    end do 
    do i=1,3 
       do p=1,3 
          do q=1,3 
             do r=1,3 
                call kdelta(p,q,delta1); call kdelta(p,r,delta2)
                tderVfir(i,p,q,r)=-(delta1*fderIsec(p,i,r)+delta2*             &
                                  fderIsec(p,i,q)+x(p)*sderIsec(p,i,q,r))
             end do 
          end do 
       end do 
    end do 

    !calculation of phi derivatives 
    do p=1,3 
       do q=1,3 
          call kdelta(p,q,delta1) 
          sderphi(p,q)=-(delta1*Ifir(p)+x(p)*fderIfir(p,q))
       end do 
    end do 
    do p=1,3 
       do q=1,3 
          do r=1,3 
             call kdelta(p,q,delta1); call kdelta(p,r,delta2)
             tderphi(p,q,r)=-(delta1*fderIfir(p,r)+delta2*fderIfir(p,q)+x(p)*  &
                            sderIfir(p,q,r))
          end do 
       end do 
    end do 

    !psi's 
    do i=1,3 
       do j=1,3 
          do k=1,3 
             do l=1,3 
                call kdelta(i,j,delta1); call kdelta(i,k,delta2)
                call kdelta(i,l,delta3)
                foderpsi(i,j,k,l)=delta1*(sderphi(k,l)-a(i)**2*                &
                                  sderVfir(i,k,l))+delta2*(sderphi(j,l)-       &
                                  a(i)**2*sderVfir(i,j,l))+delta3*             &
                                  (sderphi(j,k)-a(i)**2*sderVfir(i,j,k))+      &
                                  x(i)*(tderphi(j,k,l)-a(i)**2*                &
                                  tderVfir(i,j,k,l))
             end do 
          end do 
       end do 
    end do 

    !calculation of D4 
    premult1=f1/(f8*pi*(f1-vm))
    do i=1,3 
       do j=1,3 
          do k=1,3 
             do l=1,3 
                call kdelta(k,l,delta1); call kdelta(i,l,delta2)
                call kdelta(j,l,delta3); call kdelta(i,k,delta4)
                call kdelta(j,k,delta5)
                D4(i,j,k,l)=premult1*(foderpsi(k,l,i,j)-f2*vm*delta1*          &
                            sderphi(i,j)-(f1-vm)*(sderphi(k,j)*delta2+         &
                            sderphi(k,i)*delta3+sderphi(l,j)*delta4+           &
                            sderphi(l,i)*delta5))
             end do 
          end do 
       end do 
    end do

    ! fderphi tderpsi
    fderphi=-x*Ifir
    do i=1,3
       do j=1,3
          do l=1,3  
             call kdelta(i,j,delta1); call kdelta(i,l,delta2)
             call kdelta(j,l,delta3)
             tderpsi(i,j,l)=-delta1*x(l)*(Ifir(l)-a(i)**2*Isec(i,l))-          &  
                            x(i)*x(j)*(fderIfir(j,l)-a(i)**2*fderIsec(i,j,l))- &
                            (delta2*x(j)+delta3*x(i))*(Ifir(j)-                &
                            a(i)**2*Isec(i,j))
          end do
       end do
    end do
  end subroutine EshD4   

  subroutine EshDisp(vm,eigen,fderphi,tderpsi,u)
    implicit none 
    integer :: i,j,k
    real(8) :: vm,u(3),eigen(6),fderphi(3),tderpsi(3,3,3),MatEigen(3,3),       &
        ut(3,1),SumDiag,fderphit(3,1),premult
    call Vec2Mat(eigen,MatEigen)
    SumDiag=f0; ut=f0
    do i=1,3
       do j=1,3
          do k=1,3
             ut(i,1)=ut(i,1)+tderpsi(i,j,k)*MatEigen(j,k);
          end do
       end do
       fderphit(i,1)=fderphi(i)
       SumDiag=SumDiag+MatEigen(i,i)
    end do
    premult=f1/(f8*pi*(f1-vm))
    ut=premult*(ut-f2*vm*SumDiag*fderphit-f4*(f1-vm)*matmul(MatEigen,fderphit))
    u=ut(:,1)
  end subroutine EshDisp

  subroutine EshSol(Em,vm,stress,ellip,ocoord,sol)
    implicit none
    integer :: i,j,k,l,m,n,nobs,nellip
    real(8) :: Em,vm,Eh,vh,ocoord(:,:),ellip(:,:),stress(6),sol(:,:) !In(out)put
    ! ellip(nellip,17): 1-3 ellipsoid centroid coordinate, 4-6 semi-axises, 7-9
    ! rotation angles around x,y and z axises, 10,11 inclusion Young's modulus 
    ! and Poisson's ratio, 12-17 eigen strain 
    ! stress(6): remote stress
    ! sol(nobs,9): 1-3 displacement, 4-9 stress 
    real(8) :: ang(3),a(3),tmp,exh(3,3),R_init(3,3),Rb_init(3,3),R(3,3),       &
       Rb(3,3),PIvec(3),Tstress(3,3),Cm(6,6),straint(6,1),stresst(6,1),        &
       eigent(6,1),Ch(6,6),dC(6,6),vert(3,1),D4(3,3,3,3),fderphi(3),           &
       tderpsi(3,3,3),disp(3),dispt(3,1),Ttmp(3,3),Vtmp(6,1),Teigen(3,3),S4(6,6)
    nobs=size(ocoord,1); nellip=size(ellip,1)
    sol=f0 ! Initial solution space
    do i=1,nellip
       a=ellip(i,4:6)
       ! Stage a1>=a2>=a3
       exh=0
       do k=1,2
          do l=2,3
             if (a(k)<a(l)) then
                exh(k,l)=f1
                tmp=a(k)
                a(k)=a(l)
                a(l)=tmp
             end if 
          end do
       end do
       ! Initial rotation matrices due to axis exchange
       ang=pi/f2*(/exh(2,3),exh(1,3),exh(1,2)/)
       call Ang2Mat(ang,R_init,f1)
       call Ang2Mat(ang,Rb_init,-f1)
       ! Rotation matrices w.r.t the ellipsoid
       ang=ellip(i,7:9)
       call Ang2Mat(ang,R,f1)
       call Ang2Mat(ang,Rb,-f1) 
       ! Eshelby's tensor
       call EshS4(vm,a,S4,PIvec) 
       ! Rotate stress and initial eigenstrain against oblique ellipsoid
       call Vec2Mat(stress,Tstress) 
       Tstress=matmul(matmul(matmul(R_init,Rb),Tstress),                       &
               transpose(matmul(R_init,Rb)))
       stresst(:,1)=(/Tstress(1,1),Tstress(2,2),Tstress(3,3),Tstress(1,2),     &
                    Tstress(2,3),Tstress(1,3)/)    
       call Vec2Mat(ellip(i,12:17),Teigen)    
       Teigen=matmul(matmul(matmul(R_init,Rb),Teigen),                         &
              transpose(matmul(R_init,Rb)))
       eigent(:,1)=(/Teigen(1,1),Teigen(2,2),Teigen(3,3),Teigen(1,2),          &
                   Teigen(2,3),Teigen(1,3)/) 
       Eh=ellip(i,10); vh=ellip(i,11)
       call CMat(Em,vm,Cm); call CMat(Eh,vh,Ch); dC=Ch-Cm
       call SolveSix(Cm,stresst,straint)
       call SolveSix(Cm-matmul(dC,S4),matmul(dC,straint)+matmul(Ch,eigent),    &
          eigent)
       call Vec2Mat(eigent(:,1),Teigen)
       do j=1,nobs
          vert(:,1)=ocoord(j,:)-ellip(i,:3) ! Relative coordinate
          vert=matmul(matmul(R_init,Rb),vert)
          call EshD4(vm,a,vert(:,1),D4,fderphi,tderpsi) 
          call EshDisp(vm,eigent(:,1),fderphi,tderpsi,disp)
          dispt(:,1)=disp
          ! Rotate back
          dispt=matmul(matmul(R,Rb_init),dispt)
          ! Record displacement
          sol(j,:3)=sol(j,:3)+dispt(:,1)
          if (vert(1,1)**2/a(1)**2+vert(2,1)**2/a(2)**2+vert(3,1)**2/a(3)**2   &
             <=1) then ! J-th obs interior to i-th inclusion 
             ! Total elastic stress
             stresst=stresst+matmul(Cm,(matmul(S4,eigent)-eigent))
          else ! J-th obs exterior to i-th inclusion
             Ttmp=f0 
             do k=1,3  
                do l=1,3 
                   do m=1,3 
                      do n=1,3 
                         Ttmp(k,l)=Ttmp(k,l)+D4(k,l,m,n)*Teigen(m,n) 
                      end do
                   end do
                end do
             end do
             Vtmp(:,1)=(/Ttmp(1,1),Ttmp(2,2),Ttmp(3,3),Ttmp(1,2),Ttmp(2,3),    &
                       Ttmp(1,3)/)
             ! Total elastic stress
             stresst=stresst+matmul(Cm,Vtmp)
          end if
          ! Rotate back to origin coordinate
          call Vec2Mat(stresst(:,1),Tstress)
          Tstress=matmul(matmul(matmul(R,Rb_init),Tstress),                    &
                  transpose(matmul(R,Rb_init)))
          stresst(:,1)=(/Tstress(1,1),Tstress(2,2),Tstress(3,3),               &
                       Tstress(1,2),Tstress(2,3),Tstress(1,3)/) 
          ! Record stress         
          sol(j,4:9)=sol(j,4:9)+stresst(:,1)
          stresst(:,1)=stress ! Rest to background stress 
       end do ! nobs
    end do ! nellip
  end subroutine EshSol    
end module esh3d