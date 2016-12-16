spotprices
==========

CLI tool for CLI tool for querying amazon EC2 Spot prices.
Get Latest EC2 Spotprices from amazon

Installation:

::

   $ git clone git@github.com:huseyinyilmaz/spotprices.git
   $ cd spotprices
   $ stack build
   $ stack install


Usage:

Help output:
::

  $ spotprices --help
  CLI tool for querying amazon EC2 Spot prices.

  Usage: spotprices [-r|--region REGION] [-z|--zone ZONE]
                    [-t|--instancetype INSTANCETYPE]

  Available options:
    -h,--help                Show this help text
    -r,--region REGION       Region for spot price lookup.
    -z,--zone ZONE           Availability zone for spot price lookup.
    -t,--instancetype INSTANCETYPE
                             Instance type for spot price lookup.

Example Query:

::

   $ spotprices -z us-east-1e -z us-east-1d -z us-east-1c -t r3.xlarge -t r3.2xlarge
   Availability_Zone  Price     Instance_Type
   us-east-1e         0.045800  r3.xlarge
   us-east-1c         0.047600  r3.xlarge
   us-east-1d         0.065900  r3.xlarge
   us-east-1e         0.094300  r3.2xlarge
   us-east-1c         0.115800  r3.2xlarge
   us-east-1d         0.196600  r3.2xlarge
