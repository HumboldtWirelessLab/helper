<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="channelstats">
	<xsl:value-of select="@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/txstats/@rts" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/txstats/@cts" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/txstats/@data" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/txstats/@broadcast" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/txstats/@unicast" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/txstats/@ack" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/rxstats/@rts" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/rxstats/@cts" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/rxstats/@data" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/rxstats/@broadcast" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/rxstats/@unicast" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/rxstats/@ack" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/packetloss/@nodecol" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/packetloss/@packetcol" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sim_stats/packetloss/@capture" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>