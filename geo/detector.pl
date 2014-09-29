#############################################################
#############################################################
#
#  Define the geometry for the EIC RICH detector
#  
#  All dimensions are in mm
#  Use the hit type flux
#  
#  The geometry are divided in 5 parts: 
#  Aerogel, Fresnel lens, Mirrors, Photonsensor, and Readout
#
#############################################################
#############################################################

use strict;
use warnings;
use Getopt::Long;
use Math::Trig;

our %configuration;


my $DetectorMother="root";
my $DetectorName = 'meic_det1_rich';
my $hittype="flux";

#######------ Define detector size and location ------####### 
my $agel_halfx = 55.25;
my $agel_halfy = 55.25;
my $agel_halfz = 10.0;

my $BoxDelz = -2.0;

my $lens_z = -25.0 + $BoxDelz;
my $phodet_z = 46.0 + $BoxDelz;
my $phodet_halfx = $agel_halfx*0.8;
my $phodet_halfy = $agel_halfy*0.8;
my $phodet_halfz = 1.0;

my $readout_halfz = 4.0;
my @readout_z = ($phodet_z-$phodet_halfz+3.0, $phodet_z-$phodet_halfz+2.0*$readout_halfz);
# Size of the optical active area of the lens.
my $LensDiameter = 2.0*$agel_halfx*sqrt(2.0);

my $box_halfx = $agel_halfx + 1.0;
my $box_halfy = $agel_halfy + 1.0;
my $box_halfz = (-1.0*$lens_z+2.0*$agel_halfz+$readout_z[1]+$readout_halfz+0.0 )/2.0;


my $offset = 2*$box_halfz;

#######------ Define the holder Box for Detectors ------#######
my $box_name = "detector_holder";
my $box_mat = "Air_Opt";
sub build_box()
{
	my @box_pos  = ( 0.0, 0.0, $offset );
	my @box_size = ( $box_halfx, $box_halfy, $box_halfz );
        my %detector=init_det();
        $detector{"name"} = "$DetectorName\_$box_name";
        $detector{"mother"} = "$DetectorMother";
        $detector{"description"} = "$DetectorName\_$box_name";
        $detector{"pos"} = "$box_pos[0]*mm $box_pos[1]*mm $box_pos[2]*mm";
        $detector{"color"} = "ffffff";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$box_size[0]*mm $box_size[1]*mm $box_size[2]*mm";
        $detector{"material"} = "$box_mat";
        print_det(\%configuration, \%detector);
}

#######------ Aerogel ------#######
my $agel_name = "Aerogel";
my $agel_mat  = "aerogel";
sub build_aerogel()
{
	my @agel_pos  = ( 0.0, 0.0, $lens_z - $agel_halfz - 1.5 + $BoxDelz );
	my @agel_size = ( $agel_halfx, $agel_halfy, $agel_halfz );
        my %detector=init_det();
        $detector{"name"} = "$DetectorName\_$agel_name";
        $detector{"mother"} = "$DetectorName\_$box_name";
        $detector{"description"} = "$DetectorName\_$agel_name";
        $detector{"pos"} = "$agel_pos[0]*mm $agel_pos[1]*mm $agel_pos[2]*mm";
        $detector{"color"} = "ffa500";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$agel_size[0]*mm $agel_size[1]*mm $agel_size[2]*mm";
        $detector{"material"} = "$agel_mat";
        $detector{"sensitivity"} = "no";
        $detector{"hit_type"}    = "no";
        $detector{"identifiers"} = "aerogel manual 1";
        print_det(\%configuration, \%detector);
}

