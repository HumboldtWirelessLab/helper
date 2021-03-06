<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="link_info">
	<xsl:value-of select="../../@from" /><xsl:text>,</xsl:text>
	<xsl:value-of select="../@to" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@size" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@rate" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@n" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@mcsindex" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@ht40" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@sgi" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@fwd" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>