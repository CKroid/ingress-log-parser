#!/usr/bin/perl

use Date::Parse;

if($#ARGV != 0) {
	print "Usage: ingress_parse.pl <log filename>\n";
	exit;
}
my $Filename = $ARGV[0];
my $Name = $ARGV[1];

printf ("Processing %s ...\n", $Filename);

%Resonator_Destroyed = ();
%Resonator_Deployed = ();
%Link_Destroyed = ();
%Link_Established = ();
%CField_Destroyed = ();
%CField_Created = ();
%First_Resonator = ();
%Last_Resonator = ();
%Faction = ();
%Total_AP = ();
%Fav_Reso_Destroyed = ();
%Fav_Reso_Deployed = ();

open ($Rfh, "< $Filename") or die "could not open log file";

while(<$Rfh>)
{
	my $line = $_;
	chomp($line);

	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*destroyed.*(L\d{1}).*Resonator})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}

		if(!exists $Fav_Reso_Destroyed{$4})
		{
			$Fav_Reso_Destroyed{$4} = 0;
		}
		$Fav_Reso_Destroyed{$4}++;

		if(!exists $Resonator_Destroyed{$3})
		{
			$Resonator_Destroyed{$3} = 0;
		}
		$Resonator_Destroyed{$3}++;
		$Total_AP{$3}+=75; 
		next;
	}

	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*deployed.*(L\d{1}).*Resonator})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}
		
		if(!exists $Fav_Reso_Deployed{$4})
		{
			$Fav_Reso_Deployed{$4} = 0;
		}
		$Fav_Reso_Deployed{$4}++;
		
		if(!exists $Resonator_Deployed{$3})
		{
			$Resonator_Deployed{$3} = 0;
		}
		$Resonator_Deployed{$3}++;
		$Total_AP{$3}+=125;
		next;
	}
	
	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*destroyed.*Link})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}

		if(!exists $Total_AP{$3})
		{
			$Total_AP{$3} = 0;
		}
		
		if(!exists $Link_Destroyed{$3})
		{
			$Link_Destroyed{$3} = 0;
		}
		$Link_Destroyed{$3}++;
		$Total_AP{$3}+=187;
		next;
	}

	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*linked.*to})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}
		
		if(!exists $Total_AP{$3})
		{
			$Total_AP{$3} = 0;
		}

		if(!exists $Link_Established{$3})
		{
			$Link_Established{$3} = 0;
		}
		$Link_Established{$3}++;
		$Total_AP{$3}+=313;
		next;
	}
	
	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*destroyed.*Control Field})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}
		
		if(!exists $Total_AP{$3})
		{
			$Total_AP{$3} = 0;
		}
		
		if(!exists $CField_Destroyed{$3})
		{
			$CField_Destroyed{$3} = 0;
		}
		$CField_Destroyed{$3}++;
		$Total_AP{$3}+=750;
		next;
	}
	
	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*created.*Control Field})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}
		
		if(!exists $Total_AP{$3})
		{
			$Total_AP{$3} = 0;
		}
		
		if(!exists $CField_Created{$3})
		{
			$CField_Created{$3} = 0;
		}
		$CField_Created{$3}++;
		$Total_AP{$3}+=1250;
		next;
	}
	
	if($line =~ m{(\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2}).*\{(E|R)\}\s*(\w*)\s*captured.*})
	{
		if(!exists $Faction{$3})
		{
			$Faction{$3} = $2;
		}
		
		if(!exists $Total_AP{$3})
		{
			$Total_AP{$3} = 0;
		}
		
		if(!exists $First_Resonator{$3})
		{
			$First_Resonator{$3} = 0;
		}
		$First_Resonator{$3}++;
		$Total_AP{$3}+=500;
		next;
	}
}
close ($Rfh);

open ($Wfh, "> topten.html") or die "could not open log file";
printf $Wfh ("<html>\n");
printf $Wfh ("<link rel=\"stylesheet\" type=\"text/css\" href=\"report.css\" />");
displayTopTen("Top 10 AP Gainer", $Wfh, %Total_AP);
displayTopTen("Top 10 Destroyer", $Wfh, %Resonator_Destroyed);
displayTopTen("Top 10 Deployer", $Wfh, %Resonator_Deployed);
displayTopTen("Top 10 Breaker", $Wfh, %Link_Destroyed);
displayTopTen("Top 10 Linker", $Wfh, %Link_Established);
displayTopTen("Top 10 Neutralizer", $Wfh, %CField_Destroyed);
displayTopTen("Top 10 Fielder", $Wfh, %CField_Created);
displayTopTen("Top 10 Capturer", $Wfh, %First_Resonator);
displayResonator("Top Resonator Destroyed", $Wfh, %Fav_Reso_Destroyed);
displayResonator("Top Resonator Deployed", $Wfh, %Fav_Reso_Deployed);

printf $Wfh ("</html>\n");
close ($Wfh);

#print str2time("2013-04-22 00:00:04") . "\n";
#print str2time("2013-04-22 00:01:05") . "\n";

sub displayTopTen()
{
	my ($title, $Wfh, %hash) = @_;

	@keys = sort {$hash{$b} <=> $hash{$a}} keys %hash;

	printf $Wfh ("<div class=\"container\">\n");
	printf $Wfh ("<div class=\"header\">\n");
	printf $Wfh ("<h1>%s</h1></div>\n", $title);
	printf $Wfh ("<div class=\"agents\">\n");
	for($count=0;$count<10;$count++)
	{
		if($Faction{$keys[$count]} =~ m{R})
		{
			printf $Wfh ("<div class=\"resistance\">%s<br></div>\n",$keys[$count]);
		}
		else
		{
			printf $Wfh ("<div class=\"enlightened\">%s<br></div>\n", $keys[$count]);
		}
	}
	printf $Wfh ("</div>\n");

	printf $Wfh ("<div class=\"result\">\n");
	for($count=0;$count<10;$count++)
	{
		printf $Wfh ("%s<br>\n",$hash{$keys[$count]});
	}
	printf $Wfh ("</div>\n");

	printf $Wfh ("</div>\n");
}

sub displayResonator()
{
	my ($title, $Wfh, %hash) = @_;

	@keys = sort {$hash{$b} <=> $hash{$a}} keys %hash;

	printf $Wfh ("<div class=\"container\">\n");
	printf $Wfh ("<div class=\"header\">\n");
	printf $Wfh ("<h1>%s</h1></div>\n", $title);
	printf $Wfh ("<div class=\"agents\">\n");
	for($count=0;$count<10;$count++)
	{
		printf $Wfh ("<div class=\"resonator\">%s<br></div>\n",$keys[$count]);
	}
	printf $Wfh ("</div>\n");

	printf $Wfh ("<div class=\"result\">\n");
	for($count=0;$count<10;$count++)
	{
		printf $Wfh ("%s<br>\n",$hash{$keys[$count]});
	}
	printf $Wfh ("</div>\n");

	printf $Wfh ("</div>\n");
}