######------ Fresnel lens ------######
my $lens_holdbox = "lens_holder";
my $lens_name = "lens";
my $lens_mat  = "acrylic";
sub build_lens()
{
	my $lens_numOfHoldBox = 4;   ### number of hold box for fresnel lens
	my $lens_numOfGrooves = 100;   ### number of grooves for fresnel lens

	###### Properites of the fresnel lens
	my $GrooveWidth = ($LensDiameter/2.0)/$lens_numOfGrooves;
	if($GrooveWidth<=0) { 
		print "build_lens::GrooveWidth <= 0\n";
	}
	my $Rmin1 = ($lens_numOfGrooves-1)*$GrooveWidth;
	my $Rmax1 = ($lens_numOfGrooves-0)*$GrooveWidth;
	my $LensThickness = GetSagita($Rmax1)-GetSagita($Rmin1)+1.; #1 mm wider 

	###### build holder box for fresnel lens
	my $quadpos = sqrt(2.0)*$LensDiameter/8.0; 
	my @lens_holdbox_posX = ( -1*$quadpos, -1*$quadpos, $quadpos, $quadpos );
	my @lens_holdbox_posY = ( $quadpos, -1*$quadpos, -1*$quadpos, $quadpos );
	my @lens_holdbox_posZ = ( $lens_z+$BoxDelz, $lens_z+$BoxDelz, $lens_z+$BoxDelz, $lens_z+$BoxDelz);
	my @lens_holdbox_size = ( $quadpos, $quadpos, $LensThickness/2.0+0.25);
	my @lens_holdbox_rotZ = ( 0, -90, -180, -270 );
	my $lens_holdbox_col = "ff0000";

	for(my $iholdbox=0; $iholdbox<$lens_numOfHoldBox; $iholdbox++){
		my %detector=init_det();
		$detector{"name"} = "$DetectorName\_$lens_holdbox\_$iholdbox";
		$detector{"mother"} = "$DetectorName\_$box_name";
		$detector{"description"} = "$DetectorName\_$lens_holdbox\_$iholdbox";
		$detector{"pos"} = "$lens_holdbox_posX[$iholdbox]*mm $lens_holdbox_posY[$iholdbox]*mm $lens_holdbox_posZ[$iholdbox]*mm";
		$detector{"color"} = "$lens_holdbox_col";
		$detector{"type"} = "Box";
		$detector{"dimensions"} = "$lens_holdbox_size[0]*mm $lens_holdbox_size[1]*mm $lens_holdbox_size[2]*mm";
		$detector{"material"} = "$box_mat";
		$detector{"rotation"} = "0*deg 0*deg $lens_holdbox_rotZ[$iholdbox]*deg";
		$detector{"identifiers"} = "no";
		print_det(\%configuration, \%detector);

### build fresnel lens groove
		for(my $igroove=0; $igroove<$lens_numOfGrooves; $igroove++){
			my @lens_grooves_pos = ( sqrt(2.0)*$LensDiameter/8.0, -sqrt(2.0)*$LensDiameter/8.0, 0.0 );

## Taper the outer part of the lens to a square shape, using PhiAngle (From Hubert)
			my $circle_end = ($igroove/$lens_numOfGrooves)*(($lens_numOfGrooves+1)/$lens_numOfGrooves);
			my $lens_startphi;
			my $lens_deltaphi;
			if ($circle_end>99.6*sqrt(2.0)) {          ## test marker at the tips 99.6->0.6
				$lens_startphi = pi/2.0;
				$lens_deltaphi = 0.1;
			}
			elsif ($circle_end<0.5*sqrt(2.0)) {      ## quarter-circle, as before
				$lens_startphi = pi/2.0;
				$lens_deltaphi = pi/2.0;
			}
			else {                                    ## taper to a point
				my $start_angle = 0.5*asin( 1/($circle_end**2) -1.0 );
				$lens_startphi = -1*$start_angle+0.75*pi;
				$lens_deltaphi =  2.0*$start_angle;
			}

			$lens_startphi = $lens_startphi*180/pi;
			$lens_deltaphi = $lens_deltaphi*180/pi;

			my $iRmin1 = ($igroove+0)*$GrooveWidth;
			my $iRmax1 = ($igroove+1)*$GrooveWidth;
			my $iRmin2 = $iRmin1;
			my $iRmax2 = $iRmin2+0.0001;
			my $dZ 	   = GetSagita($iRmax1) - GetSagita($iRmin1);
			if($dZ<=0) { 
				print "build_lens::Groove depth<0 !\n";
			}

			my @lens_poly_z    = (-1*$LensThickness/2.0, $LensThickness/2.0-$dZ, $LensThickness/2.0);
			my @lens_poly_rmin = ($iRmin1, $iRmin1, $iRmin2);
			my @lens_poly_rmax = ($iRmax1, $iRmax1, $iRmax2);

			%detector=init_det();
			$detector{"name"} = "$DetectorName\_$lens_name\_$iholdbox\_$igroove";
			$detector{"mother"} = "$DetectorName\_$lens_holdbox\_$iholdbox";
			$detector{"description"} = "$DetectorName\_$lens_name\_$iholdbox\_$igroove";
			$detector{"pos"} = "$lens_grooves_pos[0]*mm $lens_grooves_pos[1]*mm $lens_grooves_pos[2]*mm";
			$detector{"color"} = "ff00ff";
			$detector{"type"} = "Polycone";
			my $dimen = "$lens_startphi*deg $lens_deltaphi*deg 3*counts";
			for(my $i = 0; $i <3; $i++) {$dimen = $dimen ." $lens_poly_rmin[$i]*mm";}
			for(my $i = 0; $i <3; $i++) {$dimen = $dimen ." $lens_poly_rmax[$i]*mm";}
			for(my $i = 0; $i <3; $i++) {$dimen = $dimen ." $lens_poly_z[$i]*mm";}
			$detector{"dimensions"} = "$dimen";
			$detector{"material"} = "$lens_mat";
			$detector{"sensitivity"} = "no";
			$detector{"hit_type"}    = "no";
			$detector{"identifiers"} = "no";
			print_det(\%configuration, \%detector);
		}
	}
}

