use strict;
use warnings;
use SNMP;
use Data::Dumper;
use Switch;

$SNMP::save_descriptions = 1;

# you may provide the root of a subtree to be printed as an argument
my $root = undef;
$root = $ARGV[0] if $ARGV[0];


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


foreach my $k (keys %SNMP::MIB){
	next unless index ($SNMP::MIB{$k}{objectID}, "1916") > 0;
	
	# uncomment if you want special filter... hard coded of course ;-)
	# next if index ($SNMP::MIB{$k}{objectID}, "1.3.6.1.4.1.1916.1.2.1") < 0;
	
	next if $root && index ($SNMP::MIB{$k}{objectID}, $root) < 0;
	
	$extremeOids{$SNMP::MIB{$k}{objectID}} = $SNMP::MIB{$k};
}


foreach my $k (sort (map {version->declare($_)} keys %extremeOids)){
	
	next if !$extremeOids{$k}{status} || lc $extremeOids{$k}{status} eq "deprecated";
	
	
	print "// ", $extremeOids{$k}{label}, " ", $extremeOids{$k}{objectID}, "\n";
	
	if ($extremeOids{$k}{description}) {
		foreach my $line (split '\n', $extremeOids{$k}{description}) {
			$line =~ s/^\s+|\s+$//g;
			print "// ", $line, "\n";
		}
	}
	
# 	print "// ", $extremeOids{$k}{status}, "\n";
	print "// ", $extremeOids{$k}{syntax}, "\n";
	foreach my $range (@{$extremeOids{$k}{ranges}}) {
		print "// range from ", $range->{low}, " (low) to ", $range->{high}, " (high)\n";
	}
	
	my @enums;
	foreach my $enum (keys %{$extremeOids{$k}{enums}}) {
		push @enums, "//    " . $extremeOids{$k}{enums}{$enum} . " (" . $enum . ")\n";
	}
	print sort @enums;
	
	if ($extremeOids{$k}{syntax})
	{
		my $syntax = $extremeOids{$k}{syntax};
		
		switch ($extremeOids{$k}{syntax}) {
			case /INTEGER|UNSIGNED32|ExtremeVlanType|ExtremeVlanEncapsType|RowStatus|COUNTER(64)?|ClientAuthType|TICKS|BITS|Timeout|ExtremeWirelessCountryCode|ExtremeWirelessAntennaType|TestAndIncr|ExtremeWirelessPhysInterfaceIndex|Dot11Speed|Dot11AChannel|ExtremeWirelessChannelAutoSelectStatus|NetworkAuthMode|Dot11AuthMode|ExtremeWirelessVirtInterfaceIndex|WPACipherSet|InterfaceIndex|Dot11Type|WirelessRemoteConnectBindingType|AuthServerType|TimeStamp|GAUGE|AuthServerAccessType|WPAKeyMgmtSet|ExtremeWirelessAntennaLocation/ {
				print ucfirst ($extremeOids{$k}{label}), " *big.Int\n";
			}
			case "TruthValue" {
				print ucfirst ($extremeOids{$k}{label}), " bool\n";
			}
			case /DisplayString|IPADDR|PortList|MacAddress|OBJECTID|OCTETSTR|L4Port|ExtremeDeviceId|ExtremeGenAddr|BridgeId|InetAddress|OwnerString/ {
				print ucfirst ($extremeOids{$k}{label}), " string\n";
			}
			else {
				die ("do not understand " . $extremeOids{$k}{syntax});
				#$extremeOidsTypeProbs{$k} = $extremeOids{$k};
			}
		}
	}
	
	print "\n\n";
}


# usual not necessary
foreach my $k (sort (map {version->declare($_)} keys %extremeOidsTypeProbs)){
	print "//TYPEPTOBLEM!!! ", $extremeOids{$k}{label}, " ", $extremeOids{$k}{objectID}, "\n";
	if ($extremeOids{$k}{description}) {
		foreach my $line (split '\n', $extremeOids{$k}{description}) {
			print "// ", $line, "\n";
		}
	}
	print "// ", $extremeOids{$k}{status}, "\n";
	print "// ", $extremeOids{$k}{syntax}, "\n";
	# 	print Dumper($extremeOids{$k}{ranges});
	foreach my $range (@{$extremeOids{$k}{ranges}}) {
		print "// range from ", $range->{low}, " (low) to ", $range->{high}, " (high)\n";
	}
	# 	print Dumper($extremeOids{$k}{enums});
	
	foreach my $enum (keys %{$extremeOids{$k}{enums}}) {
		# 		print Dumper($enum);
		# 		print Dumper($enum);
		print "//    ",$extremeOids{$k}{enums}{$enum}," (",$enum,")\n";
	}
}


























