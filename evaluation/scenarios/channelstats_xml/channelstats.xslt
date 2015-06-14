<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="channelstats">
	<xsl:value-of select="@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@time" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@id" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac/@rx_pkt" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac/@no_err_pkt" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac/@rx_bytes" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac/@tx_unicast_pkt" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac/@tx_bcast_pkt" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac_percentage/@busy" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac_percentage/@rx" /><xsl:text>,</xsl:text>
	<xsl:value-of select="mac_percentage/@tx" /><xsl:text>,</xsl:text>
	<xsl:value-of select="phy/@hwbusy" /><xsl:text>,</xsl:text>
	<xsl:value-of select="phy/@hwrx" /><xsl:text>,</xsl:text>
	<xsl:value-of select="phy/@hwtx" /><xsl:text>,</xsl:text>
	<xsl:value-of select="phy/@channel" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>

<!--

<80211n_coverage>
<channelstats node="06-11-6B-61-CF-B5" time="0.000000" id="0" length="0" hw_duration="1000" unit="ms" >
        <mac packets="0" rx_pkt="0" no_err_pkt="0" crc_err_pkt="0" phy_err_pkt="0" unknown_err_pkt="0" tx_pkt="0" rx_unicast_pkt="0" rx_retry_pkt="0" rx_bcast_pkt="0" rx_bytes="0" tx_unicast_pkt="0" tx_retry_pkt="0"
         tx_bcast_pkt="0" tx_bytes="0" zero_err_pkt="0" last_packet_time="0.000000" no_src="0" />
        <mac_percentage busy="0" rx="0" tx="0" noerr_rx="0" crc_rx="0" phy_rx="0" unknown_err_rx="0" unit="percent" />
        <mac_duration busy="0" rx="0" tx="0" noerr_rx="0" crc_rx="0" phy_rx="0" unknown_err_rx="0" unit="us" />
        <mac_virtual nav="0" unit="us" />
        <phy hwbusy="0" hwrx="0" hwtx="0" last_hw_stat_time="0.000000" hw_stats_count="0" avg_noise="0" std_noise="0" avg_rssi="0" std_rssi="0" ctl_rssi0="0" ctl_rssi1="0" ctl_rssi2="0" ext_rssi0="0" ext_rssi1="0"
         ext_rssi2="0" channel="0" />
        <perf_counter cycles="0" busy_cycles="0" rx_cycles="0" tx_cycles="0" />
        <neighbourstats>
        </neighbourstats>
        <rssi_stats min_rssi="255" >
        </rssi_stats>
        <rssi_stats_global min_rssi="255" >
        </rssi_stats_global>
</channelstats>


-->