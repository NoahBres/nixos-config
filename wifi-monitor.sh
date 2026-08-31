#!/bin/bash
# Continuous Wi-Fi / connectivity monitor.
# Run in background: ./wifi-monitor.sh &  (or nohup ./wifi-monitor.sh > /dev/null 2>&1 &)
# Logs to ~/wifi-monitor.log every 2s. When you notice an outage, note the time
# and grep the log around it, e.g.: grep -A5 -B30 "$(date '+%Y-%m-%d %H:1')" ~/wifi-monitor.log

LOG="$HOME/wifi-monitor.log"
GATEWAY=$(netstat -rn -f inet | awk '/^default/{print $2; exit}')
IFACE="en0"

echo "=== monitor started $(date) — gateway=$GATEWAY iface=$IFACE ===" >> "$LOG"

while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')

  # 1. Wi-Fi radio state (signal, rate, channel)
  WIFI=$(system_profiler SPAirPortDataType 2>/dev/null | awk '
    /Signal \/ Noise/{sn=$0}
    /Transmit Rate/{tr=$0}
    /Channel:/{ch=$0}
    END{gsub(/^[ \t]+/,"",sn); gsub(/^[ \t]+/,"",tr); gsub(/^[ \t]+/,"",ch); print ch" | "sn" | "tr}')

  # 2. Default route interface right now (catches VPN flapping / route changes)
  ROUTE_IFACE=$(netstat -rn -f inet | awk '/^default/{print $NF; exit}')

  # 3. TCP-level reachability (ICMP is blocked on this network, so use TCP connect timing)
  GW_RTT=$(curl -o /dev/null -s -w "%{time_connect}" --connect-timeout 2 "http://$GATEWAY" 2>/dev/null)
  [ -z "$GW_RTT" ] && GW_RTT="FAIL"

  INET_RTT=$(curl -o /dev/null -s -w "%{time_connect}" --connect-timeout 2 "https://1.1.1.1" 2>/dev/null)
  [ -z "$INET_RTT" ] && INET_RTT="FAIL"

  DNS_TIME=$(curl -o /dev/null -s -w "%{time_namelookup}" --connect-timeout 2 "https://claude.ai" 2>/dev/null)
  [ -z "$DNS_TIME" ] && DNS_TIME="FAIL"

  # 4. TCP retransmit/error counters (cumulative — diff between lines to see spikes)
  TCP_STATS=$(netstat -s -p tcp | awk '
    /retransmitted/{r=$1}
    /retransmit timeout/{rto=$1}
    /out-of-order/{ooo=$1}
    END{print "retrans="r" rto="rto" ooo="ooo}')

  echo "$TS | route_iface=$ROUTE_IFACE | wifi=[$WIFI] | gw_connect=${GW_RTT}s | inet_connect=${INET_RTT}s | dns=${DNS_TIME}s | $TCP_STATS" >> "$LOG"

  sleep 2
done
