Overview
--------

A puppet device plugin that makes it easier to get facts from
places ruby does not run or without writing weird puppet code.

An example could be to fetch facts from SCVMM using remote calls
to powershell functions written using a non ruby programming
language.  This script would be called by this device and as long
as the script output a JSON document that will be used as the
facts for the device

Configuration
-------------

Configuration is using the normal device config files and it
enforce some standards for arguments you have to accept:

    [script_device]
      type script
      url script://scvmm:xxx@172.28.4.173:443/scvmm/bin/scvmm_discovery.rb?timeout=100

This sets up the ```script_device``` to search the modulepath
for ```scvmm/bin/scvmm_discovery.rb``` which should be executable.

Script Arguments
----------------

The above configuration will invoke the script using the following arguments:

```
scvmm_discovery.rb --username=scvmm --password=xxx --server=192.16.1.1 --port=443 --timeout=100
```

The username, password, server and port parts of the url are optional.

You cannot change the arguments that will be passed for these standard
arguments like user, password etc but from the example above you can
see you can pass any arbitrary arguments to the script using query
parameters, they will always be invoked with ```--argument```

the password will be decrypted using the standard ASM encryption methods

Structured Data
---------------

PuppetDB now supports structured facts but we are not yet running that
version of PuppetDB or Puppet.  At the moment when this device type
detects that it got non Fixnum or String facts it will JSON encode the
data and store it as a string in a fact called ```json_facts```, without
this the data gets corrupted.

