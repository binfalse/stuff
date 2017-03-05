use strict;
use warnings;
use SNMP;
use Data::Dumper;
use Switch;
use constant { true => 1, false => 0 };
use Getopt::Long;

$SNMP::save_descriptions = 1;

my $filebase = undef;
my $packagename = "mib2go";
my $filterbase = undef;

GetOptions (
	"dir=s" => \$filebase,
	"package=s"   => \$packagename,
	"filterOid=s"  => \$filterbase)
or die("Error in command line arguments\n");


if (!$filebase || !-e $filebase or !-d $filebase) {
	die ("don't know were to store the files");
}


# load some modules

# SNMP::loadModules('EXTREME-SYSTEM-MIB');

SNMP::loadModules('EXTREME-BASE-MIB');
SNMP::loadModules('EXTREME-CABLE-MIB');
SNMP::loadModules('EXTREME-DLCS-MIB');
SNMP::loadModules('EXTREME-DOS-MIB');
SNMP::loadModules('EXTREMEdot11AP-MIB');
SNMP::loadModules('EXTREMEdot11f-MIB');
SNMP::loadModules('EXTREME-EAPS-MIB');
SNMP::loadModules('EXTREME-EDP-MIB');
SNMP::loadModules('EXTREME-ENH-DOS-MIB');
SNMP::loadModules('EXTREME-ENTITY-MIB');
SNMP::loadModules('EXTREME-ESRP-MIB');
SNMP::loadModules('EXTREME-FDB-MIB');
SNMP::loadModules('EXTREME-FILETRANSFER-MIB');
SNMP::loadModules('EXTREME-NETFLOW-MIB');
SNMP::loadModules('EXTREME-NP-MIB');
SNMP::loadModules('EXTREME-OSPF-MIB');
SNMP::loadModules('EXTREME-PBQOS-MIB');
SNMP::loadModules('EXTREME-POE-MIB');
SNMP::loadModules('EXTREME-PORT-MIB');
SNMP::loadModules('EXTREME-POS-MIB');
SNMP::loadModules('EXTREME-QOS-MIB');
SNMP::loadModules('EXTREME-RTSTATS-MIB');
SNMP::loadModules('EXTREME-SERVICES-MIB');
SNMP::loadModules('EXTREME-SLB-MIB');
SNMP::loadModules('EXTREME-SNMPV3-MIB');
SNMP::loadModules('EXTREME-STACKING-MIB');
SNMP::loadModules('EXTREME-STP-EXTENSIONS-MIB');
SNMP::loadModules('EXTREME-SYSTEM-MIB');
SNMP::loadModules('EXTREME-TRAP-MIB');
SNMP::loadModules('EXTREME-TRAPPOLL-MIB');
SNMP::loadModules('EXTREME-V2TRAP-MIB');
SNMP::loadModules('EXTREME-VC-MIB');
SNMP::loadModules('EXTREME-VLAN-MIB');
SNMP::loadModules('EXTREME-WIRELESS-MIB');



my %extremeOids;
my %extremeOidsTypeProbs;
my $extremeFiles;

my $tableOid = undef;
my $tableOidLabel = undef;
my $currentFile = undef;
my $nonTableFile = undef;
my $tableModule = undef;

my $mibModules;



foreach my $k (keys %SNMP::MIB){
	# filter for EXTREME products
	next unless index ($SNMP::MIB{$k}{objectID}, "1916") > 0;
	
	# OID filter from command line?
	next if $filterbase && index ($SNMP::MIB{$k}{objectID}, $filterbase) < 0;
	
	# everything else goes to the OIDs that should be processed
	$extremeOids{$SNMP::MIB{$k}{objectID}} = $SNMP::MIB{$k};
}




# get a module name for go structures
# will convert EXTREME-VLAN-MIB to ExtremeVlanMib
sub getModuleName {
	my $module = shift;
	my $moduleName = "";
	foreach my $part (split /[^a-zA-Z]/, $module)
	{
		$moduleName .= ucfirst lc $part;
	}
	return $moduleName;
}


sub getFilePreamble {
	my $pname = shift;
	return "package " . $pname . "

import (
	\"math/big\"
)\n\n\n";
}


