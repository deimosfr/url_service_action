url_service_action
==================

This script does an action on a Windows service if a pattern is found on a website.

You can find here a compiled binary (exe) or the Perl source code.

# Usage

> Usage : url_service_action -u <url> -p <pattern> -s <service> -a <action> [-h]<br />
>         -u : set the URL you want to check<br />
>         -p : set the required search pattern<br />
>         -s : give the Windows service name to do the action<br />
>         -a : which action do you want to perform (start, restart or stop)<br />

# Compil the binary on Windows

To compile it as a binary, use strawberry 1.16.3, then launch that command :
> pp -C -x url_service_action.pl -o url_service_action.exe --lib=C:\strawberry\perl\lib:C:\strawberry\perl\site\lib:C:\strawberry\perl\vendor\lib<br />

If you got errors :
> SYSTEM ERROR in executing url_service_action.pl: 256 at C:/strawberry/perl/site/lib/Module/ScanDeps.pm line 1302.<br />

then comment those lines in C:\strawberry\perl\site\lib\Module\ScanDeps.pm line 1302 :
>    #die $compile<br />
>    #    ? "SYSTEM ERROR in compiling $file: $rc" <br />
>    #    : "SYSTEM ERROR in executing $file: $rc" <br />
>    #    unless $rc == 0<br />

