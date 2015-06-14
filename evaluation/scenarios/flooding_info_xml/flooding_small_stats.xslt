<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="flooding_table/src/id">
	<xsl:value-of select="../@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../../@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../@node" /><xsl:text>,</xsl:text>
	<xsl:variable name="smac" select="../@node" />
	<!-- <xsl:value-of select="../../../flowstats[@node=$smac]/txflow/@packet_size" /><xsl:text>,0,0,0,0,0,</xsl:text>
	     <xsl:value-of select="../../../flowstats[@node=$smac]/txflow/@packet_count" /><xsl:text>,</xsl:text> -->
	<xsl:value-of select="$packetsize"/>
	<xsl:text>,0,0,0,0,0,</xsl:text>
	<xsl:value-of select="$packetcount"/>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="@value" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@fwd" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@sent" /><xsl:text>,</xsl:text>
	<xsl:text>0,0,0,0,0,</xsl:text>
	<xsl:value-of select="@fwd_done" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@fwd_succ" /><xsl:text>,0,</xsl:text>
	<xsl:value-of select="@time" /><xsl:value-of select="$newline" />
    </xsl:template>

</xsl:stylesheet>