sub GetSagita
{
	my $Conic = -1.0;			## original
	my $lens_type = 3;
	my $Curvature;
	my @Aspher = (0, 0, 0, 0, 0, 0, 0, 0 );

	if ($lens_type == 1) {
		$Curvature = 0.00437636761488;
		$Aspher[0] = 4.206739256e-05;
		$Aspher[1] = 9.6440152e-10;
		$Aspher[2] = -1.4884317e-15;
	}

	if ($lens_type == 2) {			## r=77mm, f~14cm
		$Curvature = 0.0132;
		$Aspher[0] = 32.0e-05;
		$Aspher[1] = -2.0e-7;
		$Aspher[2] =  1.2e-13;
	}

       if ($lens_type == 3) {			## r=77mm, f~12.5cm
       	$Curvature = 0.0150;
       	$Aspher[0] = 42.0e-05;
       	$Aspher[1] = -3.0e-7;
       	$Aspher[2] =  1.2e-13;
       }
	if ($lens_type == 4) {			## r=77mm, f~10cm
		$Curvature = 0.0175;
		$Aspher[0] = 72.0e-05;
		$Aspher[1] = -5.0e-7;
		$Aspher[2] =  1.2e-13;
	}

	my $TotAspher = 0.0;

	for(my $k=1;$k<9;$k++){
		$TotAspher += $Aspher[$k-1]*($_[0]**(2*$k));
	}

	my $ArgSqrt = 1.0-(1.0+$Conic)*($Curvature**2)*($_[0]**2);

	if ($ArgSqrt < 0.0){
		print "build_lens::Sagita: Square Root of <0 ! \n";
	}
	my $Sagita_value = $Curvature*($_[0]**2)/(1.0+sqrt($ArgSqrt)) + $TotAspher;

	return $Sagita_value ;
}


######------ photon detector ------######
my $photondet_name = "Photondet";
#my $photondet_mat  = "Aluminum";
my $photondet_mat  = "G4_Al";
sub build_photondet()
{
	my @photondet_pos  = ( 0.0, 0.0, $phodet_z );
	my @photondet_size = ( $phodet_halfx, $phodet_halfy, $phodet_halfz );
	my %detector=init_det();
	$detector{"name"} = "$DetectorName\_$photondet_name";
	$detector{"mother"} = "$DetectorName\_$box_name";
	$detector{"description"} = "$DetectorName\_$photondet_name";
	$detector{"pos"} = "$photondet_pos[0]*mm $photondet_pos[1]*mm $photondet_pos[2]*mm";
	$detector{"rotation"} = "0*deg 0*deg 0*deg";
	$detector{"color"} = "0000A0";
	$detector{"type"} = "Box";
	$detector{"dimensions"} = "$photondet_size[0]*mm $photondet_size[1]*mm $photondet_size[2]*mm";
	$detector{"material"} = "$photondet_mat";
	$detector{"mfield"} = "no";
	$detector{"sensitivity"} = "$hittype";
	$detector{"hit_type"}    = "$hittype";
	$detector{"identifiers"} = "photondet manual 1";
	print_det(\%configuration, \%detector);
}


