<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="/">
	<xsl:value-of select="count(//flooding)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@received_new)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="(sum(//flooding/localstats/@received_new) div (count(//flooding)))" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@source)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@received)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@sent)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@forward)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@passive)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@forward_new)" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>