<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="/">
	<xsl:value-of select="count(//flooding)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/forward/@count)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="(sum(//flooding/forward/@count) div (count(//flooding)))" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/source/@count)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/received/@count)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/sent/@count)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/forward/@count)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/passive/@count)" /><xsl:value-of select="$newline" />
	
    </xsl:template>
</xsl:stylesheet>