######------ reflection mirrors ------######
my $mirror_mat  = "Aluminum";
sub build_mirrors()
{
	my $dx1 = $agel_halfx;
	my $dx2 = $agel_halfx*0.8;
	my $dy1 = 0.1;
	my $dy2 = 0.1;
	my $dz = ($phodet_z - $lens_z - $phodet_halfz - 3.0)/2.0;
	my $phi = atan2($agel_halfx-$phodet_halfx, 2.0*$dz);
	my $delxy = $dz*sin($phi) + 1.0;
	my $dz_update = sqrt( $dz**2 + ($agel_halfx-$phodet_halfx)**2 );

	my $mirror_halfx = $agel_halfx;
	my $mirror_halfy = 1.0;
	my $mirror_halfz = ($phodet_z-$lens_z-$phodet_halfz-1.0)/2.0;
	my $lens_halfz = 3.0;

	####### back mirror
	my $phi_back = $phi*180.0/pi;
	my @mirror_back_pos  = ( $agel_halfy+$mirror_halfy-$delxy, 0.0, ($lens_z+$lens_halfz+($phodet_z-$phodet_halfz))/2.0+$BoxDelz );
	my $mirror_back_name = "mirror_back";
        my %detector=init_det();
        $detector{"name"} = "$DetectorName\_$mirror_back_name";
        $detector{"mother"} = "$DetectorName\_$box_name";
        $detector{"description"} = "$DetectorName\_$mirror_back_name";
        $detector{"pos"} = "$mirror_back_pos[0]*mm $mirror_back_pos[1]*mm $mirror_back_pos[2]*mm";
        $detector{"rotation"} = "0*deg $phi_back*deg 90*deg";
        $detector{"color"} = "00ff00";
        $detector{"type"} = "Trd";
        $detector{"dimensions"} = "$dx1*mm $dx2*mm $dy1*mm $dy2*mm $dz_update*mm";
        $detector{"material"} = "$mirror_mat";
	$detector{"sensitivity"} = "mirror: rich_mirrors";
	$detector{"hit_type"} = "mirror";
        $detector{"identifiers"} = "no";
        print_det(\%configuration, \%detector);

	
	####### front mirror
	my $phi_front = -1.0*$phi*180.0/pi;
	my @mirror_front_pos  = ( -1.*($agel_halfy+$mirror_halfy-$delxy), 0.0, ($lens_z+$lens_halfz+($phodet_z-$phodet_halfz))/2.0+$BoxDelz );
	my $mirror_front_name = "mirror_front";
        %detector=init_det();
        $detector{"name"} = "$DetectorName\_$mirror_front_name";
        $detector{"mother"} = "$DetectorName\_$box_name";
        $detector{"description"} = "$DetectorName\_$mirror_front_name";
        $detector{"pos"} = "$mirror_front_pos[0]*mm $mirror_front_pos[1]*mm $mirror_front_pos[2]*mm";
        $detector{"rotation"} = "0*deg $phi_front*deg 90*deg";
        $detector{"color"} = "00ff00";
        $detector{"type"} = "Trd";
        $detector{"dimensions"} = "$dx1*mm $dx2*mm $dy1*mm $dy2*mm $dz_update*mm";
        $detector{"material"} = "$mirror_mat";
	$detector{"sensitivity"} = "mirror: rich_mirrors";
	$detector{"hit_type"} = "mirror";
        $detector{"identifiers"} = "no";
        print_det(\%configuration, \%detector);
	
	####### top mirror
	my $phi_top = -1.0*$phi*180.0/pi;
	my @mirror_top_pos  = ( 0.0, $agel_halfy+$mirror_halfy-$delxy, ($lens_z+$lens_halfz+($phodet_z-$phodet_halfz))/2.0+$BoxDelz );
	my $mirror_top_name = "mirror_top";
        %detector=init_det();
        $detector{"name"} = "$DetectorName\_$mirror_top_name";
        $detector{"mother"} = "$DetectorName\_$box_name";
        $detector{"description"} = "$DetectorName\_$mirror_top_name";
        $detector{"pos"} = "$mirror_top_pos[0]*mm $mirror_top_pos[1]*mm $mirror_top_pos[2]*mm";
        $detector{"rotation"} = "$phi_top*deg 0*deg 0*deg";
        $detector{"color"} = "00ff00";
        $detector{"type"} = "Trd";
        $detector{"dimensions"} = "$dx1*mm $dx2*mm $dy1*mm $dy2*mm $dz_update*mm";
        $detector{"material"} = "$mirror_mat";
	$detector{"sensitivity"} = "mirror: rich_mirrors";
	$detector{"hit_type"} = "mirror";
        $detector{"identifiers"} = "no";
        print_det(\%configuration, \%detector);

	####### bottom mirror
	my $phi_bottom = $phi*180.0/pi;
	my @mirror_bottom_pos  = ( 0.0, -1.0*($agel_halfy+$mirror_halfy-$delxy), ($lens_z+$lens_halfz+($phodet_z-$phodet_halfz))/2.0+$BoxDelz );
	my $mirror_bottom_name = "mirror_bottom";
        %detector=init_det();
        $detector{"name"} = "$DetectorName\_$mirror_bottom_name";
        $detector{"mother"} = "$DetectorName\_$box_name";
        $detector{"description"} = "$DetectorName\_$mirror_bottom_name";
        $detector{"pos"} = "$mirror_bottom_pos[0]*mm $mirror_bottom_pos[1]*mm $mirror_bottom_pos[2]*mm";
        $detector{"rotation"} = "$phi_bottom*deg 0*deg 0*deg";
        $detector{"color"} = "00ff00";
        $detector{"type"} = "Trd";
        $detector{"dimensions"} = "$dx1*mm $dx2*mm $dy1*mm $dy2*mm $dz_update*mm";
        $detector{"material"} = "$mirror_mat";
	$detector{"sensitivity"} = "mirror: rich_mirrors";
	$detector{"hit_type"} = "mirror";
        $detector{"identifiers"} = "no";
        print_det(\%configuration, \%detector);
}


