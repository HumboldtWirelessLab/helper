<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="txflow">
	<xsl:value-of select="../@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@src" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@dst" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@avg_hops" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@packet_count" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@packet_size" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>