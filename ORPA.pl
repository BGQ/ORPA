#!/usr/bin/perl
#
#AUTHOR
#Guiqi Bi :fenghen360@126.com
#VERSION
#ORPA v1.0
#COPYRIGHT & LICENCE
#This script is free software; you can redistribute it and/or modify it.
#This  script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of merchantability or fitness for a particular purpose.

my $USAGE = 	"\nusage: 
          perl ORPA.pl -method=[Gblocks|trimAl|BMGE|noisy] <file.aln> <seqdump.txt> <output.fasta> --iqtree
  or
          perl ORPA.pl -method=[Gblocks|trimAl|BMGE|noisy] <file.aln> <seqdump.txt> <output.fasta>
      
example:
          perl ORPA.pl -method=Gblocks file.aln seqdump.txt output.fasta --iqtree
  or
          perl ORPA.pl -method=Gblocks file.aln seqdump.txt output.fasta 
     
parameters:
           -method=[Gblocks|trimAl|BMGE|noisy]   To choose which program to be used in alignment trimming. (Default: Gblocks).
           <file.aln>                            FASTA alignment file, which is downloaded from NCBI Multiple Sequence Alignment Viewer.
           <seqdump.txt>                         Complete sequence seqdump file,which is download from NCBI BLAST online tool results.
           <output.fasta>                        The final constructed multiple sequence alignment matrix file.
           --iqtree                              Optional, use built-in iqtree to construct phylogenetic tree.
                                                 (Built-in Iqtree operating parameters:-st DNA -nt AUTO -bb 1000 -alrt 1000 -m MFP)\n";

my $method;
my $aln = $ARGV[1];
my $seqdump = $ARGV[2];
my $out = $ARGV[3];
my $iqtree;
my $character_length;

foreach my $paras (@ARGV){
	if ($paras=~/-help/){
		print $USAGE;
		exit;
	}
	if ($paras=~/-h/){
		print $USAGE;
		exit;
	}
	if ($paras=~/method/){
	    $method=(split "=", $paras)[1];
	}
	if ($paras=~/--iqtree/){
	    $iqtree=1;
	}
}
if (!$ARGV[1]){
		print $USAGE;
		exit;
		print "Please provide the raw blast alignment file download from MSA viewer!\n"
	}
if (!$ARGV[2]){
		print $USAGE;
		exit;
		print "Please provide the raw sequence file download from blastn results.\n"
	}
if (!$ARGV[3]){
		print $USAGE;
		exit;
		print "Please provide the name of output file.\n"
	}
		
print "\n\n\n                  
							********************                  
						        ****ORPA  start!****                  
							********************\n";
#-------------------------------------------------------------------------------------------

my @list = ();
open (LIST,$seqdump) or die "Cannot open file $seqdump: $!\n";
while (<LIST>) {    
	    if (/^>(.*)/) {
		my @y = split /\|/, $1;
		my @w;
		@w = split /\s/, $y[1];
		my $id = "$w[0]-$w[1]";
		push @list, $id;
    }
 }
close LIST;
#-------------------------------------------------------------------------------------------
my %seq = ();
my $sid = ();
my $seq_number;
open (IN, $aln) or die "Cannot open file $aln: $!\n";;
while (<IN>) { 
    if (/^\>(\S+)/) {
	    $seq_number=0;
        $sid = $1;
        my @w = split /\|/, $sid;
        $sid = $w[1];
        }
	else {
	   $_=~tr/BDHIKMNRSVWY/NNNNNNNNNNNN/;
	   $seq_number++;
	   my $compare_number2= $_ =~m/\w/g;
	   my $compare_number1= $seq{$sid}[$seq_number-1]=~m/\w/g;
	   if($compare_number2 >= $compare_number1){
	   $seq{$sid}[$seq_number-1] = $_;}
	   else{next;}
	   
    }
}
close IN;
 
open (OUT, ">$aln.temp") or die "Cannot create file $outs: $!\n";
foreach my $id (keys %seq) {
    print OUT ">$id\n";
    for my $outseq (0..$seq_number){
    print OUT $seq{"$id"}[$outseq];}
	
}
close OUT;
#-------------------------------------------------------------------------------------------
my @trimed=glob("*.temp");
foreach my $trimed(@trimed){
         if("$method" eq "Gblocks"){system("./bin/Gblocks $trimed out");}
		 if("$method" eq "trimAl"){system("./bin/trimal -in $trimed -out ${trimed}-gb -fasta -htmlout $trimed.html -automated1");}
		 if("$method" eq "BMGE"){system("java -jar ./bin/BMGE.jar -i $trimed -t DNA -s YES -of ${trimed}-gb -oh $trimed.html");}
		 if("$method" eq "noisy"){system("./bin/noisy $trimed");}
		 unlink ("$trimed");
}

#-------------------------------------------------------------------------------------------