######------ readout hardware ------######
my $readoutdet_name = "readout";
my $readout_mat  = "Aluminum";
my @readoutdet_pos  = ( 0.0, 0.0, 0.0 );
my @readout_rinner = ( $phodet_halfx+1, $phodet_halfx+1 );
my @readout_router = ( $agel_halfx, $agel_halfy );

sub build_readout()
{
        my %detector=init_det();
        $detector{"name"} = "$DetectorName\_$readoutdet_name";
        $detector{"mother"} = "$DetectorName\_$box_name";
        $detector{"description"} = "$DetectorName\_$readoutdet_name";
        $detector{"pos"} = "$readoutdet_pos[0]*mm $readoutdet_pos[1]*mm $readoutdet_pos[2]*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = "ff0000";
	$detector{"type"} = "Pgon";    ### Polyhedra
	my $dimen = "45*deg 360*deg 4*counts 2*counts";
	for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $readout_rinner[$i]*mm";}
	for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $readout_router[$i]*mm";}
	for(my $i=0; $i<2; $i++) {$dimen = $dimen ." $readout_z[$i]*mm";}
	$detector{"dimensions"} = "$dimen";
        $detector{"material"} = "$readout_mat";
        $detector{"sensitivity"} = "no";
        $detector{"hit_type"}    = "no";
        $detector{"identifiers"} = "no";
        print_det(\%configuration, \%detector);

}


sub build_detector()
{
	build_box();
	build_aerogel();
	build_lens();
	build_photondet();
	build_mirrors();
	build_readout();
}
