<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="rxflow">
	<xsl:value-of select="../@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@src" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@dst" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@avg_hops" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@packet_count" /><xsl:text>,</xsl:text>
	<xsl:variable name="smac" select="@src" />
	<xsl:value-of select="../../flowstats[@node=$smac]/txflow/@packet_count" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@packet_size" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@min_hops" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@max_hops" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@time" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@min_time" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@max_time" /><xsl:text>,</xsl:text><xsl:value-of select="$newline" />
    </xsl:template>

</xsl:stylesheet>