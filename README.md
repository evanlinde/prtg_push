# Helper scripts for PRTG HTTP Push sensors

Turn custom sensor scripts into HTTP Push sensors.

The scripts themselves are not sensors; they are interfaces for using existing (non-push) sensor scripts as push sensors and creating new push sensors. 

Sensor Type                  | Compatible Script
-----------------------------|--------------------
HTTP Push Count              | `prtg_push` (with the `-n` option)
HTTP Push Data               | `prtg_push`
HTTP Push Data Advanced      | `prtg_push_advanced`
HTTP IoT Push Data Advanced  | `prtg_push_advanced`

These scripts are intended for Linux systems, however they should also work on Unix, macOS, and even Windows (e.g. with Cygwin) as long as the listed dependencies are installed.


## Requirements

- bash >= 4.2
- curl >= 7.18.0
- sed


## How to use

First create a push sensor on your target device in PRTG and copy the sensor's token (or set your own custom token explicitly).

The easiest way to run the push scripts is in a pipeline beginning with an existing sensor script. The push scripts require, at minimum, parameters for the probe address (protocol, IP or hostname, and port) and sensor token. Additional command line options can be used to specify the data format (i.e. `returncode:value:message` vs. `value:message` for standard scripts or XML vs. JSON for advanced scripts) and request method (i.e. `GET` or `POST`).

Full details on the command line options are available in each script's help. (Run the script with the `-?` option to view help, or read the script file.)

Schedule your push scripts to run regularly; cron and systemd timers are good options for this. If you have multiple push sensors on a system, you may want to create a single script to run all of them.

Here is an example of a short script to run multiple push sensors:
```bash
#!/bin/bash
probe="https://10.2.3.4:5051"
sensor1_script | prtg_push -a "${probe}" -t "sensor1_token"
sensor2_script | prtg_push -a "${probe}" -t "sensor2_token"
adv_script | prtg_push_advanced -a "${probe}" -t "sensor3_token"
```


## Security Note

These scripts use curl's `--insecure` option in order to work with your PRTG system's (likely) untrusted certificate. If you're using https and care about identity verification and not just having encryption, you'll want to make sure your system's cert is trusted and then remove this option.

