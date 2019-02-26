#!/usr/bin/perl
use strict;
use warnings;

# AtCoder test case extractor
# Copy HTML source of task page into clipboard, then execute this script.
# inNN.txt and outNN.txt will be created.

sub getclip {
    eval "use Win32::Clipboard; 1";
    if ($@) {
        # Mac users should use pbpaste
        `pclip.exe` or die "Died: $!";
    } else {
        my $CLIP = Win32::Clipboard();
        $CLIP->Get();
    }
}

my @in = split /\n/, getclip;
my $state = 'INIT';
my $sample = '';
my $filename = '';
my $count = 0;
foreach my $line (@in) {
    chomp $line;
    if ($state eq 'INIT') {
        if ($line =~ m{Sample (In|Out)put\s*(\d)\s*</h3><pre>(.+)}) {
            my ($inout, $num, $sample1) = ($1, $2, $3);
            $state = 'GETTING';
            if ($inout eq 'In') {
                $filename = sprintf('in%02d.txt', $num);
            } else {
                $filename = sprintf('out%02d.txt', $num);
            }
            $sample = $sample1 . "\n";
        }
    } elsif ($state eq 'GETTING') {
        if ($line =~ m{(.*)</pre>}) {
            $sample = $sample . $1;
            open my $fh, '>', $filename or die "Died: $!";
            binmode($fh);
            print $fh $sample;
            close $fh;
            print "$filename\n";
            $state = 'INIT';
            $sample = '';
            $filename = '';
            $count++;
        } else {
            $sample = $sample . $line . "\n";
        }
    }
}
if (!$count) {
    print "No test case found.\n";
}
