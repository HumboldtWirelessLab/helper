<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="lastnode">
	<xsl:value-of select="@addr" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../../../@node" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../../@node" /><xsl:text>,</xsl:text>
	<xsl:variable name="smac" select="../../@node" />
	<xsl:value-of select="$packetsize"/>
	<xsl:text>,0,0,0,0,0,</xsl:text>
	<xsl:value-of select="$packetcount"/>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="../@value" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../@fwd" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../@sent" /><xsl:value-of select="$newline" />
    </xsl:template>

</xsl:stylesheet>