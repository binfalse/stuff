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
my $indentation = "\t";

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

# SNMP::loadModules('EXTREME-BASE-MIB');
# SNMP::loadModules('EXTREME-CABLE-MIB');
# SNMP::loadModules('EXTREME-DLCS-MIB');
# SNMP::loadModules('EXTREME-DOS-MIB');
# SNMP::loadModules('EXTREMEdot11AP-MIB');
# SNMP::loadModules('EXTREMEdot11f-MIB');
# SNMP::loadModules('EXTREME-EAPS-MIB');
# SNMP::loadModules('EXTREME-EDP-MIB');
# SNMP::loadModules('EXTREME-ENH-DOS-MIB');
# SNMP::loadModules('EXTREME-ENTITY-MIB');
# SNMP::loadModules('EXTREME-ESRP-MIB');
# SNMP::loadModules('EXTREME-FDB-MIB');
# SNMP::loadModules('EXTREME-FILETRANSFER-MIB');
# SNMP::loadModules('EXTREME-NETFLOW-MIB');
# SNMP::loadModules('EXTREME-NP-MIB');
# SNMP::loadModules('EXTREME-OSPF-MIB');
# SNMP::loadModules('EXTREME-PBQOS-MIB');
# SNMP::loadModules('EXTREME-POE-MIB');
# SNMP::loadModules('EXTREME-PORT-MIB');
# SNMP::loadModules('EXTREME-POS-MIB');
# SNMP::loadModules('EXTREME-QOS-MIB');
# SNMP::loadModules('EXTREME-RTSTATS-MIB');
# SNMP::loadModules('EXTREME-SERVICES-MIB');
# SNMP::loadModules('EXTREME-SLB-MIB');
# SNMP::loadModules('EXTREME-SNMPV3-MIB');
# SNMP::loadModules('EXTREME-STACKING-MIB');
# SNMP::loadModules('EXTREME-STP-EXTENSIONS-MIB');
# SNMP::loadModules('EXTREME-SYSTEM-MIB');
# SNMP::loadModules('EXTREME-TRAP-MIB');
# SNMP::loadModules('EXTREME-TRAPPOLL-MIB');
# SNMP::loadModules('EXTREME-V2TRAP-MIB');
# SNMP::loadModules('EXTREME-VC-MIB');
# SNMP::loadModules('EXTREME-VLAN-MIB');
# SNMP::loadModules('EXTREME-WIRELESS-MIB');

