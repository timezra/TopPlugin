TopPlugin [![Build Status](https://travis-ci.org/timezra/TopPlugin.png)](https://travis-ci.org/timezra/TopPlugin)
==================

A collectd plugin for recording metrics from the top utility.

Configuration
----------------------------------------------------
In order to use this script, you will need bash > 4.

Usage
----------------------------------------------------

This bash script can be used standalone or via the collectd Exec plugin. The output conforms to the collectd [Plain Text Protocol](https://collectd.org/wiki/index.php/Plain_text_protocol) and the emitted metrics are defined in src/main/resources/types.db.custom.
The input to the script is a space-separated list of key-value pairs that can be turned into a bash associative array where the key is the process name for display and the value is a pattern for extracting a unique PID.

### Examples: ###

#### Terminal ####
```bash
./src/main/sh/TopPlugin.sh "['mintUpdate']='python2\.7.*mintUpdate' ['docker']='docker'"
```

#### Plaintext Output ####
```bash
PUTVAL "$USER-$HOST/top-per-process-values/top_type-mintUpdate" interval=10 1438664392:20:0:772668:39348:21588:0.0:1.0
PUTVAL "$USER-$HOST/top-per-process-values/top_type-docker" interval=10 1438664392:20:0:192028:10380:5964:0.0:0.3
```

#### collectd.conf ####
```xml
....
TypesDB "/PATH/TO/types.db.custom"
....
LoadPlugin exec
....
<Plugin exec>
  Exec "$USER:$GROUP" "/PATH/TO/TopPlugin.sh" "['DISPLAY_NAME_1']='PROCESS_PATTERN_1' ['DISPLAY_NAME_2']='PROCESS_PATTERN_2'"
</Plugin>
```
