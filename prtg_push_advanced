#!/bin/bash
#
# Use output from other Advanced Sensor scripts in PRTG's push sensors
#
# This script should be compatible with the HTTP Push Data Advanced
# and HTTP IoT Push Data Advanced sensors.
#
# Requires: bash >= 4.2, curl >= 7.18.0, sed
#

show_help(){
cat << END_HELP

Submit output of advanced sensor scripts via HTTP Push.

Usage:

  $0 -a <probe_address> -t <token> -d <data> [-j] [-g]
  <sensor_script> | $0 -a <probe_address> -t <token> [-j] [-g]

  -a <probe_address>
        Base address of the PRTG probe including protocol (http or https),
        hostname or IP address, and port (e.g.: "https://10.2.3.4:5051").

  -t <token>
        Token to match the target sensor in PRTG.

  -d <data> 
        Result or error data for PRTG in either xml or json format. (May
        also be read from piped input.)

  -j  
        Data is in json format. (If not specified, xml is assumed.)

  -g
        Pass data to PRTG via a GET request. (If not specified, use POST.)

END_HELP
exit 1
}


suggest_help(){
    echo "For help, run: $0 -?" 1>&2
    exit 1
}


url_encode(){
    # Pipe stuff to this function to url-encode it.
    # Use curl to url-encode the piped string and then remove 
    # the "/?" that curl adds at the beginning.
    curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | sed -e 's:^/?::';
}


# Defaults
request="POST"
data_format="xml"
curl_opts="--insecure"  # accept untrusted certificates


while getopts ":a:t:d:jg" opt; do
  case ${opt} in
    a)  probe_address="${OPTARG}" ;;
    t)  token="${OPTARG}" ;;
    d)  data="${OPTARG}" ;;
    j)  data_format="json" ;;
    g)  request="GET" ;;
    \?) show_help ;;
  esac
done
shift $((OPTIND -1))

if [[ ! -v probe_address ]] || [[ ! -v token ]]; then
    echo "ERROR: Probe address or token not set." 1>&2 
    show_help
fi

# Use piped input preferentially
if [[ -p /dev/stdin ]]; then
    data="$(cat)"
fi

if [[ "${request}" == "GET" ]]; then

    content=$(echo -n "${data}" | url_encode)
    url="${probe_address}/${token}?content=${content}"
    curl ${curl_opts} "${url}"

else  # request == POST

    content_type_header="Content-Type: application/${data_format}"
    url="${probe_address}/${token}"
    curl ${curl_opts} --request POST --data "${data}" --header "${content_type_header}" "${url}"

fi
