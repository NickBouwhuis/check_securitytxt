# check_securitytxt

A bash script that can be used with Nagios/Icinga2 to monitor the expiration date of a security.txt file located at a specified URL.

## Usage
```bash
./check_securitytxt.sh -u <url> -w <warning_days> -c <critical_days>
```

  * -u or --url: URL of the security.txt file to be monitored (not including the path to the file. the file is expected to be at <url>/.well-known/security.txt according to [RFC 9116](https://www.rfc-editor.org/rfc/rfc9116)).
  * -w or --warning: Number of days after which a WARNING message will be displayed.
  * -c or --critical: Number of days after which a CRITICAL message will be displayed.

## Example
```bash
./check_securitytxt.sh -u https://example.com -w 7 -c 3
```

## Output
The script outputs one of the following messages based on the expiration date of the security.txt file:

    * OK: The security.txt expires more than warning_days away.
    * WARNING: The security.txt expires within warning_days.
    * CRITICAL: The security.txt expires within critical_days.

The script also produces exit codes that correspond with the Nagios/Icinga2 states.

## Example configuration in Icinga2
```
object CheckCommand "check_securitytxt" {
  command = [ PluginDir + "/check_securitytxt.sh" ]

  arguments = {
    "-u" = "$security_txt_url$"
    "-w" = "$security_txt_warning_days$"
    "-c" = "$security_txt_critical_days$"
  }
}

apply Service "security.txt" {
  check_command = "check_securitytxt"

  vars.security_txt_url = "https://example.com"
  vars.security_txt_warning_days = 14
  vars.security_txt_critical_days = 7

  assign where host.name = "example.com"
}
```
