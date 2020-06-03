#!/bin/bash

/usr/bin/snapserver --config=/config/snapserver.conf \
&& /usr/bin/mopidy --config=/config/garage.conf \
&& /usr/bin/mopidy --config=/config/outside.conf \
&& /usr/bin/mopidy --config=/config/external.conf
# && /usr/bin/mopidy --config=/config/garage.conf local scan \
# && /usr/bin/mopidy --config=/config/outside.conf local scan \
# && /usr/bin/mopidy --config=/config/external.conf local scan
