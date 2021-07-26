<#
  .SYNOPSIS
  Send sensor data to PRTG via HTTP Push.


  .DESCRIPTION
  Send sensor data to PRTG via HTTP Push. Use either directly specified
  values or output from existing sensor scripts.

  This script should be compatible with the HTTP Push Data and HTTP Push
  Count sensors.


  .INPUTS
  Data. A String of the form "<numeric_value>:<message>" -- the output
  format for PRTG custom EXE/Script sensors.


  .PARAMETER ProbeAddress
  Base address of the PRTG probe including protocol (http or https),
  hostname or IP address, and port (e.g.: "https://10.2.3.4:5051").


  .PARAMETER Token
  Token to match the target sensor in PRTG.


  .PARAMETER Data
  PRTG sensor script output interpreted in value:message format. This
  option is only in effect when the -val option is not used. (May also
  be read from piped input.)


  .PARAMETER NoData
  Don't submit any value or data; only call the sensor webhook. Only
  useful for the HTTP Push Count sensor. If this option is supplied,
  the -val and -data options and piped data are ignored.


  .PARAMETER Val
  Value to assign to the target sensor in PRTG. If this option is
  supplied, the -data option and piped data are ignored.


  .PARAMETER Msg 
  Optional message text to appear on target sensor in PRTG. Only 
  applied when the -val option is used.


  .PARAMETER Post
  Push data via POST request. (If not specified, a GET request is used.)
  This option is ignored when the -nodata option is used.


  .EXAMPLE
  prtg_push.ps1 -ProbeAddress <probe_address> -Token <token> -val <numeric_value> [-msg <message>] [-Post]

  Report values directly.


  .EXAMPLE
  prtg_push.ps1 -ProbeAddress <probe_address> -Token <token> -Data <data> [-Dost]

  Push values from sensor script output.


  .EXAMPLE
  <sensor_script> | prtg_push.ps1 -ProbeAddress <probe_address> -Token <token> [-Post]

  Push values from piped sensor script output.


  .EXAMPLE
  prtg_push.ps1 -ProbeAddress <probe_address> -Token <token> -NoData

  Report to a Push Count sensor.

#>


[CmdletBinding(DefaultParameterSetName="ParseData",
               PositionalBinding=$false)]


Param(
    [Parameter(Mandatory=$true)]
    [String]$probeAddress,

    [Parameter(Mandatory=$true)]
    [String]$token,

    [Parameter(Mandatory=$true,ParameterSetName="ParseData",ValueFromPipeline=$true)]
    [String]$data,

    [Parameter(Mandatory=$true,ParameterSetName="NoData")]
    [Switch]$nodata,

    [Parameter(Mandatory=$true,ParameterSetName="DirectValue")]
    [String]$val,

    [Parameter(Mandatory=$false,ParameterSetName="DirectValue")]
    [String]$msg,

    [Parameter(Mandatory=$false,ParameterSetName="DirectValue")]
    [Parameter(Mandatory=$false,ParameterSetName="ParseData")]
    [Switch]$post
)


# Load System.Web for URL encoding
Add-Type -AssemblyName System.Web

# Set security protocols to try; older versions of powershell may default 
# to a protocol that's too low, causing https requests to fail
[Net.ServicePointManager]::SecurityProtocol = "tls13, tls12, tls11"

$webhook = "{0}/{1}" -f "$probeAddress", "$token"

if ($nodata -eq $true) {  # submitting to a push count sensor

    # Just call the webhook and don't submit any data
    Invoke-WebRequest -Uri "$webhook"

}
else {  # submitting to a push data sensor

    if (-not $val) {
        if ($data) {
            # Split $data into its components
            $val, $msg = $data.tostring() -split ':', 2
        }
        else {
            Write-Error "ERROR: Did not receive numeric value or script output."
            exit 1
        }
    }

    $umsg = [System.Web.HTTPUtility]::UrlEncode($msg)
    $submitData = "value={0}&text={1}" -f "$val", "$umsg"

    if ($post -eq $true) {

        Invoke-WebRequest -Uri "$webhook" -Method "POST" -data "$submitData" 

    }
    else {  # GET

        $uri = "{0}?{1}" -f "$webhook", "$submitData"
        Invoke-WebRequest -Uri "$uri"

    }
}