# get the file given a module id
sub getFile {
	my $module = shift;
	my $table = shift;
	my $oid = shift;
	
	if ($table)
	{
		if (!$extremeFiles->{$module . "-table"})
		{
			my $filename = $filebase."/".$module."-tables.go";
			open (my $f, '>', $filename) || die ("cannot open file " . $filename);
			$extremeFiles->{$module . "-table"} = $f;
			
			print "created ",$filename,"\n";
			
			print $f getFilePreamble ($packagename);
			print $f "// table structures of the MIB MODULE ", $module, "\n\n";
		}
		return $extremeFiles->{$module . "-table"};
	}
	else
	{
		if (!$extremeFiles->{$module})
		{
			my $filename = $filebase."/".$module.".go";
			open (my $f, '>', $filename) || die ("cannot open file " . $filename);
			$extremeFiles->{$module} = $f;
			
			print "created ",$filename,"\n";
			
			my $moduleName = getModuleName ($module);
			print $f getFilePreamble ($packagename);
			print $f "// MIB MODULE ", $module, "\n";
			print $f "type ", $moduleName, " struct {\n\n";
			print $f "// when did we read that entry?\n";
			print $f "LastUpdated *big.Int\n\n\n";
			
			$mibModules->{$module} = {
				id => $module,
				name => $moduleName,
				commonOid => $oid,
				fields => {},
				tables => {}
			};
		}
		return $extremeFiles->{$module};
	}
}
sub longestCommonOid {
	my $first = shift;
	my $second = shift;
	
	# from https://stackoverflow.com/questions/9114402/regexp-finding-longest-common-prefix-of-two-strings/9120604#9120604
	my $xor = "$first" ^ "$second";    # quotes force string xor even for numbers
	$xor =~ /^\0*/;                    # match leading null characters
	my $common_prefix_length = $+[0];  # get length of match
	
# 	print "lco of $first and $second is ",substr ($first, 0, $common_prefix_length)," ($common_prefix_length)\n";
	
	return substr ($first, 0, $common_prefix_length);
}

sub addModuleField {
	my $field = shift;
	my $type = shift;
	
	$mibModules->{$field->{moduleID}}->{fields}->{$field->{objectID}} = {
		id => $field->{objectID},
		type => $type,
		name => $field->{label}
	};
	
	$mibModules->{$field->{moduleID}}->{commonOid} = longestCommonOid ($mibModules->{$field->{moduleID}}->{commonOid}, $field->{objectID});
	
}

sub addModuleTable {
	my $field = shift;
	my $tableOid = shift;
	
	$mibModules->{$field->{moduleID}}->{tables}->{$tableOid} = {
		id => $field->{objectID},
		type => undef,
		fields => {}
	};
	
	$mibModules->{$field->{moduleID}}->{commonOid} = longestCommonOid ($mibModules->{$field->{moduleID}}->{commonOid}, $field->{objectID});
}

sub declareModuleTableEntryType {
	my $field = shift;
	my $tableOid = shift;
	my $type = shift;
	
	$mibModules->{$field->{moduleID}}->{tables}->{$tableOid}->{type} = $type;
}

sub addModuleTableField {
	my $field = shift;
	my $tableOid = shift;
	my $type = shift;
	$mibModules->{$field->{moduleID}}->{tables}->{$tableOid}->{fields}->{$field->{objectID}} = {
		id => $field->{objectID},
		type => $type,
		name => $field->{label}
	};
}
	
	
	
	