SNMP::loadModules ('EXTREME-BASE-MIB');
SNMP::loadModules ('ENTERASYS-MIB-NAMES');
SNMP::loadModules ('CTRON-OIDS');
SNMP::loadModules ('CTRON-MIB-NAMES');
SNMP::loadModules ('EXTREME-SYSTEM-MIB');
SNMP::loadModules ('EXTREME-ENTITY-MIB');
SNMP::loadModules ('EXTREME-SOFTWARE-MONITOR-MIB');
SNMP::loadModules ('EXTREME-POE-MIB');
SNMP::loadModules ('EXTREME-V2TRAP-MIB');
SNMP::loadModules ('EXTREME-VLAN-MIB');
SNMP::loadModules ('EXTREME-PORT-MIB');
SNMP::loadModules ('EXTREME-FDB-MIB');
SNMP::loadModules ('ENTERASYS-MAC-LOCKING-MIB');
SNMP::loadModules ('EXTREME-VM-MIB');
SNMP::loadModules ('EXTREME-ESRP-MIB');
SNMP::loadModules ('EXTREME-EDP-MIB');
SNMP::loadModules ('EXTREME-STP-EXTENSIONS-MIB');
SNMP::loadModules ('EXTREME-CLEARFLOW-MIB');
SNMP::loadModules ('EXTREME-ACL-MIB');
SNMP::loadModules ('EXTREME-IP-SECURITY-MIB');
SNMP::loadModules ('EXTREME-EAPS-MIB');
SNMP::loadModules ('EXTREME-ERPS-MIB');
SNMP::loadModules ('EXTREME-CFM-MIB');
SNMP::loadModules ('EXTREME-LACP-MIB');
SNMP::loadModules ('ENTERASYS-UPN-TC-MIB');
SNMP::loadModules ('ENTERASYS-POLICY-PROFILE-MIB');
SNMP::loadModules ('ENTERASYS-MULTI-AUTH-MIB');
SNMP::loadModules ('ENTERASYS-CONVERGENCE-END-POINT-MIB');
SNMP::loadModules ('EXTREME-MLAG-MIB');
SNMP::loadModules ('EXTREME-HCLAG-MIB');
SNMP::loadModules ('ENTERASYS-CLASS-OF-SERVICE-MIB');
SNMP::loadModules ('ENTERASYS-MAC-AUTHENTICATION-MIB');
SNMP::loadModules ('CTRON-ALIAS-MIB');
SNMP::loadModules ('EXTREME-OSPF-MIB');
SNMP::loadModules ('EXTREME-MPLS-MIB');
SNMP::loadModules ('EXTREME-MPLS-TE-MIB');
SNMP::loadModules ('EXTREME-RTSTATS-MIB');
SNMP::loadModules ('EXTREME-IDMGR-MIB');
SNMP::loadModules ('EXTREME-UPM-MIB');
SNMP::loadModules ('EXTREME-AUTOPROVISION-MIB');
SNMP::loadModules ('EXTREME-SNMPV3-MIB');
SNMP::loadModules ('EXTREME-TRAPPOLL-MIB');
SNMP::loadModules ('EXTREME-MAC-AUTH-MIB');
SNMP::loadModules ('EXTREME-CFGMGMT-MIB');
SNMP::loadModules ('ENTERASYS-RADIUS-AUTH-CLIENT-MIB');
SNMP::loadModules ('ENTERASYS-RADIUS-ACCT-CLIENT-EXT-MIB');
SNMP::loadModules ('ENTERASYS-RADIUS-DYNAMIC-AUTHOR-SERVER-EXT-MIB');
SNMP::loadModules ('EXTREME-IETF-BFD-TC-MIB');
SNMP::loadModules ('EXTREME-IETF-BFD-MIB');
SNMP::loadModules ('EXTREME-VRRP-MIB');
SNMP::loadModules ('EXTREME-OSPFV3-MIB');
SNMP::loadModules ('EXTREME-NP-MIB');
SNMP::loadModules ('EXTREME-PBQOS-MIB');
SNMP::loadModules ('EXTREME-POS-MIB');
SNMP::loadModules ('EXTREME-QOS-MIB');
SNMP::loadModules ('A3COM51-SS9000SX');
SNMP::loadModules ('EXTREME-CABLE-MIB');
SNMP::loadModules ('EXTREME-DLCS-MIB');
SNMP::loadModules ('EXTREME-DOS-MIB');
SNMP::loadModules ('EXTREMEdot11f-MIB');
SNMP::loadModules ('EXTREME-ENH-DOS-MIB');
SNMP::loadModules ('EXTREME-FILETRANSFER-MIB');
SNMP::loadModules ('EXTREME-NETFLOW-MIB');
SNMP::loadModules ('EXTREME-SERVICES-MIB');
SNMP::loadModules ('EXTREME-SLB-MIB');
SNMP::loadModules ('EXTREME-STACKING-MIB');
SNMP::loadModules ('EXTREME-TRAP-MIB');
SNMP::loadModules ('EXTREME-VC-MIB');
SNMP::loadModules ('EXTREME-WIRELESS-MIB');
SNMP::loadModules ('GENERIC-3COM-VLAN-MIB-1-0-1');
SNMP::loadModules ('LOAD-BAL-SYSTEM-MIB');
SNMP::loadModules ('WAN-TRAP-MIB');
SNMP::loadModules ('XEDIA-REG');
SNMP::loadModules ('XEDIA-TRAFFIC-MGMT-MIB');






my %extremeOids;
my %extremeOidsTypeProbs;

my $tableOid = undef;
my $tableOidLabel = undef;
my $tableModule = undef;

my $mibModules;

my %packageFile = (
	classStructure => "",
	snmpParseFunc => "",
	stringFunc => ""
);