if("$method" eq "Gblocks"){
my @gb=glob("*.temp-gb");
foreach my $gb(@gb){
        my $delete=0;
        open(GB, "<$gb")||die "Can't open $in:$!\n";
		open(GBOUT, ">>$gb.out")||die "Can't open $in:$!\n";
        while(<GB>){
		          
		          if(/^>/){print GBOUT "$_";}
				  elsif(/^\w{10}\s/i){
				              $delete++;
				              $_=~s/\s//g;
							  print GBOUT "$_\n";
							  }
		          
		}
close(GB);
close(GBOUT);
if ($delete==0){unlink("$gb.out");}
unlink ("$gb");
my $temp_name2=$gb.".out";
$temp_name2=~s/temp-gb\.out/fasta/g;
rename("$gb.out","$temp_name2");
}}

if("$method" eq "trimAl"){
my @gb=glob("*.temp-gb");
foreach my $gb(@gb){
        my $delete=0;
        open(GB, "<$gb")||die "Can't open $in:$!\n";
		open(GBOUT, ">>$gb.out")||die "Can't open $in:$!\n";
        while(<GB>){
		          
		          if(/^>/){print GBOUT "$_";}
				  elsif(/^[A|T|C|G|N|-]+\n/i){
				              $delete++;
				              print GBOUT "$_";
							  }
		          
		}
close(GB);
close(GBOUT);
if ($delete==0){unlink("$gb.out");}
unlink ("$gb");
my $temp_name2=$gb;
$temp_name2=~s/temp-gb/fasta/g;
rename("$gb.out","$temp_name2");
}}

if("$method" eq "BMGE"){
my @gb=glob("*.temp-gb");
foreach my $gb(@gb){
        my $delete=0;
        open(GB, "<$gb")||die "Can't open $in:$!\n";
		open(GBOUT, ">>$gb.out")||die "Can't open $in:$!\n";
        while(<GB>){
		          
		          if(/^>/){print GBOUT "$_";}
				  elsif(/^[A|T|C|G|N|-]+\n/i){
				              $delete++;
				              print GBOUT "$_";
							  }
		          
		}
close(GB);
close(GBOUT);
if ($delete==0){unlink("$gb.out");}
unlink ("$gb");
my $temp_name2=$gb;
$temp_name2=~s/temp-gb/fasta/g;
rename("$gb.out","$temp_name2");
}}

if("$method" eq "noisy"){
my @gb=glob("*.fas");
foreach my $gb(@gb){
        my $delete=0;
        open(GB, "<$gb")||die "Can't open $in:$!\n";
		open(GBOUT, ">>$gb.out")||die "Can't open $in:$!\n";
        while(<GB>){
		          
		          if(/^>/){$_=~s/ //g;print GBOUT "$_";}
				  elsif(/^[A|T|C|G|N|-]+\n/i){
				              $delete++;
				              print GBOUT "$_";
							  }
		          
		}
close(GB);
close(GBOUT);
if ($delete==0){unlink("$gb.out");}
unlink ("$gb");
my $temp_name2=$gb;
$temp_name2=~s/_out\.fas/\.fasta/g;
rename("$gb.out","$temp_name2");
}}
#-------------------------------------------------------------------------------------------
my %seq2 = ();
my $sid2 = ();
open (INI, "$aln.fasta") or die "Cannot open file $aln.fasta: $!\n";;
while (<INI>) {
    if (/^\>(\S+)/) {
	    chomp;
        $sid2 = $1;
    } 
	else {
        $seq2{$sid2} .= $_;
    }
}
close INI;


my @query = keys %seq2;
my $end_name;

open (OUT, ">$out") or die "Cannot create file $outs: $!\n";
foreach my $id (@list) {
	my @new= split /-/,$id;
    if($new[0]=~m/Query/){print OUT ">$new[1]\n";}
    print OUT $seq2{"$new[0]"};
}
close OUT;
unlink ("$aln.fasta");

if (defined $iqtree){
my $iqtree_dir=$out."_iqtree_results";
warn "Constructed ML tree by iqtree\nPlease check results in the dir $iqtree_dir\n";
system("mkdir $iqtree_dir");
system("cp $out $iqtree_dir/");
system("./bin/iqtree -s $iqtree_dir/$out -st DNA -nt AUTO -bb 1000 -alrt 1000  -m MFP |tee iqtree.log");
}

open(CAN,"$out")||die "Can'not open $out file\n";
my $count=0;
my $can_all;
while (<CAN>) {
          if($count==2){last;}
		  if($_=~/>/){$count++;next;}
		  else{chomp;$can_all.=$_;}
}
$character_length=length($can_all);
close(CAN);

print "The extracted alignments were writen in $out\n";
print "\nThe length of alignment is $character_length bp\n\n";
print "ORPA DATA PREPRATION COMPLETED! ENJOY IT!!\n\n\n";