# iterate all OIDs that we need to process
foreach my $k (sort (map {version->declare($_)} keys %extremeOids))
{
	next if !$extremeOids{$k}{status} || lc $extremeOids{$k}{status} eq "deprecated";
	
	my $module = $extremeOids{$k}{moduleID};
	my $oid = $extremeOids{$k}{objectID};
	print "processing ", $module, " -> ", $extremeOids{$k}{label}, "\n";
	
	
	if ($tableOid)
	{
		$currentFile = getFile ($module, true, $oid);
		$nonTableFile = getFile ($module, false, $oid);
	}
	else
	{
		$currentFile = getFile ($module, false, $oid);
		$nonTableFile = $currentFile;
	}
	
	
	# 	print Dumper(SNMP::getType ($oid));
# 	print Dumper();
# 	print Dumper($extremeOids{$k}{type});
# 	print Dumper($extremeOids{$k}{access});
# 	print Dumper($extremeOids{$k}{status});
# 	print Dumper($extremeOids{$k}{syntax});
# 	print Dumper($extremeOids{$k}{textualConvention});
# 	print Dumper($extremeOids{$k}{units});
	
	if ($tableOid && index ($oid, $tableOid) < 0) {
		
		if ($tableModule eq $module)
		{
			print $currentFile "\n\n}\n";
		}
		
		$tableOid = undef;
		$tableModule = undef;
		# we want to go back to the base file...
		$currentFile = $nonTableFile;
	}
	
	if ($tableOid && $tableOid.".1" eq $oid) {
		print $nonTableFile $tableOidLabel, " []", ucfirst ($extremeOids{$k}{label}), "\n\n\n";
	}
	
	
	
	print $currentFile "// ", ucfirst ($extremeOids{$k}{label}), " ", $oid, "\n";
	
	if ($extremeOids{$k}{description}) {
		foreach my $line (split '\n', $extremeOids{$k}{description}) {
			$line =~ s/^\s+|\s+$//g;
			print $currentFile "// ", $line, "\n";
		}
	}
	
	my $syntax = $extremeOids{$k}{syntax};
	
	foreach my $range (@{$extremeOids{$k}{ranges}}) {
		print $currentFile "// range from ", $range->{low}, " (low) to ", $range->{high}, " (high)\n";
	}
	
	my @enums;
	foreach my $enum (keys %{$extremeOids{$k}{enums}}) {
		push @enums, "//    " . $extremeOids{$k}{enums}{$enum} . " (" . $enum . ")\n";
	}
	print $currentFile sort @enums;
	
	my $type = "*big.Int";
	if ($syntax)
	{
		print $currentFile "// ", $extremeOids{$k}{syntax}, "\n";
		
		switch ($syntax) {
			case /INTEGER|UNSIGNED32|ExtremeVlanType|ExtremeVlanEncapsType|RowStatus|COUNTER(64)?|ClientAuthType|TICKS|BITS|Timeout|ExtremeWirelessCountryCode|ExtremeWirelessAntennaType|TestAndIncr|ExtremeWirelessPhysInterfaceIndex|Dot11Speed|Dot11AChannel|ExtremeWirelessChannelAutoSelectStatus|NetworkAuthMode|Dot11AuthMode|ExtremeWirelessVirtInterfaceIndex|WPACipherSet|InterfaceIndex|Dot11Type|WirelessRemoteConnectBindingType|AuthServerType|TimeStamp|GAUGE|AuthServerAccessType|WPAKeyMgmtSet|ExtremeWirelessAntennaLocation/ {
				$type = " *big.Int";
			}
			case "TruthValue" {
				$type = "bool";
			}
			case /DisplayString|IPADDR|PortList|MacAddress|OBJECTID|OCTETSTR|L4Port|ExtremeDeviceId|ExtremeGenAddr|BridgeId|InetAddress|OwnerString/ {
				$type = "string";
			}
			else {
				die ("do not understand syntax: " . $syntax . " (cannot decide if sting or int etc)");
			}
		}
		
		print $currentFile ucfirst ($extremeOids{$k}{label}), " ", $type, "\n\n";
	}
	
	
	
	if ($tableOid && $tableOid.".1" eq $oid) {
		my $entryStruct = ucfirst ($extremeOids{$k}{label});
		print $currentFile "type ", $entryStruct, " struct {\n";
		declareModuleTableEntryType ($extremeOids{$k}, $tableOid, $entryStruct);
	}
	
	
	if ($extremeOids{$k}{label} =~ /.*Table$/) {
		$tableOid = $oid;
		$tableOidLabel = ucfirst ($extremeOids{$k}{label});
		$tableModule = $module;
	}
	else {
		print $currentFile "\n\n";
	}
	
	
	
	
	if (!$tableOid) {
		# this is a module field
		addModuleField ($extremeOids{$k}, $type);
	}
	elsif ($tableOid eq $oid) {
		# this is a table
		addModuleTable ($extremeOids{$k}, $tableOid);
	}
	else {
		# this is a table field
		addModuleTableField ($extremeOids{$k}, $tableOid, $type);
	}
	
	
}


# finish last file if it was a table
# print $currentFile "}\n" if $tableOid;



# close all files
foreach my $k (keys %$extremeFiles){
	my $file = $extremeFiles->{$k};
	
	# if the last entry in a module is 
	# * a table we won't write a final } to the table files
	# * _not_ a table we will write a final } to the table defintion
	# we fix that in the above code, will be cumbersome, or we just
	# seek back 2 bytes and overwrite the } with another } if it was
	# set previously ;-)
	seek($file, -2, 1);
	
	
	print $file "}\n\n";
	close ($file);
}



foreach my $k (keys %$mibModules){
	print $mibModules->{$k}->{commonOid},"\n";
# 	if ($k eq "EXTREME-RTSTATS-MIB") {
	if ($k eq "EXTREME-SYSTEM-MIB") {
		print Dumper($mibModules->{$k});
	}
}

























