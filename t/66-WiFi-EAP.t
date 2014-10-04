#!perl -T

# Test suite 66-WiFi-EAP: Tests against the EAPClientConfiguration class, used
# in the WiFi payload type as the "EAPClientConfiguration" payload key.
# 
# Copyright © 2014 A. Karl Kornel.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
# 
# See http://dev.perl.org/licenses/ for more information.

use 5.10.1;
use strict;
use warnings FATAL => 'all';


use Config::Apple::Profile::Payload::WiFi::EAPClientConfiguration;
use Config::Apple::Profile::Payload::Types qw(:all);
use Readonly;
use Test::Exception;
use Test::More;


# This is the list of keys we expect to have in this payload
my @keys_expected = (
    [UserName => $ProfileString],
    [AcceptEAPTypes => $ProfileArray],
    [UserPassword => $ProfileString],
    [OneTimePassword => $ProfileBool],
    [PayloadCertificateAnchorUUID => $ProfileArray],
    [TLSTrustedServerNames => $ProfileArray],
    [TLSAllowTrustExceptions => $ProfileBool],
    [TLSCertificateIsRequired => $ProfileBool],
    [TTLSInnerAuthentication => $ProfileString],
    [OuterIdentity => $ProfileString],
    [EAPFASTUsePAC => $ProfileBool],
    [EAPFASTProvisionPAC => $ProfileBool],
    [EAPFASTProvisionPACAnonymously => $ProfileBool],
    [EAPSIMNumberOfRANDs => $ProfileNumber],
);


# First, make sure payload->keys returns all expected Font payload keys.
# Finally, check that AcceptEAPTypes, TTLSInnerAuthentication, and
# EAPSIMNumberOfRANDs only accept correct values.

plan tests =>    2*scalar(@keys_expected) # Key presence/type checks
               + 7 + 12                   # AcceptEAPTypes checks
               + 5 + 2                    # TLSTrustedServerNames checks
               + 4 + 4                    # TTLSInnerAuthentication checks
               + 2 + 2                    # EAPSIMNumberOfRANDs checks
;


# Create our object
my $object = new Config::Apple::Profile::Payload::WiFi::EAPClientConfiguration;
my $keys = $object->keys;
my $payload = $object->payload;


# Check for our payload keys
foreach my $key (@keys_expected) {
    my ($expected_name, $expected_type) = @$key;
    
    # Make sure the key exists
    ok(exists $keys->{$expected_name}, "Check key $expected_name exists");
    cmp_ok($keys->{$expected_name}->{type}, '==',
           $expected_type, "Check key type matches"
    );
}


# Test validation of the AcceptEAPTypes key
SKIP: {
lives_ok { push @{$payload->{AcceptEAPTypes}}, 13; }
         'Push type EAP-TLS';
lives_ok { push @{$payload->{AcceptEAPTypes}}, 17; }
         'Push type LEAP';
lives_ok { push @{$payload->{AcceptEAPTypes}}, 18; }
         'Push type EAP-SIM';
lives_ok { push @{$payload->{AcceptEAPTypes}}, 21; }
         'Push type EAP-TTLS';
lives_ok { push @{$payload->{AcceptEAPTypes}}, 23; }
         'Push type EAP-AKA';
lives_ok { push @{$payload->{AcceptEAPTypes}}, 25; }
         'Push type PEAP';
lives_ok { push @{$payload->{AcceptEAPTypes}}, 43; }
         'Push type EAP-FAST';
skip 'AcceptEAPTypes validation not implemented' => 12;
dies_ok { push @{$payload->{AcceptEAPTypes}}, 12; }
        'Push invalid type 12';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 14; }
        'Push invalid type 14';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 15; }
        'Push invalid type 15';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 16; }
        'Push invalid type 16';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 19; }
        'Push invalid type 19';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 20; }
        'Push invalid type 20';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 21; }
        'Push invalid type 21';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 22; }
        'Push invalid type 22';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 24; }
        'Push invalid type 24';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 26; }
        'Push invalid type 26';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 42; }
        'Push invalid type 42';
dies_ok { push @{$payload->{AcceptEAPTypes}}, 44; }
        'Push invalid type 44';
};


# Test validation of the TLSTrustedServerNames key
SKIP: {
lives_ok { push @{$payload->{TLSTrustedServerNames}}, 'karl.kornel.us'; } 
         'Push valid name karl.kornel.us';
lives_ok { push @{$payload->{TLSTrustedServerNames}}, '*.kornel.us'; } 
         'Push valid name *.kornel.us';
lives_ok { push @{$payload->{TLSTrustedServerNames}}, 'server*.wpa.example.com'; } 
         'Push valid name server*.wpa.example.com';
lives_ok { push @{$payload->{TLSTrustedServerNames}}, 'wpa-auth.example.com'; } 
         'Push valid name wpa-auth.example.com';
lives_ok { push @{$payload->{TLSTrustedServerNames}}, 'wpa-auth'; } 
         'Push valid name wpa-auth';
skip 'TLSTrustedServerNames validation not implemented' => 2;
dies_ok { push @{$payload->{TLSTrustedServerNames}}, ''; } 
        'Push invalid empty string';
dies_ok { push @{$payload->{TLSTrustedServerNames}}, "1\n2"; } 
        'Push invalid multi-line string';
};


# Test validation of the TTLSInnerAuthentication key
lives_ok { $payload->{TTLSInnerAuthentication} = 'PAP'; }
         'Set InnerAuth to PAP';
lives_ok { $payload->{TTLSInnerAuthentication} = 'CHAP'; }
         'Set InnerAuth to CHAP';
lives_ok { $payload->{TTLSInnerAuthentication} = 'MSCHAP'; }
         'Set InnerAuth to MSCHAP';
lives_ok { $payload->{TTLSInnerAuthentication} = 'MSCHAPv2'; }
         'Set InnerAuth to MSCHAPv2';
dies_ok { $payload->{TTLSInnerAuthentication} = 'Karl'; }
        'Set InnerAuth to Karl';
dies_ok { $payload->{TTLSInnerAuthentication} = ''; }
        'Set InnerAuth to empty string';
dies_ok { $payload->{TTLSInnerAuthentication} = 'MSCHAPV2'; }
        'Set InnerAuth to MSCHAPV2';
dies_ok { $payload->{TTLSInnerAuthentication} = 'ButtonMash'; }
        'Set InnerAuth to ButtonMash';


# Test validation of the EAPSIMNumberOfRANDs key
dies_ok { $payload->{EAPSIMNumberOfRANDs} = 1; } 'Set RANDs to 1';
lives_ok { $payload->{EAPSIMNumberOfRANDs} = 2; } 'Set RANDs to 2';
lives_ok { $payload->{EAPSIMNumberOfRANDs} = 3; } 'Set RANDs to 3';
dies_ok { $payload->{EAPSIMNumberOfRANDs} = 4; } 'Set RANDs to 4';


# Done!
done_testing();