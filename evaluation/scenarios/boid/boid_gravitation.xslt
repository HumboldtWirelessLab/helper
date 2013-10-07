<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="gravitation">
	<xsl:value-of select="../@time" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@x" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@y" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@z" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@mass" /><xsl:value-of select="$newline" />
    </xsl:template>

</xsl:stylesheet>