foreach my $k (keys %SNMP::MIB){
	# filter for EXTREME products
	# needs to be adjusted if we want to use cisco etc
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


# get the file preamble
sub getFilePreamble {
	my $pname = shift;
	my $imports = shift;
	
	my $ret = "package " . $pname;
	
	$ret = $ret . "\n\nimport (\n";
	
	foreach my $import (@$imports) {
		$ret = $ret . "	\"".$import."\"\n";
	}
	$ret = $ret . ")\n";
	
	return $ret . "\n\n\n";
}


# parse the MIB's syntax declaration and decide for the corresponding type in go
sub getType {
	my $syntax = shift;
	
	return undef if (!$syntax);
	
	switch ($syntax) {
		case /INTEGER|UNSIGNED32|ExtremeVlanType|ExtremeVlanEncapsType|RowStatus|COUNTER(64)?|ClientAuthType|TICKS|BITS|Timeout|ExtremeWirelessCountryCode|ExtremeWirelessAntennaType|TestAndIncr|ExtremeWirelessPhysInterfaceIndex|Dot11Speed|Dot11AChannel|ExtremeWirelessChannelAutoSelectStatus|NetworkAuthMode|Dot11AuthMode|ExtremeWirelessVirtInterfaceIndex|WPACipherSet|InterfaceIndex|Dot11Type|WirelessRemoteConnectBindingType|AuthServerType|TimeStamp|GAUGE|AuthServerAccessType|WPAKeyMgmtSet|ExtremeWirelessAntennaLocation|UnitMultiplier|SlotType|ExtremePortTrafficDirection|EapsRingPort|EapsFailTimerExpiryAction|EapsSharedPortSegmentTimerExpiryAction|EapsPortType|EapsSharedPortMode|EapsDomainPortStatus|EapsDomainPriority|EapsMbrVlanType|EapsSharedPortSegmentStatus|EapsSharedPortVlanPortStatus|EapsSharedPortState|EapsSharedPortNeighborStatus|LacpMemberPort|EapsSharedPortRootBlockerStatus|IpProtocol|InetPortNumber|IcmpAnomalyReason|TcpFlagAnomalyReason|VlanTag|TcpFragmentAnomalyReason|ExtremeIdMgrInetAddrDetectMethod|ExtremeIdMgrInetAddrSecViolation|PwIndexType|PwOperStatusTC|MplsTunnelIndex|MplsTunnelInstanceIndex|MplsExtendedTunnelId|IndexInteger|HclagMemberPort|CounterDirection|VMVPPSynchType|ExtremeBfdSessIndexTC|ExtremeBfdSessTypeTC|ExtremeBfdCtrlDestPortNumberTC|ExtremeBfdCtrlSourcePortNumberTC|ExtremeBfdSessStateTC|ExtremeBfdDiagTC|ExtremeBfdSessOperModeTC|ExtremeBfdIntervalTC|ExtremeBfdIntervalTC|ExtremeBfdIntervalTC|ExtremeBfdMultiplierTC|ExtremeBfdIntervalTC|ExtremeBfdIntervalTC|ExtremeBfdMultiplierTC|ExtremeBfdSessAuthenticationTypeTC|StorageType|ExtremeBfdDiagTC|VlanId|RingMonitorMechanismType|ExtremeCfmGroupOperStatus|ExtremeOspfv3RouterIdTc|Status|ExtremeOspfv3UpToRefreshIntervalTc|ExtremeOspfv3AreaIdTc|BigMetric|ExtremeOspfv3RouterIdTc|ExtremeOspfv3AreaIdTc|ExtremeOspfv3IfInstIdTc|Metric|DesignatedRouterPriority|HelloRange|ExtremeOspfv3DeadIntRangeTc|Dot1agCfmMepId|EapsDomainMode|EapsDomainState|PowerValue/ {
			
			
			
			return "*big.Int";
		}
		case "TruthValue" {
			return "bool";
		}
		case /DisplayString|IPADDR|PortList|MacAddress|OBJECTID|OCTETSTR|L4Port|ExtremeDeviceId|ExtremeGenAddr|BridgeId|InetAddress|OwnerString|LacpGroupId|HexOctet|AutonomousType|MplsLdpIdentifier|DateAndTime|SnmpAdminString|MplsIndexType|MplsLsrIdentifier|HclagGroupId|VPNIdOrZero|ExtremeBfdSessionAuthenticationKeyTC/ {
			return "string";
		}
		else {
# 			print (">>>>> type error: $syntax\n");
			die ("do not understand syntax: " . $syntax . " (cannot decide if sting or int etc)");
		}
	}
}


# parse the enums of a field
sub getEnums {
	my $field = shift;
	my @enums;
	foreach my $enum (keys %{$field->{enums}}) {
		push @enums, "//    " . $field->{enums}{$enum} . " (" . $enum . ")\n";
	}
	@enums = sort @enums;
	return \@enums;
}

# parse the ranges of a field
sub getRanges {
	my $field = shift;
	my @ranges;
	
	foreach my $range (@{$field->{ranges}}) {
		push @ranges, "// range from " . $range->{low} . " (low) to " . $range->{high} . " (high)\n";
	}
	return \@ranges;
}


# get the longest common OID  given two OIDs
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


# add a field to a module
sub addModuleField {
	my $field = shift;
	
# 	print $field->{objectID}. "--" . $field->{label} . "--".$field->{syntax}."\n";
	my $fieldType = getType($field->{syntax});
	
	
	####################################################
# 	if (!$fieldType)
# 	{
# 		print "------\n";
# 		print Dumper($field->{label});
# 		print Dumper($field->{objectID});
# 		print Dumper($field->{syntax});
# 		print Dumper($field->{moduleID});
# 		print Dumper($field->{type});
# 		print Dumper($field->{access});
# 		print Dumper($field->{status});
# 		print Dumper($field->{description});
# 		print "------\n";
# 	}
	####################################################
	
	## parser problems, so we need to work-around...
# 	return if (!$fieldType and $field->{access} eq "Notify");
	
	# add it to the mibModules
	$mibModules->{$field->{moduleID}}->{fields}->{$field->{objectID}} = {
		id => $field->{objectID},
		type => $fieldType,
		name => ucfirst $field->{label},
		syntax => $field->{syntax},
		description => $field->{description}
	};
	
	# more information
	if ($field->{enums}) {
		$mibModules->{$field->{moduleID}}->{fields}->{$field->{objectID}}->{enums} = getEnums ($field);
	}
	if ($field->{ranges}) {
		$mibModules->{$field->{moduleID}}->{fields}->{$field->{objectID}}->{ranges} = getRanges ($field);
	}
	
	# set common OID for the module
	$mibModules->{$field->{moduleID}}->{commonOid} = longestCommonOid ($mibModules->{$field->{moduleID}}->{commonOid}, $field->{objectID});
	
	# indicate that this file should have big.Int inclusion in the file preamble
	if ($fieldType && index ($fieldType, "big.Int") >= 0) {
		$mibModules->{$field->{moduleID}}->{needsBigInt} = true;
	}
}

# add a table to a module
sub addModuleTable {
	my $field = shift;
	my $tableOid = shift;
	
	# table setup
	$mibModules->{$field->{moduleID}}->{tables}->{$tableOid} = {
		id => $field->{objectID},
		name => ucfirst $field->{label},
		type => undef,
		fields => {},
		description => $field->{description}
	};
	
	# set common OID for the module
	$mibModules->{$field->{moduleID}}->{commonOid} = longestCommonOid ($mibModules->{$field->{moduleID}}->{commonOid}, $field->{objectID});
}

# define a table's entries type
sub declareModuleTableEntryType {
	my $field = shift;
	my $tableOid = shift;
	my $type = shift;
	
	$mibModules->{$field->{moduleID}}->{tables}->{$tableOid}->{type} = $type;
}

# add a field to a table of a module
sub addModuleTableField {
	my $field = shift;
	my $tableOid = shift;
	
	my $fieldType = getType($field->{syntax});
	
	$mibModules->{$field->{moduleID}}->{tables}->{$tableOid}->{fields}->{$field->{objectID}} = {
		id => $field->{objectID},
		type => $fieldType,
		name => ucfirst $field->{label},
		syntax => $field->{syntax},
		description => $field->{description}
	};
	
	if ($field->{enums}) {
		$mibModules->{$field->{moduleID}}->{tables}->{$tableOid}->{fields}->{$field->{objectID}}->{enums} = getEnums ($field);
	}
	
	if ($field->{ranges}) {
		$mibModules->{$field->{moduleID}}->{tables}->{$tableOid}->{fields}->{$field->{objectID}}->{ranges} = getRanges ($field);
	}
	
	# does the table definition need big.Int?
	if (index ($fieldType, "big.Int") >= 0) {
		$mibModules->{$field->{moduleID}}->{tablesNeedBigInt} = true;
	}
}
	
	
	
	


# iterate all OIDs that we need to process
foreach my $k (sort (map {version->declare($_)} keys %extremeOids))
{
	next if !$extremeOids{$k}{status};# || lc $extremeOids{$k}{status} eq "deprecated";
	
	my $module = $extremeOids{$k}{moduleID};
	my $oid = $extremeOids{$k}{objectID};
# 	print "processing ", $module, " -> ", $extremeOids{$k}{label}, "\n";
	
	if (!$mibModules->{$extremeOids{$k}{moduleID}}) {
		$mibModules->{$extremeOids{$k}{moduleID}} = {
			id => $extremeOids{$k}{moduleID},
			name => getModuleName ($extremeOids{$k}{moduleID}),
			commonOid => $extremeOids{$k}{objectID},
			needsBigInt => false,
			tablesNeedBigInt => false
		};
	}
	
	if ($tableOid && index ($oid, $tableOid) < 0) {
		# if the tableOid if not longer substring of the current OID we left the table
		$tableOid = undef;
		$tableModule = undef;
	}
	
	
	# unfortunatelly we don't have other hints for tables in perl's SNMP?
	if ($extremeOids{$k}{access} eq "NoAccess" and $extremeOids{$k}{label} =~ /.*Table$/) {
		$tableOid = $oid;
		$tableOidLabel = ucfirst ($extremeOids{$k}{label});
		$tableModule = $module;
	}
	
	if (!$tableOid) {
		# this is a module field
		addModuleField ($extremeOids{$k});
	}
	elsif ($tableOid eq $oid) {
		# this is a table
		addModuleTable ($extremeOids{$k}, $tableOid);
	}
	else {
		if ($tableOid.".1" eq $oid) {
			# this is the table entry defintion
			my $entryStruct = ucfirst ($extremeOids{$k}{label});
			declareModuleTableEntryType ($extremeOids{$k}, $tableOid, $entryStruct);
		}	else {
			# this is a table field
			addModuleTableField ($extremeOids{$k}, $tableOid);
		}
	}
	
	
}







use Devel::StackTrace;


sub getValueAssignment {
	my $type = shift;
	switch ($type) {
		case "*big.Int" {
			return  " = helpers.GetSnmpBigIntValue (pdu.Value)";
		}
		case "bool" {
			return  " = helpers.GetSnmpBoolValue (pdu.Value)";
		}
		case "string" {
			return  " = helpers.GetSnmpStringValue (pdu.Value, pdu.Type)";
		}
		else {
			my $trace = Devel::StackTrace->new;
			print $trace->as_string;
			die (">> do not understand type: " . $type . " (cannot decide if sting or int etc)");
		}
	}
}










sub writeFormatedDescription {
	my $description = shift;
	my $file = shift;
	my $indent = shift;
	foreach my $line (split '\n', $description) {
		$line =~ s/^\s+|\s+$//g;
		print $file $indent . "// ", $line, "\n";
	}
}

sub writeTableStructure {
	my $f = shift;
	my $table = shift;
	
	print $f "// " . $table->{name} . " " . $table->{id} . "\n";
	writeFormatedDescription ($table->{description}, $f, "");
	print $f "type ", $table->{type}, " struct {\n\n";
	
	# write all the table fields
	foreach my $k (keys %{$table->{fields}}) {
		writeField ($f, $table->{fields}->{$k});
	}
	
	print $f "}\n\n";
}


sub writeField {
	my $f = shift;
	my $field = shift;
	
	print $f $indentation . "// " . $field->{name} . " " . $field->{id} . "\n";
	writeFormatedDescription ($field->{description}, $f, $indentation);
	
	if ($field->{syntax}) {
		print $f $indentation . "// " . $field->{syntax} . "\n";
	}
		
	if ($field->{ranges} && scalar($field->{ranges})) {
		# 			print Dumper($field->{ranges});
		foreach my $r (@{$field->{ranges}}) {
			print $f $indentation . $r;
		}
	}
	
	if ($field->{enums} && scalar($field->{enums})) {
		# 			print Dumper($field->{enums});
		foreach my $r (@{$field->{enums}}) {
			print $f $indentation . $r;
		}
	}
# 	print Dumper($field) if (!$field->{type});
	print $f $indentation . $field->{name} . " " . $field->{type} . "\n\n\n";
}


sub writeClassStructure {
	my $module = shift;
	#print $module->{id};
	my $filename = $filebase."/".$module->{id}.".go";
	my $filenameTables = $filebase."/".$module->{id}."-tables.go";
	open (my $f, '>', $filename) || die ("cannot open file " . $filename);
	open (my $ft, '>', $filenameTables) || die ("cannot open file " . $filenameTables);
	
# 	print "created ",$filename," and ",$filenameTables,"\n";
	
	
	# preamble for module file
	my @mainPackages = ("github.com/soniah/gosnmp", "log", "fmt", "bytes", "discovery/helpers");
	push (@mainPackages, "math/big") if ($module->{needsBigInt});
	push (@mainPackages, "strings") if ($module->{tables} || $module->{fields});
	
	print $f getFilePreamble ($packagename, \@mainPackages);
	print $f "// MIB MODULE ", $module->{id}, "\n";
	print $f "// longest common oid is ", $module->{commonOid}, "\n";
	print $f "type ", $module->{name}, " struct {\n\n";
	
	
	
	# add this module to the package structure
	$packageFile{classStructure} .= $indentation . "// MIB MODULE ". $module->{id}. "\n";
	$packageFile{classStructure} .= $indentation . "// longest common oid is ". $module->{commonOid}. "\n";
	$packageFile{classStructure} .= $indentation . $module->{name}."Module ". $module->{name}. "\n\n\n";
	
	# add to the retriever function
	$packageFile{snmpParseFunc} .= $indentation . "// retrieving details about the module ". $module->{id}. "\n";
	$packageFile{snmpParseFunc} .= $indentation . "e." . $module->{name}. "Module.RetrieveEnterpriseModuleDetails (snmp, pduTrigger)\n\n\n";
	
	# add to the string function
	$packageFile{stringFunc} .= $indentation . "// print details about the module ". $module->{id}. "\n";
	$packageFile{stringFunc} .= $indentation . "buffer.WriteString (e." . $module->{name}. "Module.String ())\n";
	$packageFile{stringFunc} .= $indentation . "buffer.WriteString (\"\\n\")\n\n";
	
	
	
	my @tablesPackages;
	# preamble for tables file
	push (@tablesPackages, "math/big") if ($module->{tablesNeedBigInt});
	
	print $ft getFilePreamble ($packagename, \@tablesPackages);
	print $ft "// tables of MIB MODULE ", $module->{id}, "\n";
	
	
	
	# write all the simple fields
	foreach my $k (keys %{$module->{fields}}) {
		writeField ($f, $module->{fields}->{$k});
	}
	
	
	#write the tables
 	foreach my $k (keys %{$module->{tables}}) {
		print $f $indentation . "// " . $module->{tables}->{$k}->{name} . " " . $module->{tables}->{$k}->{id} . "\n";
		writeFormatedDescription ($module->{tables}->{$k}->{description}, $f, $indentation);
		
		print $f $indentation . $module->{tables}->{$k}->{name} . " map[string]*" . $module->{tables}->{$k}->{type} . "\n\n\n";
# 		if (!$module->{tables}->{$k}->{type})
# 		{
# 			print Dumper($module->{tables}->{$k});
# 		}
		
		writeTableStructure ($ft, $module->{tables}->{$k});
	}
	
	print $f $indentation . "// a temporary PDU Trigger to react on certain OIDs\n"
	print $f $indentation . "pduTrigger []helpers.PduTrigger\n"
	
	print $f "}\n\n\n";
	
	
	# generate the ParseSnmpFieldDetails function
	print $f "func (e *" . $module->{name} . ") ParseSnmpFieldDetails (pdu gosnmp.SnmpPDU) error {\n\n";
	if ($module->{fields} && scalar keys %{$module->{fields}}) {
		print $f $indentation . "oid := pdu.Name\n\n";
		
		print $f $indentation . "for i := range e.pduTrigger {\n";
		print $f $indentation . $indentation . "if e.pduTrigger[i].Check (oid){\n";
		print $f $indentation . $indentation . $indentation . "e.pduTrigger[i].Process (pdu)\n";
		print $f $indentation . $indentation . "}\n";
		print $f $indentation . "}\n";
		
		# stop if value is nil
		print $f $indentation . "if pdu.Value == nil {\n";
		print $f $indentation . $indentation . "log.Printf (\">> value is nil for %v (%d) -> %v\", pdu.Name, pdu.Type, pdu.Value)\n";
		print $f $indentation . $indentation . "return nil\n";
		print $f $indentation . "}\n\n\n";
		
		
		
		my $n = 0;
		foreach my $k (sort keys %{$module->{fields}}) {
			if ($n == 0)
			{
				print $f $indentation . "if ";
			}
			else
			{
				print $f $indentation . "} else if ";
			}
			print $f "strings.HasPrefix (oid, \"".$k.".\") {\n";
			
			
			
			####################################################
# 			if (!$module->{fields}->{$k}->{type})
# 			{
# 				print Dumper($module->{fields}->{$k});
# 			}
			####################################################
			
			print $f $indentation . $indentation . "e." . $module->{fields}->{$k}->{name} . getValueAssignment ($module->{fields}->{$k}->{type}) . "\n";
			$n = $n + 1;
		};
		print $f $indentation . "} else {\n";
		print $f $indentation . $indentation . "log.Printf (\">> do not understand field %v (%d) -> %v\", pdu.Name, pdu.Type, pdu.Value)\n";
		print $f $indentation . "}\n";
	}
	print $f $indentation . "return nil\n";
	print $f "}\n\n\n";
	
	
	
	# generate the ParseSnmpTableDetails function
	print $f "func (e *" . $module->{name} . ") ParseSnmpTableDetails (pdu gosnmp.SnmpPDU) error {\n\n";
	if ($module->{tables} && scalar keys %{$module->{tables}})
	{
		print $f $indentation . "oid := pdu.Name\n\n";
		
		print $f $indentation . "for i := range e.pduTrigger {\n";
		print $f $indentation . $indentation . "if e.pduTrigger[i].Check (oid){\n";
		print $f $indentation . $indentation . $indentation . "e.pduTrigger[i].Process (pdu)\n";
		print $f $indentation . $indentation . "}\n";
		print $f $indentation . "}\n";
		
		# stop if value is nil
		print $f $indentation . "if pdu.Value == nil {\n";
		print $f $indentation . $indentation . "log.Printf (\">> value is nil for table %v (%d) -> %v\", pdu.Name, pdu.Type, pdu.Value)\n";
		print $f $indentation . $indentation . "return nil\n";
		print $f $indentation . "}\n\n\n";
		
		
		foreach my $k (sort keys %{$module->{tables}}) {
			my $table = $module->{tables}->{$k};
			print $f $indentation . "// table for " . $table->{name} . "\n";
			print $f $indentation . "if strings.HasPrefix (oid, \"" . $table->{id} . ".\") {\n";
			
			# create map if not yet created
			print $f $indentation . $indentation . "if e." . $module->{tables}->{$k}->{name}." == nil {\n";
			print $f $indentation . $indentation . $indentation . "e." . $module->{tables}->{$k}->{name}." = make (map[string]*".$table->{type}.")\n";
			print $f $indentation . $indentation . "}\n";
			
	# 		print $f $indentation . $indentation . "switch oid {\n";
			my $n = 0;
			foreach my $field (sort keys %{$table->{fields}}) {
				if ($n == 0)
				{
					print $f $indentation . $indentation . "if ";
				}
				else
				{
					print $f $indentation . $indentation . "} else if ";
				}
				print $f "strings.HasPrefix (oid, \"".$field.".\") {\n";
				
				# needs to be a bit complex as we cannot assign to struct fields in a map
				# https://groups.google.com/forum/#!topic/golang-nuts/4_pabWnsMp0
				print $f $indentation . $indentation . $indentation . "rowId := oid[".(length($field) + 1).":]\n";
				print $f $indentation . $indentation . $indentation . "row := e." . $module->{tables}->{$k}->{name}."[rowId]\n";
				print $f $indentation . $indentation . $indentation . "if row == nil {\n";
				print $f $indentation . $indentation . $indentation . $indentation . "row = &".$table->{type}."{}\n";
				print $f $indentation . $indentation . $indentation . $indentation . "e." . $module->{tables}->{$k}->{name}."[rowId] = row\n";
				print $f $indentation . $indentation . $indentation . "}\n";
				
				# value
				####################################################
# 				if (!$table->{fields}->{$field}->{type})
# 				{
# 					print Dumper($table->{fields}->{$field});
# 				}
				####################################################
				print $f $indentation . $indentation . $indentation . "row." . $table->{fields}->{$field}->{name} . getValueAssignment ($table->{fields}->{$field}->{type}) . "\n";
				$n = $n + 1;
			};
			print $f $indentation . $indentation . "} else {\n";
			print $f $indentation . $indentation . $indentation . "log.Printf (\">> do not understand table field %v (%d) -> %v\", pdu.Name, pdu.Type, pdu.Value)\n";
			print $f $indentation . $indentation . "}\n";
			print $f $indentation . $indentation . "return nil\n";
			print $f $indentation . "}\n\n";
		}
	}
	print $f $indentation . "return nil\n";
	print $f "}\n\n\n";
	
	
	
	
	
	# generate the RetrieveEnterpriseModuleDetails function
	print $f "func (e *" . $module->{name} . ") RetrieveEnterpriseModuleDetails (snmp *gosnmp.GoSNMP, pduTrigger []helpers.PduTrigger) {\n\n";
	
	# set temporary PDU trigger
	print $f $indentation . "e.pduTrigger = pduTrigger\n\n";
	
	print $f $indentation . "log.Printf (\"+++ processing module ".$module->{name}." +++\")\n\n\n";
	
	if ($module->{fields} && scalar keys %{$module->{fields}}) {
		# bulk walk over all single fields
		print $f $indentation . "// get information about all fields\n";
		my $fieldOids = $indentation . "fields := []string {\n";
		foreach my $k (keys %{$module->{fields}}) {
			$fieldOids .= $indentation . $indentation . "\"$k\",\n" ;
		}
		print $f $fieldOids . $indentation . "}\n";
		print $f $indentation . "log.Printf (\"querry-ing fields %v\", fields)\n";
		print $f $indentation . "result, err := snmp.GetNext (fields)\n" . 
			$indentation . "if err != nil {\n" .
			$indentation . $indentation . "log.Printf (\">> Getting fields returned err: %v\", err)\n" .
			$indentation . "} else {\n" .
			$indentation . $indentation . "for _,pdu := range result.Variables {\n" .
			$indentation . $indentation . $indentation . "e.ParseSnmpFieldDetails (pdu)\n" .
			$indentation . $indentation . "}\n" . 
			$indentation . "}\n\n\n";
	}
	
	
	# for every table: walk over the table
	foreach my $k (sort keys %{$module->{tables}}) {
		print $f $indentation . "// get information table " . $module->{tables}->{$k}->{name} . "\n";
		print $f $indentation . "log.Printf (\"querry-ing table ".$k."\")\n";
		print $f $indentation . "err".$module->{tables}->{$k}->{name}." := snmp.Walk (\"" . $k . "\", e.ParseSnmpTableDetails)\n" . 
			$indentation . "if err".$module->{tables}->{$k}->{name}." != nil {\n" .
			$indentation . $indentation . "log.Printf (\">> Getting table for ".$module->{tables}->{$k}->{name}." returned err: %v\", err".$module->{tables}->{$k}->{name}.")\n" .
			$indentation . "}\n\n";
	}
	
	# unset current PDU trigger
	print $f $indentation . "e.pduTrigger = nil\n";
	
	
	print $f "\n}\n\n\n";
	
	
	
	# generate the String function
	print $f "func (e *" . $module->{name} . ") String () string {\n\n";
	print $f $indentation . "var buffer bytes.Buffer\n\n\n";
	print $f $indentation . "buffer.WriteString (fmt.Sprintf (\"- MODULE ".$module->{name}."\\n\"))\n\n\n";
	print $f $indentation . "// FIELDS\n";
	foreach my $k (keys %{$module->{fields}}) {
		print $f $indentation . "buffer.WriteString (fmt.Sprintf (\" -> FIELD[".$k."] = %v (".$module->{fields}->{$k}->{name}.")\\n\", e.".$module->{fields}->{$k}->{name}."))\n";
	}
	print $f "\n\n";
	
	print $f $indentation . "// TABLES\n";
	foreach my $k (sort keys %{$module->{tables}}) {
		print $f $indentation . "buffer.WriteString (fmt.Sprintf (\" -> TABLE[".$k."]: (".$module->{tables}->{$k}->{name}." of types ".$module->{tables}->{$k}->{type}.")\\n\"))\n";
		print $f $indentation . "buffer.WriteString (fmt.Sprintf (\"    ROWID\t";
		foreach my $field (sort keys %{$module->{tables}->{$k}->{fields}}) {
			print $f $module->{tables}->{$k}->{fields}->{$field}->{name} . "\t";
		}
		print $f "\\n\"))\n";
		
		
		print $f $indentation . "for k,v := range e." . $module->{tables}->{$k}->{name} ." {\n";
		
		print $f $indentation . $indentation . "buffer.WriteString (fmt.Sprintf (\"    %v\t\", k))\n";
		foreach my $field (sort keys %{$module->{tables}->{$k}->{fields}}) {
			print $f $indentation . $indentation . "buffer.WriteString (fmt.Sprintf (\"%v\t\", v.".$module->{tables}->{$k}->{fields}->{$field}->{name}."))\n";
		}
		print $f $indentation . $indentation . "buffer.WriteString (fmt.Sprintf (\"\\n\"))\n";
		print $f $indentation . "}\n";
		
		print $f "\n\n";
	}
	
	
	print $f $indentation . "return buffer.String()";
	
	
	print $f "\n}\n\n\n";
	
	close $f;
	close $ft;
}





# write files
foreach my $k (keys %$mibModules){
	writeClassStructure ($mibModules->{$k});
}


my $packageTypeName = ucfirst $packagename;

my $filename = $filebase."/".$packagename."Enterprise.go";
open (my $enterpriseFile, '>', $filename) || die ("cannot open file " . $filename);
print $enterpriseFile getFilePreamble ($packagename, ["github.com/soniah/gosnmp", "bytes", "discovery/helpers"]);


print $enterpriseFile "type " . $packageTypeName . " struct {\n\n";
print $enterpriseFile $packageFile{classStructure} . "\n";
print $enterpriseFile "\n}\n\n\n";

print $enterpriseFile "func (e *" . $packageTypeName . ") RetrieveEnterpriseDetails (snmp *gosnmp.GoSNMP, pduTrigger []helpers.PduTrigger) {\n";
print $enterpriseFile $packageFile{snmpParseFunc} . "\n";
print $enterpriseFile "\n}\n\n\n";

print $enterpriseFile "func (e *" . $packageTypeName . ") String () string {\n";
print $enterpriseFile $indentation . "var buffer bytes.Buffer\n\n\n";
print $enterpriseFile $packageFile{stringFunc} . "\n";
print $enterpriseFile $indentation . "return buffer.String()";
print $enterpriseFile "\n}\n\n\n";

print $enterpriseFile "func (e *" . $packageTypeName . ") IsValid () bool {\n";
print $enterpriseFile $indentation . "return true";
print $enterpriseFile "\n}\n\n\n";




close ($enterpriseFile);















