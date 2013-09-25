#!/usr/bin/env perl
# url_service_action v0.2
#
# License : GPLv2
# This script does an action on a Windows service if a pattern is found on a website
# Made by Pierre Mavro <pierre.mavro@enovance.com>/<pierre@mavro.fr>
#
#######################################################
#
# To compile it as a binary, use strawberry 1.16.3, then launch that command :
# pp -C -x url_service_action.pl -o url_service_action.exe --lib=C:\strawberry\perl\lib:C:\strawberry\perl\site\lib:C:\strawberry\perl\vendor\lib
#
# If you got errors :
# SYSTEM ERROR in executing url_service_action.pl: 256 at C:/strawberry/perl/site/lib/Module/ScanDeps.pm line 1302.
# then comment those lines in C:\strawberry\perl\site\lib\Module\ScanDeps.pm line 1302 :
#    #die $compile
#    #    ? "SYSTEM ERROR in compiling $file: $rc" 
#    #    : "SYSTEM ERROR in executing $file: $rc" 
#    #    unless $rc == 0

use strict;
use warnings;
use Getopt::Long;
use LWP::Simple;
# Avoid compilation errors
use Encode::Byte;

# Help print
sub help
{
    print "Usage : url_service_action -u <url> -p <pattern> -s <service> -a <action> -o <command> [-n] [-f] [-h]\n";
    print "\t-u : set the URL you want to check\n";
    print "\t-p : set the required search pattern\n";
    print "\t-n : reverse the query (if search is not found)\n";
    print "\t-s : give the Windows service name to do the action\n";
    print "\t-a : which action do you want to perform (start, restart or stop)\n";
    print "\t-e : launch one or multiple pre commands when action is finished\n";
    print "\t-o : launch one or multiple post commands when action is finished\n";
    print "\t-f : force post command execution even if service action failed\n";
    exit(1);
}

# Check args content
sub check_args {
    my $url = shift;
    my $action = shift;

    # Check URL 
    if ($url !~ /http/) {
        print "Please specify a correct URL (ex. http://www.site.com)\n";
        exit(1);
    }
    # Check action type
    if ($action !~ /\b(start|restart|stop)\b/i) {
        print "Please specify an action like : start, restart or stop\n";
        exit(1);
    }
}

# Do the job
sub proseed {
    my $url = shift;
    my $pattern = shift;
    my $service = shift;
    my $action = shift;
    my $not = shift;
    my $ref_pre = shift;
    my $ref_post = shift;
    my $force_post = shift;

    my @pre = @$ref_pre;
    my @post = @$ref_post;
    my $pattern_found = 0;
    my $result;

    # Get URL content
    my $content = get($url);

    # Check if pattern found
    $pattern_found = 1 if ($content =~ /$pattern/);

    # Does the action should be performed ?
    if ((($pattern_found == 1) and ($not == 0)) or (($pattern_found == 0) and ($not == 1))) {
        # Launch pre-script if requested
        if (@pre) {
            system($_) foreach (@pre);
        }

        # Uppercase action
        $action =~ s/($action)/\U$1/;

        # Launch actions
        print "Requested $action for $service\n";
        if ($action =~ /\b(START|STOP)\b/) {
            $result = system("NET $action \"$service\" >nul");
        } else {
            system("NET STOP \"$service\" >nul");
            $result = system("NET START \"$service\" >nul");
        }

        # Check result
        if ($result == 0) {
            print "$action $service [ OK ]\n";
        } else {
            print "$action $service [ FAILED ]\n";
            exit(1) if ($force_post == 0);
        }

        # Launch post-script if requested as a separated task
        if (@post) {
            system(1, $_) foreach (@post);
        }
        exit(0);
    } else {
        # If not, simply say the action didn't performed
        print "$service $action dropped because it doesn't match the needs\n";
        exit(0);
    }
}

# Check cli args
sub main
{
    # Vars
    my ($url,$pattern,$service,$action,@pre,@post);
    my $not = 0;
    my $force_post = 0;

    # Set options
    GetOptions(
        "help|h"    => \&help,
        "u=s"       => \$url,
        "p=s"       => \$pattern,
        "s=s"       => \$service,
        "n"         => \$not,
        "o=s"       => \@post,
        "e=s"       => \@pre,
        "f"         => \$force_post,
        "a=s"       => \$action);

    unless (($url) and ($pattern) and ($service) and ($action))
    {
        help;
    }
    else
    {
        check_args($url,$action);
        proseed($url,$pattern,$service,$action,$not,\@pre,\@post,$force_post);
    }
}

main();

