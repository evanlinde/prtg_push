<#
  .SYNOPSIS
  Send output of advanced PRTG sensor scripts via HTTP Push.


  .DESCRIPTION
  Use output from other Advanced Sensor scripts in PRTG's push sensors.

  This script should be compatible with the HTTP Push Data Advanced and 
  HTTP IoT Push Data Advanced sensors.


  .INPUTS
  Data. Result or error data for PRTG in either xml or json format.


  .PARAMETER ProbeAddress
  Base address of the PRTG probe including protocol (http or https),
  hostname or IP address, and port (e.g.: "https://10.2.3.4:5051").


  .PARAMETER Token
  Token to match the target sensor in PRTG.


  .PARAMETER Data
  Result or error data for PRTG in either xml or json format. (May
  also be read from piped input.)


  .PARAMETER Json
  Data is in json format. (If not specified, xml is assumed.)


  .PARAMETER Get
  Push data via a GET request. (If not specified, a POST request is used.)

#>


[CmdletBinding(PositionalBinding=$false)]


Param(
    [Parameter(Mandatory=$true)][String]$probeAddress,
    [Parameter(Mandatory=$true)][String]$token,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$data,
    [Parameter(Mandatory=$false)][Switch]$json,
    [Parameter(Mandatory=$false)][Switch]$get
)


# Load System.Web for URL encoding
Add-Type -AssemblyName System.Web

# Set security protocols to try; older versions of powershell may default 
# to a protocol that's too low, causing https requests to fail
[Net.ServicePointManager]::SecurityProtocol = "tls13, tls12, tls11"

$webhook = "{0}/{1}" -f "$probeAddress", "$token"

$contentType = if ($json) {"application/json"} else {"application/xml"}

if ($get) {

    $content = [System.Web.HTTPUtility]::UrlEncode($data.toString())
    $uri = "{0}?content={1}" -f "$webhook", "$content"
    Invoke-WebRequest -Uri "$uri"

}
else {

    Invoke-WebRequest -Uri "$webhook" -ContentType "$contentType" -Method "POST" -Body "$data"

}
